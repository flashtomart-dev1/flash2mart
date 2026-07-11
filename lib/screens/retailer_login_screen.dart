import 'package:flutter/material.dart';

class RetailerLoginScreen extends StatelessWidget {
  const RetailerLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Retailer Login"),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {},
          child: const Text("Retailer Login Screen"),
        ),
      ),
    );
  }
}
