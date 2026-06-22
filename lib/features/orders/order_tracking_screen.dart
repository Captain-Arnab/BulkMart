import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/api_view_state.dart';
import 'package:urban_roots/features/orders/order_model.dart';
import 'package:urban_roots/features/orders/order_tracking_models.dart';
import 'package:urban_roots/features/orders/orders_controller.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key, required this.order});

  final Order order;

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final _controller = OrdersController.findOrPut();
  GoogleMapController? _mapController;

  ApiViewStatus _status = ApiViewStatus.loading;
  String? _errorMessage;
  OrderTrackingData? _tracking;
  OrderLiveTrackingData? _liveTracking;
  Timer? _liveRefreshTimer;
  bool _liveTrackingUnavailable = false;

  @override
  void initState() {
    super.initState();
    _loadTracking(refreshLiveOnly: false);
    _liveRefreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        if (!_liveTrackingUnavailable) {
          _loadTracking(refreshLiveOnly: true);
        }
      },
    );
  }

  @override
  void dispose() {
    _liveRefreshTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  String get _rawStatusValue =>
      _tracking?.statusCode ??
      _liveTracking?.statusCode ??
      _tracking?.status ??
      _liveTracking?.status ??
      widget.order.status;

  List<OrderTrackingStep> get _rawTimelineSteps {
    if (_tracking != null && _tracking!.steps.isNotEmpty) {
      return _tracking!.steps;
    }
    return buildFallbackTrackingSteps(widget.order.status);
  }

  String get _effectiveStatusCode => reconcileStatusCode(
        apiCode: _tracking?.statusCode ?? _liveTracking?.statusCode,
        orderStatus: widget.order.status,
        steps: _rawTimelineSteps,
      );

  List<OrderTrackingStep> get _timelineSteps => normalizeTrackingSteps(
        steps: _rawTimelineSteps,
        statusCode: _effectiveStatusCode,
        orderStatus: widget.order.status,
      );

  String get _displayStatus {
    return resolveTrackingDisplayStatus(
      rawStatus: _effectiveStatusCode.isNotEmpty
          ? _effectiveStatusCode
          : _rawStatusValue,
      steps: _timelineSteps,
      orderStatusFallback: widget.order.status,
    );
  }

  TrackingCoordinate? get _destination =>
      _liveTracking?.destination ?? _tracking?.destination;

  TrackingCoordinate? get _agent => _liveTracking?.agent;

  String get _agentName {
    final live = _liveTracking?.agentName.trim() ?? '';
    if (live.isNotEmpty) return live;
    return _tracking?.agentName.trim() ?? '';
  }

  String get _agentPhone {
    final live = _liveTracking?.agentPhone.trim() ?? '';
    if (live.isNotEmpty) return live;
    return _tracking?.agentPhone.trim() ?? '';
  }

  String get _eta {
    final live = _liveTracking?.eta.trim() ?? '';
    if (live.isNotEmpty) return live;
    return _tracking?.eta.trim() ?? '';
  }

  Future<void> _loadTracking({required bool refreshLiveOnly}) async {
    if (!refreshLiveOnly) {
      setState(() {
        _status = ApiViewStatus.loading;
        _errorMessage = null;
      });
    }

    OrderTrackingData? tracking = _tracking;
    OrderLiveTrackingData? live = _liveTracking;
    String? trackingError;

    if (!refreshLiveOnly) {
      final trackingResult = await _controller.loadOrderTracking(
        orderId: widget.order.orderId,
        txnId: widget.order.txnId,
      );
      tracking = trackingResult.data;
      trackingError = trackingResult.userMessage;
    }

    if (widget.order.orderId > 0 && !_liveTrackingUnavailable) {
      final liveResult = await _controller.loadLiveTracking(
        orderId: widget.order.orderId,
      );
      live = liveResult.data;
      if (liveResult.data == null && liveResult.unavailable) {
        _liveTrackingUnavailable = true;
      }
    }

    if (!mounted) return;

    final trackingFailed =
        !refreshLiveOnly && tracking == null && trackingError != null;
    final canShowFallback = widget.order.status.trim().isNotEmpty ||
        (_tracking?.steps.isNotEmpty ?? false);

    setState(() {
      if (tracking != null) _tracking = tracking;
      if (live != null) _liveTracking = live;
      if (trackingFailed && !canShowFallback) {
        _status = ApiViewStatus.error;
        _errorMessage = trackingError;
      } else {
        _status = ApiViewStatus.success;
        _errorMessage = null;
      }
    });

    if (_destination != null || _agent != null) {
      _fitMapToMarkers();
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _fitMapToMarkers();
  }

  Future<void> _fitMapToMarkers() async {
    final controller = _mapController;
    if (controller == null) return;

    final points = <LatLng>[];
    final destination = _destination;
    final agent = _agent;
    if (destination != null) {
      points.add(LatLng(destination.latitude, destination.longitude));
    }
    if (agent != null) {
      points.add(LatLng(agent.latitude, agent.longitude));
    }
    if (points.isEmpty) return;

    if (points.length == 1) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(points.first, 14),
      );
      return;
    }

    var bounds = LatLngBounds(southwest: points.first, northeast: points.first);
    for (final point in points.skip(1)) {
      bounds = LatLngBounds(
        southwest: LatLng(
          point.latitude < bounds.southwest.latitude
              ? point.latitude
              : bounds.southwest.latitude,
          point.longitude < bounds.southwest.longitude
              ? point.longitude
              : bounds.southwest.longitude,
        ),
        northeast: LatLng(
          point.latitude > bounds.northeast.latitude
              ? point.latitude
              : bounds.northeast.latitude,
          point.longitude > bounds.northeast.longitude
              ? point.longitude
              : bounds.northeast.longitude,
        ),
      );
    }

    await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 72));
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};
    final destination = _destination;
    final agent = _agent;

    if (destination != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(destination.latitude, destination.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: 'Delivery Address',
            snippet: widget.order.formattedAddress,
          ),
        ),
      );
    }

    if (agent != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('agent'),
          position: LatLng(agent.latitude, agent.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(
            title: _agentName.isNotEmpty ? _agentName : 'Delivery Agent',
            snippet: _eta.isNotEmpty ? 'ETA: $_eta' : 'On the way',
          ),
        ),
      );
    }

    return markers;
  }

  Widget _mapSection() {
    final destination = _destination;
    final agent = _agent;
    final hasMap = destination != null || agent != null;

    if (!hasMap) {
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
                'Live map will appear once your delivery location is shared.',
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

    final initialTarget = agent != null
        ? LatLng(agent.latitude, agent.longitude)
        : LatLng(destination!.latitude, destination.longitude);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 260,
        child: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: initialTarget,
            zoom: 14,
          ),
          markers: _buildMarkers(),
          myLocationEnabled: false,
          zoomControlsEnabled: true,
        ),
      ),
    );
  }

  Widget _agentInfoCard() {
    if (_agentName.isEmpty && _agentPhone.isEmpty && _eta.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
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
            'Delivery Partner',
            style: GoogleFonts.rubik(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (_agentName.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _agentName,
              style: GoogleFonts.rubik(fontSize: 14),
            ),
          ],
          if (_agentPhone.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              _agentPhone,
              style: GoogleFonts.rubik(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
          if (_eta.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'ETA: $_eta',
              style: GoogleFonts.rubik(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                : () => _loadTracking(refreshLiveOnly: false),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: ApiStateView(
        status: _status,
        errorMessage: _errorMessage,
        onRetry: () => _loadTracking(refreshLiveOnly: false),
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => _loadTracking(refreshLiveOnly: false),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              _mapSection(),
              const SizedBox(height: 16),
              _agentInfoCard(),
              if (_agentName.isNotEmpty ||
                  _agentPhone.isNotEmpty ||
                  _eta.isNotEmpty)
                const SizedBox(height: 16),
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
                      'Current Status',
                      style: GoogleFonts.rubik(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _displayStatus,
                      style: GoogleFonts.rubik(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Order Status',
                style: GoogleFonts.rubik(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(_timelineSteps.length, (index) {
                final step = _timelineSteps[index];
                final isLast = index == _timelineSteps.length - 1;
                final isActive = step.isCurrent;
                final isComplete = step.completed;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isComplete || isActive
                                ? AppColors.primary
                                : Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isComplete
                                ? Icons.check
                                : isActive
                                    ? Icons.radio_button_checked
                                    : Icons.circle,
                            size: isComplete || isActive ? 16 : 10,
                            color: Colors.white,
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 36,
                            color: isComplete
                                ? AppColors.primary
                                : Colors.grey.shade300,
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step.label,
                              style: GoogleFonts.rubik(
                                fontSize: 15,
                                fontWeight: isComplete || isActive
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isComplete || isActive
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
              }),
              if (widget.order.formattedAddress.isNotEmpty) ...[
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
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
