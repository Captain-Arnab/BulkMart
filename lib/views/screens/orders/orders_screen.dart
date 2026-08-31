import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/ui/app_motion.dart';
import '../../../core/ui/pressable_scale.dart';
import '../../../core/ui/shell_controller.dart';
import '../../../models/order.dart';
import '../../../models/order_status.dart';
import '../../../models/payment_method.dart';
import '../../../repositories/order_repository.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../widgets/ui_states.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  static const _pageSize = 20;
  static const _filters = [
    ('all', 'All'),
    ('pending', 'Pending'),
    ('delivered', 'Delivered'),
    ('cancelled', 'Cancelled'),
  ];

  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  List<Order> _orders = [];
  String _filter = 'all';
  int _page = 1;
  bool _hasMore = false;
  final _scroll = ScrollController();
  ShellController? _shell;
  int? _lastTab;

  static final _priceFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final shell = context.read<ShellController>();
    if (_shell != shell) {
      _shell?.removeListener(_onShell);
      _shell = shell;
      _lastTab = shell.tabIndex;
      _shell!.addListener(_onShell);
    }
  }

  void _onShell() {
    final i = _shell?.tabIndex;
    if (i == ShellController.ordersTab && _lastTab != ShellController.ordersTab) {
      _load(reset: true);
    }
    _lastTab = i;
  }

  void _onScroll() {
    if (!_hasMore || _loadingMore || _loading) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  /// If the first page does not fill the viewport, keep loading until it does
  /// (or there are no more pages) — otherwise older orders never appear.
  void _maybeLoadMoreIfShortList() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_hasMore || _loadingMore || _loading) return;
      if (!_scroll.hasClients) return;
      if (_scroll.position.maxScrollExtent <= 0) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _shell?.removeListener(_onShell);
    super.dispose();
  }

  Future<void> _load({required bool reset}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _page = 1;
      });
    }
    final result = await context.read<OrderRepository>().fetchOrders(
          page: 1,
          limit: _pageSize,
          filter: _filter == 'all' ? null : _filter,
        );
    if (!mounted) return;
    result.when(
      success: (page) {
        setState(() {
          _orders = page.items;
          _hasMore = page.hasMore;
          _page = 1;
          _loading = false;
        });
        _maybeLoadMoreIfShortList();
      },
      failure: (message, {statusCode, code, fields}) {
        setState(() {
          _error = message;
          _loading = false;
        });
      },
    );
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    final next = _page + 1;
    final result = await context.read<OrderRepository>().fetchOrders(
          page: next,
          limit: _pageSize,
          filter: _filter == 'all' ? null : _filter,
        );
    if (!mounted) return;
    result.when(
      success: (page) {
        setState(() {
          _orders = [..._orders, ...page.items];
          _hasMore = page.hasMore;
          _page = next;
          _loadingMore = false;
        });
        _maybeLoadMoreIfShortList();
      },
      failure: (_, {statusCode, code, fields}) {
        setState(() => _loadingMore = false);
      },
    );
  }

  StatusPillKind _kind(OrderStatus status) {
    return switch (status) {
      OrderStatus.delivered => StatusPillKind.success,
      OrderStatus.outForDelivery => StatusPillKind.info,
      OrderStatus.cancelled => StatusPillKind.danger,
      _ => StatusPillKind.warning,
    };
  }

  String _itemPreview(Order order) {
    final names = order.items.map((e) => e.product.name).toList();
    if (names.isEmpty) {
      return order.displayItemCount > 0 ? 'Tap for details' : 'No items';
    }
    if (names.length == 1) return names.first;
    if (names.length == 2) return '${names[0]}, ${names[1]}';
    return '${names[0]}, ${names[1]} +${names.length - 2} more';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.section,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('Orders', style: AppTextStyles.display(fontSize: 26)),
            ),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final (key, label) = _filters[index];
                  final selected = _filter == key;
                  return PressableScale(
                    onTap: () {
                      if (_filter == key) return;
                      setState(() => _filter = key);
                      _load(reset: true);
                    },
                    child: AnimatedContainer(
                      duration: AppMotion.fast,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? AppColors.violet : AppColors.white,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                        border: Border.all(
                          color: selected ? AppColors.violet : AppColors.line,
                        ),
                      ),
                      child: Text(
                        label,
                        style: AppTextStyles.body(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: selected ? AppColors.white : AppColors.ink,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.violet,
                backgroundColor: AppColors.white,
                onRefresh: () => _load(reset: true),
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _orders.isEmpty) {
      return const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.violet),
        ),
      );
    }
    if (_error != null && _orders.isEmpty) {
      return ErrorState(message: _error!, onRetry: () => _load(reset: true));
    }
    if (_orders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 24),
          EmptyState(
            title: 'No orders yet',
            subtitle: 'Your COD order history will appear here once you place your first order.',
            lottieAsset: 'assets/lottie/empty_cart.json',
            icon: Icons.receipt_long_outlined,
            ctaLabel: 'Start Shopping',
            onCta: () => context.read<ShellController>().goToTab(0),
          ),
        ],
      );
    }

    return AnimationLimiter(
      child: ListView.separated(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        itemCount: _orders.length + (_loadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index >= _orders.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.violet),
                ),
              ),
            );
          }
          final order = _orders[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 280),
            child: SlideAnimation(
              verticalOffset: 24,
              curve: AppMotion.ease,
              child: FadeInAnimation(
                child: PressableScale(
                  onTap: () {
                    AppPageRoute.push(
                      context,
                      OrderDetailScreen(orderId: order.id),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      boxShadow: AppShadows.card,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                order.displayId,
                                style: AppTextStyles.body(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.violet,
                                ),
                              ),
                            ),
                            StatusPill(label: order.status.label, kind: _kind(order.status)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          DateFormat('d MMM yyyy').format(order.placedAt),
                          style: AppTextStyles.body(fontSize: 12, color: AppColors.muted),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${order.displayItemCount} item${order.displayItemCount == 1 ? '' : 's'} · ${_itemPreview(order)}',
                          style: AppTextStyles.body(fontSize: 13, color: AppColors.ink),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              _priceFormat.format(order.total),
                              style: AppTextStyles.display(fontSize: 18),
                            ),
                            const Spacer(),
                            Text(
                              order.paymentMethod.paymentMethodLabel,
                              style: AppTextStyles.body(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
