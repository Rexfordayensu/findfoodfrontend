import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../services/providers.dart';
import '../theme.dart';
import '../utils/friendly_error.dart';
import '../utils/share_helper.dart';
import 'account_settings.dart' show SheetHeader, showSettingsSheet, showSettingsMessage;
import 'widgets.dart';

/// Opens the share sheet for the signed-in restaurant: a preview of its
/// banner first, then share it to WhatsApp Status (or anywhere), share or
/// copy the link.
Future<void> showRestaurantShareSheet(BuildContext context) => showSettingsSheet<void>(context, const _ShareSheet());

/// The same sheet for anyone recommending a restaurant to friends.
Future<void> showShareRestaurantSheet(BuildContext context, {required int restaurantId, required String name}) =>
    showSettingsSheet<void>(context, _ShareSheet(restaurantId: restaurantId, restaurantName: name));

/// Where FindFood is running (share links point here).
String _site() {
  final base = Uri.base;
  return base.scheme == 'http' || base.scheme == 'https' ? base.origin : 'https://findfood-nu.vercel.app';
}

/// A round share button for the top of a restaurant's page.
class ShareRestaurantButton extends StatelessWidget {
  final int restaurantId;
  final String name;
  const ShareRestaurantButton({super.key, required this.restaurantId, required this.name});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Share $name',
      child: GestureDetector(
        key: const Key('menu-share'),
        onTap: () => showShareRestaurantSheet(context, restaurantId: restaurantId, name: name),
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.ios_share_rounded, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

/// A card inviting the restaurant to share itself (Settings).
class ShareRestaurantCard extends StatelessWidget {
  const ShareRestaurantCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppTheme.brandGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: AppTheme.accentDeep.withValues(alpha: 0.28), blurRadius: 18, offset: const Offset(0, 6)),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          key: const Key('share-restaurant-card'),
          borderRadius: BorderRadius.circular(18),
          onTap: () => showRestaurantShareSheet(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.ios_share_rounded, color: AppTheme.accent, size: 24),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Share your restaurant',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 16)),
                  SizedBox(height: 2),
                  Text('Post a ready-made banner on your WhatsApp Status and bring in orders.',
                      style: TextStyle(color: Color(0xCC000000), fontSize: 12.5, height: 1.35)),
                ]),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.black),
            ]),
          ),
        ),
      ),
    );
  }
}

class _ShareSheet extends StatefulWidget {
  /// Set when someone shares a restaurant that isn't theirs.
  final int? restaurantId;
  final String? restaurantName;
  const _ShareSheet({this.restaurantId, this.restaurantName});

