import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';

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
      child: Column(
        children: [
          TabBar(
            labelColor: const Color(0xFF019934),
            unselectedLabelColor: Colors.grey.shade600,
            indicatorColor: const Color(0xFF019934),
            isScrollable: true,
            labelStyle: GoogleFonts.rubik(fontSize: 12, fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'Description'),
              Tab(text: 'Health Benefits'),
              Tab(text: 'Selling Points'),
              Tab(text: 'Nutrition'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildScrollableHtmlTabContent(
                  description.isEmpty ? 'No description available.' : description,
                ),
                _buildScrollableHtmlTabContent(
                  healthBenefits.isEmpty
                      ? 'No health benefits information available.'
                      : healthBenefits,
                ),
                _buildScrollableHtmlTabContent(
                  sellingPoints.isEmpty ? 'No selling points provided.' : sellingPoints,
                ),
                _buildScrollableHtmlTabContent(
                  nutritionalInfo.isEmpty
                      ? 'No nutritional information available.'
                      : nutritionalInfo,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableHtmlTabContent(String content) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Html(
        data: content,
        style: {
          'body': Style(
            fontSize: FontSize(14),
            fontWeight: FontWeight.w400,
            color: Colors.black87,
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
          ),
        },
      ),
    );
  }
}
