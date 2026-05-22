import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/data/dummy_data.dart';
import 'package:urban_roots/features/dashboard/presentation/pages/bloc/dashboard_bloc.dart';
import 'package:urban_roots/features/dashboard/presentation/pages/bloc/dashboard_event.dart';
import 'package:urban_roots/core/auth/auth_session.dart';
import 'package:urban_roots/core/navigation/auth_navigation.dart';
import 'package:urban_roots/features/subscription/presentation/SubscriptionScreen.dart';
import 'package:urban_roots/features/wallet/presentation/WalletScreen.dart';
import 'package:get/get.dart';
import 'package:urban_roots/features/userProfile/domain/UserProfileController.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<dynamic> userProfileFuture;
  UserProfileController userProfileController = Get.put(UserProfileController());

  @override
  void initState() {
    super.initState();
    userProfileFuture = userProfileController.fetchUserData(DummyData.demoUserId);
  }

  Widget _profileMenuItem(IconData icon, String title, VoidCallback onTap, {Color? iconColor}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: (iconColor ?? const Color(0xFF019934)).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 22, color: iconColor ?? const Color(0xFF019934)),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(title, style: GoogleFonts.rubik(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87))),
          Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 22),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: FutureBuilder<dynamic>(
        future: userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF019934)));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No profile data available'));
          }
          final userData = snapshot.data!;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                backgroundColor: const Color(0xFF019934),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [Color(0xFF019934), Color(0xFF01752A)],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white38, width: 3)),
                          child: CircleAvatar(
                            radius: 45,
                            backgroundImage: const AssetImage("assets/logo.png"),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(userData['name'] ?? '', style: GoogleFonts.rubik(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(userData['email'] ?? '', style: GoogleFonts.rubik(fontSize: 13, color: Colors.white70)),
                        const SizedBox(height: 2),
                        Text(userData['phone'] ?? '', style: GoogleFonts.rubik(fontSize: 13, color: Colors.white60)),
                      ]),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    _profileMenuItem(Icons.account_balance_wallet_outlined, 'My Wallet', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen()));
                    }),
                    const SizedBox(height: 10),
                    _profileMenuItem(Icons.subscriptions_outlined, 'Subscriptions', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
                    }),
                    const SizedBox(height: 10),
                    _profileMenuItem(Icons.shopping_bag_outlined, 'Order History', () {
                      BlocProvider.of<DashboardBloc>(context).add(NavigateToOrderScreenEvent());
                    }),
                    const SizedBox(height: 10),
                    _profileMenuItem(Icons.payment_outlined, 'Payment History', () {
                      BlocProvider.of<DashboardBloc>(context).add(NavigateToPaymentScreenEvent());
                    }),
                    const SizedBox(height: 10),
                    _profileMenuItem(Icons.location_on_outlined, 'My Addresses', () {
                      BlocProvider.of<DashboardBloc>(context).add(NavigateToAddressScreenEvent());
                    }),
                    const SizedBox(height: 10),
                    _profileMenuItem(Icons.help_outline, 'Help & Support', () {}),
                    const SizedBox(height: 10),
                    _profileMenuItem(Icons.info_outline, 'About', () {}),
                    const SizedBox(height: 20),
                    _profileMenuItem(Icons.logout, 'Logout', () async {
                      await AuthSession.instance.clear();
                      if (!context.mounted) return;
                      navigateToLogin(context);
                    }, iconColor: Colors.red),
                    const SizedBox(height: 24),
                    Text('App Version 1.0.0', style: GoogleFonts.rubik(fontSize: 12, color: Colors.grey.shade400)),
                    const SizedBox(height: 16),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
