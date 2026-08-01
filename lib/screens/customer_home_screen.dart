import 'package:flutter/material.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int selectedIndex = 0;
  int cartCount = 0;

  final TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Groceries',
      'icon': Icons.local_grocery_store,
      'color': Colors.green,
    },
    {
      'name': 'Vegetables',
      'icon': Icons.eco,
      'color': Colors.lightGreen,
    },
    {
      'name': 'Fruits',
      'icon': Icons.apple,
      'color': Colors.red,
    },
    {
      'name': 'Medicines',
      'icon': Icons.medical_services,
      'color': Colors.blue,
    },
    {
      'name': 'Food',
      'icon': Icons.restaurant,
      'color': Colors.orange,
    },
    {
      'name': 'Fashion',
      'icon': Icons.checkroom,
      'color': Colors.purple,
    },
    {
      'name': 'Electronics',
      'icon': Icons.devices,
      'color': Colors.indigo,
    },
    {
      'name': 'More',
      'icon': Icons.grid_view_rounded,
      'color': Colors.blueGrey,
    },
  ];

  final List<Map<String, dynamic>> products = [
    {
      'name': 'Fresh Tomatoes',
      'quantity': '1 Kg',
      'price': 40,
      'oldPrice': 50,
      'icon': Icons.eco,
      'color': Colors.red,
    },
    {
      'name': 'Fresh Apples',
      'quantity': '1 Kg',
      'price': 150,
      'oldPrice': 180,
      'icon': Icons.apple,
      'color': Colors.redAccent,
    },
    {
      'name': 'Fresh Milk',
      'quantity': '1 Litre',
      'price': 65,
      'oldPrice': 70,
      'icon': Icons.local_drink,
      'color': Colors.blue,
    },
    {
      'name': 'Sunflower Oil',
      'quantity': '1 Litre',
      'price': 135,
      'oldPrice': 160,
      'icon': Icons.water_drop,
      'color': Colors.amber,
    },
    {
      'name': 'Premium Rice',
      'quantity': '5 Kg',
      'price': 399,
      'oldPrice': 450,
      'icon': Icons.rice_bowl,
      'color': Colors.brown,
    },
    {
      'name': 'Fresh Bread',
      'quantity': '400 Grams',
      'price': 45,
      'oldPrice': 55,
      'icon': Icons.breakfast_dining,
      'color': Colors.orange,
    },
  ];

  void showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(15),
      ),
    );
  }

  void addToCart(String productName) {
    setState(() {
      cartCount++;
    });

    showMessage('$productName added to cart');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      body: IndexedStack(
        index: selectedIndex,
        children: [
          buildHomePage(),
          buildSimplePage(
            title: 'Categories',
            icon: Icons.category_outlined,
            message: 'All product categories will appear here',
          ),
          buildSimplePage(
            title: 'My Cart',
            icon: Icons.shopping_cart_outlined,
            message: cartCount == 0
                ? 'Your cart is empty'
                : '$cartCount products added to your cart',
          ),
          buildSimplePage(
            title: 'My Orders',
            icon: Icons.receipt_long_outlined,
            message: 'Your orders will appear here',
          ),
          buildSimplePage(
            title: 'My Profile',
            icon: Icons.person_outline,
            message: 'Customer profile details will appear here',
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xff3A7BFF),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 15,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: buildCartIcon(),
            activeIcon: buildCartIcon(),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget buildHomePage() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));

          if (mounted) {
            showMessage('Products updated');
          }
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: buildHeader(),
            ),
            SliverToBoxAdapter(
              child: buildSearchBar(),
            ),
            SliverToBoxAdapter(
              child: buildOfferBanner(),
            ),
            SliverToBoxAdapter(
              child: buildSectionTitle(
                title: 'Shop by Category',
                buttonText: 'See All',
              ),
            ),
            SliverToBoxAdapter(
              child: buildCategories(),
            ),
            SliverToBoxAdapter(
              child: buildSectionTitle(
                title: 'Popular Products',
                buttonText: 'View All',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 25),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return buildProductCard(products[index]);
                  },
                  childCount: products.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 25),
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
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
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
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FLASH 2 MART',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Everything delivered fast',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  showMessage('No new notifications');
                },
                icon: const Icon(
                  Icons.notifications_none,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Delivery Location',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          InkWell(
            onTap: () {
              showMessage('Location selection will be added next');
            },
            child: const Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.amber,
                  size: 21,
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Nellore, Andhra Pradesh',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 18, 15, 5),
      child: TextField(
        controller: searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            showMessage('Searching for ${value.trim()}');
          }
        },
        decoration: InputDecoration(
          hintText: 'Search products, shops and services',
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xff3A7BFF),
          ),
          suffixIcon: IconButton(
            onPressed: () {
              showMessage('Voice search will be added next');
            },
            icon: const Icon(
              Icons.mic_none,
              color: Color(0xff7B2FF7),
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey.shade200,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildOfferBanner() {
    return Container(
      height: 160,
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xffFF7A18),
            Color(0xffFFB347),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'SPECIAL OFFER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Up to 50% OFF',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'On groceries and daily essentials',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_basket,
              size: 48,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionTitle({
    required String title,
    required String buttonText,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(17, 8, 10, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xff202124),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              showMessage('$title selected');
            },
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  Widget buildCategories() {
    return SizedBox(
      height: 108,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) {
          return const SizedBox(width: 14);
        },
        itemBuilder: (context, index) {
          final category = categories[index];

          return InkWell(
            onTap: () {
              showMessage('${category['name']} selected');
            },
            borderRadius: BorderRadius.circular(15),
            child: SizedBox(
              width: 72,
              child: Column(
                children: [
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      color:
                          (category['color'] as Color).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      category['icon'] as IconData,
                      color: category['color'] as Color,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    category['name'].toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildProductCard(Map<String, dynamic> product) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color:
                          (product['color'] as Color).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      product['icon'] as IconData,
                      size: 70,
                      color: product['color'] as Color,
                    ),
                  ),
                  Positioned(
                    top: 7,
                    right: 7,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          showMessage(
                            '${product['name']} added to favourites',
                          );
                        },
                        icon: const Icon(
                          Icons.favorite_border,
                          size: 20,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              product['name'].toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              product['quantity'].toString(),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                Text(
                  '₹${product['price']}',
                  style: const TextStyle(
                    color: Color(0xff202124),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  '₹${product['oldPrice']}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    addToCart(product['name'].toString());
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xff3A7BFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCartIcon() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.shopping_cart_outlined),
        if (cartCount > 0)
          Positioned(
            top: -7,
            right: -9,
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                cartCount > 99 ? '99+' : cartCount.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget buildSimplePage({
    required String title,
    required IconData icon,
    required String message,
  }) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xff7B2FF7),
                  Color(0xff3A7BFF),
                ],
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 90,
                      color: const Color(0xff3A7BFF),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
