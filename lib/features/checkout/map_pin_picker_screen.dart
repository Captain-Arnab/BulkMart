import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:urban_roots/core/location/location_service.dart';
import 'package:urban_roots/core/theme/app_colors.dart';

/// Pick delivery location on map; reverse geocodes on confirm.
class MapPinPickerScreen extends StatefulWidget {
  const MapPinPickerScreen({
    super.key,
    this.initialLat = 17.385044,
    this.initialLng = 78.486671,
  });

  final double initialLat;
  final double initialLng;

  @override
  State<MapPinPickerScreen> createState() => _MapPinPickerScreenState();
}

class _MapPinPickerScreenState extends State<MapPinPickerScreen> {
  late LatLng _pin;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _pin = LatLng(widget.initialLat, widget.initialLng);
  }

  Future<void> _confirm() async {
    setState(() => _loading = true);
    try {
      final address = await LocationService.instance.reverseGeocode(
        _pin.latitude,
        _pin.longitude,
      );
      if (!mounted) return;
      Navigator.pop(context, address);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not resolve address: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pin on Map',
          style: GoogleFonts.rubik(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _pin, zoom: 15),
            onCameraMove: (position) => _pin = position.target,
            onCameraIdle: () {},
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
          ),
          const Center(
            child: Icon(Icons.location_pin, size: 48, color: AppColors.primary),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: ElevatedButton(
              onPressed: _loading ? null : _confirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Confirm Location',
                      style: GoogleFonts.rubik(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
