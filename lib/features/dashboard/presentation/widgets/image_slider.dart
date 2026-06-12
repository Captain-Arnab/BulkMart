import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:urban_roots/core/ui/network_image_widget.dart';
import 'package:urban_roots/features/products/data/ProductsController.dart';

class SliderPage extends StatefulWidget {
  const SliderPage({super.key});

  @override
  State<SliderPage> createState() => _SliderPageState();
}

class _SliderPageState extends State<SliderPage> {
  int _currentIndex = 0;
  final _controller = Get.put(ProductsController());

  static const _fallbackSliders = [
    'assets/slider1.png',
    'assets/slider2.png',
    'assets/slider3.png',
  ];

  @override
  void initState() {
    super.initState();
    _controller.fetchBanners();
  }

  List<String> _bannerUrls() {
    return _controller.banners
        .map((banner) => pickImageUrl(Map<String, dynamic>.from(banner)))
        .where((url) => url.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bannerUrls = _bannerUrls();
      final useNetwork = bannerUrls.isNotEmpty;
      final itemCount = useNetwork ? bannerUrls.length : _fallbackSliders.length;

      return Column(
        children: [
          Expanded(
            child: CarouselSlider.builder(
              itemCount: itemCount,
              itemBuilder: (context, index, _) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: useNetwork
                      ? Image.network(
                          bannerUrls[index],
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                            _fallbackSliders[index % _fallbackSliders.length],
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          _fallbackSliders[index],
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                );
              },
              options: CarouselOptions(
                enlargeCenterPage: true,
                autoPlay: itemCount > 1,
                aspectRatio: 16 / 7,
                autoPlayCurve: Curves.easeInOut,
                enableInfiniteScroll: itemCount > 1,
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                viewportFraction: 1,
                onPageChanged: (index, _) =>
                    setState(() => _currentIndex = index),
              ),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSmoothIndicator(
            activeIndex: _currentIndex,
            count: itemCount,
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
    });
  }
}
