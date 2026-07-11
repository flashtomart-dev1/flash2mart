import 'package:flutter/material.dart';

class DeliveryPartnerLoginScreen extends StatelessWidget {
  const DeliveryPartnerLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Delivery Partner Login"),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {},
          child: const Text("Delivery Partner Login Screen"),
        ),
      ),
    );
  }
}
