import 'package:flutter/material.dart';

class DelightOffers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20), // Optional: Add padding if needed
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title Section
          Container(
            margin: EdgeInsets.only(bottom: 20),
            child: Text(
              'Delight Offers',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Images Section
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // First Image
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(8), // Optional: Adjust margin as needed
                  child: Image.asset(
                    'assets/poster1.jpg', // Adjust path accordingly
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              // Second Image
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(8), // Optional: Adjust margin as needed
                  child: Image.asset(
                    'assets/poster2.jpg', // Adjust path accordingly
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
