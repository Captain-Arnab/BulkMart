import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/data/dummy_data.dart';

class AddToCartWidget extends StatefulWidget {
  final int productId;

  const AddToCartWidget({Key? key, required this.productId}) : super(key: key);

  @override
  _AddToCartWidgetState createState() => _AddToCartWidgetState();
}

class _AddToCartWidgetState extends State<AddToCartWidget> {
  int quantity = 0;
  bool isLoading = false;

  Future<void> addToCart() async {
    setState(() => isLoading = true);

    await Future.delayed(const Duration(milliseconds: 300));

    final product = DummyData.products.firstWhere(
      (p) => p.id == widget.productId.toString(),
      orElse: () => DummyData.products.first,
    );

    bool found = false;
    for (var item in DummyData.cartItems) {
      if (item['product_id'] == widget.productId.toString()) {
        item['quantity'] = (item['quantity'] as int) + quantity;
        found = true;
        break;
      }
    }
    if (!found) {
      DummyData.cartItems.add({
        'product_id': widget.productId.toString(),
        'name': product.name,
        'price': product.price,
        'quantity': quantity,
        'imageUrl': '',
      });
    }

    setState(() => isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} added to cart')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        double fontSize = screenWidth < 600
            ? screenWidth * 0.08
            : screenWidth * 0.07;
        double iconSize = screenWidth * 0.1;
        double buttonWidth = screenWidth < 600
            ? screenWidth * 0.95
            : screenWidth * 0.45;

        return screenWidth < 600
            ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove, size: iconSize),
                        onPressed: () {
                          if (quantity > 1) setState(() => quantity--);
                        },
                      ),
                      Text('$quantity',
                          style: TextStyle(fontSize: fontSize * 1.2)),
                      IconButton(
                        icon: Icon(Icons.add, size: iconSize),
                        onPressed: () => setState(() => quantity++),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: buttonWidth,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : addToCart,
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.green)
                          : Text('Add to Cart',
                              style: GoogleFonts.poppins(fontSize: fontSize)),
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove, size: iconSize),
                        onPressed: () {
                          if (quantity > 1) setState(() => quantity--);
                        },
                      ),
                      Text('$quantity',
                          style: TextStyle(fontSize: fontSize)),
                      IconButton(
                        icon: Icon(Icons.add, size: iconSize),
                        onPressed: () => setState(() => quantity++),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: buttonWidth,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : addToCart,
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.green)
                          : Text('Add to Cart',
                              style: GoogleFonts.poppins(fontSize: fontSize)),
                    ),
                  ),
                ],
              );
      },
    );
  }
}
