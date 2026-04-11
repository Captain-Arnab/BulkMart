import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class SliderPage extends StatefulWidget {
  @override
  State<SliderPage> createState() => _SliderPageState();
}

class _SliderPageState extends State<SliderPage> {
  int _currentIndex = 0;

  final List<String> _sliders = [
    'assets/slider1.png',
    'assets/slider2.png',
    'assets/slider3.png',
    'assets/slider4.png',
    'assets/slider5.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: CarouselSlider.builder(
            itemCount: _sliders.length,
            itemBuilder: (context, index, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(_sliders[index], width: double.infinity, fit: BoxFit.cover),
              );
            },
            options: CarouselOptions(
              enlargeCenterPage: true,
              autoPlay: true,
              aspectRatio: 16 / 7,
              autoPlayCurve: Curves.easeInOut,
              enableInfiniteScroll: true,
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              viewportFraction: 1,
              onPageChanged: (index, _) => setState(() => _currentIndex = index),
            ),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedSmoothIndicator(
          activeIndex: _currentIndex,
          count: _sliders.length,
          effect: WormEffect(
            activeDotColor: const Color(0xFF019934),
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
