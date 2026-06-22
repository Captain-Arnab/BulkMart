import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/features/offers/presentation/widgets/offers_coming_soon_banner.dart';

class DelightOffers extends StatelessWidget {
  const DelightOffers({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Delight Offers',
            style: GoogleFonts.rubik(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          const OffersComingSoonBanner(),
        ],
      ),
    );
  }
}
