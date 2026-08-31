import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/ui/app_motion.dart';
import '../../../core/ui/pressable_scale.dart';
import '../../../models/saved_address.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../viewmodels/address_view_model.dart';
import '../screens/account/addresses_screen.dart';

Future<void> showLocationPickerSheet(BuildContext context) {
  final hostContext = context;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return _LocationPickerSheet(hostContext: hostContext);
    },
  );
}

class _LocationPickerSheet extends StatelessWidget {
  const _LocationPickerSheet({required this.hostContext});

  final BuildContext hostContext;

  @override
  Widget build(BuildContext context) {
    final addresses = context.watch<AddressViewModel>();
    final bottom = MediaQuery.paddingOf(context).bottom;
    final hasSaved = addresses.addresses.isNotEmpty;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Delivering to', style: AppTextStyles.display(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            hasSaved
                ? 'Choose a saved address or detect your current location'
                : 'Add a delivery address to continue, or detect your current location',
            style: AppTextStyles.body(fontSize: 13, color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          if (!hasSaved &&
              !addresses.isDetectingLocation &&
              addresses.detectedLocation == null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'No saved addresses yet',
                style: AppTextStyles.body(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                ),
              ),
            ),
          if (addresses.isDetectingLocation)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Detecting your location…',
                    style: AppTextStyles.body(fontSize: 13, color: AppColors.muted),
                  ),
                ],
              ),
            ),
          if (addresses.detectedLocation != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _CurrentLocationTile(
                label: addresses.detectedLocation!.displayLabel,
                selected: addresses.defaultAddress == null,
                onTap: () => Navigator.pop(context),
              ),
            )
          else if (!addresses.isDetectingLocation)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _DetectLocationButton(
                onTap: () => context.read<AddressViewModel>().detectCurrentLocation(),
              ),
            ),
          if (hasSaved)
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: addresses.addresses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final a = addresses.addresses[index];
                  return _AddressTile(
                    address: a,
                    selected: a.isDefault,
                    onTap: () {
                      context.read<AddressViewModel>().setDefault(a.id);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            )
          else
            const SizedBox(height: 4),
          const SizedBox(height: 12),
          PressableScale(
            onTap: () {
              Navigator.of(context).pop();
              AppPageRoute.push(hostContext, const AddressesScreen(openAddOnMount: true));
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.pill),
                border: Border.all(color: AppColors.violet),
              ),
              alignment: Alignment.center,
              child: Text(
                'Add new address',
                style: AppTextStyles.body(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.violet,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.12, end: 0, duration: 320.ms, curve: Curves.easeOutBack);
  }
}

class _DetectLocationButton extends StatelessWidget {
  const _DetectLocationButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.section,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            const Icon(Icons.my_location_rounded, color: AppColors.violet),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detect current location',
                    style: AppTextStyles.body(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Uses GPS only when you tap this',
                    style: AppTextStyles.body(fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class _CurrentLocationTile extends StatelessWidget {
  const _CurrentLocationTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.greenSoft : AppColors.section,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: selected ? AppColors.violet : AppColors.line),
        ),
        child: Row(
          children: [
            const Icon(Icons.my_location_rounded, color: AppColors.violet),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current location',
                    style: AppTextStyles.body(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded, color: AppColors.violet, size: 20),
          ],
        ),
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile({
    required this.address,
    required this.selected,
    required this.onTap,
  });

  final SavedAddress address;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.greenSoft : AppColors.section,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: selected ? AppColors.violet : AppColors.line),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on_rounded,
              color: selected ? AppColors.violet : AppColors.muted,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.label,
                    style: AppTextStyles.body(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    address.fullAddress,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded, color: AppColors.violet, size: 20),
          ],
        ),
      ),
    );
  }
}
