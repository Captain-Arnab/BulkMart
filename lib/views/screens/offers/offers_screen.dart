import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/ui/app_motion.dart';
import '../../../core/ui/pressable_scale.dart';
import '../../../core/ui/shell_controller.dart';
import '../../../models/offer.dart';
import '../../../models/offer_style.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../viewmodels/offer_view_model.dart';
import '../../widgets/ui_states.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OfferViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OfferViewModel>();
    final dateFmt = DateFormat('d MMM yyyy');

    return Scaffold(
      backgroundColor: AppColors.section,
      appBar: AppBar(
        backgroundColor: AppColors.section,
        elevation: 0,
        foregroundColor: AppColors.ink,
        title: Text('Offers & Discounts', style: AppTextStyles.display(fontSize: 18)),
      ),
      body: vm.isLoading
          ? const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.green),
              ),
            )
          : vm.offers.isEmpty
              ? const EmptyState(
                  title: 'No offers right now',
                  subtitle: 'Check back soon for bulk discounts and seasonal deals.',
                  icon: Icons.local_offer_outlined,
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: vm.offers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final offer = vm.offers[index];
                    return _OfferCard(
                      offer: offer,
                      validLabel: 'Valid till ${dateFmt.format(offer.validUntil)}',
                      onTap: () {
                        if (offer.categoryId == null) return;
                        context.read<ShellController>().goToCategories(
                              categoryId: offer.categoryId,
                            );
                        Navigator.of(context).pop();
                      },
                    ).animate(delay: (index * 40).ms).fadeIn(duration: 220.ms).slideY(
                          begin: 0.06,
                          end: 0,
                        );
                  },
                ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.offer,
    required this.validLabel,
    required this.onTap,
  });

  final Offer offer;
  final String validLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = OfferStyle.colorsOf(offer);
    final textColor = OfferStyle.textColorOf(offer);

    return PressableScale(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: AppShadows.soft(opacity: 0.08),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: Text(
                offer.discountLabel,
                style: AppTextStyles.body(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              offer.title.replaceAll('\n', ' '),
              style: AppTextStyles.display(fontSize: 18, color: textColor, height: 1.25),
            ),
            const SizedBox(height: 8),
            Text(
              offer.subtitle,
              style: AppTextStyles.body(
                fontSize: 13,
                color: textColor.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (offer.minQty != null)
                  Text(
                    'Min qty ${offer.minQty}',
                    style: AppTextStyles.body(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: textColor.withValues(alpha: 0.85),
                    ),
                  ),
                const Spacer(),
                Text(
                  validLabel,
                  style: AppTextStyles.body(
                    fontSize: 11,
                    color: textColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
