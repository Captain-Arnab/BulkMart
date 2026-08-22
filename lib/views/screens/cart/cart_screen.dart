import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/ui/app_motion.dart';
import '../../../core/ui/shell_controller.dart';
import '../../../models/cart_item.dart';
import '../../../repositories/order_repository.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../viewmodels/address_view_model.dart';
import '../../../viewmodels/cart_view_model.dart';
import '../../widgets/location_picker_sheet.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/product_network_image.dart';
import '../../widgets/stepper_qty.dart';
import '../../widgets/ui_states.dart';
import '../orders/order_confirmation_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  PrimaryButtonState _placeState = PrimaryButtonState.idle;

  static final _priceFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  Future<void> _placeOrder() async {
    final cart = context.read<CartViewModel>();
    final addressVm = context.read<AddressViewModel>();
    final delivery = addressVm.defaultAddress;
    if (cart.items.isEmpty || delivery == null) return;

    setState(() => _placeState = PrimaryButtonState.loading);
    HapticFeedback.lightImpact();

    final payload = cart.items
        .map((e) => {'product_id': e.product.id, 'quantity': e.quantity})
        .toList();

    final result = await context.read<OrderRepository>().placeOrder(
          items: payload,
          addressId: delivery.id,
          deliveryAddress: delivery.fullAddress,
        );

    if (!mounted) return;

    await result.when(
      success: (order) async {
        setState(() => _placeState = PrimaryButtonState.success);
        await Future<void>.delayed(const Duration(milliseconds: 450));
        if (!mounted) return;
        cart.clear();
        await AppPageRoute.push(context, OrderConfirmationScreen(order: order));
        if (mounted) setState(() => _placeState = PrimaryButtonState.idle);
      },
      failure: (message, {statusCode, code, fields}) async {
        setState(() => _placeState = PrimaryButtonState.idle);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.rust),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartViewModel>();
    final addressVm = context.watch<AddressViewModel>();
    final delivery = addressVm.defaultAddress;
    final shell = context.read<ShellController>();
    // Clearance for floating bottom nav pill (64) + gap + system inset.
    final bottomClearance =
        64 + 12 + MediaQuery.viewPaddingOf(context).bottom + 8;
    final canPlace = delivery != null && cart.items.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: Text('Cart', style: AppTextStyles.display(fontSize: 18, color: AppColors.white)),
      ),
      body: cart.items.isEmpty
          ? EmptyState(
              title: 'Your cart is empty',
              subtitle: 'Browse the catalog and add bulk items to place a COD order.',
              lottieAsset: 'assets/lottie/empty_cart.json',
              icon: Icons.shopping_bag_outlined,
              ctaLabel: 'Browse Catalog',
              onCta: shell.goToHome,
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return _CartDismissibleTile(
                        item: item,
                        priceFormat: _priceFormat,
                        onDismissed: () => cart.remove(item.product.id),
                        onQtyChanged: (q) => cart.updateQuantity(item.product.id, q),
                      );
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(16, 14, 16, bottomClearance),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: const Border(top: BorderSide(color: AppColors.line)),
                    boxShadow: AppShadows.soft(opacity: 0.06),
                  ),
                  child: Column(
                    children: [
                      PressableAddressRow(
                        label: delivery == null
                            ? 'Select a delivery address'
                            : '${delivery.label} · ${delivery.city}',
                        subtitle: delivery?.fullAddress,
                        missing: delivery == null,
                        onTap: () => showLocationPickerSheet(context),
                      ),
                      if (delivery == null) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Select a delivery address to continue',
                            style: AppTextStyles.body(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.rust,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      _summaryRow('Subtotal', _priceFormat.format(cart.subtotal)),
                      _summaryRow('Delivery', 'Free · COD'),
                      const SizedBox(height: 8),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: AppTextStyles.body(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          AnimatedSwitcher(
                            duration: AppMotion.fast,
                            transitionBuilder: (child, anim) => FadeTransition(
                              opacity: anim,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.3),
                                  end: Offset.zero,
                                ).animate(anim),
                                child: child,
                              ),
                            ),
                            child: Text(
                              _priceFormat.format(cart.total),
                              key: ValueKey(cart.total),
                              style: AppTextStyles.mono(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(AppRadii.md),
                          border: Border.all(color: AppColors.accent),
                        ),
                        child: Text(
                          'Cash on Delivery only — pay when your order arrives.',
                          style: AppTextStyles.body(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        label: 'Place Order (COD)',
                        state: _placeState,
                        backgroundColor: canPlace
                            ? AppColors.success
                            : AppColors.muted.withValues(alpha: 0.45),
                        onPressed: canPlace ? _placeOrder : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body(fontSize: 12, color: AppColors.slate)),
          Text(
            value,
            style: AppTextStyles.mono(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class PressableAddressRow extends StatelessWidget {
  const PressableAddressRow({
    super.key,
    required this.label,
    this.subtitle,
    required this.missing,
    required this.onTap,
  });

  final String label;
  final String? subtitle;
  final bool missing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: missing ? AppColors.rust.withValues(alpha: 0.06) : AppColors.section,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color: missing ? AppColors.rust.withValues(alpha: 0.35) : AppColors.line,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: missing ? AppColors.rust : AppColors.green,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.body(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: missing ? AppColors.rust : AppColors.ink,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body(fontSize: 11, color: AppColors.muted),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartDismissibleTile extends StatelessWidget {
  const _CartDismissibleTile({
    required this.item,
    required this.priceFormat,
    required this.onDismissed,
    required this.onQtyChanged,
  });

  final CartItem item;
  final NumberFormat priceFormat;
  final VoidCallback onDismissed;
  final ValueChanged<int> onQtyChanged;

  void _remove(BuildContext context) {
    HapticFeedback.mediumImpact();
    onDismissed();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.product.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _remove(context),
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.rust.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.rust),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: AppColors.line),
          boxShadow: AppShadows.soft(opacity: 0.04),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.sm),
              child: SizedBox(
                width: 52,
                height: 52,
                child: ProductNetworkImage(product: item.product, iconSize: 22),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: AppTextStyles.body(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  StepperQty(
                    value: item.quantity,
                    min: item.product.moq,
                    onChanged: onQtyChanged,
                  ),
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: AppMotion.fast,
                    child: Text(
                      priceFormat.format(item.lineTotal),
                      key: ValueKey(item.lineTotal),
                      style: AppTextStyles.mono(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.forestDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Remove item',
              onPressed: () => _remove(context),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: Icon(
                Icons.delete_outline_rounded,
                color: AppColors.rust.withValues(alpha: 0.9),
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
