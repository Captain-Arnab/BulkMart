import 'package:flutter/material.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/data/dummy_data.dart';
import 'package:urban_roots/features/payments/presentation/PhonePePaymentScreen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  @override
  Widget build(BuildContext context) {
    final active = DummyData.activeSubscription;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text('Subscriptions', style: GoogleFonts.rubik(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (active != null) ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF019934), Color(0xFF01752A)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified, color: Colors.white, size: 22),
                      const SizedBox(width: 8),
                      Text('Active Plan', style: GoogleFonts.rubik(fontSize: 13, color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(active['planName'] ?? '', style: GoogleFonts.rubik(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(
                    'Renews on ${active['renewalDate']} • ₹${active['price']}/mo',
                    style: GoogleFonts.rubik(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Upgrade or Change Plan', style: GoogleFonts.rubik(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
          ] else ...[
            Text('Choose a Plan', style: GoogleFonts.rubik(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Subscribe for regular deliveries of fresh organic groceries.',
              style: GoogleFonts.rubik(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
          ],
          ...DummyData.subscriptionPlans.map((plan) => _planCard(context, plan)),
        ],
      ),
    );
  }

  Widget _planCard(BuildContext context, Map<String, dynamic> plan) {
    final popular = plan['popular'] == true;
    final features = (plan['features'] as List).cast<String>();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: popular ? Border.all(color: const Color(0xFF019934), width: 2) : null,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(plan['name'] ?? '', style: GoogleFonts.rubik(fontSize: 18, fontWeight: FontWeight.w700)),
                ),
                if (popular)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFF019934), borderRadius: BorderRadius.circular(20)),
                    child: Text('Popular', style: GoogleFonts.rubik(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(plan['description'] ?? '', style: GoogleFonts.rubik(fontSize: 13, color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            Text(
              '₹${plan['price']} / ${plan['duration']}',
              style: GoogleFonts.rubik(fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFF019934)),
            ),
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF019934),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => _subscribe(context, plan),
                child: Text('Subscribe via PhonePe', style: GoogleFonts.rubik(fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _subscribe(BuildContext context, Map<String, dynamic> plan) {
    final price = (plan['price'] as num).toDouble();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PhonePePaymentScreen(
          amount: price,
          title: plan['name'] ?? 'Subscription',
          subtitle: '${plan['duration']} subscription — Urban Roots',
          showSuccessScreen: false,
          onSuccess: () {
            setState(() {
              DummyData.activeSubscription = {
                'planId': plan['id'],
                'planName': plan['name'],
                'price': plan['price'],
                'renewalDate': '2026-06-20',
                'status': 'Active',
              };
            });
            SweetAlert.success(context, message: 'Subscribed to ${plan['name']} via PhonePe!');
          },
        ),
      ),
    );
  }
}
