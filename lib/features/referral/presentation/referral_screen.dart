import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/ui/api_view_state.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  String _code = '';
  double _balance = 0;
  ApiViewStatus _status = ApiViewStatus.loading;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _status = ApiViewStatus.loading);
    final result = await UrbanRootsApi.instance.support.referral();
    if (!mounted) return;
    if (result is ApiFailure) {
      setState(() {
        _status = ApiViewStatus.error;
        _error = (result as ApiFailure).message;
      });
      return;
    }
    final data = (result as ApiSuccess).data;
    _code = data['code']?.toString() ?? '';
    _balance = double.tryParse(data['balance']?.toString() ?? '0') ?? 0;
    setState(() => _status = ApiViewStatus.success);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Referral & Rewards', style: GoogleFonts.rubik(fontWeight: FontWeight.w600))),
      body: ApiStateView(
        status: _status,
        errorMessage: _error,
        onRetry: _load,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Card(
                child: ListTile(
                  title: const Text('Your Referral Code'),
                  subtitle: Text(_code, style: GoogleFonts.rubik(fontSize: 20, fontWeight: FontWeight.w700)),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _code));
                      showApiSnackBar(context, 'Code copied');
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Rewards Balance: ₹${_balance.toStringAsFixed(0)}',
                  style: GoogleFonts.rubik(fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
