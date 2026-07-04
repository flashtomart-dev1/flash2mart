import 'package:flutter/material.dart';
import 'customer_dashboard_screen.dart'; // డాష్‌బోర్డ్ పేజీని ఇంపోర్ట్ చేయండి

class CustomerAuthScreen extends StatefulWidget {
  const CustomerAuthScreen({super.key});

  @override
  State<CustomerAuthScreen> createState() => _CustomerAuthScreenState();
}

class _CustomerAuthScreenState extends State<CustomerAuthScreen> {
  bool isLogin = true; 
  bool isOTPStep = false; 

  // కంట్రోలర్లు
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isOTPStep ? "OTP Verification" : (isLogin ? "Customer Login" : "Registration")),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (!isLogin && !isOTPStep) ...[
                TextField(controller: nameController, decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder())),
                const SizedBox(height: 15),
              ],

              if (!isOTPStep) ...[
                TextField(controller: mobileController, decoration: const InputDecoration(labelText: "Mobile Number", border: OutlineInputBorder()), keyboardType: TextInputType.phone),
                const SizedBox(height: 15),
                TextField(controller: passwordController, decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder()), obscureText: true),
              ] else ...[
                const Text("Enter the 6-digit code sent to your mobile number"),
                const SizedBox(height: 15),
                TextField(controller: otpController, decoration: const InputDecoration(labelText: "Enter OTP", border: OutlineInputBorder()), keyboardType: TextInputType.number),
              ],
              
              const SizedBox(height: 30),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // OTP దశలో ఉంటే, వెరిఫై చేసి డాష్‌బోర్డ్‌కి పంపండి
                    if (isOTPStep) {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CustomerDashboardScreen()));
                    } else {
                      // రిజిస్టర్/లాగిన్ బటన్ నొక్కితే OTP స్టేజ్ కి వెళ్తుంది
                      setState(() => isOTPStep = true);
                    }
                  },
                  child: Text(isOTPStep ? "Verify OTP" : (isLogin ? "Login" : "Continue to OTP")),
                ),
              ),
              
              if (!isOTPStep)
                TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(isLogin ? "New User? Register here" : "Already a user? Login"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}