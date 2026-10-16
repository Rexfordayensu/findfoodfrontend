import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../services/providers.dart';
import '../theme.dart';
import '../legal/legal_documents.dart' show supportEmail;
import '../services/notifications_provider.dart';
import '../screens/legal_screen.dart';
import 'user_avatar.dart' show EditableAvatar;
import 'widgets.dart';
import '../utils/friendly_error.dart';

/// Account settings shared by every role: profile, email, password,
/// notifications, appearance and support pages.
///
/// [businessRows] lets a role add its own rows (e.g. the restaurant profile)
/// at the top of the list.
class AccountSettingsSection extends StatelessWidget {
  final String role;
  final List<Widget> businessRows;

  const AccountSettingsSection({
    super.key,
    required this.role,
    this.businessRows = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (businessRows.isNotEmpty) ...[
          SettingsGroup(title: 'BUSINESS', children: businessRows),
          const SizedBox(height: 20),
        ],
        SettingsGroup(title: 'ACCOUNT', children: [
          SettingsTile(
            key: const Key('settings-edit-profile'),
            icon: Icons.person_outline_rounded,
            title: 'Edit profile',
            subtitle: 'Update your name',
            onTap: () => showEditProfileSheet(context),
          ),
          SettingsTile(
            key: const Key('settings-change-email'),
            icon: Icons.alternate_email_rounded,
            title: 'Change email',
            subtitle: 'Verify a new email address',
            onTap: () => showChangeEmailSheet(context),
          ),
          SettingsTile(
            key: const Key('settings-change-password'),
            icon: Icons.lock_outline_rounded,
            title: 'Change password',
            subtitle: 'Update your password',
            onTap: () => showChangePasswordSheet(context),
          ),
        ]),
        const SizedBox(height: 20),
        SettingsGroup(title: 'PREFERENCES', children: [
          SettingsTile(
            key: const Key('settings-notifications'),
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage alert preferences',
            onTap: () => showNotificationPreferencesSheet(context),
          ),
          SettingsTile(
            key: const Key('settings-appearance'),
            icon: theme.isDark
                ? Icons.wb_sunny_outlined
                : Icons.nightlight_outlined,
            title: 'Appearance',
            subtitle: theme.isDark ? 'Dark mode' : 'Light mode',
            trailing: Switch(
              value: theme.isDark,
              onChanged: (_) => theme.toggle(),
            ),
            onTap: theme.toggle,
          ),
        ]),
        const SizedBox(height: 20),
        SettingsGroup(title: 'SUPPORT', children: [
          SettingsTile(
            key: const Key('settings-help'),
            icon: Icons.help_outline_rounded,
            title: 'Help & support',
            subtitle: 'Answers to common questions',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => HelpSupportScreen(role: role))),
          ),
          SettingsTile(
            key: const Key('settings-terms'),
            icon: Icons.policy_outlined,
            title: 'Terms & privacy',
            subtitle: 'Your rights and how we use your data',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const LegalScreen())),
          ),
        ]),
      ],
    );
  }
}

/// Header showing the signed-in user's name, email and role.
class AccountHeader extends StatelessWidget {
  final String? subtitle;
  const AccountHeader({super.key, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final name = (auth.name?.trim().isNotEmpty ?? false) ? auth.name! : 'Your account';
    return Row(
      children: [
        const EditableAvatar(size: 60),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  key: const Key('account-header-name'),
                  style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
              if (auth.email != null && auth.email!.isNotEmpty)
                Text(auth.email!,
                    key: const Key('account-header-email'),
                    style: TextStyle(
                        color: AppColors.textSecondary(context), fontSize: 13)),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(subtitle!,
                      style: const TextStyle(
                          color: AppTheme.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// "ACCOUNT" -> "Account": calmer than shouting headings.
String _sentenceCase(String text) => text.isEmpty
    ? text
    : text[0].toUpperCase() + text.substring(1).toLowerCase();

class SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const SettingsGroup({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Text(_sentenceCase(title),
              style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Column(children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0)
                Divider(
                    height: 1,
                    indent: 66,
                    color: AppColors.border(context)),
              children[i],
            ],
          ]),
        ),
      ],
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: AppColors.accentText(context), size: 19),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Text(subtitle!,
                          style: TextStyle(
                              color: AppColors.textSecondary(context),
                              fontSize: 12.5)),
                    ),
                ],
              ),
            ),
            trailing ??
                Icon(Icons.chevron_right_rounded,
                    color: AppColors.textHint(context), size: 22),
          ],
        ),
      ),
    );
  }
}

