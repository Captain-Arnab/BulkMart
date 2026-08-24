import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/ui/app_motion.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

/// Structured legal section used by Terms / Cancellation screens.
class LegalSection {
  const LegalSection({
    required this.title,
    required this.blocks,
  });

  final String title;
  final List<LegalBlock> blocks;
}

sealed class LegalBlock {
  const LegalBlock();
}

class LegalParagraph extends LegalBlock {
  const LegalParagraph(this.text);
  final String text;
}

class LegalBullets extends LegalBlock {
  const LegalBullets(this.items);
  final List<String> items;
}

/// Shared layout for long-form legal documents.
class LegalDocumentScaffold extends StatelessWidget {
  const LegalDocumentScaffold({
    super.key,
    required this.title,
    required this.lastUpdated,
    required this.intro,
    required this.sections,
    this.closing,
    this.contactEmail = 'Veggiicart@gmail.com',
    this.contactPhoneDisplay = '+91 8099999086',
    this.contactPhoneTel = '+918099999086',
  });

  final String title;
  final String lastUpdated;
  final List<LegalBlock> intro;
  final List<LegalSection> sections;
  final List<LegalBlock>? closing;
  final String contactEmail;
  final String contactPhoneDisplay;
  final String contactPhoneTel;

  Future<void> _launch(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.section,
      appBar: AppBar(
        backgroundColor: AppColors.section,
        elevation: 0,
        foregroundColor: AppColors.ink,
        title: Text(title, style: AppTextStyles.display(fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          Text(
            'Last Updated: $lastUpdated',
            style: AppTextStyles.body(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 18),
          for (final block in intro) ...[
            _LegalBlockView(block: block),
            const SizedBox(height: 12),
          ],
          for (final section in sections) ...[
            const SizedBox(height: 8),
            Text(
              section.title,
              style: AppTextStyles.display(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.forest,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < section.blocks.length; i++) ...[
              _LegalBlockView(block: section.blocks[i]),
              if (i < section.blocks.length - 1) const SizedBox(height: 10),
            ],
            const SizedBox(height: 18),
          ],
          if (closing != null) ...[
            for (final block in closing!) ...[
              _LegalBlockView(block: block),
              const SizedBox(height: 12),
            ],
          ],
          const SizedBox(height: 8),
          _ContactCard(
            email: contactEmail,
            phoneDisplay: contactPhoneDisplay,
            onEmail: () => _launch(Uri(
              scheme: 'mailto',
              path: contactEmail,
            )),
            onPhone: () => _launch(Uri(scheme: 'tel', path: contactPhoneTel)),
          ),
        ],
      ),
    );
  }
}

class _LegalBlockView extends StatelessWidget {
  const _LegalBlockView({required this.block});

  final LegalBlock block;

  @override
  Widget build(BuildContext context) {
    return switch (block) {
      LegalParagraph(:final text) => LegalRichText(text: text),
      LegalBullets(:final items) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < items.length; i++) ...[
              _BulletRow(text: items[i]),
              if (i < items.length - 1) const SizedBox(height: 8),
            ],
          ],
        ),
    };
  }
}

/// Renders body copy with optional `**bold**` markers.
class LegalRichText extends StatelessWidget {
  const LegalRichText({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final base = AppTextStyles.body(
      fontSize: 13.5,
      color: AppColors.ink,
      height: 1.5,
    );
    final bold = base.copyWith(fontWeight: FontWeight.w700);

    final spans = <TextSpan>[];
    final re = RegExp(r'\*\*(.+?)\*\*');
    var start = 0;
    for (final match in re.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      spans.add(TextSpan(text: match.group(1), style: bold));
      start = match.end;
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return Text.rich(TextSpan(style: base, children: spans));
  }
}

class _BulletRow extends StatelessWidget {
  const _BulletRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.forest,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: LegalRichText(text: text)),
      ],
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.email,
    required this.phoneDisplay,
    required this.onEmail,
    required this.onPhone,
  });

  final String email;
  final String phoneDisplay;
  final VoidCallback onEmail;
  final VoidCallback onPhone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.greenSoft,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Veggiicart',
            style: AppTextStyles.body(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.forest,
            ),
          ),
          const SizedBox(height: 12),
          _ContactLinkRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: email,
            onTap: onEmail,
          ),
          const SizedBox(height: 10),
          _ContactLinkRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: phoneDisplay,
            onTap: onPhone,
          ),
        ],
      ),
    );
  }
}

class _ContactLinkRow extends StatelessWidget {
  const _ContactLinkRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.green),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.label(
                      fontSize: 10,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: AppTextStyles.body(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.green,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.open_in_new_rounded, size: 14, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
