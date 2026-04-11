import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:urban_roots/Utils/AppBarWidget.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<dynamic> cartItems = [];
  bool isLoading = true;
  double totalValue = 0.0;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    final url = Uri.parse('https://vsnl.online/shoping/api/fetchCart.php');
    var headers = {
      'Cookie': 'PHPSESSID=8f6842a6ba85d35f546261569f743a6c'
    };
    final response = await http.get(url,headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> items = json.decode(response.body);
      print("Items" + items.toString());
      double total = 0.0;

      for (var item in items) {
        total += int.parse(item['quantity']) * int.parse(item['price']);
      }

      setState(() {
        cartItems = List<dynamic>.from(items);
        totalValue = total;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load cart items')),
      );
    }
  }

  void checkout() {
    // Handle the checkout process here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Proceeding to checkout')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return ListTile(
                  title: Text(item['name'],style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 16,fontWeight: FontWeight.bold),),
                  subtitle: Text(
                      '${item['quantity']} x \₹${item['price']}',style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 14),),
                  trailing: Text(
                      '\₹${(int.parse(item['quantity']) * int.parse(item['price']) )}',style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 14,fontWeight: FontWeight.w700)),
                );
              },
              separatorBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Divider(thickness: 1,color: Colors.green.shade800,),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Total: \₹${totalValue.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: checkout,
                  child: const Text('Checkout'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
