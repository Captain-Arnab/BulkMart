import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_roots/core/ui/api_view_state.dart';
import 'package:urban_roots/features/products/data/ProductsController.dart';
import 'package:urban_roots/features/products/models/Product.dart';
import 'package:urban_roots/features/products/presentation/ProductCard.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _query = TextEditingController();
  final _products = Get.put(ProductsController());
  List<Product> _results = [];
  ApiViewStatus _status = ApiViewStatus.idle;
  String? _error;

  Future<void> _search() async {
    if (_query.text.trim().isEmpty) return;
    setState(() => _status = ApiViewStatus.loading);
    try {
      _results = await _products.searchProducts(keyword: _query.text.trim());
      setState(() => _status = _results.isEmpty ? ApiViewStatus.empty : ApiViewStatus.success);
    } catch (e) {
      setState(() {
        _status = ApiViewStatus.error;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _query,
          decoration: const InputDecoration(hintText: 'Search products...', border: InputBorder.none),
          onSubmitted: (_) => _search(),
        ),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: _search)],
      ),
      body: ApiStateView(
        status: _status,
        errorMessage: _error,
        onRetry: _search,
        emptyMessage: 'No products found',
        child: GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: _results.length,
          itemBuilder: (context, i) {
            final p = _results[i];
            return ProductCard(
              id: int.tryParse(p.id) ?? 0,
              name: p.name,
              grams: p.grams,
              stock: p.stock,
              price: p.price,
              imageUrl: p.imageUrl,
            );
          },
        ),
      ),
    );
  }
}
