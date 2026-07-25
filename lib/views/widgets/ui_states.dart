import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/ui/app_motion.dart';
import '../../core/ui/pressable_scale.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import 'primary_button.dart';

class CatalogShimmer extends StatelessWidget {
  const CatalogShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.paper2,
      highlightColor: AppColors.white,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.paper2,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.md)),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 12, width: double.infinity, color: AppColors.paper2),
                      const SizedBox(height: 8),
                      Container(height: 10, width: 72, color: AppColors.paper2),
                      const Spacer(),
                      Container(height: 12, width: 56, color: AppColors.paper2),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: AppColors.rust),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body(color: AppColors.slate),
            ),
            const SizedBox(height: 16),
            PressableScale(
              onTap: onRetry,
              child: Text(
                'Retry',
                style: AppTextStyles.body(
                  fontWeight: FontWeight.w700,
                  color: AppColors.forest,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inventory_2_outlined,
    this.lottieAsset,
    this.ctaLabel,
    this.onCta,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final String? lottieAsset;
  final String? ctaLabel;
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (lottieAsset != null)
              SizedBox(
                height: 140,
                child: Lottie.asset(
                  lottieAsset!,
                  repeat: true,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    icon,
                    size: 56,
                    color: AppColors.slate.withValues(alpha: 0.45),
                  ),
                ),
              )
            else
              Icon(icon, size: 48, color: AppColors.slate.withValues(alpha: 0.45)),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.display(fontSize: 18),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: AppTextStyles.body(color: AppColors.slate, height: 1.45),
              ),
            ],
            if (ctaLabel != null && onCta != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: 200,
                child: PrimaryButton(label: ctaLabel!, onPressed: onCta, expand: true),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.kind});

  final String label;
  final StatusPillKind kind;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (kind) {
      StatusPillKind.success => (AppColors.success, AppColors.white),
      StatusPillKind.info => (AppColors.violet, AppColors.white),
      StatusPillKind.warning => (AppColors.accent, AppColors.ink),
      StatusPillKind.danger => (AppColors.alert, AppColors.white),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label,
        style: AppTextStyles.body(fontSize: 10, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }
}

enum StatusPillKind { success, info, warning, danger }
