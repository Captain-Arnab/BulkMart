import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/async_views.dart';
import 'package:urban_roots/features/admin/controllers/admin_delivery_attendance_controller.dart';
import 'package:urban_roots/features/admin/models/admin_models.dart';

class AdminDeliveryAttendanceScreen extends StatefulWidget {
  const AdminDeliveryAttendanceScreen({
    super.key,
    required this.deliveryBoyId,
    this.deliveryBoyName = '',
  });

  final String deliveryBoyId;
  final String deliveryBoyName;

  @override
  State<AdminDeliveryAttendanceScreen> createState() =>
      _AdminDeliveryAttendanceScreenState();
}

class _AdminDeliveryAttendanceScreenState
    extends State<AdminDeliveryAttendanceScreen> {
  late final AdminDeliveryAttendanceController c;
  // Unique tag so multiple boys can be opened without controller clashes.
  late final String _tag;

  @override
  void initState() {
    super.initState();
    _tag = 'attendance_${widget.deliveryBoyId}';
    c = Get.put(
      AdminDeliveryAttendanceController(
        deliveryBoyId: widget.deliveryBoyId,
        initialName: widget.deliveryBoyName,
      ),
      tag: _tag,
    );
  }

  @override
  void dispose() {
    Get.delete<AdminDeliveryAttendanceController>(tag: _tag);
    super.dispose();
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final initial =
        (isFrom ? c.fromDate.value : c.toDate.value) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      c.setRange(from: isFrom ? picked : null, to: isFrom ? null : picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.deliveryBoyName.isNotEmpty
        ? widget.deliveryBoyName
        : 'Attendance';
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Text(title,
            style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Obx(() {
        if (c.isLoading.value && c.report.value == null) {
          return const LoadingView(label: 'Loading attendance...');
        }
        if (c.errorMessage.value.isNotEmpty && c.report.value == null) {
          return FailureView(message: c.errorMessage.value, onRetry: c.load);
        }
        final report = c.report.value ?? const AttendanceReport();
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: c.load,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildRangeRow(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _summaryCard('Days Worked',
                        report.totalDaysWorked, Icons.event_available_outlined),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _summaryCard('Hours Worked',
                        report.totalHoursWorked, Icons.timer_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Attendance Details',
                style: GoogleFonts.rubik(
                    fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (report.attendance.isEmpty)
                const EmptyView(
                  icon: Icons.event_busy_outlined,
                  message: 'No attendance records',
                  subtitle: 'No data for the selected range.',
                )
              else
                ...report.attendance.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _AttendanceRow(entry: e),
                    )),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildRangeRow() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _dateButton(
              'From',
              c.fromDate.value,
              () => _pickDate(isFrom: true),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _dateButton(
              'To',
              c.toDate.value,
              () => _pickDate(isFrom: false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateButton(String label, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.rubik(fontSize: 11, color: AppColors.hint)),
            const SizedBox(height: 2),
            Text(
              date != null ? DateFormat('dd MMM yyyy').format(date) : 'Any',
              style: GoogleFonts.rubik(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceMint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 10),
          Text(value,
              style: GoogleFonts.rubik(
                  fontSize: 22, fontWeight: FontWeight.w800)),
          Text(label,
              style: GoogleFonts.rubik(fontSize: 12, color: AppColors.hint)),
        ],
      ),
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({required this.entry});

  final AttendanceEntry entry;

  @override
  Widget build(BuildContext context) {
    final absent = entry.isAbsent;
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
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              entry.date.isEmpty ? '--' : entry.date,
              style: GoogleFonts.rubik(fontWeight: FontWeight.w600),
            ),
          ),
          if (absent)
            Text(
              'Absent',
              style: GoogleFonts.rubik(
                fontWeight: FontWeight.w700,
                color: const Color(0xFFD32F2F),
              ),
            )
          else ...[
            Expanded(
              flex: 4,
              child: Text(
                '${entry.clockIn} - ${entry.clockOut.isEmpty ? '--' : entry.clockOut}',
                style: GoogleFonts.rubik(fontSize: 13, color: AppColors.hint),
              ),
            ),
            Text(
              '${entry.totalHours}h',
              style: GoogleFonts.rubik(
                  fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ],
        ],
      ),
    );
  }
}
