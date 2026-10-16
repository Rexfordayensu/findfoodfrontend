import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../services/providers.dart';
import '../theme.dart';
import '../utils/friendly_error.dart';
import 'account_settings.dart' show SheetHeader, showSettingsSheet, showSettingsMessage;

/// A round profile picture: the person's photo when they have one (uploaded,
/// or from Google), otherwise their initial on the brand gradient.
class UserAvatar extends StatelessWidget {
  final String? name;
  final String? url;
  final double size;

  const UserAvatar({super.key, required this.name, required this.url, this.size = 42});

  @override
  Widget build(BuildContext context) {
    final trimmed = name?.trim() ?? '';
    final initial = trimmed.isEmpty ? '' : trimmed.characters.first.toUpperCase();
    final fallback = DecoratedBox(
      decoration: const BoxDecoration(gradient: AppTheme.brandGradient),
      child: Center(
        child: initial.isEmpty
            ? Icon(Icons.person_rounded, size: size * 0.52, color: const Color(0xFF111111))
            : Text(initial,
                style: TextStyle(
                    color: const Color(0xFF111111),
                    fontSize: size * 0.42,
                    height: 1,
                    fontWeight: FontWeight.w800)),
      ),
    );
    final photo = ApiService.imageUrl(url);
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: photo == null
            ? fallback
            : Image.network(
                photo,
                key: const Key('user-avatar-photo'),
                fit: BoxFit.cover,
                width: size,
                height: size,
                // A broken or slow photo shows the initial instead.
                errorBuilder: (_, __, ___) => fallback,
                loadingBuilder: (_, child, progress) => progress == null ? child : fallback,
              ),
      ),
    );
  }
}

/// The signed-in person's avatar with a small camera button to add, change
/// or remove their photo. A photo is optional.
class EditableAvatar extends StatefulWidget {
  final double size;
  const EditableAvatar({super.key, this.size = 64});

  @override
  State<EditableAvatar> createState() => _EditableAvatarState();
}

class _EditableAvatarState extends State<EditableAvatar> {
  bool _busy = false;

  Future<void> _choose() async {
    final auth = context.read<AuthProvider>();
    final hasPhoto = (auth.avatarUrl ?? '').isNotEmpty;
    final action = await showSettingsSheet<String>(context, _PhotoOptions(hasPhoto: hasPhoto));
    if (action == null || !mounted) return;
    setState(() => _busy = true);
    try {
      if (action == 'remove') {
        final user = await ApiService.deleteAvatar(auth.token!);
        await auth.setAvatarUrl(user['avatar_url']?.toString());
        if (mounted) showSettingsMessage(context, 'Photo removed.');
        return;
      }
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (picked == null) return;
      final user = await ApiService.uploadAvatar(
          token: auth.token!, imageBytes: await picked.readAsBytes(), filename: picked.name);
      await auth.setAvatarUrl(user['avatar_url']?.toString());
      if (mounted) showSettingsMessage(context, 'Looking good! Photo updated.');
    } catch (e) {
      if (mounted) showSettingsMessage(context, friendlyMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final size = widget.size;
    return Semantics(
      button: true,
      label: 'Profile photo. Tap to change it.',
      child: GestureDetector(
        key: const Key('edit-avatar'),
        onTap: _busy ? null : _choose,
        child: SizedBox(
          width: size + 4,
          height: size + 4,
          child: Stack(clipBehavior: Clip.none, children: [
            UserAvatar(name: auth.name, url: auth.avatarUrl, size: size),
            if (_busy)
              Positioned.fill(
                right: 4,
                bottom: 4,
                child: ClipOval(
                  child: ColoredBox(
                    color: Colors.black38,
                    child: Center(
                      child: SizedBox(
                        width: size * 0.36,
                        height: size * 0.36,
                        child: const CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: size * 0.38,
                height: size * 0.38,
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.sheet(context), width: 2),
                ),
                child: Icon(Icons.photo_camera_rounded, size: size * 0.2, color: Colors.black),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _PhotoOptions extends StatelessWidget {
  final bool hasPhoto;
  const _PhotoOptions({required this.hasPhoto});

  @override
  Widget build(BuildContext context) {
    Widget option(String value, IconData icon, String label, {Color? color}) => ListTile(
          key: Key('avatar-$value'),
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: color ?? AppColors.textPrimary(context)),
          title: Text(label,
              style: TextStyle(
                  color: color ?? AppColors.textPrimary(context), fontWeight: FontWeight.w600)),
          onTap: () => Navigator.of(context).pop(value),
        );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SheetHeader(
          title: 'Profile photo',
          subtitle: "Optional. It helps restaurants and riders recognise you.",
        ),
        option('choose', Icons.photo_library_outlined, hasPhoto ? 'Choose a new photo' : 'Add a photo'),
        if (hasPhoto)
          option('remove', Icons.delete_outline_rounded, 'Remove photo', color: AppTheme.danger),
      ],
    );
  }
}
