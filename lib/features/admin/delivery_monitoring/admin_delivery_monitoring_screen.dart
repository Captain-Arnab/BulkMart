import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/async_views.dart';
import 'package:urban_roots/features/admin/controllers/admin_delivery_monitoring_controller.dart';
import 'package:urban_roots/features/admin/delivery_attendance/admin_delivery_attendance_screen.dart';
import 'package:urban_roots/features/admin/models/admin_models.dart';

class AdminDeliveryMonitoringScreen extends StatefulWidget {
  const AdminDeliveryMonitoringScreen({super.key});

  @override
  State<AdminDeliveryMonitoringScreen> createState() =>
      _AdminDeliveryMonitoringScreenState();
}

class _AdminDeliveryMonitoringScreenState
    extends State<AdminDeliveryMonitoringScreen> {
  late final AdminDeliveryMonitoringController c;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    c = Get.put(AdminDeliveryMonitoringController());
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    Get.delete<AdminDeliveryMonitoringController>();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: c.selectedDate.value ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null) c.setDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Text('Delivery Monitoring',
            style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: c.load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Obx(() {
              if (c.isLoading.value && c.boys.isEmpty) {
                return const LoadingView(label: 'Loading...');
              }
              if (c.errorMessage.value.isNotEmpty && c.boys.isEmpty) {
                return FailureView(
                    message: c.errorMessage.value, onRetry: c.load);
              }
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: c.load,
                child: c.boys.isEmpty
                    ? const EmptyView(
                        icon: Icons.delivery_dining_outlined,
                        message: 'No delivery boys',
                        subtitle: 'No records for this date.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: c.boys.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _BoyCard(
                          boy: c.boys[i],
                          onTap: () => _openAttendance(c.boys[i]),
                        ),
                      ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _openAttendance(DeliveryMonitorItem boy) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminDeliveryAttendanceScreen(
          deliveryBoyId: boy.deliveryBoyId,
          deliveryBoyName: boy.name,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Obx(
            () => InkWell(
              onTap: _pickDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Text(
                      c.selectedDate.value != null
                          ? DateFormat('EEE, dd MMM yyyy')
                              .format(c.selectedDate.value!)
                          : 'Select date',
                      style: GoogleFonts.rubik(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    const Icon(Icons.keyboard_arrow_down_rounded),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: _summaryChip(
                    'Active',
                    c.activeCount.toString(),
                    AppColors.primary,
                    Icons.online_prediction_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _summaryChip(
                    'Inactive',
                    c.inactiveCount.toString(),
                    Colors.grey,
                    Icons.power_settings_new_rounded,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: GoogleFonts.rubik(
                      fontSize: 20, fontWeight: FontWeight.w800, color: color)),
              Text(label,
                  style:
                      GoogleFonts.rubik(fontSize: 12, color: AppColors.hint)),
            ],
          ),
        ],
      ),
    );
  }
}

class _BoyCard extends StatelessWidget {
  const _BoyCard({required this.boy, required this.onTap});

  final DeliveryMonitorItem boy;
  final VoidCallback onTap;

  String _liveDuration() {
    final start = DateTime.tryParse('${boy.date} ${boy.clockIn}');
    if (start == null) return '--:--:--';
    final d = DateTime.now().difference(start);
    if (d.isNegative) return '00:00:00';
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final working = boy.isCurrentlyWorking;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    boy.name,
                    style: GoogleFonts.rubik(
                        fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
                StatusBadge.forStatus(boy.isActive ? 'Active' : 'Inactive'),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right_rounded, color: AppColors.hint),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _block('Clock In', boy.clockIn)),
                Expanded(
                  child: working
                      ? _block('Working', _liveDuration(),
                          color: AppColors.primary)
                      : _block('Clock Out',
                          boy.clockOut.isEmpty ? '--' : boy.clockOut),
                ),
                Expanded(
                  child: _block(
                    'Total',
                    boy.totalHours.isEmpty ? '--' : '${boy.totalHours}h',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _block(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.rubik(fontSize: 11, color: AppColors.hint)),
        const SizedBox(height: 2),
        Text(
          value.isEmpty ? '--' : value,
          style: GoogleFonts.rubik(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
