import 'package:flutter/material.dart';

class FlashRideLoginScreen extends StatelessWidget {
  const FlashRideLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flash Ride Login"),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {},
          child: const Text("Flash Ride Login Screen"),
        ),
      ),
    );
  }
}
