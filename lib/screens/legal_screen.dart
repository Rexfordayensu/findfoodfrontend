import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../legal/legal_documents.dart';
import '../theme.dart';

/// The Terms of Service and Privacy Policy, at /terms and /privacy.
class LegalScreen extends StatefulWidget {
  final bool privacy;
  const LegalScreen({super.key, this.privacy = false});

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  late bool _privacy = widget.privacy;
  final _scroll = ScrollController();
  final _sectionKeys = <String, GlobalKey>{};
  final _topKey = GlobalKey();

  LegalDocument get _doc => _privacy ? privacyPolicy : termsOfService;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _show(bool privacy) {
    if (privacy == _privacy) return;
    setState(() {
      _privacy = privacy;
      _sectionKeys.clear();
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _jumpTo(GlobalKey key) {
    final target = key.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(target,
        duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
  }

  void _back() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final doc = _doc;
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.bg(context),
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _back,
        ),
        title: const Text('Legal'),
      ),
      body: SingleChildScrollView(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              key: _topKey,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DocSwitch(privacy: _privacy, onChanged: _show),
                const SizedBox(height: 24),
                Text(doc.title,
                    key: const Key('legal-title'),
                    style: TextStyle(
                        color: textPri,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5)),
                const SizedBox(height: 6),
                Text('Last updated $legalUpdated',
                    style: TextStyle(color: textSec, fontSize: 13)),
                const SizedBox(height: 14),
                Text(doc.intro,
                    style: TextStyle(color: textPri, fontSize: 15, height: 1.6)),
                const SizedBox(height: 20),
                _ShortVersion(points: doc.summary),
                const SizedBox(height: 20),
                _Contents(
                  sections: doc.sections,
                  onTap: (section) => _jumpTo(_keyFor(section)),
                ),
                const SizedBox(height: 12),
                for (var i = 0; i < doc.sections.length; i++)
                  _SectionView(
                    key: _keyFor(doc.sections[i]),
                    number: i + 1,
                    section: doc.sections[i],
                  ),
                const SizedBox(height: 28),
                _Footer(onTop: () => _jumpTo(_topKey)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  GlobalKey _keyFor(LegalSection section) =>
      _sectionKeys.putIfAbsent(section.id, () => GlobalKey(debugLabel: section.id));
}

class _DocSwitch extends StatelessWidget {
  final bool privacy;
  final ValueChanged<bool> onChanged;
  const _DocSwitch({required this.privacy, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget tab(String label, bool value, Key key) {
      final active = privacy == value;
      return Expanded(
        child: Semantics(
          button: true,
          selected: active,
          child: GestureDetector(
            key: key,
            onTap: () => onChanged(value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: active ? AppTheme.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(label,
                  style: TextStyle(
                      color: active ? Colors.black : AppColors.textSecondary(context),
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
            ),
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
        tab('Terms of Service', false, const Key('legal-tab-terms')),
        tab('Privacy Policy', true, const Key('legal-tab-privacy')),
      ]),
    );
  }
}

class _ShortVersion extends StatelessWidget {
  final List<String> points;
  const _ShortVersion({required this.points});

  @override
  Widget build(BuildContext context) {
    final textPri = AppColors.textPrimary(context);
    return Container(
      key: const Key('legal-summary'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
      decoration: BoxDecoration(
        color: AppTheme.accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.35)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('The short version',
            style: TextStyle(color: textPri, fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        for (final point in points)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.check_circle_rounded, size: 17, color: AppTheme.accentDeep),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(point,
                    style: TextStyle(color: textPri, fontSize: 14, height: 1.5)),
              ),
            ]),
          ),
      ]),
    );
  }
}

class _Contents extends StatelessWidget {
  final List<LegalSection> sections;
  final ValueChanged<LegalSection> onTap;
  const _Contents({required this.sections, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textSec = AppColors.textSecondary(context);
    return Material(
      color: AppColors.card(context),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: AppColors.border(context)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: const Key('legal-contents'),
          tilePadding: const EdgeInsets.symmetric(horizontal: 18),
          childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
          leading: Icon(Icons.format_list_numbered_rounded, color: textSec, size: 20),
          title: Text('Contents',
              style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
          children: [
            for (var i = 0; i < sections.length; i++)
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => onTap(sections[i]),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                  child: Row(children: [
                    SizedBox(
                      width: 28,
                      child: Text('${i + 1}.',
                          style: TextStyle(color: textSec, fontSize: 13)),
                    ),
                    Expanded(
                      child: Text(sections[i].title,
                          style: TextStyle(color: AppColors.textPrimary(context), fontSize: 14)),
                    ),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionView extends StatelessWidget {
  final int number;
  final LegalSection section;
  const _SectionView({super.key, required this.number, required this.section});

  @override
  Widget build(BuildContext context) {
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);
    final body = TextStyle(color: textSec, fontSize: 14.5, height: 1.65);
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: Text('$number',
                style: TextStyle(color: textPri, fontWeight: FontWeight.w800, fontSize: 13)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(section.title,
                  style: TextStyle(color: textPri, fontSize: 18, fontWeight: FontWeight.w800)),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        for (final paragraph in section.paragraphs)
          if (paragraph.startsWith('- '))
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.only(top: 9, right: 12),
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                        color: AppTheme.accentDeep, shape: BoxShape.circle),
                  ),
                ),
                Expanded(child: _RichText(paragraph.substring(2), style: body)),
              ]),
            )
          else if (paragraph.startsWith('> '))
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 4, bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
                border: const Border(left: BorderSide(color: AppTheme.warning, width: 3)),
              ),
              child: _RichText(paragraph.substring(2),
                  style: body.copyWith(color: textPri)),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RichText(paragraph, style: body),
            ),
      ]),
    );
  }
}

/// Text with **bold** runs.
class _RichText extends StatelessWidget {
  final String text;
  final TextStyle style;
  const _RichText(this.text, {required this.style});

  @override
  Widget build(BuildContext context) {
    final parts = text.split('**');
    return SelectableText.rich(TextSpan(style: style, children: [
      for (var i = 0; i < parts.length; i++)
        TextSpan(
          text: parts[i],
          style: i.isOdd
              ? TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.w700)
              : null,
        ),
    ]));
  }
}

class _Footer extends StatelessWidget {
  final VoidCallback onTop;
  const _Footer({required this.onTop});

  @override
  Widget build(BuildContext context) {
    final textSec = AppColors.textSecondary(context);
    return Column(children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(children: [
          const Icon(Icons.mail_outline_rounded, color: AppTheme.accentDeep),
          const SizedBox(width: 12),
          Expanded(
            child: SelectableText.rich(TextSpan(
              style: TextStyle(color: textSec, fontSize: 14, height: 1.5),
              children: [
                const TextSpan(text: 'Questions? Email us at '),
                TextSpan(
                    text: supportEmail,
                    style: TextStyle(
                        color: AppColors.textPrimary(context), fontWeight: FontWeight.w700)),
              ],
            )),
          ),
        ]),
      ),
      const SizedBox(height: 12),
      TextButton.icon(
        onPressed: onTop,
        icon: const Icon(Icons.arrow_upward_rounded, size: 18),
        label: const Text('Back to top'),
      ),
    ]);
  }
}
