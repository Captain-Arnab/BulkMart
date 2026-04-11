abstract class DashboardEvent {}

class DashboardUpdateEvent extends DashboardEvent {
  final int index;
  final int category;

  DashboardUpdateEvent({required this.index, required this.category});
}

class NavigateToProductDescriptionEvent extends DashboardEvent {
  final String productId; // or whatever type your product ID is

  NavigateToProductDescriptionEvent({required this.productId});
}

class NavigateToPaymentScreenEvent extends DashboardEvent {
  NavigateToPaymentScreenEvent();
}

class NavigateToOrderScreenEvent extends DashboardEvent {
  NavigateToOrderScreenEvent();
}

class NavigateToAddressScreenEvent extends DashboardEvent {
  NavigateToAddressScreenEvent();
}
