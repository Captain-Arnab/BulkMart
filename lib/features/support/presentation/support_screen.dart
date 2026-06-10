import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/ui/api_view_state.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/data/network/urban_roots_api.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _subject = TextEditingController();
  final _message = TextEditingController();
  final _orderId = TextEditingController();
  ApiViewStatus _status = ApiViewStatus.idle;

  Future<void> _submit() async {
    if (_subject.text.isEmpty || _message.text.isEmpty) {
      showApiSnackBar(context, 'Subject and message are required', isError: true);
      return;
    }
    setState(() => _status = ApiViewStatus.loading);
    final result = await UrbanRootsApi.instance.support.createTicket(
      subject: _subject.text,
      message: _message.text,
      orderId: _orderId.text.isEmpty ? null : _orderId.text,
    );
    if (!mounted) return;
    setState(() => _status = ApiViewStatus.idle);
    if (result is ApiFailure) {
      showApiSnackBar(context, (result as ApiFailure).message, isError: true);
      return;
    }
    final ticketId = (result as ApiSuccess).data['ticket_id'];
    showApiSnackBar(context, 'Ticket #$ticketId created');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Help & Support', style: GoogleFonts.rubik(fontWeight: FontWeight.w600))),
      body: ApiStateView(
        status: _status,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(controller: _subject, decoration: const InputDecoration(labelText: 'Subject')),
              TextField(controller: _orderId, decoration: const InputDecoration(labelText: 'Order ID (optional)')),
              TextField(controller: _message, maxLines: 5, decoration: const InputDecoration(labelText: 'Message')),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _submit, child: const Text('Submit')),
            ],
          ),
        ),
      ),
    );
  }
}
