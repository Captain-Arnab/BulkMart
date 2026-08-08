import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/ui/app_motion.dart';
import '../../../core/ui/pressable_scale.dart';
import '../../../models/order.dart';
import '../../../models/support_ticket.dart';
import '../../../repositories/order_repository.dart';
import '../../../repositories/support_repository.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/auth_widgets.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _search = TextEditingController();
  int? _expandedFaq;
  String? _ticketId;
  List<SupportTicket> _tickets = [];
  bool _loadingTickets = true;

  static const _faqs = [
    (
      q: 'How do I track my order?',
      a: 'Open the Orders tab and tap any order card to see live status, timeline, and estimated delivery.',
    ),
    (
      q: 'What is the minimum order quantity?',
      a: 'Each product shows an MOQ badge. You must order at least that many units of the SKU.',
    ),
    (
      q: 'How does Cash on Delivery work?',
      a: 'VeggiiCart is COD-only. Pay the delivery partner in cash when your order arrives — no cards or UPI needed.',
    ),
    (
      q: 'Can I cancel an order?',
      a: 'You can request cancellation from order details while the order is still pending or confirmed. Once out for delivery, contact support.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadTickets() async {
    setState(() => _loadingTickets = true);
    final result = await context.read<SupportRepository>().fetchTickets();
    if (!mounted) return;
    result.when(
      success: (list) => setState(() {
        _tickets = list;
        _loadingTickets = false;
      }),
      failure: (_, {statusCode}) => setState(() => _loadingTickets = false),
    );
  }

  List<({String q, String a})> get _filteredFaqs {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return _faqs;
    return _faqs
        .where((f) => f.q.toLowerCase().contains(q) || f.a.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _callSupport() async {
    final uri = Uri.parse('tel:+918000000000');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _whatsApp() async {
    final uri = Uri.parse('https://wa.me/918000000000?text=Hi%20VeggiiCart%20Support');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _raiseTicket() async {
    final result = await showModalBottomSheet<_TicketResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _TicketSheet(),
    );
    if (result == null || !mounted) return;
    setState(() {
      _ticketId = result.ticket.id;
      _tickets = [result.ticket, ..._tickets.where((t) => t.id != result.ticket.id)];
    });
    showAppSuccessSnackBar(context, message: 'Support ticket submitted');
  }

  @override
  Widget build(BuildContext context) {
    final faqs = _filteredFaqs;

    return Scaffold(
      backgroundColor: AppColors.section,
      appBar: AppBar(
        backgroundColor: AppColors.section,
        elevation: 0,
        foregroundColor: AppColors.ink,
        title: Text('Help & Support', style: AppTextStyles.display(fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          PillTextField(
            controller: _search,
            hint: 'Search for help',
            prefix: const Padding(
              padding: EdgeInsets.only(left: 14),
              child: Icon(Icons.search_rounded, color: AppColors.muted, size: 22),
            ),
            onChanged: (_) => setState(() {}),
          ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.08, end: 0),
          const SizedBox(height: 20),
          Text('FAQs', style: AppTextStyles.display(fontSize: 18))
              .animate()
              .fadeIn(delay: 40.ms, duration: 200.ms),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              children: List.generate(faqs.length, (i) {
                final faq = faqs[i];
                final open = _expandedFaq == i;
                return Column(
                  children: [
                    if (i > 0) const Divider(height: 1, color: AppColors.line),
                    PressableScale(
                      onTap: () => setState(() => _expandedFaq = open ? null : i),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    faq.q,
                                    style: AppTextStyles.body(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                AnimatedRotation(
                                  turns: open ? 0.5 : 0,
                                  duration: AppMotion.normal,
                                  child: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                            AnimatedSize(
                              duration: AppMotion.normal,
                              curve: AppMotion.ease,
                              alignment: Alignment.topCenter,
                              child: open
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 10, right: 8),
                                      child: Text(
                                        faq.a,
                                        style: AppTextStyles.body(
                                          fontSize: 13,
                                          color: AppColors.muted,
                                          height: 1.45,
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ).animate().fadeIn(delay: 80.ms, duration: 220.ms),
          const SizedBox(height: 16),
          if (_ticketId != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
              ),
              child: Text(
                'Ticket #$_ticketId raised — we\'ll respond within 24 hours',
                style: AppTextStyles.body(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          PressableScale(
            onTap: _raiseTicket,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.greenSoft,
                borderRadius: BorderRadius.circular(AppRadii.lg),
                boxShadow: AppShadows.card,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.violet,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.confirmation_number_outlined, color: AppColors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Raise a Support Ticket',
                          style: AppTextStyles.body(fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Order, delivery, product, or account help',
                          style: AppTextStyles.body(fontSize: 12, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.violet),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 120.ms, duration: 220.ms),
          const SizedBox(height: 24),
          Text('My Tickets', style: AppTextStyles.display(fontSize: 16)),
          const SizedBox(height: 10),
          if (_loadingTickets)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.violet),
                ),
              ),
            )
          else if (_tickets.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: Border.all(color: AppColors.line),
              ),
              child: Text(
                'No tickets yet. Raise one above if you need help.',
                style: AppTextStyles.body(fontSize: 13, color: AppColors.muted),
              ),
            )
          else
            ..._tickets.map((t) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            t.id,
                            style: AppTextStyles.mono(fontSize: 11, color: AppColors.slate),
                          ),
                        ),
                        Text(
                          t.status.toUpperCase(),
                          style: AppTextStyles.body(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.violet,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t.subject,
                      style: AppTextStyles.body(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body(fontSize: 12, color: AppColors.muted),
                    ),
                    if (t.relatedOrderId != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Order ${t.relatedOrderId}',
                        style: AppTextStyles.mono(fontSize: 10, color: AppColors.muted),
                      ),
                    ],
                  ],
                ),
              );
            }),
          const SizedBox(height: 24),
          Text('Still need help?', style: AppTextStyles.display(fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: PressableScale(
                  onTap: _callSupport,
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      boxShadow: AppShadows.button(color: AppColors.success),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.call_rounded, color: AppColors.white, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Call Support',
                          style: AppTextStyles.body(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PressableScale(
                  onTap: _whatsApp,
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      border: Border.all(color: AppColors.success),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.chat_rounded, color: AppColors.success, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'WhatsApp',
                          style: AppTextStyles.body(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 160.ms, duration: 220.ms),
        ],
      ),
    );
  }
}

class _TicketResult {
  const _TicketResult(this.ticket);
  final SupportTicket ticket;
}

class _TicketSheet extends StatefulWidget {
  const _TicketSheet();

  @override
  State<_TicketSheet> createState() => _TicketSheetState();
}

class _TicketSheetState extends State<_TicketSheet> {
  static const _subjects = [
    'Order Issue',
    'Delivery Issue',
    'Product Issue',
    'Account Issue',
    'Other',
  ];

  String _subject = 'Order Issue';
  final _desc = TextEditingController();
  List<Order> _orders = [];
  String? _relatedOrderId;
  bool _loadingOrders = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final result = await context.read<OrderRepository>().fetchOrders(limit: 20);
    if (!mounted) return;
    result.when(
      success: (page) => setState(() {
        _orders = page.items;
        _loadingOrders = false;
      }),
      failure: (_, {statusCode}) => setState(() => _loadingOrders = false),
    );
  }

  @override
  void dispose() {
    _desc.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_desc.text.trim().isEmpty) return;
    setState(() => _submitting = true);
    final result = await context.read<SupportRepository>().submitTicket(
          subject: _subject,
          description: _desc.text.trim(),
          relatedOrderId: _relatedOrderId,
        );
    if (!mounted) return;
    result.when(
      success: (ticket) => Navigator.of(context).pop(_TicketResult(ticket)),
      failure: (message, {statusCode}) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.rust),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPadding(
      duration: AppMotion.fast,
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.88),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + MediaQuery.paddingOf(context).bottom),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Raise a ticket', style: AppTextStyles.display(fontSize: 20)),
              const SizedBox(height: 16),
              Text(
                'SUBJECT',
                style: AppTextStyles.label(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _subjects.map((s) {
                  final selected = s == _subject;
                  return PressableScale(
                    onTap: () => setState(() => _subject = s),
                    child: AnimatedContainer(
                      duration: AppMotion.fast,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.violet : AppColors.section,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                      child: Text(
                        s,
                        style: AppTextStyles.body(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: selected ? AppColors.white : AppColors.ink,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const AuthFieldLabel('Description'),
              const SizedBox(height: 8),
              PillTextField(
                controller: _desc,
                hint: 'Tell us what happened…',
                tall: true,
                maxLines: 4,
                minLines: 3,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              Text(
                'ATTACH RELATED ORDER (optional)',
                style: AppTextStyles.label(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 8),
              if (_loadingOrders)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.violet),
                    ),
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    PressableScale(
                      onTap: () => setState(() => _relatedOrderId = null),
                      child: _OrderChip(label: 'None', selected: _relatedOrderId == null),
                    ),
                    ..._orders.map(
                      (o) => PressableScale(
                        onTap: () => setState(() => _relatedOrderId = o.id),
                        child: _OrderChip(
                          label: o.id,
                          selected: _relatedOrderId == o.id,
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              AuthPrimaryButton(
                label: 'Submit Ticket',
                isLoading: _submitting,
                enabled: _desc.text.trim().isNotEmpty,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderChip extends StatelessWidget {
  const _OrderChip({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.fast,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.greenSoft : AppColors.section,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: selected ? AppColors.violet : AppColors.line),
      ),
      child: Text(
        label,
        style: AppTextStyles.body(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: selected ? AppColors.violet : AppColors.ink,
        ),
      ),
    );
  }
}
