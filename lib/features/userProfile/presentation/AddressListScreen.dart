import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/features/dashboard/dashboard_controller.dart';
import 'package:urban_roots/features/userProfile/presentation/widgets/AddressListWidget.dart';

class AddressListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => DashboardController.findOrPut().backToProfile(),
        ),
        title: Text('My Addresses', style: GoogleFonts.rubik(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87)),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: const AddressListWidget(),
      ),
    );
  }
}
