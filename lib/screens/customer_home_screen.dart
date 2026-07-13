import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Flash2MartHomeScreen(), debugShowCheckedModeBanner: false));

class Flash2MartHomeScreen extends StatelessWidget {
  const Flash2MartHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("CUSTOMER", style: TextStyle(fontSize: 10, color: Colors.grey)),
            const Text("Flash2Mart", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location & Search
              const Row(children: [Icon(Icons.location_on, color: Colors.orange), Text(" Vijayawada, AP")]),
              const SizedBox(height: 10),
              TextField(decoration: InputDecoration(hintText: "Search products, shops, services...", prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
              
              const SizedBox(height: 20),
              
              // Section 1: Order & Deliver
              const Text("🚀 Order & Deliver", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                children: [
                  _buildServiceItem("🍛", "Food"),
                  _buildServiceItem("💊", "Medical"),
                  _buildServiceItem("🛒", "Groceries"),
                  _buildServiceItem("💍", "Jewellery"),
                  _buildServiceItem("📱", "Electronics"),
                  _buildServiceItem("🌱", "Agri"),
                  _buildServiceItem("🏭", "Wholesale"),
                  _buildServiceItem("🐾", "Pets"),
                ],
              ),

              const SizedBox(height: 20),

              // Section 2: Flash Deals
              const Text("🔥 Flash Deals", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildDealCard("Toor Dal", "₹142", "14% OFF"),
                    _buildDealCard("Sun Oil", "₹185", "12% OFF"),
                    _buildDealCard("Tomatoes", "₹36", "20% OFF"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Section 3: Book & Enquire
              const Text("📅 Book & Enquire", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                children: [
                  _buildServiceItem("🎓", "Edu"),
                  _buildServiceItem("💻", "IT/Digi"),
                  _buildServiceItem("🚗", "Auto"),
                  _buildServiceItem("🧱", "Const"),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Explore"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildServiceItem(String emoji, String label) {
    return Column(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)), child: Text(emoji, style: const TextStyle(fontSize: 24))), Text(label, style: const TextStyle(fontSize: 10))]);
  }

  Widget _buildDealCard(String name, String price, String discount) {
    return Container(
      width: 100, margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(10)),
      child: Column(children: [Text(discount, style: const TextStyle(color: Colors.red, fontSize: 10)), Text(name), Text(price, style: const TextStyle(fontWeight: FontWeight.bold))]),
    );
  }
}