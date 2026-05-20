import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/data/dummy_data.dart';
import 'package:urban_roots/features/payments/presentation/PhonePePaymentScreen.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;
  double totalValue = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  void _loadCartItems() {
    setState(() {
      cartItems = List<Map<String, dynamic>>.from(DummyData.cartItems.map((item) => Map<String, dynamic>.from(item)));
      updateTotalValue();
      isLoading = false;
    });
  }

  void updateTotalValue() {
    double total = 0.0;
    for (var item in cartItems) {
      total += item['quantity'] * double.parse(item['price']);
    }
    setState(() => totalValue = total);
  }

  void updateQuantity(int index, int newQuantity) {
    setState(() {
      cartItems[index]['quantity'] = newQuantity;
      updateTotalValue();
    });
  }

  void checkout() {
    if (cartItems.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PhonePePaymentScreen(
          amount: totalValue,
          title: 'Urban Roots Order',
          subtitle: '${cartItems.length} item(s) — Secure checkout',
          onSuccess: () {
            setState(() {
              cartItems.clear();
              totalValue = 0.0;
            });
          },
        ),
      ),
    );
  }

  void deleteCartItem(int index) {
    setState(() {
      cartItems.removeAt(index);
      updateTotalValue();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('My Cart', style: GoogleFonts.rubik(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87)),
        centerTitle: false,
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: () => setState(() { cartItems.clear(); totalValue = 0.0; }),
              child: Text('Clear All', style: GoogleFonts.rubik(fontSize: 13, color: Colors.red.shade400)),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF019934)))
          : cartItems.isEmpty
              ? Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text('Your cart is empty', style: GoogleFonts.rubik(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey.shade500)),
                    const SizedBox(height: 8),
                    Text('Browse products and add items', style: GoogleFonts.rubik(fontSize: 13, color: Colors.grey.shade400)),
                  ]),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text('${cartItems.length} item${cartItems.length > 1 ? 's' : ''} in cart', style: GoogleFonts.rubik(fontSize: 13, color: Colors.grey.shade500)),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          final itemTotal = item['quantity'] * int.parse(item['price']);
                          final imageUrl = item['imageUrl'] ?? DummyData.getProductImage(item['product_id']);
                          return Dismissible(
                            key: Key(item['product_id']),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(16)),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                            ),
                            onDismissed: (_) => deleteCartItem(index),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(imageUrl, width: 70, height: 70, fit: BoxFit.cover),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(item['name'], style: GoogleFonts.rubik(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Text('\u20B9${item['price']} each', style: GoogleFonts.rubik(fontSize: 12, color: Colors.grey.shade500)),
                                    ]),
                                  ),
                                  Column(
                                    children: [
                                      Text('\u20B9$itemTotal', style: GoogleFonts.rubik(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF019934))),
                                      const SizedBox(height: 8),
                                      Container(
                                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                                          InkWell(
                                            onTap: () { if (item['quantity'] > 1) updateQuantity(index, item['quantity'] - 1); },
                                            child: Padding(padding: const EdgeInsets.all(6), child: Icon(Icons.remove, size: 16, color: Colors.grey.shade700)),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            child: Text('${item['quantity']}', style: GoogleFonts.rubik(fontSize: 14, fontWeight: FontWeight.w600)),
                                          ),
                                          InkWell(
                                            onTap: () => updateQuantity(index, item['quantity'] + 1),
                                            child: Padding(padding: const EdgeInsets.all(6), child: Icon(Icons.add, size: 16, color: const Color(0xFF019934))),
                                          ),
                                        ]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -4))],
                      ),
                      child: Column(
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text('Total', style: GoogleFonts.rubik(fontSize: 16, color: Colors.grey.shade600)),
                            Text('\u20B9${totalValue.toStringAsFixed(0)}', style: GoogleFonts.rubik(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black87)),
                          ]),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF019934),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 2,
                              ),
                              onPressed: checkout,
                              child: Text('Checkout', style: GoogleFonts.rubik(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
