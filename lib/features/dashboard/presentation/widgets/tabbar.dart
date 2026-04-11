import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class TabBarWidget extends StatelessWidget {
  final String name;
  final String description;
  final String healthBenefits;
  final String sellingPoints;
  final String nutritionalInfo;

  const TabBarWidget({
    super.key,
    required this.name,
    required this.description,
    required this.healthBenefits,
    required this.sellingPoints,
    required this.nutritionalInfo,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            name,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20.0),
          ),
          bottom: TabBar(
            labelColor: Theme.of(context).primaryColor,
            indicatorColor: Theme.of(context).primaryColor,
            isScrollable: true,
            tabs: [
              Tab(child: Text('Description')),
              Tab(child: Text('Health Benefits')),
              Tab(child: Text('Unique Selling Points')),
              Tab(child: Text('Nutritional Information')),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            _buildScrollableHtmlTabContent(description.isEmpty ? "No description available." : description),
            _buildScrollableHtmlTabContent(healthBenefits.isEmpty ? "No health benefits information available." : healthBenefits),
            _buildScrollableHtmlTabContent(sellingPoints.isEmpty ? "No selling points provided." : sellingPoints),
            _buildScrollableHtmlTabContent(nutritionalInfo.isEmpty ? "No nutritional information available." : nutritionalInfo),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableHtmlTabContent(String content) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Html(
          data: content,
          style: {
            "body": Style(
              fontSize: FontSize(14.0),
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          },
        ),
      ),
    );
  }
}
