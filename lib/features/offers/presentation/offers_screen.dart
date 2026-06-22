import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/features/offers/presentation/widgets/offers_coming_soon_banner.dart';

/// Offers and deals screen — no live offers API yet.
class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Text(
          'Offers & Deals',
          style: GoogleFonts.rubik(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_offer_outlined,
                size: 72,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 20),
              const OffersComingSoonBanner(),
            ],
          ),
        ),
      ),
    );
  }
}
