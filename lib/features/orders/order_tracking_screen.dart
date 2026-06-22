import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:urban_roots/core/order/order_status.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/api_view_state.dart';
import 'package:urban_roots/features/orders/order_model.dart';
import 'package:urban_roots/features/orders/order_tracking_models.dart';
import 'package:urban_roots/features/orders/orders_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key, required this.order});

  final Order order;

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with SingleTickerProviderStateMixin {
  final _controller = OrdersController.findOrPut();
  GoogleMapController? _mapController;
  late AnimationController _pulseController;

  ApiViewStatus _status = ApiViewStatus.loading;
  String? _errorMessage;
  OrderTrackingData? _tracking;
  OrderLiveTrackingData? _liveTracking;
  Timer? _trackingTimer;
  Timer? _liveTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _loadAll(showLoading: true);
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    _liveTimer?.cancel();
    _pulseController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  OrderStatus get _orderStatus {
    final fromTracking = _tracking?.orderStatus ?? '';
    if (fromTracking.isNotEmpty) {
      return OrderStatus.fromString(fromTracking);
    }
    return OrderStatus.fromString(widget.order.status);
  }

  String get _headlineStatus {
    final fromApi = _tracking?.orderStatus.trim() ?? '';
    if (fromApi.isNotEmpty) return fromApi;
    return _orderStatus.label;
  }

  bool get _isCompleted => _tracking?.completed ?? _orderStatus.isTerminal;

  int get _statusCode =>
      _tracking?.statusCode ?? _orderStatus.trackingCode;

  bool get _showLiveMap => _tracking?.showLiveMap ?? (_statusCode >= 3 && !_isCompleted);

  List<OrderTrackingStep> get _steps {
    if (_tracking != null && _tracking!.steps.isNotEmpty) {
      return _tracking!.steps;
    }
    return buildFallbackTrackingSteps(_headlineStatus);
  }

  void _configurePolling() {
    _trackingTimer?.cancel();
    _liveTimer?.cancel();

    if (_isCompleted) return;

    _trackingTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _loadTracking(showLoading: false),
    );

    if (_showLiveMap) {
      _liveTimer = Timer.periodic(
        const Duration(seconds: 15),
        (_) => _loadLiveTracking(),
      );
    }
  }

  Future<void> _loadAll({required bool showLoading}) async {
    await _loadTracking(showLoading: showLoading);
    if (_showLiveMap) {
      await _loadLiveTracking();
    }
    _configurePolling();
  }

  Future<void> _loadTracking({required bool showLoading}) async {
    if (showLoading) {
      setState(() {
        _status = ApiViewStatus.loading;
        _errorMessage = null;
      });
    }

    final result = await _controller.loadOrderTracking(
      orderId: widget.order.orderId,
      txnId: widget.order.txnId,
    );

    if (!mounted) return;

    if (result.data != null) {
      setState(() {
        _tracking = result.data;
        _status = ApiViewStatus.success;
        _errorMessage = null;
      });
      if (_isCompleted) {
        _trackingTimer?.cancel();
        _liveTimer?.cancel();
      }
      return;
    }

    if (showLoading && widget.order.status.trim().isEmpty) {
      setState(() {
        _status = ApiViewStatus.error;
        _errorMessage = result.userMessage ?? 'Unable to load tracking';
      });
    } else if (showLoading) {
      setState(() => _status = ApiViewStatus.success);
    }
  }

  Future<void> _loadLiveTracking() async {
    if (widget.order.orderId <= 0 || !_showLiveMap || _isCompleted) return;

    final result = await _controller.loadLiveTracking(
      orderId: widget.order.orderId,
    );

    if (!mounted || result.data == null) return;

    setState(() => _liveTracking = result.data);
    _moveMapToLocation();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _moveMapToLocation();
  }

  Future<void> _moveMapToLocation() async {
    final controller = _mapController;
    final location = _liveTracking?.location;
    if (controller == null || location == null) return;

    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(location.latitude, location.longitude),
        15,
      ),
    );
  }

  Future<void> _callDeliveryPartner() async {
    final phone = _liveTracking?.agentPhone.trim() ?? '';
    if (phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget _terminalBanner() {
    if (!_isCompleted) return const SizedBox.shrink();

    final isCancelled = _orderStatus == OrderStatus.cancelled;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCancelled ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCancelled ? Colors.red.shade200 : Colors.green.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCancelled ? Icons.cancel_outlined : Icons.check_circle_outline,
            color: isCancelled ? Colors.red.shade700 : Colors.green.shade700,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isCancelled ? 'Order Cancelled' : 'Order Completed',
              style: GoogleFonts.rubik(
                fontWeight: FontWeight.w700,
                color: isCancelled ? Colors.red.shade800 : Colors.green.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _liveMapSection() {
    if (!_showLiveMap) return const SizedBox.shrink();

    final location = _liveTracking?.location;
    if (location == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.map_outlined, color: Colors.grey.shade500),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Live location will appear when the delivery partner is on the way.',
                style: GoogleFonts.rubik(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 240,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(location.latitude, location.longitude),
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('delivery'),
                  position: LatLng(location.latitude, location.longitude),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueAzure,
                  ),
                  infoWindow: const InfoWindow(title: 'Delivery partner'),
                ),
              },
              myLocationEnabled: false,
              zoomControlsEnabled: true,
            ),
          ),
        ),
        if (_liveTracking?.eta.isNotEmpty ?? false) ...[
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Chip(
              avatar: const Icon(Icons.schedule, size: 18, color: AppColors.primary),
              label: Text(
                'ETA: ${_liveTracking!.eta}',
                style: GoogleFonts.rubik(fontWeight: FontWeight.w600),
              ),
              backgroundColor: AppColors.primary.withValues(alpha: 0.08),
            ),
          ),
        ],
        if ((_liveTracking?.agentName.isNotEmpty ?? false) ||
            (_liveTracking?.agentPhone.isNotEmpty ?? false)) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery Partner',
                        style: GoogleFonts.rubik(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        _liveTracking!.agentName.isNotEmpty
                            ? _liveTracking!.agentName
                            : 'Assigned',
                        style: GoogleFonts.rubik(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_liveTracking!.agentPhone.isNotEmpty)
                  IconButton.filled(
                    onPressed: _callDeliveryPartner,
                    icon: const Icon(Icons.call),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _stepRow(OrderTrackingStep step, bool isLast) {
    final scale = step.isCurrent
        ? 1.0 + (_pulseController.value * 0.08)
        : 1.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Transform.scale(
              scale: scale,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: step.completed
                      ? AppColors.primary
                      : step.isCurrent
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : Colors.grey.shade300,
                  shape: BoxShape.circle,
                  border: step.isCurrent
                      ? Border.all(color: AppColors.primary, width: 2)
                      : null,
                ),
                child: Icon(
                  step.completed
                      ? Icons.check
                      : step.isCurrent
                          ? Icons.radio_button_checked
                          : Icons.circle,
                  size: step.completed || step.isCurrent ? 16 : 10,
                  color: step.completed
                      ? Colors.white
                      : step.isCurrent
                          ? AppColors.primary
                          : Colors.white,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: step.completed
                    ? ColoredBox(color: AppColors.primary)
                    : CustomPaint(
                        painter: _DashedLinePainter(color: Colors.grey.shade300),
                      ),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.label,
                  style: GoogleFonts.rubik(
                    fontSize: 15,
                    fontWeight: step.isCurrent || step.completed
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: step.completed || step.isCurrent
                        ? Colors.black87
                        : Colors.grey.shade500,
                  ),
                ),
                if (step.timestamp.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    step.timestamp,
                    style: GoogleFonts.rubik(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Track Order #${widget.order.orderId}',
              style: GoogleFonts.rubik(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: _status == ApiViewStatus.loading
                    ? null
                    : () => _loadAll(showLoading: true),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: ApiStateView(
            status: _status,
            errorMessage: _errorMessage,
            onRetry: () => _loadAll(showLoading: true),
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => _loadAll(showLoading: false),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  _terminalBanner(),
                  if (_isCompleted) const SizedBox(height: 12),
                  Text(
                    _headlineStatus,
                    style: GoogleFonts.rubik(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: _orderStatus.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _liveMapSection(),
                  if (_showLiveMap) const SizedBox(height: 16),
                  Text(
                    'Order Status',
                    style: GoogleFonts.rubik(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(_steps.length, (index) {
                    return _stepRow(
                      _steps[index],
                      index == _steps.length - 1,
                    );
                  }),
                  if (widget.order.formattedAddress.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delivering to',
                            style: GoogleFonts.rubik(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.order.formattedAddress,
                            style: GoogleFonts.rubik(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    const dashHeight = 4.0;
    const gap = 4.0;
    var y = 0.0;
    while (y < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, y + dashHeight),
        paint,
      );
      y += dashHeight + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