// ─── SHEETS ──────────────────────────────────────────────────────────────────

Future<T?> showSettingsSheet<T>(BuildContext context, Widget child) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    // Solid: a sheet must not show the page behind it.
    backgroundColor: AppColors.sheet(context),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(sheetContext).viewInsets.bottom + 24),
      child: SingleChildScrollView(child: child),
    ),
  );
}

void showSettingsMessage(BuildContext context, String message,
    {bool isError = false}) {
  final messenger = appScaffoldMessengerKey.currentState ??
      ScaffoldMessenger.maybeOf(context);
  // Replace any visible message so feedback is immediate rather than queued.
  messenger?.hideCurrentSnackBar();
  messenger?.showSnackBar(SnackBar(
    content: Text(message, style: const TextStyle(color: Colors.white)),
    backgroundColor: isError ? AppTheme.danger : AppTheme.success,
  ));
}

String _errorText(Object error) =>
    friendlyMessage(error);

class SheetHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  const SheetHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(title,
            style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 18,
                fontWeight: FontWeight.w800)),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!,
              style: TextStyle(
                  color: AppColors.textSecondary(context), fontSize: 13)),
        ],
        const SizedBox(height: 20),
      ],
    );
  }
}

Future<void> showEditProfileSheet(BuildContext context) =>
    showSettingsSheet(context, const _EditProfileForm());

Future<void> showChangeEmailSheet(BuildContext context) =>
    showSettingsSheet(context, const _ChangeEmailForm());

Future<void> showChangePasswordSheet(BuildContext context) =>
    showSettingsSheet(context, const _ChangePasswordForm());

Future<void> showNotificationPreferencesSheet(BuildContext context) =>
    showSettingsSheet(context, const _NotificationPreferencesForm());

class _EditProfileForm extends StatefulWidget {
  const _EditProfileForm();

  @override
  State<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<_EditProfileForm> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameCtrl.text = auth.name ?? '';
    final token = auth.token;
    if (token != null) {
      ApiService.getMyProfile(token).then((me) {
        if (mounted && _phoneCtrl.text.isEmpty) _phoneCtrl.text = '${me['phone'] ?? ''}';
      }).catchError((_) {});
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final auth = context.read<AuthProvider>();
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      showSettingsMessage(context, 'Name cannot be empty.', isError: true);
      return;
    }
    setState(() => _saving = true);
    try {
      final data = await ApiService.updateMyProfile(
          token: auth.token!, name: name, phone: _phoneCtrl.text);
      await auth.updateName(data['name']?.toString() ?? name);
      if (!mounted) return;
      Navigator.of(context).pop();
      showSettingsMessage(context, 'Profile updated.');
    } catch (error) {
      if (mounted) showSettingsMessage(context, _errorText(error), isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = context.watch<AuthProvider>().email ?? '';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SheetHeader(title: 'Edit profile'),
        AppTextField(
          key: const Key('profile-name-field'),
          controller: _nameCtrl,
          hint: 'Full name',
          prefixIcon: Icons.person_outline_rounded,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        AppTextField(
          key: const Key('profile-phone-field'),
          controller: _phoneCtrl,
          hint: 'Phone number (optional)',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _save(),
        ),
        const SizedBox(height: 6),
        Text(
            context.watch<AuthProvider>().isRider
                ? 'Restaurants and customers see it while you have their delivery.'
                : 'Used only to reach you about your orders.',
            style: TextStyle(color: AppColors.textHint(context), fontSize: 12)),
        const SizedBox(height: 12),
        InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.verified_user_outlined),
          ),
          child: Text(email),
        ),
        const SizedBox(height: 6),
        Text('Use "Change email" to switch to a different address.',
            style: TextStyle(color: AppColors.textHint(context), fontSize: 12)),
        const SizedBox(height: 20),
        PrimaryButton(
          key: const Key('profile-save'),
          label: 'Save changes',
          isLoading: _saving,
          onPressed: _saving ? null : _save,
        ),
      ],
    );
  }
}

class _ChangeEmailForm extends StatefulWidget {
  const _ChangeEmailForm();

