import 'package:flutter/material.dart';
import 'customer_login_screen.dart';
import 'retailer_login_screen.dart';
import 'delivery_partner_login_screen.dart';
import 'flash_ride_login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [

            //================ HEADER =================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff7B2FF7),
                    Color(0xff3A7BFF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [

                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.bolt,
                          color: Colors.amber,
                          size: 30,
                        ),
                      ),

                      const SizedBox(width: 15),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            Text(
                              "FLASH 2 MART",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 2),

                            Text(
                              "ALL-IN-ONE SUPER APP",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      CircleAvatar(
                        backgroundColor: Colors.white24,
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.dark_mode,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                                    const SizedBox(height: 35),

                  const Text(
                    "Choose your role",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Select how you want to use Flash 2 Mart",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                children: [

                  roleTile(
                    context,
                    Icons.person_outline,
                    Colors.deepPurple,
                    "Customer",
                    "Shop services near you",
                    const CustomerLoginScreen(),
                  ),

                  roleTile(
                    context,
                    Icons.storefront_outlined,
                    Colors.orange,
                    "Retailer",
                    "Register & manage your shop",
                    const RetailerLoginScreen(),
                  ),

                  roleTile(
                    context,
                    Icons.delivery_dining,
                    Colors.green,
                    "Delivery Partner",
                    "Earn with every delivery",
                    const DeliveryPartnerLoginScreen(),
                  ),

                  roleTile(
                    context,
                    Icons.flash_on,
                    Colors.blue,
                    "Flash Ride",
                    "Book rides - KM based pricing",
                    const FlashRideLoginScreen(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
    Widget roleTile(
    BuildContext context,
    IconData icon,
    Color color,
    String title,
    String subtitle,
    Widget screen,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),

        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 30,
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
        ),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => screen,
            ),
          );
        },
      ),
    );
  }
}