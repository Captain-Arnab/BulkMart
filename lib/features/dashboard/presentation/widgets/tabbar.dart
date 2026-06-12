import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';

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
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceMint,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey.shade600,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(4),
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelStyle: GoogleFonts.rubik(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.rubik(fontSize: 12),
              tabs: const [
                Tab(text: 'Description'),
                Tab(text: 'Health Benefits'),
                Tab(text: 'Selling Points'),
                Tab(text: 'Nutrition'),
              ],
            ),
          ),
          const SizedBox(height: 12),
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
                  sellingPoints.isEmpty
                      ? 'No selling points provided.'
                      : sellingPoints,
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Html(
          data: content,
          style: {
            'body': Style(
              fontSize: FontSize(14),
              fontWeight: FontWeight.w400,
              color: Colors.black87,
              lineHeight: const LineHeight(1.6),
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
            ),
          },
        ),
      ),
    );
  }
}
