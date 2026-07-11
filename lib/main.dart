import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'screens/customer_login_screen.dart';
import 'screens/retailer_login_screen.dart';
import 'screens/delivery_partner_login_screen.dart';
import 'screens/flash_ride_login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Flash2MartApp());
}

class Flash2MartApp extends StatelessWidget {
  const Flash2MartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flash2Mart',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),

      // First Screen
      home: const SplashScreen(),

      // Routes
      routes: {
        '/customerLogin': (context) => const CustomerLoginScreen(),
        '/retailerLogin': (context) => const RetailerLoginScreen(),
        '/deliveryLogin': (context) => const DeliveryPartnerLoginScreen(),
        '/flashRideLogin': (context) => const FlashRideLoginScreen(),
      },
    );
  }
}
