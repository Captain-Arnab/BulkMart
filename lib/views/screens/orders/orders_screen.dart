import 'package:flutter/material.dart';

import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../widgets/ui_states.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: Text(
          'Orders',
          style: AppTextStyles.display(fontSize: 18, color: AppColors.white),
        ),
      ),
      body: const EmptyState(
        title: 'No orders yet',
        subtitle: 'Active and past orders will show here once you place your first COD order.',
        icon: Icons.receipt_long_outlined,
      ),
    );
  }
}
