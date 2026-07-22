import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/api_view_state.dart';
import 'package:urban_roots/core/ui/app_ui_kit.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart';
import 'package:urban_roots/core/ui/ui_state.dart';
import 'package:urban_roots/features/checkout/buy_now_view_model.dart';
import 'package:urban_roots/features/checkout/checkout_summary.dart';
import 'package:urban_roots/features/orders/order_success_screen.dart';
import 'package:urban_roots/features/orders/orders_controller.dart';
import 'package:urban_roots/features/userProfile/address_controller.dart';
import 'package:urban_roots/features/userProfile/model/Address.dart';
import 'package:urban_roots/features/userProfile/presentation/widgets/AddressFormWidget.dart';
import 'package:urban_roots/features/userProfile/user_profile_controller.dart';
import 'package:urban_roots/features/wallet/wallet_payment_webview.dart';

/// Address + payment checkout for a single product (skips the cart).
class BuyNowCheckoutScreen extends StatefulWidget {
  const BuyNowCheckoutScreen({
    super.key,
    required this.productId,
    required this.quantity,
    required this.productName,
    this.unitPrice,
  });

  final String productId;
  final int quantity;
  final String productName;
  final double? unitPrice;

  @override
  State<BuyNowCheckoutScreen> createState() => _BuyNowCheckoutScreenState();
}

class _BuyNowCheckoutScreenState extends State<BuyNowCheckoutScreen> {
  final _addressController = AddressController.findOrPut();
  late final BuyNowViewModel _vm;
  String? _selectedAddressId;
  String _payment = 'cod';
  String _customerEmail = '';

  @override
  void initState() {
    super.initState();
    _vm = BuyNowViewModel();
    _vm.addListener(_onVmChanged);
    _bootstrap();
  }

  @override
  void dispose() {
    _vm.removeListener(_onVmChanged);
    _vm.dispose();
    super.dispose();
  }

  void _onVmChanged() => setState(() {});

  Future<void> _bootstrap() async {
    await Future.wait([
      _addressController.loadAddresses(),
      _loadProfileEmail(),
    ]);
    if (!mounted) return;
    _pickDefaultAddress();
  }

  Future<void> _loadProfileEmail() async {
    try {
      final profile = await UserProfileController().fetchUserData();
      if (!mounted) return;
      setState(() {
        _customerEmail = profile['cust_email']?.toString() ??
            profile['email']?.toString() ??
            '';
      });
    } catch (_) {}
  }

  void _pickDefaultAddress() {
    if (_addressController.addresses.isEmpty) return;
    Address? selected;
    for (final address in _addressController.addresses) {
      if (address.isDefault) {
        selected = address;
        break;
      }
    }
    selected ??= _addressController.addresses.first;
    setState(() => _selectedAddressId = selected!.id);
  }

  Address? get _selectedAddress {
    if (_selectedAddressId == null) return null;
    for (final address in _addressController.addresses) {
      if (address.id == _selectedAddressId) return address;
    }
    return null;
  }

  Future<void> _openAddAddressSheet() async {
    await showDialog<void>(
      context: context,
      builder: (_) => AddressFormWidget(
        onSave: (address) async {
          final ok = await _addressController.saveAddress(address);
          if (ok && mounted) {
            await _addressController.loadAddresses();
            Address? pick;
            for (final a in _addressController.addresses) {
              if (a.isDefault) {
                pick = a;
                break;
              }
            }
            pick ??= _addressController.addresses.isNotEmpty
                ? _addressController.addresses.last
                : null;
            if (pick != null) {
              setState(() => _selectedAddressId = pick!.id);
            }
          }
          return ok;
        },
      ),
    );
  }

  Future<void> _placeOrder() async {
    final selected = _selectedAddress;
    if (selected == null) {
      showApiSnackBar(context, 'Please select a delivery address', isError: true);
      return;
    }

    if (selected.phone.trim().isEmpty || selected.addressLine1.trim().isEmpty) {
      showApiSnackBar(context, 'Selected address is incomplete', isError: true);
      return;
    }

    final fields = checkoutFieldsFromAddress(
      fullName: selected.fullName,
      phone: selected.phone,
      addressLine: selected.addressLine1,
      landmark: selected.addressLine2 ?? '',
      city: selected.city,
      state: selected.state,
      pincode: selected.pincode,
      addressType: selected.category,
      email: _customerEmail,
    );

    if (fields['firstName']!.trim().isEmpty ||
        fields['phone']!.trim().isEmpty ||
        fields['address']!.trim().isEmpty ||
        fields['city']!.trim().isEmpty ||
        fields['state']!.trim().isEmpty ||
        fields['pincode']!.trim().isEmpty) {
      showApiSnackBar(
        context,
        'Please complete all required address fields',
        isError: true,
      );
      return;
    }

    _vm.resetSubmitState();

    final result = await _vm.submit(
      firstName: fields['firstName']!,
      lastName: fields['lastName']!,
      email: fields['email']!,
      phone: fields['phone']!,
      address: fields['address']!,
      city: fields['city']!,
      state: fields['state']!,
      pincode: fields['pincode']!,
      landmark: fields['landmark']!,
      addressType: fields['addressType']!,
      productId: widget.productId,
      quantity: widget.quantity,
      paymentMethodUi: _payment,
    );

    if (!mounted) return;

    final state = _vm.submitState;
    if (state is UiError<BuyNowResult>) {
      showApiSnackBar(context, state.message, isError: true);
      _vm.resetSubmitState();
      return;
    }

    if (result == null) {
      _vm.resetSubmitState();
      return;
    }

    final orderId = result.orderId;
    final txnId = result.txnId;
    final totalAmount = result.totalAmount;

    if (_payment == 'online') {
      final paymentUrl = result.paymentUrl;
      if (paymentUrl == null || paymentUrl.isEmpty) {
        _vm.resetSubmitState();
        await SweetAlert.error(
          context,
          message:
              'Could not start online payment. Please try again or use Cash on Delivery.',
        );
        return;
      }

      final paid = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => WalletPaymentWebView(
            paymentUrl: paymentUrl,
            amount: totalAmount ?? 0,
            onReturnVerify: (orderId.isNotEmpty || (txnId?.isNotEmpty ?? false))
                ? () => OrdersController.findOrPut().verifyOrderPayment(
                      orderId:
                          orderId.isNotEmpty ? int.tryParse(orderId) : null,
                      txnId: txnId,
                    )
                : null,
          ),
        ),
      );

