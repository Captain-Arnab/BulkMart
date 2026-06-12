import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/Utils/Loader.dart';
import 'package:urban_roots/core/ui/api_view_state.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart';
import 'package:urban_roots/features/subscription/domain/subscription_controller.dart';
import 'package:urban_roots/features/wallet/presentation/wallet_payment_webview.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final _controller = Get.put(SubscriptionController());

  Future<void> _subscribe(Map<String, dynamic> plan) async {
    Loader.show(context);
    final result = await _controller.subscribe(plan);
    if (mounted) Loader.hide(context);

    if (!mounted) return;

    if (!result.success) {
      await SweetAlert.error(context, message: result.message);
      return;
    }

    final paymentUrl = result.paymentUrl;
    if (paymentUrl != null && paymentUrl.isNotEmpty) {
      final paid = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => WalletPaymentWebView(
            paymentUrl: paymentUrl,
            amount: (plan['price'] as num?)?.toDouble() ?? 0,
          ),
        ),
      );
      if (!mounted) return;
      await _controller.loadStatus();
      if (paid == true) {
        await SweetAlert.success(context, message: result.message);
      }
      return;
    }

    await SweetAlert.success(context, message: result.message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          'Subscriptions',
          style: GoogleFonts.rubik(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF019934)),
          );
        }

        if (_controller.errorMessage.value.isNotEmpty &&
            _controller.plans.isEmpty) {
          return ApiStateView(
            status: ApiViewStatus.error,
            errorMessage: _controller.errorMessage.value,
            onRetry: _controller.load,
            child: const SizedBox.shrink(),
          );
        }

        final active = _controller.activeSubscription.value;

        return RefreshIndicator(
          color: const Color(0xFF019934),
          onRefresh: _controller.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              if (active != null) ...[
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF019934), Color(0xFF01752A)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.verified, color: Colors.white, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Active Plan',
                            style: GoogleFonts.rubik(fontSize: 13, color: Colors.white70),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        active['planName']?.toString() ?? '',
                        style: GoogleFonts.rubik(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _activePlanSubtitle(active),
                        style: GoogleFonts.rubik(fontSize: 13, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Upgrade or Change Plan',
                  style: GoogleFonts.rubik(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
              ] else ...[
                Text(
                  'Choose a Plan',
                  style: GoogleFonts.rubik(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Subscribe for regular deliveries of fresh organic groceries.',
                  style: GoogleFonts.rubik(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
              ],
              if (_controller.plans.isEmpty)
                ApiStateView(
                  status: ApiViewStatus.empty,
                  emptyMessage: 'No subscription plans available',
                  onRetry: _controller.load,
                  child: const SizedBox.shrink(),
                )
              else
                ..._controller.plans.map((plan) => _planCard(context, plan)),
            ],
          ),
        );
      }),
    );
  }

  String _activePlanSubtitle(Map<String, dynamic> active) {
    final renewal = active['renewalDate']?.toString() ?? '';
    final price = active['price']?.toString() ?? '';
    if (renewal.isNotEmpty && price.isNotEmpty && price != '0') {
      return 'Renews on $renewal • ₹$price';
    }
    if (renewal.isNotEmpty) return 'Renews on $renewal';
    if (price.isNotEmpty && price != '0') return '₹$price';
    return active['status']?.toString() ?? 'Active';
  }

  String _planPriceLabel(Map<String, dynamic> plan) {
    final priceRaw = plan['price'];
    final price = priceRaw is num
        ? priceRaw.toDouble()
        : double.tryParse(priceRaw?.toString() ?? '') ?? 0;
    final duration = plan['duration']?.toString().trim() ?? '';

    if (price > 0 && duration.isNotEmpty) {
      return '₹${price.toStringAsFixed(0)} / $duration';
    }
    if (price > 0) {
      return '₹${price.toStringAsFixed(0)}';
    }

    final type = plan['subscription_type']?.toString() ?? '';
    if (type.isNotEmpty) {
      return type[0].toUpperCase() + type.substring(1);
    }
    return plan['name']?.toString() ?? 'Plan';
  }

  String _planPriceSubtitle(Map<String, dynamic> plan) {
    final priceRaw = plan['price'];
    final price = priceRaw is num
        ? priceRaw.toDouble()
        : double.tryParse(priceRaw?.toString() ?? '') ?? 0;
    final duration = plan['duration']?.toString().trim() ?? '';
    final days = plan['duration_days']?.toString() ?? '';
    final weeklyDays = plan['weekly_days']?.toString() ?? '';

    if (price <= 0) {
      if (days.isNotEmpty) return 'Price set at checkout • $days day plan';
      return 'Price set at checkout';
    }
    if (duration.isEmpty && days.isNotEmpty) {
      return '$days day plan';
    }
    if (weeklyDays.isNotEmpty) {
      return 'Deliveries on $weeklyDays';
    }
    return '';
  }

  Widget _planCard(BuildContext context, Map<String, dynamic> plan) {
    final popular = plan['popular'] == true;
    final features = (plan['features'] as List?)?.cast<String>() ?? const [];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: popular ? Border.all(color: const Color(0xFF019934), width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    plan['name']?.toString() ?? '',
                    style: GoogleFonts.rubik(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                if (popular)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF019934),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Popular',
                      style: GoogleFonts.rubik(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              plan['description']?.toString() ?? '',
              style: GoogleFonts.rubik(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            Text(
              _planPriceLabel(plan),
              style: GoogleFonts.rubik(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF019934),
              ),
            ),
            if (_planPriceSubtitle(plan).isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                _planPriceSubtitle(plan),
                style: GoogleFonts.rubik(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
            const SizedBox(height: 12),
            ...features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 18, color: Color(0xFF019934)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(f, style: GoogleFonts.rubik(fontSize: 13))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF019934),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _controller.isSubscribing.value
                      ? null
                      : () => _subscribe(plan),
                  child: _controller.isSubscribing.value
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Subscribe',
                          style: GoogleFonts.rubik(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
