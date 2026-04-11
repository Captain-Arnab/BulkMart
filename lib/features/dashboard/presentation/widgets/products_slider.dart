import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/data/dummy_data.dart';
import 'package:urban_roots/features/dashboard/presentation/pages/all_products.dart';

class ProductSliderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: DummyData.categories.length,
        itemBuilder: (context, index) {
          final cat = DummyData.categories[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => ProductPage(category: int.parse(cat['id']!), minPrice: 0, maxPrice: 2000),
              ));
            },
            child: Container(
              width: 90,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.green.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 3))],
                    ),
                    child: ClipOval(
                      child: Image.asset(cat['image']!, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat['name']!,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.rubik(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.black87),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
