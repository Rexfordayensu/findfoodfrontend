import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../services/api_service.dart';
import '../../services/providers.dart';
import 'google_oauth_flow.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.returnRoute = '/home',
    this.pendingAction,
    this.pendingParameters,
  });

  final String returnRoute;
  final String? pendingAction;
  final Map<String, dynamic>? pendingParameters;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginKey = GlobalKey<FormState>();
  final _signupKey = GlobalKey<FormState>();

  final _loginEmail = TextEditingController();
  final _loginPassword = TextEditingController();
  final _signupName = TextEditingController();
  final _signupEmail = TextEditingController();
  final _signupPass = TextEditingController();
  final _resetEmail = TextEditingController();
  final _cuisineController = TextEditingController();
  final _addressController = TextEditingController();

  bool _obscureLogin = true;
  bool _obscureSignup = true;
  bool _isLoading = false;
  bool _googleLoading = false;
  bool _isRequestingOtp = false;
  bool _useOtpLogin = false;
  int _tabIndex = 0;
  String _signupRole = 'customer';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() => _tabIndex = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmail.dispose();
    _loginPassword.dispose();
    _signupName.dispose();
    _signupEmail.dispose();
    _signupPass.dispose();
    _resetEmail.dispose();
    _cuisineController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // ── LOGIN ─────────────────────────────────────────────────────────────────
  Future<void> _login() async {
    if (!_loginKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.login(
        _loginEmail.text.trim(),
        _loginPassword.text,
      );
      if (!mounted) return;

      if (otpRequiredFromResponse(data)) {
        context.go(_emailVerificationUri(_loginEmail.text.trim()));
        return;
      }

      final token = data['access_token']?.toString();
      final userId = int.tryParse(data['user_id']?.toString() ?? '');
      final role = data['role']?.toString().toLowerCase();
      if (token == null ||
          token.isEmpty ||
          userId == null ||
          role == null ||
          role.isEmpty) {
        throw Exception('Invalid login response from server');
      }

      await Provider.of<AuthProvider>(context, listen: false).login(
        token: token,
        userId: userId,
        role: role,
        name: data['name']?.toString(),
        email: data['email']?.toString() ?? _loginEmail.text.trim(),
        isEmailVerified: data['is_verified'] == true ||
            data['email_verified'] == true ||
            data['is_email_verified'] == true,
        isRestaurantApproved: data['is_approved'] == true,
      );

      if (!mounted) return;
      context.go(_routeAfterLogin(role));
    } on EmailNotVerifiedException {
      if (!mounted) return;
      context.go(_emailVerificationUri(_loginEmail.text.trim()));
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _requestOtp() async {
    final email = _loginEmail.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showError('Enter a valid email');
      return;
    }

    setState(() => _isRequestingOtp = true);
    try {
      await ApiService.requestLoginOtp(email: email);
      if (!mounted) return;

      context.go(_emailVerificationUri(email));
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isRequestingOtp = false);
    }
  }

  // ── REGISTER ──────────────────────────────────────────────────────────────
  Future<void> _register(TextEditingController cuisineController,
      TextEditingController addressController) async {
    // 1. Basic form validation (Email, Password, Name)
    if (!_signupKey.currentState!.validate()) return;

    // 2. Strict validation: Ensure restaurant users supplied their details
    if (_signupRole == 'restaurant') {
      if (cuisineController.text.trim().isEmpty ||
          addressController.text.trim().isEmpty) {
        _showError(
            'Cuisine Type and Store Address are required for restaurants!');
        return; // Halt registration here
      }
    }

    setState(() => _isLoading = true);

    final registrationEmail = _signupEmail.text.trim();
    final registrationRole = _signupRole;

    try {
      // 3. Make the API call with all required fields
      final data = await ApiService.register(
        name: _signupName.text.trim(),
        email: registrationEmail,
        password: _signupPass.text.trim(),
        role: registrationRole,
        cuisineType: registrationRole == 'restaurant'
            ? cuisineController.text.trim()
            : '',
        address: registrationRole == 'restaurant'
            ? addressController.text.trim()
            : '',
      );
      if (!mounted) return;

      final otpRequired = otpRequiredFromResponse(data);
      final registrationPassword = _signupPass.text;
      _showSuccess(otpRequired
          ? 'Account created! Please verify your email.'
          : 'Account created successfully.');

      // Clear form
      _signupName.clear();
      _signupEmail.clear();
      _signupPass.clear();
      cuisineController.clear();
      addressController.clear();

      if (!mounted) return;
      if (otpRequired) {
        context.go(
          '/email-verification?email=${Uri.encodeComponent(registrationEmail)}&role=${Uri.encodeComponent(registrationRole)}&mode=${Uri.encodeComponent('registration')}',
          extra: {'password': registrationPassword},
        );
      } else {
        setState(() {
          _tabIndex = 0;
          _tabController.animateTo(0);
        });
      }
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _routeForRole(String role) {
    switch (role) {
      case 'admin':
        return '/admin';
      case 'restaurant':
        return '/restaurant/orders';
      case 'rider':
        return '/rider';
      default:
        return '/';
    }
  }

  String _routeAfterLogin(String role) {
    final requested = widget.returnRoute;
    if (role == 'customer' && requested.isNotEmpty && requested != '/home') {
      return requested;
    }
    return _routeForRole(role);
  }

  String _emailVerificationUri(String email) {
    return Uri(
      path: '/email-verification',
      queryParameters: {
        'email': email,
        'role': '',
        'mode': 'login',
      },
    ).toString();
  }

  // ── FORGOT PASSWORD ───────────────────────────────────────────────────────
  void _showForgotPassword() {
    context.push('/forgot-password');
  }

  // ── GOOGLE SIGN IN ───────────────────────────────────────────────────────
  /// Hands over to Google (the browser leaves the app on the web and comes
  /// back to /auth/callback when Google is done).
  Future<void> _googleSignIn() async {
    if (_googleLoading) return;
    setState(() => _googleLoading = true);
    try {
      await GoogleOAuthFlowService.startGoogleAuth(
        context: context,
        route: widget.returnRoute,
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Could not open Google sign-in. Please try again.');
    } finally {
      // On the web the page is already navigating to Google; elsewhere the
      // browser has opened, so the button can be used again.
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: AppTheme.danger,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Text(msg, style: const TextStyle(color: Colors.white)),
    ));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: AppTheme.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Text(msg, style: const TextStyle(color: Colors.white)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.bg(context);
    final surf = AppColors.surface(context);
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);
    final textHint = AppColors.textHint(context);
    final border = AppColors.border(context);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                children: [
                  // ── Logo ──────────────────────────────────
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.fastfood_rounded,
                        color: Colors.black, size: 34),
                  ),
                  const SizedBox(height: 14),
                  Text('FindFood',
                      style: TextStyle(
                          color: textPri,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.0)),
                  const SizedBox(height: 4),
                  Text('Food delivery, done fast.',
                      style: TextStyle(color: textSec, fontSize: 14)),
                  const SizedBox(height: 32),

                  // ── Tab switcher ───────────────────────────
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: surf,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: border),
                    ),
                    child: Row(children: [
                      _tabBtn('Sign in', 0, surf, textSec),
                      _tabBtn('Sign up', 1, surf, textSec),
                    ]),
                  ),
                  const SizedBox(height: 28),

                  // ── Forms ─────────────────────────────────
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _tabIndex == 0
                        ? _buildLoginForm(
                            key: const ValueKey('login'),
                            textHint: textHint,
                            border: border,
                            surf: surf)
                        : _buildSignupForm(
                            key: const ValueKey('signup'),
                            surf: surf,
                            border: border),
                  ),

                  const SizedBox(height: 24),

                  // ── Divider ───────────────────────────────
                  Row(children: [
                    Expanded(child: Divider(color: border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('or continue with',
                          style: TextStyle(color: textHint, fontSize: 12)),
                    ),
                    Expanded(child: Divider(color: border)),
                  ]),
                  const SizedBox(height: 16),

                  // ── Social buttons ────────────────────────
                  _GoogleSignInButton(
                    loading: _googleLoading,
                    onPressed: _googleSignIn,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabBtn(String label, int index, Color surf, Color textSec) {
    final active = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
          setState(() => _tabIndex = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: active ? AppTheme.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                  color: active ? Colors.black : textSec,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                )),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm({
    required Key key,
    required Color textHint,
    required Color border,
    required Color surf,
  }) {
    return Form(
      key: _loginKey,
      child: Column(
        key: key,
        children: [
          AppTextField(
            controller: _loginEmail,
            hint: 'Email address',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction:
                _useOtpLogin ? TextInputAction.done : TextInputAction.next,
            onFieldSubmitted: (_) {
              if (_useOtpLogin) {
                _requestOtp();
              } else {
                FocusScope.of(context).nextFocus();
              }
            },
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              final reg = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
              if (!reg.hasMatch(v.trim())) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 14),
          if (!_useOtpLogin) ...[
            AppTextField(
              controller: _loginPassword,
              hint: 'Password',
              prefixIcon: Icons.lock_outline_rounded,
              obscure: _obscureLogin,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _login(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureLogin ? Icons.visibility_off : Icons.visibility,
                  color: textHint,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureLogin = !_obscureLogin),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Password is required' : null,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _showForgotPassword,
                child: Text('Forgot password?',
                    style: TextStyle(color: AppColors.accentText(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ] else ...[
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => setState(() => _useOtpLogin = false),
                child: Text('Use password instead',
                    style: TextStyle(color: AppColors.accentText(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          PrimaryButton(
            label: _useOtpLogin ? 'Continue' : 'Sign in',
            isLoading: _useOtpLogin ? _isRequestingOtp : _isLoading,
            onPressed: _useOtpLogin ? _requestOtp : _login,
          ),
          const SizedBox(height: 12),
          if (!_useOtpLogin)
            TextButton(
              onPressed: () => setState(() => _useOtpLogin = true),
              child: Text('Login using OTP',
                  style: TextStyle(color: AppColors.accentText(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ),
          const SizedBox(height: 8),
          Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text("Don't have an account? ",
                    style: TextStyle(
                        color: AppColors.textSecondary(context), fontSize: 13)),
                GestureDetector(
                  onTap: () => setState(() {
                    _tabIndex = 1;
                    _tabController.animateTo(1);
                  }),
                  child: Text('Sign up',
                      style: TextStyle(color: AppColors.accentText(context),
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                ),
              ]),
        ],
      ),
    );
  }

  Widget _buildSignupForm({
    required Key key,
    required Color surf,
    required Color border,
  }) {
    return Form(
      key: _signupKey,
      child: Column(
        key: key,
        children: [
          // Role picker
          Container(
            decoration: BoxDecoration(
              color: surf,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            child: Row(children: [
              _roleChip('Customer', 'customer', Icons.person_outline),
              _roleChip('Restaurant', 'restaurant', Icons.storefront_outlined),
              _roleChip('Rider', 'rider', Icons.electric_bike_outlined),
            ]),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _signupName,
            hint: 'Full name',
            prefixIcon: Icons.person_outline_rounded,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Name is required' : null,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _signupEmail,
            hint: 'Email address',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              final reg = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
              if (!reg.hasMatch(v.trim())) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 14),
          if (_signupRole == 'restaurant') ...[
            AppTextField(
              controller: _cuisineController,
              hint: 'Cuisine Type e.g. local, Italian, Chinese, Fast Food',
              prefixIcon: Icons.restaurant_menu_outlined,
              validator: (v) {
                if (_signupRole == 'restaurant' &&
                    (v == null || v.trim().isEmpty)) {
                  return 'Cuisine type is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _addressController,
              hint: 'Restaurant Address',
              prefixIcon: Icons.location_on_outlined,
              validator: (v) {
                if (_signupRole == 'restaurant' &&
                    (v == null || v.trim().isEmpty)) {
                  return 'Restaurant address is required';
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: 14),
          AppTextField(
            controller: _signupPass,
            hint: 'Password (min 8 characters)',
            prefixIcon: Icons.lock_outline_rounded,
            obscure: _obscureSignup,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureSignup ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textHint(context),
                size: 20,
              ),
              onPressed: () => setState(() => _obscureSignup = !_obscureSignup),
            ),
            validator: (v) =>
                (v == null || v.length < 8) ? 'Min 8 characters' : null,
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: _signupRole == 'restaurant'
                ? 'Submit application'
                : 'Create account',
            isLoading: _isLoading,
            onPressed: () => _register(_cuisineController, _addressController),
          ),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Already have an account? ',
                style: TextStyle(
                    color: AppColors.textSecondary(context), fontSize: 13)),
            GestureDetector(
              onTap: () => setState(() {
                _tabIndex = 0;
                _tabController.animateTo(0);
              }),
              child: Text('Sign in',
                  style: TextStyle(color: AppColors.accentText(context),
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _roleChip(String label, String value, IconData icon) {
    final selected = _signupRole == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _signupRole = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppTheme.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(children: [
            Icon(icon,
                size: 18,
                color: selected ? Colors.black : AppColors.textHint(context)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color:
                        selected ? Colors.black : AppColors.textHint(context))),
          ]),
        ),
      ),
    );
  }
}

// ─── SOCIAL BUTTON ────────────────────────────────────────────────────────────
/// "Continue with Google" in Google's own button style: the official G,
/// a neutral surface and a thin outline (see Google's sign-in branding).
/// "Continue with Google": the official G on a soft, raised white card
/// (a deep charcoal one in dark mode), matching the app's rounded inputs.
class _GoogleSignInButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onPressed;

  const _GoogleSignInButton({required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final background = dark ? const Color(0xFF1E1F22) : Colors.white;
    final outline = dark ? const Color(0x33FFFFFF) : const Color(0xFFDADCE0);
    final text = dark ? const Color(0xFFE8EAED) : const Color(0xFF1F1F1F);

    return Semantics(
      button: true,
      label: 'Continue with Google',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.35 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: Material(
            key: const Key('google-sign-in'),
            color: background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: outline),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: loading ? null : onPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  children: [
                    // The G sits in its own white circle so it stays crisp on
                    // the dark button too.
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: dark ? null : Border.all(color: outline),
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Color(0xFF4285F4)),
                            )
                          : Image.asset('assets/brand/google_g.png',
                              width: 22, height: 22),
                    ),
                    Expanded(
                      child: Text(
                        loading ? 'Opening Google…' : 'Continue with Google',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: text,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.1),
                      ),
                    ),
                    // Balances the logo so the label sits in the true centre.
                    const SizedBox(width: 44),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

bool otpRequiredFromResponse(Map<String, dynamic> data) {
  return data['otp_required'] == true;
}
