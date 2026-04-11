import 'package:urban_roots/data/dummy_data.dart';

class RazorpayService {
  Future<List<dynamic>> fetchPaymentHistory() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return DummyData.samplePayments;
  }
}
