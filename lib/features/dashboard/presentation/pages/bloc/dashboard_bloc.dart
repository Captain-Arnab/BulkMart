import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urban_roots/features/dashboard/presentation/pages/bloc/dashboard_event.dart';
import 'package:urban_roots/features/dashboard/presentation/pages/bloc/dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(HomeInit()) {
    on<DashboardUpdateEvent>((event, emit) {
      switch (event.index) {
        case 0:
          emit(HomeInit());
          break;
        case 1:
          emit(HomeProducts());
          break;
        case 2:
          emit(HomeWishList());
          break;
        case 3:
          emit(HomeCart());
          break;
        case 4:
          emit(HomeProfile());
          break;
        default:
          emit(HomeInit());
          break;
      }
    });

    on<NavigateToProductDescriptionEvent>((event, emit) {
      emit(ProductDetailsState(productId: event.productId));
    });

    on<NavigateToPaymentScreenEvent>((event, emit) {
      emit(PaymentScreenState());
    });

    on<NavigateToOrderScreenEvent>((event, emit) {
      emit(OrderScreenState());
    });

    on<NavigateToAddressScreenEvent>((event, emit) {
      emit(AddressScreenState());
    });
  }
}
