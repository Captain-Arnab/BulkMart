import 'package:flutter/material.dart';

class WebViewExample extends StatefulWidget {
  final String url;
  const WebViewExample({super.key, required this.url});

  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web View'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Text('Web view disabled in demo mode'),
      ),
    );
  }
}
