import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/features/dashboard/presentation/pages/Dashboard.dart';

class OTPVerificationScreen extends StatefulWidget {
  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  String buttonTxt = "Send OTP";
  bool enableOTP = false;

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF019934),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Image.asset("assets/logo.png", width: 160, height: 160, fit: BoxFit.contain),
            const SizedBox(height: 10),
            Text('Phone Verification', style: GoogleFonts.rubik(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 4),
            Text('We\'ll send you a one-time code', style: GoogleFonts.rubik(fontSize: 14, color: Colors.white70)),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Phone Number', style: GoogleFonts.rubik(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: phoneController,
                      style: GoogleFonts.poppins(fontSize: 14),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 10,
                      decoration: InputDecoration(
                        counterText: '',
                        prefixIcon: Icon(Icons.phone_outlined, color: Colors.green.shade400, size: 20),
                        prefixText: '+91 ',
                        prefixStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                        hintText: 'Enter mobile number',
                        hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF019934), width: 1.5)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    if (enableOTP) ...[
                      const SizedBox(height: 18),
                      Text('Enter OTP', style: GoogleFonts.rubik(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: otpController,
                        maxLength: 6,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: GoogleFonts.poppins(fontSize: 18, letterSpacing: 8),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: '------',
                          hintStyle: GoogleFonts.poppins(fontSize: 18, color: Colors.grey.shade300, letterSpacing: 8),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF019934), width: 1.5)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF019934),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 3,
                        ),
                        onPressed: () {
                          if (buttonTxt.toLowerCase() == "send otp") {
                            if (phoneController.text.isNotEmpty && phoneController.text.length == 10) {
                              setState(() { buttonTxt = "Verify & Login"; enableOTP = true; });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter valid mobile number")));
                            }
                          } else {
                            if (otpController.text.isNotEmpty && otpController.text.length == 6) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(duration: Duration(milliseconds: 500), content: Text("User Login Successful!!")));
                              Future.delayed(const Duration(milliseconds: 300), () {
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Dashboard()));
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter valid OTP")));
                            }
                          }
                        },
                        child: Text(buttonTxt, style: GoogleFonts.rubik(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
