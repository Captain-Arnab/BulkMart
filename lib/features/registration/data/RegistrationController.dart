import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegistrationController extends GetxController {
  TextEditingController registerFirstNameController = TextEditingController();
  TextEditingController registerLastNameController = TextEditingController();
  TextEditingController registerPhoneNumberController = TextEditingController();
  TextEditingController registerPasswordController = TextEditingController();
  TextEditingController registerEmailController = TextEditingController();
  TextEditingController registerConfirmPasswordController = TextEditingController();

  RxBool passwordVisible = false.obs;
  bool isRegistrationSuccess = false;

  isDataValid(BuildContext context) {
    if (registerFirstNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: Duration(milliseconds: 300),
          content: Text("Please enter first name to proceed",
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center),
          backgroundColor: Colors.white));
      return false;
    } else if (registerLastNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: Duration(milliseconds: 300),
          content: Text("Please enter last name to proceed",
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center),
          backgroundColor: Colors.white));
      return false;
    } else if (registerPhoneNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: Duration(milliseconds: 300),
          content: Text("Please enter phone number to proceed",
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center),
          backgroundColor: Colors.white));
      return false;
    } else if (registerEmailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: Duration(milliseconds: 300),
          content: Text("Please enter email to proceed",
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center),
          backgroundColor: Colors.white));
      return false;
    } else if (registerPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: Duration(milliseconds: 300),
          content: Text("Please enter password to proceed",
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center),
          backgroundColor: Colors.white));
      return false;
    } else if (registerConfirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: Duration(milliseconds: 300),
          content: Text("Please enter confirm password to proceed",
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center),
          backgroundColor: Colors.white));
      return false;
    }
    return true;
  }

  Future<void> registerUser(String fName, String lName, String phoneNumber,
      String email, String password, String rePassword) async {
    await Future.delayed(const Duration(milliseconds: 800));
    Get.back();
    isRegistrationSuccess = true;
  }

  clearData() {
    registerFirstNameController.clear();
    registerLastNameController.clear();
    registerPhoneNumberController.clear();
    registerEmailController.clear();
    registerPasswordController.clear();
    registerConfirmPasswordController.clear();
  }
}
