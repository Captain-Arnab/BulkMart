import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/notifications/push_notification_service.dart';
import 'package:urban_roots/features/splash/Splashscreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await PushNotificationService.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Urban Roots',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF019934),
        scaffoldBackgroundColor: Colors.white,
        secondaryHeaderColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            textStyle: GoogleFonts.rubik(
                fontSize: 14.0,
                fontWeight: FontWeight.w200,
                color: Colors.white),
            backgroundColor: Color(0xFF019934),
            foregroundColor: Colors.white,
          ),
        ),
        buttonTheme: ButtonThemeData(
            textTheme: ButtonTextTheme.normal,
            buttonColor: Colors.green.shade700,
            highlightColor: Colors.grey),
        hintColor: const Color(0xFF7e7d7d),
        useMaterial3: true,
        textTheme: TextTheme(
          titleSmall: GoogleFonts.rubik(
              fontSize: 14.0, fontWeight: FontWeight.w400, letterSpacing: 0.7),
          displayLarge: GoogleFonts.rubik(
              fontSize: 16.0, fontWeight: FontWeight.w400, letterSpacing: 0.8),
          displaySmall: GoogleFonts.rubik(
              fontSize: 14.0, fontWeight: FontWeight.w400, letterSpacing: 0.5),
          titleLarge: GoogleFonts.rubik(
              fontSize: 20.0, fontWeight: FontWeight.w400),
          titleMedium: GoogleFonts.rubik(
              fontSize: 16.0, fontWeight: FontWeight.w100),
          bodyMedium: GoogleFonts.rubik(
              fontSize: 10.0, fontWeight: FontWeight.w400),
        ),
      ),
      home: SplashScreen(),
    );
  }
}
