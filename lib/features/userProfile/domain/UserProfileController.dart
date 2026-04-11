import 'package:get/get.dart';
import 'package:urban_roots/data/dummy_data.dart';

class UserProfileController extends GetxController {
  String userName = DummyData.demoUserId;

  Future<void> saveAddresses(List<String> addresses) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<List<String>> loadAddresses() async {
    return ['123, MG Road, Bangalore - 560001'];
  }

  Future<void> saveDeliveryInstructions(String instructions) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<String> loadDeliveryInstructions() async {
    return 'Leave at the door if no one is available.';
  }

  Future<Map<String, dynamic>> fetchUserData(String custId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return DummyData.userProfile;
  }
}