  @override
  State<_ChangeEmailForm> createState() => _ChangeEmailFormState();
}

class _ChangeEmailFormState extends State<_ChangeEmailForm> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  bool _codeSent = false;
  bool _busy = false;
  bool _usesGoogle = false;

  @override
  void initState() {
    super.initState();
    _loadProvider();
  }

  Future<void> _loadProvider() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;
    try {
      final me = await ApiService.getMyProfile(token);
      if (!mounted) return;
      setState(() {
        _usesGoogle = me['provider'] == 'google';
        final pending = me['pending_email']?.toString();
        if (pending != null && pending.isNotEmpty) {
          _emailCtrl.text = pending;
          _codeSent = true;
        }
      });
    } catch (_) {
      // The form still works; the server validates the password.
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final email = _emailCtrl.text.trim();
    if (!email.contains('@') || !email.contains('.')) {
      showSettingsMessage(context, 'Enter a valid email address.', isError: true);
      return;
    }
    if (!_usesGoogle && _passwordCtrl.text.isEmpty) {
      showSettingsMessage(context, 'Enter your current password.', isError: true);
      return;
    }
    setState(() => _busy = true);
    try {
      final message = await ApiService.requestEmailChange(
        token: context.read<AuthProvider>().token!,
        newEmail: email,
        password: _passwordCtrl.text,
      );
      if (!mounted) return;
      setState(() => _codeSent = true);
      showSettingsMessage(context, message);
    } catch (error) {
      if (mounted) showSettingsMessage(context, _errorText(error), isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    if (_codeCtrl.text.trim().length != 6) {
      showSettingsMessage(context, 'Enter the 6-digit code.', isError: true);
      return;
    }
    final auth = context.read<AuthProvider>();
    setState(() => _busy = true);
    try {
      final data = await ApiService.verifyEmailChange(
          token: auth.token!, otp: _codeCtrl.text);
      await auth.updateEmail(data['email'].toString());
      if (!mounted) return;
      Navigator.of(context).pop();
      showSettingsMessage(context, 'Email updated to ${data['email']}.');
    } catch (error) {
      if (mounted) showSettingsMessage(context, _errorText(error), isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SheetHeader(
          title: 'Change email',
          subtitle: _codeSent
              ? 'Enter the code we sent to ${_emailCtrl.text.trim()}.'
              : 'We will send a verification code to the new address.',
        ),
        if (!_codeSent) ...[
          AppTextField(
            key: const Key('email-new-field'),
            controller: _emailCtrl,
            hint: 'New email address',
            prefixIcon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          if (!_usesGoogle) ...[
            const SizedBox(height: 12),
            AppTextField(
              key: const Key('email-password-field'),
              controller: _passwordCtrl,
              hint: 'Current password',
              prefixIcon: Icons.lock_outline_rounded,
              obscure: true,
            ),
          ],
          const SizedBox(height: 20),
          PrimaryButton(
            key: const Key('email-send-code'),
            label: 'Send code',
            isLoading: _busy,
            onPressed: _busy ? null : _sendCode,
          ),
        ] else ...[
          AppTextField(
            key: const Key('email-code-field'),
            controller: _codeCtrl,
            hint: '6-digit code',
            prefixIcon: Icons.pin_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            key: const Key('email-verify'),
            label: 'Confirm new email',
            isLoading: _busy,
            onPressed: _busy ? null : _verify,
          ),
          TextButton(
            onPressed: _busy ? null : () => setState(() => _codeSent = false),
            child: const Text('Use a different address'),
          ),
        ],
      ],
    );
  }
}

class _ChangePasswordForm extends StatefulWidget {
  const _ChangePasswordForm();

  @override
  State<_ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<_ChangePasswordForm> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _saving = false;
  bool _obscure = true;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_currentCtrl.text.isEmpty) {
      showSettingsMessage(context, 'Enter your current password.', isError: true);
      return;
    }
    if (_newCtrl.text.length < 8) {
      showSettingsMessage(context, 'New password must be at least 8 characters.',
          isError: true);
      return;
    }
    if (_newCtrl.text != _confirmCtrl.text) {
      showSettingsMessage(context, 'New passwords do not match.', isError: true);
      return;
    }
    setState(() => _saving = true);
    try {
      await ApiService.changeMyPassword(
        token: context.read<AuthProvider>().token!,
        currentPassword: _currentCtrl.text,
        newPassword: _newCtrl.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      showSettingsMessage(context, 'Password changed.');
    } catch (error) {
      if (mounted) showSettingsMessage(context, _errorText(error), isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final toggle = IconButton(
      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
          color: AppColors.textHint(context), size: 20),
      onPressed: () => setState(() => _obscure = !_obscure),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SheetHeader(title: 'Change password'),
        AppTextField(
          key: const Key('password-current-field'),
          controller: _currentCtrl,
          hint: 'Current password',
          prefixIcon: Icons.lock_outline_rounded,
          obscure: _obscure,
          suffixIcon: toggle,
        ),
        const SizedBox(height: 12),
        AppTextField(
          key: const Key('password-new-field'),
          controller: _newCtrl,
          hint: 'New password (min 8 characters)',
          prefixIcon: Icons.lock_reset_rounded,
          obscure: _obscure,
        ),
        const SizedBox(height: 12),
        AppTextField(
          key: const Key('password-confirm-field'),
          controller: _confirmCtrl,
          hint: 'Confirm new password',
          prefixIcon: Icons.lock_reset_rounded,
          obscure: _obscure,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              final router = GoRouter.of(context);
              Navigator.of(context).pop();
              router.push('/forgot-password');
            },
            child: const Text('Signed up with Google or forgot it?'),
          ),
        ),
        const SizedBox(height: 8),
        PrimaryButton(
          key: const Key('password-save'),
          label: 'Update password',
          isLoading: _saving,
          onPressed: _saving ? null : _save,
        ),
      ],
    );
  }
}

