import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:urban_roots/core/theme/app_colors.dart';

class HomeBannerCarousel extends StatefulWidget {
  const HomeBannerCarousel({super.key});

  static const sliderAssets = [
    'assets/slider1.png',
    'assets/slider2.png',
    'assets/slider3.png',
    'assets/slider4.png',
    'assets/slider5.png',
  ];

  /// Lower value = taller banner. ~2.05 gives a comfortable height on phones.
  static const double bannerAspectRatio = 2.05;

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final itemCount = HomeBannerCarousel.sliderAssets.length;

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: itemCount,
          itemBuilder: (context, index, _) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ColoredBox(
                color: AppColors.primary,
                child: Image.asset(
                  HomeBannerCarousel.sliderAssets[index],
                  width: double.infinity,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
            );
          },
          options: CarouselOptions(
            aspectRatio: HomeBannerCarousel.bannerAspectRatio,
            autoPlay: itemCount > 1,
            autoPlayCurve: Curves.easeInOut,
            enableInfiniteScroll: itemCount > 1,
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            viewportFraction: 1,
            onPageChanged: (index, _) => setState(() => _currentIndex = index),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedSmoothIndicator(
          activeIndex: _currentIndex,
          count: itemCount,
          effect: WormEffect(
            activeDotColor: AppColors.primary,
            dotColor: Colors.grey.shade300,
            dotHeight: 6,
            dotWidth: 6,
            spacing: 6,
          ),
        ),
      ],
    );
  }
}
