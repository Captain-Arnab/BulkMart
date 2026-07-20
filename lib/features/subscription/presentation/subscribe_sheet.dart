import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/repositories/subscription_repository.dart';

/// Bottom sheet: pick a subscription plan + start date, then create via API.
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
  final _repo = ApiSubscriptionRepository();
  List<Map<String, dynamic>> _plans = [];
  Map<String, dynamic>? _selected;
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await _repo.getSubscriptionPlans();
    if (!mounted) return;
    if (result is ApiFailure<List<Map<String, dynamic>>>) {
      setState(() {
        _loading = false;
        _error = result.message;
      });
      return;
    }
    final plans =
        (result as ApiSuccess<List<Map<String, dynamic>>>).data;
    setState(() {
      _plans = plans;
      _selected = plans.isNotEmpty ? plans.first : null;
      _loading = false;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _confirm() async {
    final plan = _selected;
    if (plan == null) return;
    final planId = plan['id']?.toString() ?? plan['plan_id']?.toString() ?? '';
    if (planId.isEmpty) {
      await SweetAlert.error(context, message: 'Invalid plan selected');
      return;
    }

    setState(() => _submitting = true);
    final result = await _repo.createSubscription(
      planId: planId,
      productId: widget.productId,
      startDate: DateFormat('yyyy-MM-dd').format(_startDate),
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (result is ApiFailure<SubscriptionCreateData>) {
      await SweetAlert.error(context, message: result.message);
      return;
    }

    final data = (result as ApiSuccess<SubscriptionCreateData>).data;
    Navigator.pop(context);
    if (!mounted) return;

    final details = [
      if (data.subscriptionId.isNotEmpty) 'ID: ${data.subscriptionId}',
      if (data.totalDeliveries.isNotEmpty)
        'Deliveries: ${data.totalDeliveries}',
      if (data.startDate.isNotEmpty) 'Start: ${data.startDate}',
      if (data.endDate.isNotEmpty) 'End: ${data.endDate}',
    ].join('\n');

    await SweetAlert.success(
      context,
      title: 'Subscribed',
      message: details.isNotEmpty ? details : data.message,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
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
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rubik(color: Colors.red.shade600),
                    ),
                    TextButton(onPressed: _loadPlans, child: const Text('Retry')),
                  ],
                ),
              )
            else if (_plans.isEmpty)
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
                  itemCount: _plans.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final plan = _plans[index];
                    final selected = identical(plan, _selected) ||
                        plan['id']?.toString() ==
                            _selected?['id']?.toString();
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
                        onTap: () => setState(() => _selected = plan),
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
                  DateFormat('dd MMM yyyy').format(_startDate),
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
                  onPressed: _submitting || _selected == null
                      ? null
                      : _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _submitting
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
