import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/async_views.dart';
import 'package:urban_roots/features/delivery/controllers/delivery_work_log_controller.dart';
import 'package:urban_roots/features/delivery/models/delivery_models.dart';

class DeliveryWorkLogScreen extends StatefulWidget {
  const DeliveryWorkLogScreen({super.key});

  @override
  State<DeliveryWorkLogScreen> createState() => _DeliveryWorkLogScreenState();
}

class _DeliveryWorkLogScreenState extends State<DeliveryWorkLogScreen> {
  late final DeliveryWorkLogController c;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    c = Get.put(DeliveryWorkLogController());
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    Get.delete<DeliveryWorkLogController>();
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
        title: Text('Work Log',
            style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          Obx(
            () => InkWell(
              onTap: _pickDate,
              child: Container(
                margin: const EdgeInsets.all(16),
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
          Expanded(
            child: Obx(() {
              if (c.isLoading.value && c.logs.isEmpty) {
                return const LoadingView(label: 'Loading work log...');
              }
              if (c.errorMessage.value.isNotEmpty && c.logs.isEmpty) {
                return FailureView(
                    message: c.errorMessage.value, onRetry: c.load);
              }
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: c.load,
                child: c.logs.isEmpty
                    ? const EmptyView(
                        icon: Icons.event_busy_outlined,
                        message: 'No work log entries',
                        subtitle: 'No clock-in records for this date.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: c.logs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _LogCard(entry: c.logs[i]),
                      ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _LogCard extends StatelessWidget {
  const _LogCard({required this.entry});

  final WorkLogEntry entry;

  String _liveDuration() {
    final start = DateTime.tryParse('${entry.date} ${entry.clockIn}');
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
    final active = entry.isActive;
    return Container(
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
                  entry.date.isEmpty ? 'Entry' : entry.date,
                  style: GoogleFonts.rubik(
                      fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
              if (active)
                StatusBadge.forStatus('Active')
              else
                Text(
                  '${entry.totalHours} hrs',
                  style: GoogleFonts.rubik(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _timeBlock('Clock In', entry.clockIn),
              ),
              Expanded(
                child: active
                    ? _timeBlock('Running', _liveDuration(),
                        color: AppColors.primary)
                    : _timeBlock('Clock Out',
                        entry.clockOut.isEmpty ? '--' : entry.clockOut),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeBlock(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.rubik(fontSize: 11, color: AppColors.hint)),
        const SizedBox(height: 2),
        Text(
          value.isEmpty ? '--' : value,
          style: GoogleFonts.rubik(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
