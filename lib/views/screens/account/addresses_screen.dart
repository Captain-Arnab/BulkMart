import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/ui/app_motion.dart';
import '../../../core/ui/pressable_scale.dart';
import '../../../models/saved_address.dart';
import '../../../services/location_service.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../viewmodels/address_view_model.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/auth_widgets.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddressViewModel>();

    return Scaffold(
      backgroundColor: AppColors.section,
      appBar: AppBar(
        backgroundColor: AppColors.section,
        elevation: 0,
        foregroundColor: AppColors.ink,
        title: Text('Saved Addresses', style: AppTextStyles.display(fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          ...List.generate(vm.addresses.length, (index) {
            final address = vm.addresses[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Dismissible(
                key: ValueKey(address.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                      ),
                      title: Text('Delete address?', style: AppTextStyles.display(fontSize: 18)),
                      content: Text(
                        'Remove ${address.label} from your saved addresses?',
                        style: AppTextStyles.body(color: AppColors.muted),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text('Cancel', style: AppTextStyles.body(color: AppColors.muted)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(
                            'Delete',
                            style: AppTextStyles.body(
                              fontWeight: FontWeight.w700,
                              color: AppColors.alert,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                  return ok == true;
                },
                onDismissed: (_) {
                  context.read<AddressViewModel>().remove(address.id);
                  showAppSuccessSnackBar(
                    context,
                    message: 'Address deleted — Undo',
                    duration: const Duration(seconds: 4),
                    action: SnackBarAction(
                      label: 'Undo',
                      textColor: AppColors.white,
                      onPressed: () => context.read<AddressViewModel>().undoDelete(),
                    ),
                  );
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: AppColors.alert.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                  ),
                  child: const Icon(Icons.delete_outline_rounded, color: AppColors.alert),
                ),
                child: _AddressCard(
                  address: address,
                  onEdit: () => _openSheet(context, address: address),
                  onDelete: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                        ),
                        title: Text('Delete address?', style: AppTextStyles.display(fontSize: 18)),
                        content: Text(
                          'Remove ${address.label} from your saved addresses?',
                          style: AppTextStyles.body(color: AppColors.muted),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(
                              'Delete',
                              style: AppTextStyles.body(
                                fontWeight: FontWeight.w700,
                                color: AppColors.alert,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (ok != true || !context.mounted) return;
                    context.read<AddressViewModel>().remove(address.id);
                    showAppSuccessSnackBar(
                      context,
                      message: 'Address deleted — Undo',
                      duration: const Duration(seconds: 4),
                      action: SnackBarAction(
                        label: 'Undo',
                        textColor: AppColors.white,
                        onPressed: () => context.read<AddressViewModel>().undoDelete(),
                      ),
                    );
                  },
                ),
              )
                  .animate()
                  .fadeIn(delay: (60 * index).ms, duration: 220.ms)
                  .slideY(begin: 0.1, end: 0, delay: (60 * index).ms),
            );
          }),
          PressableScale(
            onTap: () => _openSheet(context),
            child: CustomPaint(
              painter: _DashedRRectPainter(
                color: AppColors.violet.withValues(alpha: 0.45),
                radius: AppRadii.lg,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 22),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_rounded, color: AppColors.violet, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Add New Address',
                      style: AppTextStyles.body(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.violet,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(delay: (60 * vm.addresses.length).ms, duration: 220.ms),
        ],
      ),
    );
  }

  Future<void> _openSheet(BuildContext context, {SavedAddress? address}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddressSheet(existing: address),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
  });

  final SavedAddress address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text(
                  address.label,
                  style: AppTextStyles.body(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
              if (address.isDefault) ...[
                const SizedBox(width: 8),
                Text(
                  'Default',
                  style: AppTextStyles.body(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.violet,
                  ),
                ),
              ],
              const Spacer(),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.muted),
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.alert),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            address.fullAddress,
            style: AppTextStyles.body(fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _AddressSheet extends StatefulWidget {
  const _AddressSheet({this.existing});

  final SavedAddress? existing;

  @override
  State<_AddressSheet> createState() => _AddressSheetState();
}

class _AddressSheetState extends State<_AddressSheet> {
  static const _labels = ['Home', 'Warehouse', 'Shop'];

  late final TextEditingController _line1;
  late final TextEditingController _line2;
  late final TextEditingController _city;
  late final TextEditingController _pincode;
  late String _label;
  late bool _isDefault;
  late String _state;
  double? _geoLat;
  double? _geoLng;
  bool _fetchingLocation = false;
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _label = e?.label ?? 'Shop';
    _isDefault = e?.isDefault ?? false;
    _state = e?.state ?? '';
    _geoLat = e?.geoLat;
    _geoLng = e?.geoLng;
    _line1 = TextEditingController(text: e?.line1 ?? '');
    _line2 = TextEditingController(text: e?.line2 ?? '');
    _city = TextEditingController(text: e?.city ?? '');
    _pincode = TextEditingController(text: e?.pincode ?? '');
  }

  bool get _hasGeo => _geoLat != null && _geoLng != null;

  Future<void> _fetchCurrentLocation() async {
    setState(() => _fetchingLocation = true);
    try {
      final details = await _locationService.detectAddressFromCurrentLocation();
      if (!mounted) return;
      if (details == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not get location. Allow location permission and try again.',
            ),
          ),
        );
        return;
      }
      _line1.text = details.line1;
      _line2.text = details.line2 ?? '';
      _city.text = details.city;
      _pincode.text = details.pincode;
      _state = details.state;
      _geoLat = details.latitude;
      _geoLng = details.longitude;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not fetch location: $e')),
      );
    } finally {
      if (mounted) setState(() => _fetchingLocation = false);
    }
  }

  @override
  void dispose() {
    _line1.dispose();
    _line2.dispose();
    _city.dispose();
    _pincode.dispose();
    super.dispose();
  }

  bool get _valid =>
      _line1.text.trim().isNotEmpty &&
      _city.text.trim().isNotEmpty &&
      _pincode.text.trim().length == 6;

  void _save() {
    final address = SavedAddress(
      id: widget.existing?.id ?? 'a_${DateTime.now().millisecondsSinceEpoch}',
      label: _label,
      line1: _line1.text.trim(),
      line2: _line2.text.trim().isEmpty ? null : _line2.text.trim(),
      city: _city.text.trim(),
      state: _state,
      pincode: _pincode.text.trim(),
      geoLat: _geoLat,
      geoLng: _geoLng,
      isDefault: _isDefault,
    );
    context.read<AddressViewModel>().upsert(address);
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          widget.existing == null ? 'Address added' : 'Address updated',
          style: AppTextStyles.body(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPadding(
      duration: AppMotion.fast,
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + MediaQuery.paddingOf(context).bottom),
        child: SingleChildScrollView(
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
              Text(
                widget.existing == null ? 'Add Address' : 'Edit Address',
                style: AppTextStyles.display(fontSize: 20),
              ),
              const SizedBox(height: 16),
              Text(
                'LABEL',
                style: AppTextStyles.label(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _labels.map((l) {
                  final selected = l == _label;
                  return PressableScale(
                    onTap: () => setState(() => _label = l),
                    child: AnimatedContainer(
                      duration: AppMotion.fast,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.accent : AppColors.section,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                      child: Text(
                        l,
                        style: AppTextStyles.body(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              PressableScale(
                onTap: _fetchingLocation ? null : _fetchCurrentLocation,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.greenSoft,
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.my_location_rounded,
                        color: _hasGeo ? AppColors.success : AppColors.violet,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Use current location',
                              style: AppTextStyles.body(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _fetchingLocation
                                  ? 'Fetching GPS & address…'
                                  : _hasGeo
                                      ? 'Location captured — review fields below'
                                      : 'Auto-fill address from your device GPS',
                              style: AppTextStyles.body(
                                fontSize: 11,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_fetchingLocation)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.violet,
                          ),
                        )
                      else if (_hasGeo)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                          ),
                          child: Text(
                            'Captured',
                            style: AppTextStyles.body(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const AuthFieldLabel('Address line 1'),
              const SizedBox(height: 8),
              PillTextField(
                controller: _line1,
                hint: 'Street, building, landmark',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),
              const AuthFieldLabel('Address line 2', optional: true),
              const SizedBox(height: 8),
              PillTextField(
                controller: _line2,
                hint: 'Floor, suite, notes',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),
              const AuthFieldLabel('City'),
              const SizedBox(height: 8),
              PillTextField(
                controller: _city,
                hint: 'City',
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),
              const AuthFieldLabel('Pincode'),
              const SizedBox(height: 8),
              PillTextField(
                controller: _pincode,
                hint: '6-digit pincode',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Set as default',
                      style: AppTextStyles.body(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Switch(
                    value: _isDefault,
                    activeColor: AppColors.violet,
                    onChanged: (v) => setState(() => _isDefault = v),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AuthPrimaryButton(
                label: widget.existing == null ? 'Save Address' : 'Update Address',
                enabled: _valid,
                onPressed: _save,
              ),
            ],
          ),
        ),
      )
          .animate()
          .slideY(begin: 0.15, end: 0, duration: 320.ms, curve: Curves.easeOutBack)
          .fadeIn(duration: 200.ms),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + 6;
        canvas.drawPath(metric.extractPath(distance, next.clamp(0, metric.length)), paint);
        distance += 12;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
