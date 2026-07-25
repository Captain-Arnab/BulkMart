import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../viewmodels/cart_view_model.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/stepper_qty.dart';
import '../../widgets/ui_states.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static final _priceFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartViewModel>();

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: Text('Cart', style: AppTextStyles.display(fontSize: 18, color: AppColors.white)),
      ),
      body: cart.items.isEmpty
          ? const EmptyState(
              title: 'Your cart is empty',
              subtitle: 'Browse the catalog and add bulk items.',
              icon: Icons.shopping_bag_outlined,
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.paper2,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.inventory_2_outlined,
                                color: AppColors.forest,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: AppTextStyles.body(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  StepperQty(
                                    value: item.quantity,
                                    min: item.product.moq,
                                    onChanged: (q) => cart.updateQuantity(
                                      item.product.id,
                                      q,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _priceFormat.format(item.lineTotal),
                                    style: AppTextStyles.mono(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.forestDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    border: Border(top: BorderSide(color: AppColors.line)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        _summaryRow('Subtotal', _priceFormat.format(cart.subtotal)),
                        _summaryRow('Delivery', 'TBD'),
                        const Divider(height: 20),
                        _summaryRow(
                          'Total',
                          _priceFormat.format(cart.total),
                          bold: true,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.mustard.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.mustard,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Text(
                            'Cash on Delivery only — pay when your order arrives.',
                            style: AppTextStyles.body(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF8A5C13),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        PrimaryButton(
                          label: 'Place Order (COD)',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Place-order API will be wired in the next session.',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body(
              fontSize: bold ? 14 : 12,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              color: bold ? AppColors.ink : AppColors.slate,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.mono(
              fontSize: bold ? 14 : 12,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
