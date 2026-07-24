import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/theme/app_colors.dart';
import 'package:urban_roots/core/ui/api_view_state.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart';
import 'package:urban_roots/data/network/api_result.dart';
import 'package:urban_roots/features/payments/card_save_flow.dart';
import 'package:urban_roots/features/payments/cards_controller.dart';
import 'package:urban_roots/features/payments/models/saved_card.dart';

class SavedCardsScreen extends StatefulWidget {
  const SavedCardsScreen({super.key});

  @override
  State<SavedCardsScreen> createState() => _SavedCardsScreenState();
}

class _SavedCardsScreenState extends State<SavedCardsScreen> {
  late final CardsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CardsController.findOrPut();
    _controller.loadCards();
  }

  Future<void> _addCard() async {
    await startSaveCardFlow(context);
  }

  Future<void> _deleteCard(SavedCard card) async {
    await SweetAlert.confirm(
      context,
      title: 'Remove card',
      message:
          'Remove ${card.maskedNumber}${card.cardNetwork.isNotEmpty ? ' (${card.cardNetwork})' : ''}?',
      confirmText: 'Remove',
      onConfirm: () async {
        final result = await _controller.deleteCard(card.cardTokenId);
        if (!mounted) return;
        if (result is ApiFailure<void>) {
          await SweetAlert.error(context, message: result.message);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Saved Cards',
          style: GoogleFonts.rubik(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _controller.isSaving.value ? null : _addCard,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_card_outlined, color: Colors.white),
        label: Text(
          'Save Card',
          style: GoogleFonts.rubik(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Obx(() {
        if (_controller.isLoading.value && _controller.cards.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (_controller.errorMessage.value.isNotEmpty &&
            _controller.cards.isEmpty) {
          return ApiStateView(
            status: ApiViewStatus.error,
            errorMessage: _controller.errorMessage.value,
            onRetry: _controller.loadCards,
            child: const SizedBox(),
          );
        }
        if (_controller.cards.isEmpty) {
          return ApiStateView(
            status: ApiViewStatus.empty,
            emptyMessage: 'No saved cards yet.\nTap Save Card to add one.',
            child: const SizedBox(),
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _controller.loadCards,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            itemCount: _controller.cards.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final card = _controller.cards[index];
              return _SavedCardTile(
                card: card,
                onDelete: () => _deleteCard(card),
              );
            },
          ),
        );
      }),
    );
  }
}

class _SavedCardTile extends StatelessWidget {
  const _SavedCardTile({
    required this.card,
    required this.onDelete,
  });

  final SavedCard card;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final networkColor = cardNetworkColor(card.cardNetwork);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: networkColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              cardNetworkIcon(card.cardNetwork),
              color: networkColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.maskedNumber,
                  style: GoogleFonts.rubik(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    if (card.cardNetwork.isNotEmpty) card.cardNetwork,
                    if (card.expiryDisplay.isNotEmpty)
                      'Exp ${card.expiryDisplay}',
                  ].join(' · '),
                  style: GoogleFonts.rubik(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            tooltip: 'Remove card',
            icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
          ),
        ],
      ),
    );
  }
}
