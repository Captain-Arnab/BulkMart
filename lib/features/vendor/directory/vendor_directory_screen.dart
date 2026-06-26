import 'package:flutter/material.dart';
import 'package:urban_roots/data/network/services/vendor_api_service.dart';

class VendorDirectoryScreen extends StatefulWidget {
  const VendorDirectoryScreen({super.key});

  @override
  State<VendorDirectoryScreen> createState() => _VendorDirectoryScreenState();
}

class _VendorDirectoryScreenState extends State<VendorDirectoryScreen> {
  final _api = VendorApiService.instance;
  var _loading = true;
  String? _error;
  var _vendors = <({String name, String status})>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await _api.vendorList();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = result.error;
      _vendors =
          result.vendors.map((v) => (name: v.name, status: v.status)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vendor Directory')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!),
                      ElevatedButton(
                          onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    itemCount: _vendors.length,
                    itemBuilder: (context, index) {
                      final v = _vendors[index];
                      return ListTile(
                        title: Text(v.name),
                        subtitle: Text(v.status),
                      );
                    },
                  ),
                ),
    );
  }
}
