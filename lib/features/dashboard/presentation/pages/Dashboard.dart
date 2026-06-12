import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/Utils/GlobalVariable.dart';
import 'package:urban_roots/features/dashboard/presentation/WishlistView.dart';
import 'package:urban_roots/features/dashboard/presentation/pages/CartView.dart';
import 'package:urban_roots/features/dashboard/presentation/pages/all_products.dart';
import 'package:urban_roots/features/orders/presentation/OrderHistory.dart';
import 'package:urban_roots/features/payments/presentation/PaymentHistory.dart';
import 'package:urban_roots/features/products/presentation/NewScreen.dart';
import 'package:urban_roots/features/products/presentation/Products.dart';
import 'package:urban_roots/features/userProfile/presentation/AddressListScreen.dart';
import 'package:urban_roots/features/userProfile/presentation/TestProfile.dart';
import 'bloc/dashboard_bloc.dart';
import 'bloc/dashboard_event.dart';
import 'bloc/dashboard_state.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<Dashboard> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    BlocProvider.of<DashboardBloc>(GlobalVariable.dashboardBlocContext!).add(DashboardUpdateEvent(index: index, category: 0));
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => DashboardBloc(),
      child: Scaffold(
        body: Center(
          child: BlocConsumer<DashboardBloc, DashboardState>(
            listener: (context, state) {
              if (state is HomeInit) setState(() => _selectedIndex = 0);
              else if (state is HomeProducts) setState(() => _selectedIndex = 1);
              else if (state is HomeWishList) setState(() => _selectedIndex = 2);
              else if (state is HomeCart) setState(() => _selectedIndex = 3);
              else if (state is HomeProfile) setState(() => _selectedIndex = 4);
            },
            builder: (context, state) {
              GlobalVariable.dashboardBlocContext = context;
              if (state is HomeInit) return ProductScreenNew();
              else if (state is HomeProducts) return ProductPage(category: 0, minPrice: 0, maxPrice: 10000);
              else if (state is HomeWishList) return const WishListPage();
              else if (state is HomeCart) return const CartPage();
              else if (state is HomeProfile) return UserProfileScreen();
              else if (state is PaymentScreenState) return const PaymentHistoryScreen();
              else if (state is OrderScreenState) return const OrderHistory();
              else if (state is AddressScreenState) return AddressListScreen();
              else return ProductScreen();
            },
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4))],
          ),
          child: BottomNavigationBar(
            selectedLabelStyle: GoogleFonts.rubik(fontSize: 11, fontWeight: FontWeight.w600),
            unselectedLabelStyle: GoogleFonts.rubik(fontSize: 11),
            unselectedItemColor: Colors.grey.shade400,
            selectedFontSize: 12,
            backgroundColor: Colors.white,
            items: [
              BottomNavigationBarItem(label: 'Home', icon: Icon(_selectedIndex == 0 ? Icons.home_rounded : Icons.home_outlined)),
              BottomNavigationBarItem(label: 'Products', icon: Icon(_selectedIndex == 1 ? Icons.grid_view_rounded : Icons.grid_view_outlined)),
              BottomNavigationBarItem(label: 'Wishlist', icon: Icon(_selectedIndex == 2 ? Icons.favorite : Icons.favorite_border)),
              BottomNavigationBarItem(label: 'Cart', icon: Icon(_selectedIndex == 3 ? Icons.shopping_cart : Icons.shopping_cart_outlined)),
              BottomNavigationBarItem(label: 'Profile', icon: Icon(_selectedIndex == 4 ? Icons.person : Icons.person_outline)),
            ],
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            selectedItemColor: const Color(0xFF019934),
            showUnselectedLabels: true,
            iconSize: 24,
            onTap: _onItemTapped,
            elevation: 0,
          ),
        ),
      ),
    );
  }
}