      if (!mounted) return;
      _vm.resetSubmitState();

      if (paid != true) {
        await SweetAlert.warning(
          context,
          message: orderId.isNotEmpty
              ? 'Payment was not completed. Order #$orderId is pending until payment succeeds.'
              : 'Payment was not completed. Please try again.',
        );
        return;
      }

      if (orderId.isNotEmpty || (txnId?.isNotEmpty ?? false)) {
        final verified = await OrdersController.findOrPut().verifyOrderPayment(
          orderId: orderId.isNotEmpty ? int.tryParse(orderId) : null,
          txnId: txnId,
        );
        if (!verified) {
          if (!mounted) return;
          await SweetAlert.warning(
            context,
            message:
                'Payment was not completed. Order #$orderId is pending until payment succeeds.',
          );
          return;
        }
      }
    } else {
      _vm.resetSubmitState();
    }

    await OrdersController.findOrPut().loadOrders();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OrderSuccessScreen(
          orderId: orderId,
          txnId: txnId,
          totalAmount: totalAmount,
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.rubik(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _productSummary() {
    final unit = widget.unitPrice;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.softCard(radius: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shopping_bag_outlined,
              color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.productName,
                  style: GoogleFonts.rubik(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${widget.quantity}',
                  style: GoogleFonts.rubik(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (unit != null && unit > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '₹${unit.toStringAsFixed(0)} each',
                    style: GoogleFonts.rubik(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _addressCard(Address address) {
    final selected = _selectedAddressId == address.id;
    final label = address.category.isNotEmpty ? address.category : 'Home';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedAddressId = address.id),
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.06)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? AppColors.primary : Colors.grey.shade200,
                width: selected ? 1.5 : 1,
              ),
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  label.toLowerCase() == 'work'
                      ? Icons.work_outline
                      : Icons.home_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            label,
                            style: GoogleFonts.rubik(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          if (address.isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Default',
                                style: GoogleFonts.rubik(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address.fullName,
                        style: GoogleFonts.rubik(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${address.addressLine1}, ${address.city} - ${address.pincode}',
                        style: GoogleFonts.rubik(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                      Text(
                        address.phone,
                        style: GoogleFonts.rubik(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Radio<String>(
                  value: address.id,
                  groupValue: _selectedAddressId,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _selectedAddressId = v),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _paymentTile({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected = _payment == value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _payment = value),
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? AppColors.primary : Colors.grey.shade200,
                width: selected ? 1.5 : 1,
              ),
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.rubik(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.rubik(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Radio<String>(
                  value: value,
                  groupValue: _payment,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _payment = v!),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _vm.isSubmitting;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Text(
          'Buy Now',
          style: GoogleFonts.rubik(fontWeight: FontWeight.w600),
        ),
      ),
      body: Obx(() {
        final addressesLoading = _addressController.isLoading.value;
        final addresses = _addressController.addresses.toList();

        return Column(
          children: [
            Expanded(
              child: ApiStateView(
                status: isLoading ? ApiViewStatus.loading : ApiViewStatus.idle,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    _productSummary(),
                    const SizedBox(height: 20),
                    _sectionTitle('Deliver to'),
                    if (addressesLoading)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    else if (addresses.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: AppDecorations.softCard(radius: 16),
                        child: Column(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 40,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No saved address',
                              style: GoogleFonts.rubik(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add an address to continue',
                              style: GoogleFonts.rubik(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...addresses.map(_addressCard),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _openAddAddressSheet,
                        icon: const Icon(Icons.add, color: AppColors.primary),
                        label: Text(
                          'Add new address',
                          style: GoogleFonts.rubik(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _sectionTitle('Payment method'),
                    _paymentTile(
                      value: 'cod',
                      title: 'Cash on Delivery',
                      subtitle: 'Pay when your order arrives',
                      icon: Icons.payments_outlined,
                    ),
                    _paymentTile(
                      value: 'online',
                      title: 'Pay Online',
                      subtitle: 'UPI, card, or net banking',
                      icon: Icons.credit_card_rounded,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _placeOrder,
                    child: Text(
                      _payment == 'online'
                          ? 'Pay & Place Order'
                          : 'Place Order',
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