  @override
  State<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<_ShareSheet> {
  Map<String, dynamic>? _info;
  String? _error;
  // Restaurants mostly post to their Status; customers send links to friends.
  late bool _story = !_customer;

  bool get _customer => widget.restaurantId != null;
  final _bytes = <bool, Uint8List>{};
  bool _busy = false;

  String get _url => '${_info!['url']}';
  String get _caption => '${_info!['text']} 👉 $_url';
  String _imagePath(bool story) => '${_info![story ? 'story_image' : 'wide_image']}';
  String _filename(bool story) => 'findfood-${story ? 'status' : 'banner'}.jpg';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final id = widget.restaurantId;
      final info = id != null
          ? <String, dynamic>{
              'url': '${_site()}/r/$id',
              'story_image': '/share/restaurants/$id/card.jpg?size=story',
              'wide_image': '/share/restaurants/$id/card.jpg?size=wide',
              'text': 'Check out ${widget.restaurantName} on FindFood',
              'has_photo': true,
            }
          : await ApiService.getMyRestaurantShare(context.read<AuthProvider>().token!);
      if (!mounted) return;
      setState(() {
        _info = info;
        _error = null;
      });
      // Have both pictures ready: phones only allow sharing straight after a
      // tap, with no waiting for a download in between.
      for (final story in [true, false]) {
        ApiService.getImageBytes(_imagePath(story)).then((bytes) {
          if (mounted) setState(() => _bytes[story] = bytes);
        }).catchError((_) {});
      }
    } catch (e) {
      if (mounted) setState(() => _error = friendlyMessage(e));
    }
  }

  void _message(String text, {bool error = false}) => showSettingsMessage(context, text, isError: error);

  Future<void> _copyLink({String? note}) async {
    await Clipboard.setData(ClipboardData(text: _url));
    _message(note ?? 'Link copied. Paste it anywhere.');
  }

  bool _save(bool story) {
    final bytes = _bytes[story];
    return bytes != null && saveImage(bytes, _filename(story));
  }

  Future<void> _shareBanner() async {
    final bytes = _bytes[_story];
    if (bytes == null || _busy) return;
    setState(() => _busy = true);
    final result = await shareImage(bytes, filename: _filename(_story), text: _caption);
    if (!mounted) return;
    setState(() => _busy = false);
    if (result == ShareResult.unsupported) {
      // No share menu (e.g. a computer): save the picture and copy the link.
      final saved = _save(_story);
      await Clipboard.setData(ClipboardData(text: _caption));
      _message(saved
          ? 'Banner saved and caption copied. Post the picture on your Status and paste the caption.'
          : 'Caption copied. Long-press the picture to save it, then post it on your Status.');
    }
  }

  Future<void> _shareLink() async {
    final result = await shareLink(text: '${_info!['text']}', url: _url);
    if (result == ShareResult.unsupported && mounted) {
      await _copyLink(note: 'Link copied. Paste it in a chat: it shows the banner.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textSec = AppColors.textSecondary(context);
    final info = _info;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
      SheetHeader(
        title: _customer ? 'Share ${widget.restaurantName}' : 'Share your restaurant',
        subtitle: _customer
            ? 'Send it to friends or post it on your Status. They can tap it to order.'
            : 'Your banner is made from your photo, menu and reviews. Customers tap it to order.',
      ),
      if (_error != null)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: textSec)),
        )
      else if (info == null)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
        )
      else ...[
        _FormatSwitch(story: _story, onChanged: (story) => setState(() => _story = story)),
        const SizedBox(height: 14),
        _Preview(bytes: _bytes[_story], story: _story),
        const SizedBox(height: 8),
        Text(
          _story
              ? 'For WhatsApp Status: tap Share, choose WhatsApp, then My status.'
              : _customer
                  ? 'Send the link in any chat: it shows this picture.'
                  : 'This is what people see when you send your link in a chat.',
          textAlign: TextAlign.center,
          style: TextStyle(color: textSec, fontSize: 12.5),
        ),
        if (info['has_photo'] != true) ...[
          const SizedBox(height: 10),
          Container(
            key: const Key('share-photo-tip'),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.warning.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Tip: add a banner photo (Settings) and photos to your dishes. Banners with real food get far more orders.',
              style: TextStyle(fontSize: 12.5, height: 1.4),
            ),
          ),
        ],
        const SizedBox(height: 16),
        // The tall banner goes on a Status; the wide one is the link's preview,
        // so that tab shares the link itself.
        if (_story)
          PrimaryButton(
            key: const Key('share-banner'),
            label: 'Share to Status',
            icon: Icons.ios_share_rounded,
            isLoading: _busy || _bytes[true] == null,
            onPressed: _bytes[true] == null ? null : _shareBanner,
          )
        else
          PrimaryButton(
            key: const Key('share-link-primary'),
            label: 'Share link',
            icon: Icons.ios_share_rounded,
            onPressed: _shareLink,
          ),
        const SizedBox(height: 10),
        Row(children: [
          if (_story) ...[
            Expanded(
              child: _SecondaryButton(
                key: const Key('share-link'),
                icon: Icons.link_rounded,
                label: 'Share link',
                onPressed: _shareLink,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: _SecondaryButton(
              key: const Key('share-copy'),
              icon: Icons.copy_rounded,
              label: 'Copy link',
              onPressed: _copyLink,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SecondaryButton(
              key: const Key('share-save'),
              icon: Icons.download_rounded,
              label: 'Save',
              onPressed: _bytes[_story] == null
                  ? null
                  : () {
                      if (_save(_story)) {
                        _message('Banner saved to your downloads.');
                      } else {
                        _message('Long-press the picture to save it.', error: true);
                      }
                    },
            ),
          ),
        ]),
        const SizedBox(height: 12),
        SelectableText(_url,
            key: const Key('share-url'),
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.accentText(context), fontWeight: FontWeight.w700, fontSize: 13)),
      ],
    ]);
  }
}

class _FormatSwitch extends StatelessWidget {
  final bool story;
  final ValueChanged<bool> onChanged;
  const _FormatSwitch({required this.story, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget tab(bool value, IconData icon, String label) {
      final active = story == value;
      return Expanded(
        child: GestureDetector(
          key: Key('share-format-${value ? 'story' : 'wide'}'),
          onTap: () => onChanged(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: active ? AppTheme.accent : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 17, color: active ? Colors.black : AppColors.textSecondary(context)),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: active ? Colors.black : AppColors.textSecondary(context),
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5)),
            ]),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(children: [
        tab(true, Icons.amp_stories_outlined, 'Status'),
        tab(false, Icons.chat_outlined, 'Link preview'),
      ]),
    );
  }
}

class _Preview extends StatelessWidget {
  final Uint8List? bytes;
  final bool story;
  const _Preview({required this.bytes, required this.story});

  @override
  Widget build(BuildContext context) {
    final ratio = story ? 1080 / 1920 : 1200 / 630;
    final height = story ? 400.0 : null;
    final box = AspectRatio(
      aspectRatio: ratio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(story ? 18 : 14),
        child: bytes == null
            ? Container(
                color: AppColors.surface(context),
                alignment: Alignment.center,
                child: const SizedBox(
                    width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.accent)),
              )
            : Image.memory(bytes!,
                key: Key('share-preview-${story ? 'story' : 'wide'}'), fit: BoxFit.cover, gaplessPlayback: true),
      ),
    );
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(story ? 18 : 14),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 20, offset: const Offset(0, 8))
          ],
        ),
        child: height == null ? box : SizedBox(height: height, child: box),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  const _SecondaryButton({super.key, required this.icon, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary(context),
        side: BorderSide(color: AppColors.border(context)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700, fontSize: 13),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 20),
        const SizedBox(height: 4),
        Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}
