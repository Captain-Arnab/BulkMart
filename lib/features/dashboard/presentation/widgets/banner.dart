import 'package:flutter/material.dart';
import 'package:svg_flutter/svg_flutter.dart';

class BannerSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBannerItem(
                'assets/icon-1.svg',
                'Best prices & offers',
                'Orders \$50 or more',
              ),
              _buildBannerItem(
                'assets/icon-2.svg',
                'Free delivery',
                '24/7 amazing services',
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBannerItem(
                'assets/icon-3.svg',
                'Great daily deal',
                'When you sign up',
              ),
              _buildBannerItem(
                'assets/icon-4.svg',
                'Wide assortment',
                'Mega Discounts',
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildBannerItem(
                'assets/icon-5.svg',
                'Easy returns',
                'Within 30 days',
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBannerItem(String iconPath, String title, String subtitle) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              height: 40.0, // Adjust size as needed
            ),// Adjust size as needed
            SizedBox(width: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                Text(subtitle),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
