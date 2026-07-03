import 'package:flutter/material.dart';
import 'home_page.dart'; // హోమ్ పేజ్ ఇంపోర్ట్ చేశాము

class CustomerAuthScreen extends StatefulWidget {
  const CustomerAuthScreen({super.key});
  @override
  State<CustomerAuthScreen> createState() => _CustomerAuthScreenState();
}

class _CustomerAuthScreenState extends State<CustomerAuthScreen> {
  bool isLogin = true; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? "Customer Login" : "Customer Registration")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (!isLogin) ...[
                const TextField(decoration: InputDecoration(labelText: "Full Name", border: OutlineInputBorder())),
                const SizedBox(height: 15),
              ],
              const TextField(decoration: InputDecoration(labelText: "Mobile Number", border: OutlineInputBorder())),
              const SizedBox(height: 15),
              const TextField(decoration: InputDecoration(labelText: "Password", border: OutlineInputBorder()), obscureText: true),
              const SizedBox(height: 30),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // లాగిన్/రిజిస్ట్రేషన్ తర్వాత హోమ్ పేజ్ కి వెళ్తుంది
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
                  },
                  child: Text(isLogin ? "Login" : "Register"),
                ),
              ),
              
              TextButton(
                onPressed: () {
                  setState(() => isLogin = !isLogin);
                },
                child: Text(isLogin ? "New User? Register here" : "Already a user? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}