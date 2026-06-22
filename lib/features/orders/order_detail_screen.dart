import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/order/order_status.dart';
import 'package:urban_roots/core/ui/api_view_state.dart';
import 'package:urban_roots/core/ui/network_image_widget.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart';
import 'package:urban_roots/features/orders/orders_controller.dart';
import 'package:urban_roots/features/orders/order_model.dart';
import 'package:urban_roots/features/orders/order_tracking_screen.dart';
import 'package:urban_roots/features/wallet/wallet_payment_webview.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({
    super.key,
    this.orderId,
    this.txnId,
    this.summary,
  });

  final int? orderId;
  final String? txnId;
  final Order? summary;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Order? _order;
  ApiViewStatus _status = ApiViewStatus.loading;
  String? _errorMessage;
  bool _isPaymentLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final hasTxn = widget.txnId != null && widget.txnId!.trim().isNotEmpty;
    final hasOrderId = widget.orderId != null && widget.orderId! > 0;
    if (!hasTxn && !hasOrderId) {
      setState(() {
        _status = ApiViewStatus.error;
        _errorMessage = 'Missing order reference';
      });
      return;
    }

    setState(() {
      _status = ApiViewStatus.loading;
      _errorMessage = null;
    });

    final detail = await OrdersController.findOrPut().loadOrderDetail(
      orderId: widget.orderId,
      txnId: widget.txnId,
    );

    if (!mounted) return;

    if (detail != null) {
      final merged = _mergeWithSummary(detail, widget.summary);
      OrdersController.findOrPut().upsertOrder(merged);
      setState(() {
        _order = merged;
        _status = ApiViewStatus.success;
      });
      return;
    }

    if (widget.summary != null) {
      setState(() {
        _order = widget.summary;
        _status = ApiViewStatus.success;
        _errorMessage = OrdersController.findOrPut().errorMessage.value.isNotEmpty
            ? OrdersController.findOrPut().errorMessage.value
            : null;
      });
      return;
    }

    setState(() {
      _status = ApiViewStatus.error;
      _errorMessage = OrdersController.findOrPut().errorMessage.value.isNotEmpty
          ? OrdersController.findOrPut().errorMessage.value
          : 'Could not load order details';
    });
  }

  Color _statusColor(String status) =>
      OrderStatus.fromString(status).color;

  Color _statusBg(String status) =>
      OrderStatus.fromString(status).backgroundColor;

  Widget _infoTile(String label, String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.rubik(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.rubik(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Order _mergeWithSummary(Order detail, Order? summary) {
    if (summary == null) return detail;

    final items = detail.items.length >= summary.items.length
        ? detail.items
        : summary.items;

    var total = detail.total > 0 ? detail.total : summary.total;
    if (total <= 0 && items.isNotEmpty) {
      total = items.fold(0.0, (sum, item) => sum + item.subtotal);
    }

    return Order(
      orderId: detail.orderId,
      txnId: detail.txnId.isNotEmpty ? detail.txnId : summary.txnId,
      date: detail.date.isNotEmpty ? detail.date : summary.date,
      total: total,
      status: detail.status.isNotEmpty ? detail.status : summary.status,
      items: items,
      paymentMethod: detail.paymentMethod.isNotEmpty
          ? detail.paymentMethod
          : summary.paymentMethod,
      paymentStatus: detail.paymentStatus.isNotEmpty
          ? detail.paymentStatus
          : summary.paymentStatus,
      pendingPaymentUrl: detail.pendingPaymentUrl.isNotEmpty
          ? detail.pendingPaymentUrl
          : summary.pendingPaymentUrl,
      customerName: detail.customerName.isNotEmpty
          ? detail.customerName
          : summary.customerName,
      email: detail.email.isNotEmpty ? detail.email : summary.email,
      phone: detail.phone.isNotEmpty ? detail.phone : summary.phone,
      address: detail.address.isNotEmpty ? detail.address : summary.address,
      city: detail.city.isNotEmpty ? detail.city : summary.city,
      state: detail.state.isNotEmpty ? detail.state : summary.state,
      pincode: detail.pincode.isNotEmpty ? detail.pincode : summary.pincode,
      landmark: detail.landmark.isNotEmpty ? detail.landmark : summary.landmark,
    );
  }

  String get _screenTitle {
    if (widget.orderId != null && widget.orderId! > 0) {
      return 'Order #${widget.orderId}';
    }
    final txn = widget.txnId ?? _order?.txnId ?? '';
    if (txn.isNotEmpty) return 'Order $txn';
    return 'Order Details';
  }

  int? get _resolvedOrderId {
    if (widget.orderId != null && widget.orderId! > 0) return widget.orderId;
    final fromOrder = _order?.orderId;
    return fromOrder != null && fromOrder > 0 ? fromOrder : null;
  }

  String? get _resolvedTxnId {
    if (widget.txnId != null && widget.txnId!.trim().isNotEmpty) {
      return widget.txnId!.trim();
    }
    final fromOrder = _order?.txnId ?? '';
    return fromOrder.isNotEmpty ? fromOrder : null;
  }

  Future<void> _reloadDetail() async {
    final detail = await OrdersController.findOrPut().loadOrderDetail(
      orderId: _resolvedOrderId,
      txnId: _resolvedTxnId,
    );
    if (!mounted || detail == null) return;
    setState(() => _order = _mergeWithSummary(detail, widget.summary));
  }

  Future<void> _payOnline() async {
    final order = _order;
    if (order == null || _isPaymentLoading) return;

    setState(() => _isPaymentLoading = true);
    final controller = OrdersController.findOrPut();
    final result = await controller.payOrderOnline(order);
    if (!mounted) return;
    setState(() => _isPaymentLoading = false);

    if (!result.success || result.paymentUrl == null) {
      await SweetAlert.error(
        context,
        message: result.message.isNotEmpty
            ? result.message
            : 'Could not start online payment',
      );
      return;
    }

    final paid = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => WalletPaymentWebView(
          paymentUrl: result.paymentUrl!,
          amount: order.total,
          onReturnVerify: () => OrdersController.findOrPut().verifyOrderPayment(
                orderId: _resolvedOrderId,
                txnId: _resolvedTxnId,
              ),
        ),
      ),
    );

    if (!mounted) return;
    await _reloadDetail();
    final paymentComplete = _order?.isPaymentComplete ?? false;
    if (paid == true && paymentComplete) {
      await SweetAlert.success(context, message: 'Payment completed successfully');
    } else {
      await SweetAlert.warning(
        context,
        message:
            'Payment was not completed. You can try again or choose pay at delivery.',
      );
    }
  }

  Future<void> _payOnDelivery() async {
    final order = _order;
    if (order == null || _isPaymentLoading) return;

    setState(() => _isPaymentLoading = true);
    final result = await OrdersController.findOrPut().payOrderOnDelivery(order);
    if (!mounted) return;
    setState(() => _isPaymentLoading = false);

    if (!result.success) {
      await SweetAlert.error(context, message: result.message);
      return;
    }

    await SweetAlert.success(context, message: result.message);
    await _reloadDetail();
  }

  Widget _paymentActionSection(Order order) {
    if (!order.needsPaymentAction) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Payment Pending',
            style: GoogleFonts.rubik(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.orange.shade900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose how you would like to pay for this order.',
            style: GoogleFonts.rubik(
              fontSize: 13,
              color: Colors.orange.shade900,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF019934),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isPaymentLoading ? null : _payOnline,
              icon: const Icon(Icons.payment, color: Colors.white),
              label: Text(
                'Pay Online',
                style: GoogleFonts.rubik(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF019934),
                side: const BorderSide(color: Color(0xFF019934)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isPaymentLoading ? null : _payOnDelivery,
              icon: const Icon(Icons.local_shipping_outlined),
              label: Text(
                'Pay at Delivery',
                style: GoogleFonts.rubik(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          _screenTitle,
          style: GoogleFonts.rubik(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
      body: ApiStateView(
        status: _status,
        errorMessage: _errorMessage,
        onRetry: _loadDetail,
        child: order == null
            ? const SizedBox.shrink()
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_errorMessage != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Text(
                        'Showing summary only. $_errorMessage',
                        style: GoogleFonts.rubik(
                          fontSize: 12,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Track Delivery',
                          style: GoogleFonts.rubik(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    OrderTrackingScreen(order: order),
                              ),
                            );
                          },
                          icon: const Icon(Icons.location_searching),
                          label: const Text('Track Order'),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Order Summary',
                                style: GoogleFonts.rubik(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _statusBg(
                                  order.status.isEmpty
                                      ? 'Processing'
                                      : order.status,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                order.status.isEmpty
                                    ? OrderStatus.processing.label
                                    : OrderStatus.fromString(order.status).label,
                                style: GoogleFonts.rubik(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _statusColor(order.status),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _infoTile('Date', order.date),
                        _infoTile('Total', '\u20B9${order.total.toStringAsFixed(0)}'),
                        if (order.paymentMethod.isNotEmpty)
                          _infoTile('Payment', order.paymentMethod),
                        if (order.paymentStatus.isNotEmpty)
                          _infoTile('Payment Status', order.paymentStatus),
                      ],
                    ),
                  ),
                  _paymentActionSection(order),
                  if (order.customerName.isNotEmpty ||
                      order.phone.isNotEmpty ||
                      order.formattedAddress.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delivery Details',
                            style: GoogleFonts.rubik(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _infoTile('Name', order.customerName),
                          _infoTile('Phone', order.phone),
                          _infoTile('Address', order.formattedAddress),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Items',
                          style: GoogleFonts.rubik(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (order.items.isEmpty)
                          Text(
                            'No item details available',
                            style: GoogleFonts.rubik(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          )
                        else
                          ...order.items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  NetworkOrAssetImage(
                                    url: item.imageUrl,
                                    width: 52,
                                    height: 52,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: GoogleFonts.rubik(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item.quantity > 1 && item.unitPrice > 0
                                              ? 'Qty: ${item.quantity} × ₹${item.unitPrice.toStringAsFixed(0)}'
                                              : 'Qty: ${item.quantity}',
                                          style: GoogleFonts.rubik(
                                            fontSize: 12,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '\u20B9${item.subtotal.toStringAsFixed(0)}',
                                    style: GoogleFonts.rubik(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF019934),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
