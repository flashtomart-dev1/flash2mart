import 'package:flutter/material.dart';

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  // కేటగిరీల లిస్ట్
  final List<Map<String, dynamic>> allCategories = const [
    {"name": "Medicines", "icon": Icons.medical_services},
    {"name": "Vegetables", "icon": Icons.grass},
    {"name": "Provisions", "icon": Icons.shopping_basket},
    {"name": "Fruits", "icon": Icons.apple},
    {"name": "Dairy", "icon": Icons.local_drink},
    {"name": "Bakery", "icon": Icons.cake},
    {"name": "Jewellery", "icon": Icons.diamond},
    {"name": "Electronics", "icon": Icons.tv},
  ];

  List<Map<String, dynamic>> displayedCategories = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    displayedCategories = allCategories;
  }

  // సెర్చ్ లాజిక్
  void filterCategories(String query) {
    setState(() {
      displayedCategories = allCategories.where((cat) => 
          cat["name"].toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Customer Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // సెర్చ్ బార్
            SizedBox(
              height: 45,
              child: TextField(
                controller: searchController,
                onChanged: filterCategories,
                decoration: const InputDecoration(
                  labelText: "Search items",
                  prefixIcon: Icon(Icons.search, size: 20),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            
            // గ్రిడ్ వ్యూ - చిన్న బాక్సుల కోసం
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // ఒక లైన్ లో 3 బాక్సులు
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.0, 
                ),
                itemCount: displayedCategories.length + 1, // +1 ఫర్ 'More'
                itemBuilder: (context, index) {
                  // 'More' ఆప్షన్ డిజైన్
                  if (index == displayedCategories.length) {
                    return Card(
                      color: Colors.blue[50],
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.more_horiz, size: 30), 
                          Text("More", style: TextStyle(fontSize: 12))
                        ],
                      ),
                    );
                  }
                  
                  // మెయిన్ కేటగిరీ బాక్సుల డిజైన్
                  return Card(
                    elevation: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(displayedCategories[index]["icon"], size: 30, color: Colors.blueAccent),
                        const SizedBox(height: 5),
                        Text(
                          displayedCategories[index]["name"], 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}