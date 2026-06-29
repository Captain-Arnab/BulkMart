import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/async_views.dart';
import 'package:urban_roots/features/vendor/controllers/vendor_profile_controller.dart';

class VendorProfileScreen extends StatelessWidget {
  const VendorProfileScreen({super.key});

  // Keys shown in the hero header or considered internal — excluded from the
  // detail sections to avoid duplication / noise.
  static const _hiddenKeys = {
    'sl',
    'id',
    'is_open',
    'status',
    'token_expiry',
    'vendor_name',
    'marketing_name',
    'email',
  };

  static const _sections = <_Section>[
    _Section('Business Details', Icons.storefront_rounded,
        ['category_vendor', 'msme']),
    _Section('Contact', Icons.contact_phone_rounded,
        ['phone_number', 'address', 'city', 'state', 'country', 'pincode']),
    _Section('Legal & Compliance', Icons.verified_user_rounded,
        ['pan_no', 'gst_no', 'fssai_certificate']),
    _Section('Account', Icons.info_rounded, ['date_time']),
  ];

  @override
  Widget build(BuildContext context) {
    final c = Get.find<VendorProfileController>();
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Text('Profile',
            style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Obx(() {
        if (c.isLoading.value && c.profile.value == null) {
          return const LoadingView(label: 'Loading profile...');
        }
        if (c.errorMessage.value.isNotEmpty && c.profile.value == null) {
          return FailureView(message: c.errorMessage.value, onRetry: c.load);
        }
        final fields = c.profile.value?.fields ?? {};
        final lookup = <String, String>{
          for (final e in fields.entries) e.key.toLowerCase().trim(): e.value,
        };
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: c.load,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _Header(lookup: lookup),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // TODO: Backend pending — do not integrate yet.
                    // Quick actions for Support (/api/vendor/support/tickets.php,
                    // /api/vendor/support/raise-ticket.php) and Payments
                    // (/api/vendor/payouts/history.php) go here once the backend
                    // endpoints are live.
                    ..._buildSections(lookup, fields),
                    _buildOtherSection(lookup, fields),
                    const SizedBox(height: 8),
                    _logoutButton(context, c),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  List<Widget> _buildSections(
    Map<String, String> lookup,
    Map<String, String> fields,
  ) {
    final widgets = <Widget>[];
    for (final section in _sections) {
      final rows = <_InfoRow>[];
      for (final key in section.keys) {
        final value = lookup[key];
        if (value != null && value.trim().isNotEmpty) {
          rows.add(_InfoRow(
            icon: _iconFor(key),
            label: _labelFor(key),
            value: value.trim(),
          ));
        }
      }
      if (rows.isNotEmpty) {
        widgets.add(_InfoCard(
          title: section.title,
          icon: section.icon,
          rows: rows,
        ));
        widgets.add(const SizedBox(height: 14));
      }
    }
    return widgets;
  }

  Widget _buildOtherSection(
    Map<String, String> lookup,
    Map<String, String> fields,
  ) {
    final known = <String>{
      ..._hiddenKeys,
      for (final s in _sections) ...s.keys,
    };
    final rows = <_InfoRow>[];
    for (final e in fields.entries) {
      final key = e.key.toLowerCase().trim();
      if (known.contains(key)) continue;
      if (e.value.trim().isEmpty) continue;
      rows.add(_InfoRow(
        icon: Icons.chevron_right_rounded,
        label: _labelFor(e.key),
        value: e.value.trim(),
      ));
    }
    if (rows.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        _InfoCard(
          title: 'Additional Info',
          icon: Icons.more_horiz_rounded,
          rows: rows,
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _logoutButton(BuildContext context, VendorProfileController c) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFD32F2F),
          side: const BorderSide(color: Color(0xFFD32F2F)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () async {
          final ok = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text('Logout?'),
              content: const Text('You will need to sign in again to access '
                  'your vendor panel.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F)),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );
          if (ok == true) await c.logout();
        },
        icon: const Icon(Icons.logout_rounded),
        label: Text('Logout',
            style: GoogleFonts.rubik(fontWeight: FontWeight.w700)),
      ),
    );
  }

  static String _labelFor(String key) {
    const labels = {
      'category_vendor': 'Category',
      'msme': 'MSME',
      'phone_number': 'Phone',
      'pan_no': 'PAN No.',
      'gst_no': 'GST No.',
      'fssai_certificate': 'FSSAI Certificate',
      'date_time': 'Member Since',
      'pincode': 'Pincode',
    };
    final lower = key.toLowerCase().trim();
    if (labels.containsKey(lower)) return labels[lower]!;
    // Prettify: replace underscores, capitalise each word.
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  static IconData _iconFor(String key) {
    switch (key.toLowerCase().trim()) {
      case 'category_vendor':
        return Icons.category_rounded;
      case 'msme':
        return Icons.badge_rounded;
      case 'phone_number':
        return Icons.phone_rounded;
      case 'address':
        return Icons.location_on_rounded;
      case 'city':
        return Icons.location_city_rounded;
      case 'state':
        return Icons.map_rounded;
      case 'country':
        return Icons.public_rounded;
      case 'pincode':
        return Icons.pin_drop_rounded;
      case 'pan_no':
        return Icons.credit_card_rounded;
      case 'gst_no':
        return Icons.receipt_long_rounded;
      case 'fssai_certificate':
        return Icons.verified_rounded;
      case 'date_time':
        return Icons.calendar_today_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.lookup});

  final Map<String, String> lookup;

  String get _name {
    final v = lookup['vendor_name'];
    if (v != null && v.trim().isNotEmpty) return v.trim();
    final m = lookup['marketing_name'];
    if (m != null && m.trim().isNotEmpty) return m.trim();
    return 'Vendor';
  }

  String get _initials {
    final parts =
        _name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'V';
    if (parts.length == 1) {
      final p = parts.first;
      return (p.length >= 2 ? p.substring(0, 2) : p).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  bool get _isOpen => (lookup['is_open'] ?? '').trim() == '1';
  bool get _isActive {
    final s = (lookup['status'] ?? '').trim().toLowerCase();
    return s == '1' || s == 'active';
  }

  @override
  Widget build(BuildContext context) {
    final marketing = lookup['marketing_name']?.trim() ?? '';
    final email = lookup['email']?.trim() ?? '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: Colors.white,
            child: Text(
              _initials,
              style: GoogleFonts.rubik(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _name,
            textAlign: TextAlign.center,
            style: GoogleFonts.rubik(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          if (marketing.isNotEmpty && marketing != _name) ...[
            const SizedBox(height: 2),
            Text(
              marketing,
              textAlign: TextAlign.center,
              style: GoogleFonts.rubik(fontSize: 14, color: Colors.white70),
            ),
          ],
          if (email.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.email_outlined,
                    size: 14, color: Colors.white70),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    email,
                    overflow: TextOverflow.ellipsis,
                    style:
                        GoogleFonts.rubik(fontSize: 13, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _chip(_isOpen ? 'Store Open' : 'Store Closed', _isOpen),
              const SizedBox(width: 10),
              _chip(_isActive ? 'Active' : 'Inactive', _isActive),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, bool positive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: positive ? const Color(0xFF8FFFB0) : Colors.white60,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.rubik(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.icon, required this.rows});

  final String title;
  final IconData icon;
  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.rubik(
                    fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const Divider(height: 22),
          for (var i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i != rows.length - 1) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.hint),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.rubik(fontSize: 12, color: AppColors.hint),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.rubik(
                    fontSize: 14.5, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Section {
  const _Section(this.title, this.icon, this.keys);
  final String title;
  final IconData icon;
  final List<String> keys;
}
