abstract class DashboardState {}

class HomeInit extends DashboardState {}
class HomeProducts extends DashboardState {}
class HomeWishList extends DashboardState {}
class HomeCart extends DashboardState {}
class HomeProfile extends DashboardState {}
class ProductDetailsState extends DashboardState {
  final String productId;

  ProductDetailsState({required this.productId});
}
class PaymentScreenState extends DashboardState {
  PaymentScreenState();
}
class OrderScreenState extends DashboardState {
  OrderScreenState();
}
class AddressScreenState extends DashboardState {
  AddressScreenState();
}