class _NotificationPreferencesForm extends StatefulWidget {
  const _NotificationPreferencesForm();

  @override
  State<_NotificationPreferencesForm> createState() =>
      _NotificationPreferencesFormState();
}

class _NotificationPreferencesFormState
    extends State<_NotificationPreferencesForm> {
  bool _loading = true;
  bool _saving = false;
  String? _error;
  bool _email = true;
  bool _push = true;
  bool _orders = true;
  bool _promotions = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiService.getNotificationPrefs(
          context.read<AuthProvider>().token!);
      if (!mounted) return;
      setState(() {
        _email = data['email_notifications'] ?? true;
        _push = data['push_notifications'] ?? true;
        _orders = data['order_alerts'] ?? true;
        _promotions = data['promotions'] ?? true;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = _errorText(error);
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ApiService.updateNotificationPrefs(
        token: context.read<AuthProvider>().token!,
        emailNotifications: _email,
        pushNotifications: _push,
        orderAlerts: _orders,
        promotions: _promotions,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      showSettingsMessage(context, 'Notification preferences saved.');
    } catch (error) {
      if (mounted) showSettingsMessage(context, _errorText(error), isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Turning push on asks this device straight away (browsers only prompt
  /// in response to a tap); turning it off stops pushes to this device.
  Future<void> _setPush(bool on) async {
    setState(() => _push = on);
    final notes = context.read<NotificationsProvider?>();
    if (notes == null) return;
    if (!on) {
      await notes.disablePush();
      return;
    }
    final result = await notes.enablePush();
    if (!mounted) return;
    final problem = switch (result) {
      PushResult.denied =>
        'Notifications are blocked. Allow them for this site in your browser settings.',
      PushResult.needsHomeScreen =>
        'On iPhone, add FindFood to your Home Screen first, then turn this on there.',
      PushResult.unsupported => "This browser can't show notifications.",
      PushResult.failed => "Couldn't turn on notifications on this device.",
      PushResult.enabled => null,
    };
    if (problem != null) showSettingsMessage(context, problem, isError: true);
    setState(() {});
  }

  String _pushSubtitle() {
    final notes = context.read<NotificationsProvider?>();
    if (notes == null || !_push) return 'Alerts on this device, even when FindFood is closed';
    final push = notes.push;
    if (push.needsHomeScreen) return 'Add FindFood to your Home Screen to get alerts';
    if (!push.supported) return "This browser can't show notifications";
    if (push.permission == 'denied') return 'Blocked in your browser settings';
    if (push.permission == 'granted') return 'On for this device';
    return 'Alerts on this device, even when FindFood is closed';
  }

  Widget _switch(String key, String title, String subtitle, bool value,
      ValueChanged<bool> onChanged) {
    return SwitchListTile(
      key: Key(key),
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: onChanged,
      title: Text(title,
          style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 14,
              fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style: TextStyle(color: AppColors.textHint(context), fontSize: 12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SheetHeader(title: 'Notifications'),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
          )
        else if (_error != null) ...[
          Text(_error!, style: TextStyle(color: AppColors.textSecondary(context))),
          TextButton(onPressed: _load, child: const Text('Try again')),
        ] else ...[
          _switch('notif-email', 'Email notifications',
              'Order and account updates by email', _email,
              (v) => setState(() => _email = v)),
          _switch('notif-push', 'Push notifications',
              _pushSubtitle(), _push, _setPush),
          _switch('notif-orders', 'Order alerts',
              'New and updated orders', _orders,
              (v) => setState(() => _orders = v)),
          _switch('notif-promotions', 'Offers and news',
              'Deals and news from FindFood. Important updates always come through.',
              _promotions, (v) => setState(() => _promotions = v)),
          const SizedBox(height: 16),
          PrimaryButton(
            key: const Key('notif-save'),
            label: 'Save preferences',
            isLoading: _saving,
            onPressed: _saving ? null : _save,
          ),
        ],
      ],
    );
  }
}

// ─── SUPPORT PAGES ───────────────────────────────────────────────────────────


class HelpSupportScreen extends StatelessWidget {
  final String role;
  const HelpSupportScreen({super.key, required this.role});

  List<(String, String)> get _faqs => switch (role) {
        'restaurant' => const [
            ('How do I accept an order?',
                'New paid orders appear under Orders as "Pending". Tap "Start preparing", then "Mark ready" when the food is done.'),
            ('How do I stop receiving orders?',
                'Turn off "Kitchen open" in Settings. Customers can still see your menu but cannot order until you reopen.'),
            ('What happens when I reject an order?',
                'The order is cancelled and the customer is refunded automatically.'),
            ('How do I change my menu photos?',
                'Open the Menu tab, edit an item and choose a new photo.'),
          ],
        'rider' => const [
            ('How do I take a delivery?',
                'Go online on the Available tab and tap "Accept" on a job. It moves to My Deliveries.'),
            ('How are my earnings calculated?',
                'You earn 10% of the order total for every delivered order.'),
            ('How do I contact the customer?',
                'Open the chat on the delivery card to message the customer.'),
          ],
        'admin' => const [
            ('How do I approve a restaurant?',
                'Open Approvals, review the details, then Approve or Reject.'),
            ('How do I suspend an account?',
                'Open Users, find the account and use the menu to suspend or reactivate it. Suspended users are signed out immediately.'),
            ('What does "Refund needs attention" mean?',
                'A cancelled order could not be refunded automatically. Refund it from your payment provider dashboard.'),
          ],
        _ => const [
            ('How do I track my order?',
                'Open Orders and tap an order to follow it live.'),
            ('Can I cancel an order?',
                'Yes, until the restaurant starts preparing it. Paid orders are refunded automatically.'),
            ('My payment did not finish. What now?',
                'Open Orders, tap the order marked "Awaiting payment" and choose "Pay now".'),
            ('How do I rate an order?',
                'After delivery or pickup, open the order and tap "Rate order".'),
          ],
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Frequently asked questions',
              style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          for (final (question, answer) in _faqs)
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(question,
                  style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w600)),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(answer,
                      style: TextStyle(
                          color: AppColors.textSecondary(context), height: 1.5)),
                ),
              ],
            ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.accentDim,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.support_agent_rounded, color: AppTheme.accent),
                const SizedBox(width: 12),
                Expanded(
                  child: SelectableText(
                    'Still need help? Email us at $supportEmail',
                    style: TextStyle(color: AppColors.textPrimary(context)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Confirms, signs out and returns to the home screen.
class SignOutButton extends StatelessWidget {
  const SignOutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GhostButton(
      key: const Key('settings-sign-out'),
      label: 'Sign out',
      onPressed: () async {
        if (!await confirmLogout(context) || !context.mounted) return;
        await context.read<AuthProvider>().logout();
        if (!context.mounted) return;
        showLogoutSuccess(context);
        context.go('/');
      },
    );
  }
}
