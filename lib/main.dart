import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'home_page.dart'; // హోమ్ పేజీని ఇక్కడ ఇంపోర్ట్ చేసుకోండి

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const Flash2MartApp());
}

class Flash2MartApp extends StatelessWidget {
  const Flash2MartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(), // మీ ప్రాజెక్ట్ ఎప్పుడూ ఇక్కడి నుంచే మొదలవుతుంది
    );
  }
}
