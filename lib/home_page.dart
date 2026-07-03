import 'package:flutter/material.dart';
import 'customer_auth.dart'; // లాగిన్ పేజీకి కనెక్ట్ చేయడానికి

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final List<Map<String, dynamic>> profiles = const [
    {
      "name": "Customer",
      "icon": Icons.shopping_bag_rounded,
      "color": Color(0xFF6C63FF),
      "bg": Color(0xFFEDE9FE)
    },
    {
      "name": "Retailer",
      "icon": Icons.storefront_rounded,
      "color": Color(0xFF00D2FF),
      "bg": Color(0xFFE0F7FA)
    },
    {
      "name": "Delivery",
      "icon": Icons.delivery_dining_rounded,
      "color": Color(0xFFFF6B6B),
      "bg": Color(0xFFFFEBEE)
    },
    {
      "name": "Flash Ride",
      "icon": Icons.electric_bike_rounded,
      "color": Color(0xFF2E7D32),
      "bg": Color(0xFFE8F5E9)
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 80),
              const Icon(Icons.flash_on, size: 60, color: Colors.amber),
              const Text("FLASH 2 MART",
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 1.5)),
              const SizedBox(height: 50),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.25,
                  ),
                  itemCount: profiles.length,
                  itemBuilder: (context, index) =>
                      _buildModernCard(context, profiles[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernCard(BuildContext context, Map<String, dynamic> data) {
    return InkWell(
      onTap: () {
        if (data['name'] == 'Customer') {
          // కస్టమర్ క్లిక్ చేస్తే నేరుగా లాగిన్/రిజిస్ట్రేషన్ పేజీకి వెళ్తుంది
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const CustomerAuthScreen()));
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
            color: data['bg'], borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Icon(data['icon'], size: 28, color: data['color']),
            ),
            const SizedBox(height: 12),
            Text(data['name'],
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}
