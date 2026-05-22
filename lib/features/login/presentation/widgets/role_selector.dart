import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/auth/auth_role.dart';
import 'package:urban_roots/features/login/data/LoginController.dart';

/// Customer / Vendor role chips shared by email and phone login.
class RoleSelector extends StatelessWidget {
  const RoleSelector({super.key, required this.controller});

  final LoginController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Login as',
          style: GoogleFonts.rubik(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Row(
            children: [
              Expanded(
                child: _RoleChip(
                  label: 'Customer',
                  selected: controller.selectedRole.value == AuthRole.user,
                  onTap: () => controller.selectedRole.value = AuthRole.user,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _RoleChip(
                  label: 'Vendor',
                  selected: controller.selectedRole.value == AuthRole.vendor,
                  onTap: () => controller.selectedRole.value = AuthRole.vendor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF019934).withValues(alpha: 0.12)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF019934) : Colors.grey.shade200,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.rubik(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? const Color(0xFF019934) : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }
}
