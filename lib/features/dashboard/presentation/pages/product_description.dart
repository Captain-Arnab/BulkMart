import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart';
import 'package:urban_roots/data/dummy_data.dart';
import 'package:urban_roots/features/dashboard/presentation/pages/bloc/dashboard_bloc.dart';
import 'package:urban_roots/features/dashboard/presentation/pages/bloc/dashboard_event.dart';
import 'package:urban_roots/features/dashboard/presentation/widgets/tabbar.dart';
import 'package:urban_roots/features/products/data/ProductsController.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productVal;
  const ProductDetailsPage({super.key, required this.productVal});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final ProductsController productsController = Get.put(ProductsController());
  Map<String, dynamic>? _data;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  Future<void> _loadProductData() async {
    _data = await productsController.fetchProductData(widget.productVal);
    if (mounted) setState(() {});
  }

  void _addToCart() {
    bool found = false;
    for (var item in DummyData.cartItems) {
      if (item['product_id'] == widget.productVal) {
        item['quantity'] = (item['quantity'] as int) + _quantity;
        found = true;
        break;
      }
    }
    if (!found) {
      DummyData.cartItems.add({
        'product_id': widget.productVal,
        'name': _data?['name'] ?? '',
        'price': _data?['price'] ?? '0',
        'quantity': _quantity,
        'imageUrl': DummyData.getProductImage(widget.productVal),
      });
    }
    SweetAlert.success(context, message: '${_data?['name']} added to cart');
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = DummyData.getProductImage(widget.productVal);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: _data == null
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF019934)))
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 280,
                  pinned: true,
                  backgroundColor: Colors.white,
                  leading: Padding(
                    padding: const EdgeInsets.all(8),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, size: 20, color: Colors.black),
                        onPressed: () => BlocProvider.of<DashboardBloc>(context).add(DashboardUpdateEvent(index: 0, category: 0)),
                      ),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      color: const Color(0xFFF0F7F0),
                      child: Center(child: Hero(
                        tag: 'product_${widget.productVal}',
                        child: Image.asset(imageUrl, height: 200, fit: BoxFit.contain),
                      )),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(_data?['name'] ?? '', style: GoogleFonts.rubik(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black87)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                                child: Text(_data?['packingType'] ?? '', style: GoogleFonts.rubik(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF019934))),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(_data?['grams'] ?? '', style: GoogleFonts.rubik(fontSize: 14, color: Colors.grey.shade500)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Text('\u20B9${_data?['price'] ?? '0'}', style: GoogleFonts.rubik(fontSize: 28, fontWeight: FontWeight.w700, color: const Color(0xFF019934))),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6)),
                                child: Text('${_data?['gst'] ?? '5'}% GST', style: GoogleFonts.rubik(fontSize: 11, color: Colors.grey.shade600)),
                              ),
                              const Spacer(),
                              Text('In Stock: ${_data?['stock'] ?? '0'}', style: GoogleFonts.rubik(fontSize: 13, color: Colors.grey.shade500)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                                child: Row(children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 18),
                                    onPressed: () { if (_quantity > 1) setState(() => _quantity--); },
                                  ),
                                  Text('$_quantity', style: GoogleFonts.rubik(fontSize: 16, fontWeight: FontWeight.w600)),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 18),
                                    onPressed: () => setState(() => _quantity++),
                                  ),
                                ]),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF019934),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      elevation: 2,
                                    ),
                                    onPressed: _addToCart,
                                    icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
                                    label: Text('Add to Cart', style: GoogleFonts.rubik(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 500,
                            child: TabBarWidget(
                              name: _data?['name'] ?? "Product",
                              description: _data?['description'] ?? "",
                              healthBenefits: _data?['healthBenefits'] ?? "",
                              nutritionalInfo: _data?['nutritionalInfo'] ?? "",
                              sellingPoints: _data?['sellingPoints'] ?? "",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
