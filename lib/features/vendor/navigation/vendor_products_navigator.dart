import 'package:flutter/material.dart';
import 'package:urban_roots/features/vendor/navigation/vendor_routes.dart';
import 'package:urban_roots/features/vendor/products/add_edit_product_screen.dart';
import 'package:urban_roots/features/vendor/products/product_detail_screen.dart';
import 'package:urban_roots/features/vendor/products/product_list_screen.dart';
import 'package:urban_roots/features/vendor/categories/category_list_screen.dart';

class VendorProductsNavigator extends StatelessWidget {
  const VendorProductsNavigator({super.key, required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      initialRoute: VendorRoutes.productList,
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case VendorRoutes.productList:
        return MaterialPageRoute(builder: (_) => const ProductListScreen());
      case VendorRoutes.productDetail:
        final productId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ProductDetailScreen(productId: productId),
        );
      case VendorRoutes.addEditProduct:
        final productId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => AddEditProductScreen(productId: productId),
        );
      case VendorRoutes.categoryList:
        return MaterialPageRoute(builder: (_) => const CategoryListScreen());
      default:
        return MaterialPageRoute(builder: (_) => const ProductListScreen());
    }
  }
}

void vendorProductsPush(BuildContext context, String route, {Object? arguments}) {
  Navigator.of(context).pushNamed(route, arguments: arguments);
}

void vendorProductsPushReplacement(BuildContext context, String route, {Object? arguments}) {
  Navigator.of(context).pushReplacementNamed(route, arguments: arguments);
}
