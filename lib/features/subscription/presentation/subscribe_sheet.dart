import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart';
import 'package:urban_roots/core/ui/ui_state.dart';
import 'package:urban_roots/data/repositories/subscription_repository.dart';
import 'package:urban_roots/features/subscription/presentation/subscription_success_screen.dart';
import 'package:urban_roots/features/subscription/subscribe_view_model.dart';
import 'package:urban_roots/features/wallet/wallet_payment_webview.dart';

/// Bottom sheet: pick a subscription plan + start date, then create via API.
/// Same visual family as Apply Coupon (drag handle, white sheet, top radius).
Future<void> showSubscribeSheet(
  BuildContext context, {
  required String productId,
  String productName = '',
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SubscribeSheet(
      productId: productId,
      productName: productName,
    ),
  );
}

class _SubscribeSheet extends StatefulWidget {
  const _SubscribeSheet({
    required this.productId,
    required this.productName,
  });

  final String productId;
  final String productName;

  @override
  State<_SubscribeSheet> createState() => _SubscribeSheetState();
}

class _SubscribeSheetState extends State<_SubscribeSheet> {
  late final SubscribeViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = SubscribeViewModel()..addListener(_onVmChanged);
    _vm.loadPlans();
  }

  @override
  void dispose() {
    _vm.removeListener(_onVmChanged);
    _vm.dispose();
    super.dispose();
  }

  void _onVmChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _vm.startDate.isBefore(_vm.minStartDate)
          ? _vm.minStartDate
          : _vm.startDate,
      firstDate: _vm.minStartDate,
      lastDate: _vm.maxStartDate,
    );
    if (picked != null) _vm.setStartDate(picked);
  }

  Future<void> _confirm() async {
    final plan = _vm.selectedPlan;
    if (plan == null) return;

    final data = await _vm.confirm(productId: widget.productId);
    if (!mounted) return;

    if (data == null) {
      final err = _vm.createState;
      final message = err is UiError<SubscriptionCreateData>
          ? err.message
          : 'Could not create subscription';
      await SweetAlert.error(context, message: message);
      return;
    }

    final planName = plan['name']?.toString() ??
        plan['plan_name']?.toString() ??
        '';

    // Capture navigator before popping the sheet (sheet context unmounts).
    final nav = Navigator.of(context);
    nav.pop();

    // Billing is charged upfront — if create.php returns a payment URL, open it.
    final paymentUrl = data.paymentUrl;
    if (paymentUrl != null && paymentUrl.isNotEmpty) {
      final amount = data.amount ??
          double.tryParse(plan['price']?.toString() ?? '') ??
          0;
      final paid = await nav.push<bool>(
        MaterialPageRoute(
          builder: (_) => WalletPaymentWebView(
            paymentUrl: paymentUrl,
            amount: amount,
            transactionId: data.transactionId ?? '',
          ),
        ),
      );
      if (paid != true) {
        // Subscription may already exist unpaid — still show confirmation
        // so the user has the subscription_id to follow up.
        await nav.push(
          MaterialPageRoute(
            builder: (_) => SubscriptionSuccessScreen(
              data: data,
              productName: widget.productName,
              planName: planName,
              paymentPending: true,
            ),
          ),
        );
        return;
      }
    }

    await nav.push(
      MaterialPageRoute(
        builder: (_) => SubscriptionSuccessScreen(
          data: data,
          productName: widget.productName,
          planName: planName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final plansState = _vm.plansState;
    final plans = plansState is UiSuccess<List<Map<String, dynamic>>>
        ? plansState.data
        : const <Map<String, dynamic>>[];
    final plansError = plansState is UiError<List<Map<String, dynamic>>>
        ? plansState.message
        : null;

    return Container(
      margin: EdgeInsets.only(bottom: bottom),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            const SizedBox(height: 16),
            Text(
              'Subscribe',
              style: GoogleFonts.rubik(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (widget.productName.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                widget.productName,
                style: GoogleFonts.rubik(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (_vm.isLoadingPlans)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (plansError != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Text(
                      plansError,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rubik(color: Colors.red.shade600),
                    ),
                    TextButton(
                      onPressed: _vm.loadPlans,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (plans.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No subscription plans available',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.rubik(color: Colors.grey.shade600),
                ),
              )
            else ...[
              Text(
                'Choose a plan',
                style: GoogleFonts.rubik(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: plans.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    final selected = identical(plan, _vm.selectedPlan) ||
                        plan['id']?.toString() ==
                            _vm.selectedPlan?['id']?.toString();
                    final name = plan['name']?.toString() ??
                        plan['plan_name']?.toString() ??
                        'Plan';
                    final price = plan['price']?.toString() ?? '';
                    final type =
                        plan['subscription_type']?.toString() ?? '';
                    return Material(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _vm.selectPlan(plan),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Icon(
                                selected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: selected
                                    ? AppColors.primary
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: GoogleFonts.rubik(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (type.isNotEmpty || price.isNotEmpty)
                                      Text(
                                        [
                                          if (type.isNotEmpty) type,
                                          if (price.isNotEmpty) '₹$price',
                                        ].join(' · '),
                                        style: GoogleFonts.rubik(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Start date',
                style: GoogleFonts.rubik(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today_outlined, size: 18),
                label: Text(
                  _vm.startDateDisplay,
                  style: GoogleFonts.rubik(fontWeight: FontWeight.w500),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.4),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _vm.isCreating || _vm.selectedPlan == null
                      ? null
                      : _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _vm.isCreating
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Confirm Subscription',
                          style: GoogleFonts.rubik(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
