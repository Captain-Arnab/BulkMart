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
      if (bannerUrls.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        children: [
          Expanded(
            child: CarouselSlider.builder(
              itemCount: bannerUrls.length,
              itemBuilder: (context, index, _) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: NetworkOrAssetImage(
                    url: bannerUrls[index],
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                );
              },
              options: CarouselOptions(
                enlargeCenterPage: true,
                autoPlay: bannerUrls.length > 1,
                aspectRatio: 16 / 7,
                autoPlayCurve: Curves.easeInOut,
                enableInfiniteScroll: bannerUrls.length > 1,
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
            count: bannerUrls.length,
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
