import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/features/cart/cart_controller.dart';
import 'package:urban_roots/features/cart/models/available_coupon.dart';

/// Shows applicable coupons (and promo offers) without autofocusing the
/// keyboard — the old AlertDialog + soft keyboard path ANR'd on emulator.
Future<void> showApplyCouponSheet({
  required BuildContext context,
  required CartController cart,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (_) => ApplyCouponSheet(
      cart: cart,
      hostContext: context,
    ),
  );
}

class ApplyCouponSheet extends StatefulWidget {
  const ApplyCouponSheet({
    super.key,
    required this.cart,
    required this.hostContext,
  });

  final CartController cart;
  final BuildContext hostContext;

  @override
  State<ApplyCouponSheet> createState() => _ApplyCouponSheetState();
}

class _ApplyCouponSheetState extends State<ApplyCouponSheet> {
  final _codeController = TextEditingController();
  List<AvailableCoupon> _coupons = const [];
  bool _loadingList = true;
  bool _applying = false;
  String? _listError;
  String? _fieldError;

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadCoupons() async {
    setState(() {
      _loadingList = true;
      _listError = null;
    });
    try {
      final coupons = await widget.cart.fetchAvailableCoupons();
      if (!mounted) return;
      setState(() {
        _coupons = coupons;
        _loadingList = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingList = false;
        _listError = 'Could not load coupons. You can still enter a code.';
      });
    }
  }

  Future<void> _apply(String rawCode) async {
    final code = rawCode.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _fieldError = 'Enter a coupon code');
      return;
    }
    if (_applying) return;

    setState(() {
      _applying = true;
      _fieldError = null;
    });

    final result = await widget.cart.applyCoupon(code);
    if (!mounted) return;

    setState(() => _applying = false);

    if (result is ApiFailure<Map<String, dynamic>>) {
      setState(() => _fieldError = result.message);
      return;
    }

    Navigator.pop(context);
    final host = widget.hostContext;
    if (!host.mounted) return;
    await SweetAlert.success(host, message: 'Coupon "$code" applied');
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Apply Coupon',
                        style: GoogleFonts.rubik(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _applying ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Pick a coupon below or enter a code',
                  style: GoogleFonts.rubik(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _codeController,
                        // Critical: do NOT autofocus — IME open on janky UI caused ANR.
                        autofocus: false,
                        textCapitalization: TextCapitalization.characters,
                        autocorrect: false,
                        enableSuggestions: false,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[A-Za-z0-9_\-]'),
                          ),
                        ],
                        onChanged: (_) {
                          if (_fieldError != null) {
                            setState(() => _fieldError = null);
                          }
                        },
                        onSubmitted: _applying ? null : _apply,
                        decoration: InputDecoration(
                          hintText: 'Enter coupon code',
                          hintStyle: GoogleFonts.rubik(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          errorText: _fieldError,
                          errorMaxLines: 2,
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          prefixIcon: const Icon(
                            Icons.local_offer_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _applying
                            ? null
                            : () => _apply(_codeController.text),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _applying
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Apply',
                                style: GoogleFonts.rubik(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Available coupons',
                  style: GoogleFonts.rubik(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildCouponList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCouponList() {
    if (_loadingList) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_listError != null && _coupons.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _listError!,
                textAlign: TextAlign.center,
                style: GoogleFonts.rubik(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              TextButton(onPressed: _loadCoupons, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_coupons.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No coupons available right now.\nEnter a code above if you have one.',
            textAlign: TextAlign.center,
            style: GoogleFonts.rubik(color: Colors.grey.shade600, height: 1.4),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      itemCount: _coupons.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final coupon = _coupons[index];
        return _CouponTile(
          coupon: coupon,
          enabled: !_applying,
          onApply: () => _apply(coupon.code),
        );
      },
    );
  }
}

class _CouponTile extends StatelessWidget {
  const _CouponTile({
    required this.coupon,
    required this.onApply,
    required this.enabled,
  });

  final AvailableCoupon coupon;
  final VoidCallback onApply;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onApply : null,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_offer_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coupon.displayTitle,
                        style: GoogleFonts.rubik(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        coupon.code,
                        style: GoogleFonts.rubik(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                          color: AppColors.primary,
                        ),
                      ),
                      if (coupon.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          coupon.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.rubik(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Apply',
                  style: GoogleFonts.rubik(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: enabled ? AppColors.primary : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
