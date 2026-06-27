import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/features/delivery/controllers/delivery_dashboard_controller.dart';

class DeliveryDashboardScreen extends StatefulWidget {
  const DeliveryDashboardScreen({super.key});

  @override
  State<DeliveryDashboardScreen> createState() =>
      _DeliveryDashboardScreenState();
}

class _DeliveryDashboardScreenState extends State<DeliveryDashboardScreen> {
  late final DeliveryDashboardController c;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    c = Get.put(DeliveryDashboardController());
    // Rebuild every second so the live session timer updates.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Text('Delivery Dashboard',
            style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Obx(() {
        final clockedIn = c.isClockedIn.value;
        final start = c.clockInTime.value;
        final session =
            start != null ? DateTime.now().difference(start) : Duration.zero;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: clockedIn
                      ? [AppColors.primary, AppColors.primaryDark]
                      : [const Color(0xFF455A64), const Color(0xFF263238)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Icon(
                    clockedIn
                        ? Icons.access_time_filled_rounded
                        : Icons.bedtime_outlined,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    clockedIn ? 'You are Clocked In' : 'You are Clocked Out',
                    style: GoogleFonts.rubik(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (clockedIn && start != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Since ${DateFormat('hh:mm a').format(start)}',
                      style: GoogleFonts.rubik(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _formatDuration(session),
                      style: GoogleFonts.rubik(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor:
                      clockedIn ? const Color(0xFFD32F2F) : AppColors.primary,
                ),
                onPressed: c.isProcessing.value ? null : c.toggleClock,
                icon: c.isProcessing.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(clockedIn
                        ? Icons.logout_rounded
                        : Icons.login_rounded),
                label: Text(
                  clockedIn ? 'Clock Out' : 'Clock In',
                  style: GoogleFonts.rubik(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            if (!clockedIn && c.lastSessionHours.value != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMint,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded,
                        color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Today's last session: ${c.lastSessionHours.value} hours worked",
                        style: GoogleFonts.rubik(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      }),
    );
  }
}
