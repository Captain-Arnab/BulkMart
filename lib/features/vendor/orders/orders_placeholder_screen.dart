import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrdersPlaceholderScreen extends StatelessWidget {
  const OrdersPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tabs = ['All', 'Pending', 'Shipped', 'Completed', 'Cancelled'];
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Orders', style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          bottom: TabBar(
            isScrollable: true,
            labelColor: const Color(0xFF019934),
            unselectedLabelColor: Colors.grey,
            tabs: tabs.map((t) => Tab(child: Text(t, style: GoogleFonts.rubik(fontSize: 12)))).toList(),
          ),
        ),
        body: TabBarView(
          children: List.generate(
            tabs.length,
            (_) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.construction_outlined, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'Coming Soon',
                      style: GoogleFonts.rubik(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Order management is on the way. Tabs are disabled until Phase 2.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rubik(fontSize: 14, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
