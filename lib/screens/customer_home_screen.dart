import 'package:flutter/material.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({
    super.key,
    this.customerName = 'Customer',
    this.registeredPartners = const <Map<String, String>>[],
  });

  /// Later, backend/API data can be passed here using the same keys returned by
  /// RetailerRegisterScreen: accountType, business, owner, category, city,
  /// address, profileDescription, serviceCharge, salary, skills, etc.
  final String customerName;
  final List<Map<String, String>> registeredPartners;

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  static const Color purple = Color(0xff6C3EF4);
  static const Color blue = Color(0xff2F80ED);
  static const Color ink = Color(0xff172554);
  static const Color page = Color(0xffF7F8FC);

  int _tab = 0;
  final Map<_MarketplaceItem, int> _cart = <_MarketplaceItem, int>{};
  final Set<_MarketplaceItem> _favourites = <_MarketplaceItem>{};
  final List<_CustomerOrder> _customerOrders = <_CustomerOrder>[];
  String _location = 'Your location';
  String _query = '';
  String _exploreType = 'All';
  String _homeMode = 'All';
  String _sort = 'Recommended';
  bool _onlyFastDelivery = false;
  bool _onlyTopRated = false;
  int _bannerIndex = 0;
  bool _flashPassActive = false;
  bool _notificationsEnabled = true;
  bool _darkModeRequested = false;
  String _appliedCoupon = '';
  String _selectedInstruction = '';
  int _rewardPoints = 240;
  double _walletBalance = 125.0;

  final List<String> _recentSearches = <String>[
    'Biryani',
    'Grocery',
    'AC service',
  ];
  final List<_SavedAddress> _savedAddresses = <_SavedAddress>[
    const _SavedAddress(
      label: 'Home',
      address: 'Add your complete home address',
      icon: Icons.home_rounded,
    ),
    const _SavedAddress(
      label: 'Work',
      address: 'Add your work address',
      icon: Icons.work_rounded,
    ),
  ];

  final TextEditingController _searchController = TextEditingController();

  late final List<_MarketplaceItem> _items;

  int get _cartCount =>
      _cart.values.fold<int>(0, (total, quantity) => total + quantity);

  double get _cartSubtotal => _cart.entries.fold<double>(
        0,
        (total, entry) => total + (entry.key.numericPrice * entry.value),
      );

  double get _deliveryFee =>
      _flashPassActive || _appliedCoupon == 'FREEDEL' ? 0 : 29;

  double get _couponDiscount {
    if (_appliedCoupon == 'FLASH40') {
      final discount = _cartSubtotal * .40;
      return discount > 100 ? 100 : discount;
    }
    if (_appliedCoupon == 'LOCAL50' && _cartSubtotal >= 499) return 50;
    return 0;
  }

  double get _cartTotal =>
      _cartSubtotal + _deliveryFee + 5 + (_cartSubtotal * .03) - _couponDiscount;

  @override
  void initState() {
    super.initState();
    _items = <_MarketplaceItem>[
      ..._demoItems,
      ...widget.registeredPartners.map(_MarketplaceItem.fromRegistration),
    ];
  }

  List<_MarketplaceItem> get _filteredItems {
    final q = _query.trim().toLowerCase();
    final filtered = _items.where((item) {
      final typeMatches = _exploreType == 'All' || item.type == _exploreType;
      final queryMatches = q.isEmpty ||
          item.title.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q) ||
          item.subtitle.toLowerCase().contains(q) ||
          item.city.toLowerCase().contains(q) ||
          item.tags.any((tag) => tag.toLowerCase().contains(q));
      final fastMatches = !_onlyFastDelivery || item.deliveryMinutes <= 30;
      final ratingMatches = !_onlyTopRated || item.rating >= 4.5;
      return typeMatches && queryMatches && fastMatches && ratingMatches;
    }).toList();

    if (_sort == 'Rating') {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_sort == 'Delivery time') {
      filtered.sort(
        (a, b) => a.deliveryMinutes.compareTo(b.deliveryMinutes),
      );
    } else if (_sort == 'Price: Low to High') {
      filtered.sort((a, b) => a.numericPrice.compareTo(b.numericPrice));
    }
    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _home(),
      _explore(),
      _buildCartScreen(),
      _orders(),
      _profile(),
    ];

    return Theme(
      data: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: page,
        colorScheme: ColorScheme.fromSeed(
          seedColor: purple,
          primary: purple,
          secondary: blue,
          surface: Colors.white,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: purple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.white,
          selectedColor: purple,
          side: const BorderSide(color: Color(0xffE5E7EF)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          labelStyle: const TextStyle(
            color: ink,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: page,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[Color(0xffFAFBFF), Color(0xffF5F4FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: IndexedStack(index: _tab, children: pages),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xffECECF4))),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Color(0x14172554),
                blurRadius: 24,
                offset: Offset(0, -8),
              ),
            ],
          ),
          child: NavigationBar(
            height: 74,
            selectedIndex: _tab,
            elevation: 0,
            backgroundColor: Colors.transparent,
            indicatorColor: const Color(0xffEAE4FF),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: (value) => setState(() => _tab = value),
            destinations: <NavigationDestination>[
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: purple),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded, color: purple),
            label: 'Browse',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: _cartCount > 0,
              label: Text('$_cartCount'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: _cartCount > 0,
              label: Text('$_cartCount'),
              child: const Icon(Icons.shopping_cart_rounded, color: purple),
            ),
            label: 'Cart',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded, color: purple),
            label: 'Orders',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: purple),
            label: 'Profile',
          ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _home() {
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: purple,
        onRefresh: () async => Future<void>.delayed(
          const Duration(milliseconds: 700),
        ),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            SliverToBoxAdapter(child: _homeHeader()),
            SliverToBoxAdapter(child: _smartGreetingCard()),
            SliverToBoxAdapter(child: _searchBox()),
            SliverToBoxAdapter(child: _primaryBusinessGateways()),
            SliverToBoxAdapter(child: _quickActions()),
            SliverToBoxAdapter(child: _trendingNow()),
            SliverToBoxAdapter(child: _flashPromiseStrip()),
            SliverToBoxAdapter(child: _offerCarousel()),
            SliverToBoxAdapter(child: _flashPassCard()),
            SliverToBoxAdapter(
              child: _sectionHeader(
                title: 'What are you looking for?',
                action: 'View all',
                onTap: () => _openExplore('Product Seller'),
              ),
            ),
            SliverToBoxAdapter(child: _categoryGrid()),
            SliverToBoxAdapter(child: _dailyDeals()),
            SliverToBoxAdapter(child: _smartRecommendations()),
            SliverToBoxAdapter(
              child: _sectionHeader(
                title: 'Top picks near you',
                action: 'See all',
                onTap: () => _openExplore('Product Seller'),
              ),
            ),
            _horizontalItems('Product Seller'),
            SliverToBoxAdapter(child: _quickReorder()),
            SliverToBoxAdapter(
              child: _sectionHeader(
                title: 'Book trusted services',
                action: 'See all',
                onTap: () => _openExplore('Service Provider'),
              ),
            ),
            _horizontalItems('Service Provider'),
            SliverToBoxAdapter(
              child: _sectionHeader(
                title: 'Jobs for you',
                action: 'See all',
                onTap: () => _openExplore('Employer / Job Provider'),
              ),
            ),
            _horizontalItems('Employer / Job Provider'),
            SliverToBoxAdapter(child: _smartExperienceHub()),
            SliverToBoxAdapter(child: _neighbourhoodSpotlight()),
            SliverToBoxAdapter(child: _customerProtectionCard()),
            SliverToBoxAdapter(child: _safetyAndTrust()),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }

  Widget _homeHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 14, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: <Color>[purple, blue]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: _chooseLocation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'DELIVER TO',
                    style: TextStyle(
                      color: Color(0xff7C8496),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: <Widget>[
                      const Icon(Icons.location_on_rounded,
                          size: 17, color: purple),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          _location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 19),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _roundButton(Icons.notifications_none_rounded, _showNotifications),
          const SizedBox(width: 8),
          Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              _roundButton(
                Icons.shopping_bag_outlined,
                () => setState(() => _tab = 2),
              ),
              if (_cartCount > 0)
                Positioned(
                  right: -3,
                  top: -4,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 18),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xffEF4444),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$_cartCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smartGreetingCard() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    final firstName = widget.customerName.trim().isEmpty
        ? 'Customer'
        : widget.customerName.trim().split(' ').first;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.fromLTRB(16, 15, 12, 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xffFFFFFF), Color(0xffF1EDFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffE5DEFF)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0D172554),
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[purple, blue],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.waving_hand_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '$greeting, $firstName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Everything nearby, delivered in a flash.',
                  style: TextStyle(
                    color: Color(0xff6B7280),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _showRewards,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xffFFF7D6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xffFDE68A)),
              ),
              child: Column(
                children: <Widget>[
                  const Icon(
                    Icons.stars_rounded,
                    color: Color(0xffD97706),
                    size: 18,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$_rewardPoints',
                    style: const TextStyle(
                      color: Color(0xff92400E),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _homeModeSelector() {
    const modes = <(String, IconData)>[
      ('All', Icons.auto_awesome_rounded),
      ('Food', Icons.restaurant_rounded),
      ('Grocery', Icons.local_grocery_store_rounded),
      ('Services', Icons.handyman_rounded),
      ('Jobs', Icons.work_rounded),
    ];
    return SizedBox(
      height: 53,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 9, 16, 4),
        scrollDirection: Axis.horizontal,
        itemCount: modes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final mode = modes[index];
          final selected = _homeMode == mode.$1;
          return Material(
            color: selected ? ink : Colors.white,
            borderRadius: BorderRadius.circular(22),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () {
                setState(() => _homeMode = mode.$1);
                if (mode.$1 == 'Food' || mode.$1 == 'Grocery') {
                  _searchController.text = mode.$1;
                  setState(() => _query = mode.$1);
                  _openExplore('Product Seller');
                } else if (mode.$1 == 'Services') {
                  _openExplore('Service Provider');
                } else if (mode.$1 == 'Jobs') {
                  _openExplore('Employer / Job Provider');
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13),
                child: Row(
                  children: <Widget>[
                    Icon(
                      mode.$2,
                      size: 17,
                      color: selected ? Colors.white : purple,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      mode.$1,
                      style: TextStyle(
                        color: selected ? Colors.white : ink,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _primaryBusinessGateways() {
    final gateways = <({
      String title,
      String subtitle,
      String type,
      IconData icon,
      Color color,
      Color softColor,
    })>[
      (
        title: 'Products',
        subtitle: 'Shops & items',
        type: 'Product Seller',
        icon: Icons.shopping_bag_rounded,
        color: const Color(0xffF97316),
        softColor: const Color(0xffFFF1E8),
      ),
      (
        title: 'Services',
        subtitle: 'Book experts',
        type: 'Service Provider',
        icon: Icons.home_repair_service_rounded,
        color: const Color(0xff0284C7),
        softColor: const Color(0xffE7F6FF),
      ),
      (
        title: 'Jobs',
        subtitle: 'Find & apply',
        type: 'Employer / Job Provider',
        icon: Icons.business_center_rounded,
        color: const Color(0xff7C3AED),
        softColor: const Color(0xffF1EAFF),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(Icons.grid_view_rounded, color: purple, size: 20),
              SizedBox(width: 7),
              Text(
                'Explore Flash2Mart',
                style: TextStyle(
                  color: ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            children: gateways.map((gateway) {
              final partnerCount = _items
                  .where((item) => item.type == gateway.type)
                  .length;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: gateway == gateways.last ? 0 : 8,
                  ),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(21),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(21),
                      onTap: () => _openBusinessHub(gateway.type),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 150),
                        padding: const EdgeInsets.fromLTRB(10, 13, 10, 11),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(21),
                          border: Border.all(color: gateway.color.withAlpha(35)),
                          boxShadow: const <BoxShadow>[
                            BoxShadow(
                              color: Color(0x0D172554),
                              blurRadius: 16,
                              offset: Offset(0, 7),
                            ),
                          ],
                        ),
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: gateway.softColor,
                                borderRadius: BorderRadius.circular(17),
                              ),
                              child: Icon(
                                gateway.icon,
                                color: gateway.color,
                                size: 27,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              gateway.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: ink,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              gateway.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xff7C8496),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: gateway.softColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$partnerCount nearby',
                                maxLines: 1,
                                style: TextStyle(
                                  color: gateway.color,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _searchBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onChanged: (value) => setState(() => _query = value),
        onSubmitted: (value) {
          final term = value.trim();
          if (term.isNotEmpty && !_recentSearches.contains(term)) {
            setState(() {
              _recentSearches.insert(0, term);
              if (_recentSearches.length > 6) _recentSearches.removeLast();
            });
          }
          _openExplore('All');
        },
        decoration: InputDecoration(
          hintText: 'Search products, services or jobs',
          hintStyle: const TextStyle(color: Color(0xff9299A8), fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: purple),
          suffixIcon: _query.isEmpty
              ? IconButton(
                  onPressed: _showSmartSearch,
                  icon: const Icon(Icons.mic_none_rounded),
                )
              : IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xffE4E7EF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: purple, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _quickActions() {
    const actions = <(String, IconData, Color, String)>[
      ('Food', Icons.lunch_dining_rounded, Color(0xffF97316), 'Food'),
      ('Grocery', Icons.shopping_basket_rounded, Color(0xff22C55E), 'Grocery'),
      ('Shops', Icons.storefront_rounded, Color(0xffEC4899), 'Product Seller'),
      ('Medicines', Icons.medication_rounded, Color(0xffEF4444), 'Pharmacy'),
      ('Services', Icons.handyman_rounded, Color(0xff0EA5E9), 'Service Provider'),
      ('Jobs', Icons.work_rounded, Color(0xff8B5CF6), 'Employer / Job Provider'),
      ('Flash Ride', Icons.two_wheeler_rounded, Color(0xff10B981), 'Ride'),
      ('All', Icons.apps_rounded, Color(0xff334155), 'All'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 2),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: .88,
          mainAxisSpacing: 5,
          crossAxisSpacing: 4,
        ),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final item = actions[index];
          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              if (item.$4 == 'Ride') {
                _showRideBooking();
              } else if (item.$4 == 'Food' ||
                  item.$4 == 'Grocery' ||
                  item.$4 == 'Pharmacy') {
                _searchController.text = item.$4;
                setState(() => _query = item.$4);
                _openExplore('Product Seller');
              } else if (item.$4 == 'Product Seller' ||
                  item.$4 == 'Service Provider' ||
                  item.$4 == 'Employer / Job Provider') {
                _openBusinessHub(item.$4);
              } else {
                _openExplore(item.$4);
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[item.$3.withAlpha(235), item.$3],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: item.$3.withAlpha(45),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(item.$2, color: Colors.white, size: 27),
                ),
                const SizedBox(height: 7),
                Text(
                  item.$1,
                  maxLines: 1,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _trendingNow() {
    const trends = <(String, String, IconData, Color, String)>[
      ('30 min', 'Quick meals', Icons.timer_rounded, Color(0xffF97316), 'Food'),
      ('Fresh', 'Daily grocery', Icons.eco_rounded, Color(0xff10B981), 'Grocery'),
      ('Verified', 'Home experts', Icons.verified_user_rounded, Color(0xff0EA5E9), 'Service Provider'),
      ('Hiring', 'Jobs nearby', Icons.trending_up_rounded, Color(0xff8B5CF6), 'Employer / Job Provider'),
      ('Instant', 'Flash Ride', Icons.electric_bike_rounded, Color(0xffEC4899), 'Ride'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 17, 16, 10),
          child: Row(
            children: <Widget>[
              Icon(Icons.local_fire_department_rounded, color: Color(0xffF97316), size: 21),
              SizedBox(width: 7),
              Text(
                'Trending now',
                style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w900),
              ),
              Spacer(),
              _SmallBadge(label: 'LIVE', color: Color(0xffEF4444)),
            ],
          ),
        ),
        SizedBox(
          height: 112,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: trends.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final trend = trends[index];
              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    if (trend.$5 == 'Ride') {
                      _showRideBooking();
                    } else if (trend.$5 == 'Food' || trend.$5 == 'Grocery') {
                      _searchController.text = trend.$5;
                      setState(() => _query = trend.$5);
                      _openExplore('Product Seller');
                    } else {
                      _openExplore(trend.$5);
                    }
                  },
                  child: Container(
                    width: 154,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: trend.$4.withAlpha(38)),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(color: Color(0x0A172554), blurRadius: 16, offset: Offset(0, 6)),
                      ],
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: <Color>[trend.$4.withAlpha(220), trend.$4],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(trend.$3, color: Colors.white, size: 23),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(trend.$1, style: TextStyle(color: trend.$4, fontSize: 10, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 4),
                              Text(trend.$2, maxLines: 2, style: const TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _smartExperienceHub() {
    const experiences = <(IconData, String, String, Color, String)>[
      (Icons.restaurant_menu_rounded, 'Food in a Flash', 'Menus, offers & live delivery', Color(0xffF97316), 'Food'),
      (Icons.shopping_bag_rounded, 'Local Marketplace', 'Trusted stores around you', Color(0xffEC4899), 'Product Seller'),
      (Icons.home_repair_service_rounded, 'Home Services', 'Book verified professionals', Color(0xff0EA5E9), 'Service Provider'),
      (Icons.business_center_rounded, 'Career Hub', 'Discover and apply for jobs', Color(0xff8B5CF6), 'Employer / Job Provider'),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 2),
      padding: const EdgeInsets.fromLTRB(15, 16, 15, 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xff171A3A), Color(0xff252A62)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x30172554), blurRadius: 24, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(Icons.auto_awesome_rounded, color: Color(0xffC4B5FD), size: 22),
              SizedBox(width: 8),
              Expanded(
                child: Text('Your Flash2Mart universe', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),
              ),
              _SmallBadge(label: 'ALL-IN-ONE', color: Color(0xffA5B4FC)),
            ],
          ),
          const SizedBox(height: 5),
          const Text('One official app for daily life, local discovery and trusted connections.', style: TextStyle(color: Color(0xffC7CCE5), fontSize: 10.5, height: 1.4)),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: experiences.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.55,
              mainAxisSpacing: 9,
              crossAxisSpacing: 9,
            ),
            itemBuilder: (context, index) {
              final item = experiences[index];
              return Material(
                color: const Color(0x12FFFFFF),
                borderRadius: BorderRadius.circular(17),
                child: InkWell(
                  borderRadius: BorderRadius.circular(17),
                  onTap: () {
                    if (item.$5 == 'Food') {
                      _searchController.text = 'Food';
                      setState(() => _query = 'Food');
                      _openExplore('Product Seller');
                    } else {
                      _openExplore(item.$5);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(11),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 39,
                          height: 39,
                          decoration: BoxDecoration(color: item.$4.withAlpha(45), borderRadius: BorderRadius.circular(12)),
                          child: Icon(item.$1, color: item.$4, size: 21),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(item.$2, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 3),
                              Text(item.$3, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xffADB4D2), fontSize: 8.5, height: 1.25)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _flashPromiseStrip() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 3),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xffF0ECFF),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xffDDD5FF)),
      ),
      child: const Row(
        children: <Widget>[
          Icon(Icons.bolt_rounded, color: purple, size: 22),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Fast local delivery • Verified partners • Secure payments',
              style: TextStyle(
                color: ink,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Icon(Icons.verified_rounded, color: Color(0xff10B981), size: 19),
        ],
      ),
    );
  }

  Widget _offerCarousel() {
    const banners = <_HomeBanner>[
      _HomeBanner(
        eyebrow: 'WELCOME TO FLASH2MART',
        title: 'Up to 40% OFF',
        subtitle: 'On your first local order',
        button: 'ORDER NOW',
        icon: Icons.local_shipping_rounded,
        colors: <Color>[Color(0xff6D3FF1), Color(0xff337CF1)],
      ),
      _HomeBanner(
        eyebrow: 'FOOD IN A FLASH',
        title: 'Free delivery',
        subtitle: 'On selected restaurants near you',
        button: 'EXPLORE FOOD',
        icon: Icons.ramen_dining_rounded,
        colors: <Color>[Color(0xffF97316), Color(0xffEF4444)],
      ),
      _HomeBanner(
        eyebrow: 'HOME SERVICES',
        title: 'Trusted experts',
        subtitle: 'Book verified professionals at home',
        button: 'BOOK NOW',
        icon: Icons.home_repair_service_rounded,
        colors: <Color>[Color(0xff0891B2), Color(0xff2563EB)],
      ),
    ];
    return Column(
      children: <Widget>[
        SizedBox(
          height: 170,
          child: PageView.builder(
            itemCount: banners.length,
            onPageChanged: (index) => setState(() => _bannerIndex = index),
            itemBuilder: (context, index) {
              final banner = banners[index];
              return Container(
                margin: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: banner.colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            banner.eyebrow,
                            style: const TextStyle(
                              color: Color(0xffF3EFFF),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .8,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            banner.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            banner.subtitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () {
                              if (index == 1) {
                                _searchController.text = 'Food';
                                setState(() => _query = 'Food');
                                _openExplore('Product Seller');
                              } else if (index == 2) {
                                _openExplore('Service Provider');
                              } else {
                                _openExplore('Product Seller');
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                banner.button,
                                style: TextStyle(
                                  color: banner.colors.first,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(banner.icon, color: Colors.white, size: 76),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 7),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(
            banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: _bannerIndex == index ? 20 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: _bannerIndex == index
                    ? purple
                    : const Color(0xffD7D9E0),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _offerBanner() {
    return Container(
      height: 150,
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xff6D3FF1), Color(0xff337CF1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'WELCOME OFFER',
                  style: TextStyle(
                    color: Color(0xffE8E3FF),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Up to 40% OFF',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'On your first local order',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'ORDER NOW',
                    style: TextStyle(color: purple, fontSize: 11, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 82),
        ],
      ),
    );
  }

  Widget _flashPassCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xff111827), Color(0xff312E81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x26312E81),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          const Positioned(
            right: -20,
            top: -22,
            child: Icon(
              Icons.bolt_rounded,
              color: Color(0x246D5DFB),
              size: 145,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffFACC15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'FLASH PASS',
                        style: TextStyle(
                          color: Color(0xff422006),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .8,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (_flashPassActive)
                      const _SmallBadge(
                        label: 'ACTIVE',
                        color: Color(0xff34D399),
                      ),
                  ],
                ),
                const SizedBox(height: 13),
                Text(
                  _flashPassActive
                      ? 'Your delivery benefits are active'
                      : 'Save more on every local order',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Free delivery • Extra offers • Priority support',
                  style: TextStyle(
                    color: Color(0xffC7D2FE),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.verified_rounded,
                      color: Color(0xff34D399),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'Official member benefits',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: ink,
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: _showFlashPass,
                      child: Text(_flashPassActive ? 'VIEW' : 'TRY FREE'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _smartRecommendations() {
    final products = _items
        .where((item) => item.type == 'Product Seller')
        .take(3)
        .toList();
    if (products.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      padding: const EdgeInsets.fromLTRB(15, 16, 15, 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(Icons.auto_awesome_rounded, color: purple, size: 21),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Picked for you',
                  style: TextStyle(
                    color: ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _SmallBadge(label: 'SMART PICKS', color: purple),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Popular around your location right now',
            style: TextStyle(color: Color(0xff7C8496), fontSize: 11),
          ),
          const SizedBox(height: 14),
          ...products.asMap().entries.map((entry) {
            final item = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: entry.key == products.length - 1 ? 0 : 11),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _showDetails(item),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: page,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: item.color.withAlpha(30),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(item.icon, color: item.color, size: 27),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: ink,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.category} • ${item.deliveryMinutes} min',
                              style: const TextStyle(
                                color: Color(0xff71798A),
                                fontSize: 10.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xffF59E0B),
                        size: 16,
                      ),
                      Text(
                        item.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: ink,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 7),
                      const Icon(Icons.chevron_right_rounded, color: purple),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _neighbourhoodSpotlight() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xffECFDF5), Color(0xffEFF6FF)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffBAE6FD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(Icons.location_city_rounded, color: Color(0xff047857)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your neighbourhood, one app',
                  style: TextStyle(
                    color: ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Shop local, book trusted professionals, discover jobs and travel with Flash Ride.',
            style: TextStyle(
              color: Color(0xff475569),
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: <Widget>[
              _spotlightStat('100+', 'Categories'),
              _spotlightStat('Verified', 'Partners'),
              _spotlightStat('One', 'Checkout'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _spotlightStat(String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(220),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          children: <Widget>[
            Text(
              value,
              style: const TextStyle(
                color: ink,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xff64748B),
                fontSize: 9.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customerProtectionCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 13, 16, 0),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xffECFDF5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: Color(0xff059669),
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Flash2Mart Customer Protection',
                  style: TextStyle(
                    color: ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Secure payments and support for eligible orders.',
                  style: TextStyle(
                    color: Color(0xff71798A),
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          TextButton(onPressed: _showCustomerProtection, child: const Text('KNOW MORE')),
        ],
      ),
    );
  }

  Widget _sectionHeader({
    required String title,
    required String action,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(17, 23, 12, 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
          TextButton(onPressed: onTap, child: Text(action)),
        ],
      ),
    );
  }

  Widget _categoryStrip() {
    const categories = <(String, IconData, Color)>[
      ('Grocery', Icons.local_grocery_store_rounded, Color(0xff22C55E)),
      ('Food', Icons.restaurant_rounded, Color(0xffF97316)),
      ('Pharmacy', Icons.medication_rounded, Color(0xffEF4444)),
      ('Fashion', Icons.checkroom_rounded, Color(0xffEC4899)),
      ('Electronics', Icons.devices_rounded, Color(0xff3B82F6)),
      ('Home', Icons.chair_rounded, Color(0xff8B5CF6)),
      ('Beauty', Icons.spa_rounded, Color(0xffF43F5E)),
    ];
    return SizedBox(
      height: 104,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final item = categories[index];
          return InkWell(
            onTap: () {
              _searchController.text = item.$1;
              setState(() => _query = item.$1);
              _openExplore('Product Seller');
            },
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 66,
              child: Column(
                children: <Widget>[
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: item.$3,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(item.$2, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 7),
                  Text(item.$1, maxLines: 1, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _categoryGrid() {
    const categories = <_HomeCategory>[
      _HomeCategory('Biryani', Icons.rice_bowl_rounded, Color(0xffFFF1E8)),
      _HomeCategory('Tiffins', Icons.breakfast_dining_rounded, Color(0xffFFF7D8)),
      _HomeCategory('Vegetables', Icons.eco_rounded, Color(0xffEAFBEF)),
      _HomeCategory('Fruits', Icons.apple_rounded, Color(0xffFFF0F2)),
      _HomeCategory('Dairy', Icons.local_drink_rounded, Color(0xffEAF6FF)),
      _HomeCategory('Medicines', Icons.medication_rounded, Color(0xffFFECEE)),
      _HomeCategory('Fashion', Icons.checkroom_rounded, Color(0xffFFF0FA)),
      _HomeCategory('Electronics', Icons.devices_rounded, Color(0xffEEF2FF)),
      _HomeCategory('Beauty', Icons.spa_rounded, Color(0xffFFF0F5)),
      _HomeCategory('Home Needs', Icons.chair_rounded, Color(0xffF4F0FF)),
      _HomeCategory('Pet Care', Icons.pets_rounded, Color(0xffFFF5E8)),
      _HomeCategory('More', Icons.grid_view_rounded, Color(0xffEFF2F5)),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: .82,
          mainAxisSpacing: 10,
          crossAxisSpacing: 4,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              if (category.label == 'More') {
                _openExplore('All');
              } else {
                _searchController.text = category.label;
                setState(() => _query = category.label);
                _openExplore('Product Seller');
              }
            },
            child: Column(
              children: <Widget>[
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: category.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(category.icon, color: ink, size: 29),
                ),
                const SizedBox(height: 6),
                Text(
                  category.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _dailyDeals() {
    final deals = _items
        .where((item) => item.type == 'Product Seller')
        .take(4)
        .toList();
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 18, 12, 2),
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xffFFF7ED), Color(0xffFFF1F2)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffFED7AA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: <Widget>[
                Icon(Icons.flash_on_rounded, color: Color(0xffEA580C)),
                SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Flash Deals',
                    style: TextStyle(
                      color: ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  'ENDS IN 02:18:45',
                  style: TextStyle(
                    color: Color(0xffEA580C),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          SizedBox(
            height: 164,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              scrollDirection: Axis.horizontal,
              itemCount: deals.length,
              separatorBuilder: (_, __) => const SizedBox(width: 9),
              itemBuilder: (context, index) {
                final item = deals[index];
                return Container(
                  width: 135,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Container(
                            width: double.infinity,
                            height: 70,
                            decoration: BoxDecoration(
                              color: item.color.withAlpha(35),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Icon(item.icon, color: item.color, size: 38),
                          ),
                          const Positioned(
                            left: 5,
                            top: 5,
                            child: _SmallBadge(
                              label: 'DEAL',
                              color: Color(0xffEA580C),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: ink,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '₹${item.numericPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: ink,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 28,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: purple,
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: () => _addToCart(item),
                          child: const Text(
                            'ADD',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickReorder() {
    if (_customerOrders.isEmpty) return const SizedBox.shrink();
    final order = _customerOrders.first;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xffF0ECFF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.replay_rounded, color: purple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Order again',
                  style: TextStyle(color: ink, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  '${order.itemCount} items • ₹${order.total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Color(0xff71798A),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(onPressed: () => setState(() => _tab = 3), child: const Text('VIEW')),
        ],
      ),
    );
  }

  Widget _safetyAndTrust() {
    const values = <(IconData, String, String)>[
      (Icons.verified_user_rounded, 'Verified', 'Trusted local partners'),
      (Icons.lock_rounded, 'Secure', 'Protected payments'),
      (Icons.support_agent_rounded, 'Support', 'Help when you need it'),
    ];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 25, 16, 4),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xff111827),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: <Widget>[
          const Text(
            'WHY FLASH2MART',
            style: TextStyle(
              color: Color(0xffA5B4FC),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 17),
          Row(
            children: values.map((value) {
              return Expanded(
                child: Column(
                  children: <Widget>[
                    Icon(value.$1, color: Colors.white, size: 27),
                    const SizedBox(height: 8),
                    Text(
                      value.$2,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      value.$3,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xff9CA3AF),
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _horizontalItems(String type) {
    final data = _items.where((item) => item.type == type).take(5).toList();
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 232,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: data.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) => SizedBox(
            width: 190,
            child: _itemCard(data[index]),
          ),
        ),
      ),
    );
  }

  Widget _explore() {
    const filters = <(String, String, IconData)>[
      ('All', 'All', Icons.auto_awesome_rounded),
      ('Products', 'Product Seller', Icons.shopping_bag_rounded),
      ('Services', 'Service Provider', Icons.home_repair_service_rounded),
      ('Jobs', 'Employer / Job Provider', Icons.business_center_rounded),
    ];
    final results = _filteredItems;
    return SafeArea(
      bottom: false,
      child: Column(
        children: <Widget>[
          _simpleAppBar('Explore Flash2Mart'),
          _searchBox(),
          SizedBox(
            height: 52,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = filters[index];
                final selected = _exploreType == filter.$2;
                return ChoiceChip(
                  avatar: Icon(
                    filter.$3,
                    size: 17,
                    color: selected ? Colors.white : purple,
                  ),
                  label: Text(filter.$1),
                  selected: selected,
                  showCheckmark: false,
                  selectedColor: purple,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : ink,
                    fontWeight: FontWeight.w700,
                  ),
                  onSelected: (_) => setState(() => _exploreType = filter.$2),
                );
              },
            ),
          ),
          _exploreFilterBar(results.length),
          Expanded(
            child: results.isEmpty
                ? _emptyState(
                    Icons.search_off_rounded,
                    'No results found',
                    'Try another product, service, job or location.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _wideItemCard(results[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _exploreFilterBar(int resultCount) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 7, 12, 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              '$resultCount results',
              style: const TextStyle(
                color: ink,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _filterButton(
            icon: Icons.tune_rounded,
            label: 'Filters',
            active: _onlyFastDelivery || _onlyTopRated,
            onTap: _showExploreFilters,
          ),
          const SizedBox(width: 8),
          _filterButton(
            icon: Icons.swap_vert_rounded,
            label: 'Sort',
            active: _sort != 'Recommended',
            onTap: _showSortOptions,
          ),
        ],
      ),
    );
  }

  Widget _filterButton({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: active ? purple : ink,
        side: BorderSide(
          color: active ? purple : const Color(0xffD8DCE5),
        ),
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _itemCard(_MarketplaceItem item) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _showDetails(item),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    height: 92,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: item.color,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(item.icon, color: Colors.white, size: 48),
                  ),
                  Positioned(
                    top: 7,
                    right: 7,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.star_rounded, color: Color(0xffF59E0B), size: 14),
                          Text(item.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 7,
                    left: 7,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => _toggleFavourite(item),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            _favourites.contains(item)
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: _favourites.contains(item)
                                ? const Color(0xffEF4444)
                                : ink,
                            size: 17,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: ink, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(item.category, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xff71798A), fontSize: 12)),
              const Spacer(),
              Row(
                children: <Widget>[
                  const Icon(Icons.location_on_outlined, size: 14, color: purple),
                  const SizedBox(width: 3),
                  Expanded(child: Text(item.city, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11))),
                  Text(item.priceLabel, style: const TextStyle(color: purple, fontSize: 11, fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 7),
              Row(
                children: <Widget>[
                  Icon(
                    item.deliveryMinutes <= 30
                        ? Icons.bolt_rounded
                        : Icons.schedule_rounded,
                    size: 14,
                    color: item.deliveryMinutes <= 30
                        ? const Color(0xff10B981)
                        : const Color(0xff64748B),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${item.deliveryMinutes} min',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (item.type == 'Product Seller')
                    InkWell(
                      onTap: () => _addToCart(item),
                      child: const Text(
                        'ADD +',
                        style: TextStyle(
                          color: purple,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _wideItemCard(_MarketplaceItem item) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _showDetails(item),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(color: item.color, borderRadius: BorderRadius.circular(16)),
                child: Icon(item.icon, color: Colors.white, size: 39),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(child: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w900))),
                        const Icon(Icons.star_rounded, color: Color(0xffF59E0B), size: 17),
                        Text(item.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(item.category, style: const TextStyle(color: Color(0xff667085), fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(item.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xff8A91A0), fontSize: 12)),
                    const SizedBox(height: 7),
                    Row(
                      children: <Widget>[
                        const Icon(Icons.location_on_outlined, size: 15, color: purple),
                        Expanded(child: Text(item.city, style: const TextStyle(fontSize: 11))),
                        Text(item.priceLabel, style: const TextStyle(color: purple, fontSize: 12, fontWeight: FontWeight.w900)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        _SmallBadge(
                          label: '${item.deliveryMinutes} MIN',
                          color: item.deliveryMinutes <= 30
                              ? const Color(0xff059669)
                              : const Color(0xff64748B),
                        ),
                        const SizedBox(width: 6),
                        if (item.isVerified)
                          const _SmallBadge(
                            label: 'VERIFIED',
                            color: purple,
                          ),
                        const Spacer(),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _toggleFavourite(item),
                          icon: Icon(
                            _favourites.contains(item)
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: _favourites.contains(item)
                                ? const Color(0xffEF4444)
                                : const Color(0xff64748B),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartScreen() {
    return SafeArea(
      bottom: false,
      child: Column(
        children: <Widget>[
          _simpleAppBar('My Cart'),
          Expanded(
            child: _cartCount == 0
                ? _emptyState(
                    Icons.shopping_cart_outlined,
                    'Your cart is waiting',
                    'Add food, groceries or products from nearby partners.',
                    button: 'EXPLORE NOW',
                    onPressed: () => setState(() => _tab = 1),
                  )
                : Column(
                    children: <Widget>[
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
                          children: <Widget>[
                            _cartStoreHeader(),
                            const SizedBox(height: 12),
                            ..._cart.entries.map(_cartItemTile),
                            const SizedBox(height: 6),
                            _couponCard(),
                            const SizedBox(height: 12),
                            _deliveryAddressCard(),
                            const SizedBox(height: 12),
                            _billDetails(),
                            const SizedBox(height: 12),
                            _deliveryInstructions(),
                          ],
                        ),
                      ),
                      _cartCheckoutBar(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _cartStoreHeader() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[purple, blue],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.storefront_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Flash2Mart local order',
                  style: TextStyle(color: ink, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 3),
                Text(
                  'Items may arrive in separate deliveries',
                  style: TextStyle(color: Color(0xff71798A), fontSize: 11),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _tab = 1),
            child: const Text('ADD MORE'),
          ),
        ],
      ),
    );
  }

  Widget _cartItemTile(MapEntry<_MarketplaceItem, int> entry) {
    final item = entry.key;
    final quantity = entry.value;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: item.color.withAlpha(30),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(item.icon, color: item.color, size: 31),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.category,
                  style: const TextStyle(
                    color: Color(0xff71798A),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '₹${item.numericPrice.toStringAsFixed(0)}',
                  style: const TextStyle(color: ink, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xffF0ECFF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xffD8CEFF)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _quantityButton(Icons.remove_rounded, () => _removeFromCart(item)),
                SizedBox(
                  width: 28,
                  child: Text(
                    '$quantity',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: purple,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _quantityButton(Icons.add_rounded, () => _addToCart(item, silent: true)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, color: purple, size: 17),
      ),
    );
  }

  Widget _couponCard() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: _showCoupons,
        child: const Padding(
          padding: EdgeInsets.all(15),
          child: Row(
            children: <Widget>[
              Icon(Icons.local_offer_rounded, color: purple),
              SizedBox(width: 11),
              Expanded(
                child: Text(
                  'Apply coupon',
                  style: TextStyle(color: ink, fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                'View offers',
                style: TextStyle(
                  color: purple,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: purple),
            ],
          ),
        ),
      ),
    );
  }

  Widget _deliveryAddressCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.home_rounded, color: purple),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Deliver to Home',
                  style: TextStyle(color: ink, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  _location == 'Your location'
                      ? 'Select your delivery address'
                      : _location,
                  style: const TextStyle(
                    color: Color(0xff71798A),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          TextButton(onPressed: _chooseLocation, child: const Text('CHANGE')),
        ],
      ),
    );
  }

  Widget _billDetails() {
    const platformFee = 5.0;
    final taxes = _cartSubtotal * .03;
    final total = _cartTotal;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Bill details',
            style: TextStyle(color: ink, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          _priceRow('Item total', '₹${_cartSubtotal.toStringAsFixed(0)}'),
          _priceRow(
            'Delivery fee',
            _deliveryFee == 0 ? 'FREE' : '₹${_deliveryFee.toStringAsFixed(0)}',
          ),
          _priceRow('Platform fee', '₹${platformFee.toStringAsFixed(0)}'),
          _priceRow('Taxes & charges', '₹${taxes.toStringAsFixed(0)}'),
          if (_couponDiscount > 0)
            _priceRow(
              'Coupon discount ($_appliedCoupon)',
              '- ₹${_couponDiscount.toStringAsFixed(0)}',
            ),
          const Divider(height: 25),
          _priceRow('To pay', '₹${total.toStringAsFixed(0)}', strong: true),
        ],
      ),
    );
  }

  Widget _deliveryInstructions() {
    const instructions = <(IconData, String)>[
      (Icons.notifications_none_rounded, 'Avoid calling'),
      (Icons.door_front_door_outlined, 'Leave at door'),
      (Icons.security_rounded, 'Contactless'),
    ];
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Delivery instructions',
            style: TextStyle(color: ink, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 70,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: instructions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 9),
              itemBuilder: (context, index) {
                final instruction = instructions[index];
                final selected = _selectedInstruction == instruction.$2;
                return InkWell(
                  borderRadius: BorderRadius.circular(13),
                  onTap: () => setState(() {
                    _selectedInstruction = selected ? '' : instruction.$2;
                  }),
                  child: Container(
                    width: 105,
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xffF0ECFF) : page,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: selected ? purple : const Color(0xffE4E7ED),
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        Icon(
                          selected ? Icons.check_circle_rounded : instruction.$1,
                          size: 21,
                          color: selected ? purple : ink,
                        ),
                        const Spacer(),
                        Text(
                          instruction.$2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: selected ? purple : ink,
                            fontSize: 9.5,
                            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartCheckoutBar() {
    final total = _cartTotal;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, -4)),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '₹${total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'TOTAL',
                  style: TextStyle(
                    color: Color(0xff71798A),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: purple,
              minimumSize: const Size(205, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _startCheckout,
            icon: const Icon(Icons.lock_outline_rounded, size: 18),
            label: const Text(
              'SELECT PAYMENT',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orders() {
    return SafeArea(
      bottom: false,
      child: Column(
        children: <Widget>[
          _simpleAppBar('Orders & Bookings'),
          Expanded(
            child: _customerOrders.isEmpty
                ? _emptyState(
                    Icons.receipt_long_outlined,
                    'No orders yet',
                    'Product orders, service bookings and job applications will appear here.',
                    button: 'START EXPLORING',
                    onPressed: () => setState(() => _tab = 1),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 25),
                    itemCount: _customerOrders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _orderCard(_customerOrders[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _orderCard(_CustomerOrder order) {
    final isService = order.kind == 'Service';
    final isJob = order.kind == 'Job';
    final accent = isService
        ? const Color(0xff0EA5E9)
        : isJob
            ? const Color(0xff8B5CF6)
            : const Color(0xff059669);
    final icon = isService
        ? Icons.home_repair_service_rounded
        : isJob
            ? Icons.work_rounded
            : Icons.inventory_2_rounded;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xffECFDF5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      order.id,
                      style: const TextStyle(
                        color: ink,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isJob
                          ? '${order.note} • ${order.paymentMethod}'
                          : isService
                              ? '${order.partnerName} • ${order.note}'
                              : '${order.itemCount} items • ${order.paymentMethod}',
                      style: const TextStyle(
                        color: Color(0xff71798A),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              _SmallBadge(label: order.status, color: accent),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: isJob ? .2 : isService ? .25 : .35,
              minHeight: 6,
              backgroundColor: const Color(0xffE5E7EB),
              color: accent,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  isJob
                      ? 'Application sent for employer review'
                      : isService
                          ? 'Waiting for provider confirmation'
                          : 'Partner is preparing your order',
                  style: const TextStyle(
                    color: ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (!isJob)
                Text(
                  order.total <= 0
                      ? 'Price pending'
                      : '₹${order.total.toStringAsFixed(0)}',
                  style: const TextStyle(color: ink, fontWeight: FontWeight.w900),
                ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => isJob
                      ? _message('Application timeline opened')
                      : _showOrderTracking(order),
                  icon: Icon(
                    isJob ? Icons.timeline_rounded : Icons.location_on_outlined,
                    size: 17,
                  ),
                  label: Text(isJob ? 'STATUS' : 'TRACK'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: purple),
                  onPressed: () => _message('Support request opened'),
                  icon: const Icon(Icons.support_agent_rounded, size: 17),
                  label: const Text('HELP'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _profile() {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 26),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[Color(0xff4C1D95), Color(0xff2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0x42FFFFFF),
                        shape: BoxShape.circle,
                      ),
                      child: const CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person_rounded,
                          color: purple,
                          size: 38,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.customerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Row(
                            children: <Widget>[
                              Icon(
                                Icons.verified_rounded,
                                color: Color(0xff86EFAC),
                                size: 15,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Verified Flash2Mart Customer',
                                style: TextStyle(
                                  color: Color(0xffEAE6FF),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _showEditProfile,
                      icon: const Icon(Icons.edit_outlined, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: <Widget>[
                    _profileSummary(
                      Icons.account_balance_wallet_rounded,
                      '₹${_walletBalance.toStringAsFixed(0)}',
                      'Wallet',
                      _showWallet,
                    ),
                    const SizedBox(width: 9),
                    _profileSummary(
                      Icons.stars_rounded,
                      '$_rewardPoints',
                      'Rewards',
                      _showRewards,
                    ),
                    const SizedBox(width: 9),
                    _profileSummary(
                      Icons.workspace_premium_rounded,
                      _flashPassActive ? 'Active' : 'Join',
                      'Flash Pass',
                      _showFlashPass,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 20, 18, 10),
            child: Text(
              'MY ACCOUNT',
              style: TextStyle(
                color: Color(0xff7C8496),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
          _profileTile(
            Icons.location_on_outlined,
            'Saved Addresses',
            'Home, work and other addresses',
            onTap: _showSavedAddresses,
          ),
          _profileTile(
            Icons.account_balance_wallet_outlined,
            'Payments & Wallet',
            'UPI, cards, cash and wallet',
            onTap: _showWallet,
          ),
          _profileTile(
            Icons.favorite_border_rounded,
            'Favourites',
            '${_favourites.length} saved partners',
            onTap: _showFavourites,
          ),
          _profileTile(
            Icons.local_offer_outlined,
            'Coupons & Offers',
            _appliedCoupon.isEmpty ? 'Offers selected for you' : '$_appliedCoupon applied',
            onTap: _showCoupons,
          ),
          _profileTile(
            Icons.card_giftcard_rounded,
            'Refer & Earn',
            'Invite friends and earn rewards',
            onTap: _showReferAndEarn,
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 13, 18, 10),
            child: Text(
              'SUPPORT & SETTINGS',
              style: TextStyle(
                color: Color(0xff7C8496),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
          _profileTile(
            Icons.support_agent_rounded,
            'Help & Support',
            'Orders, payments and account help',
            onTap: _showHelpAndSupport,
          ),
          _profileTile(
            Icons.tune_rounded,
            'App Settings',
            'Notifications, language and appearance',
            onTap: _showAppSettings,
          ),
          _profileTile(
            Icons.shield_outlined,
            'Privacy & Security',
            'Account protection and permissions',
            onTap: _showPrivacyAndSecurity,
          ),
          _profileTile(
            Icons.info_outline_rounded,
            'About Flash2Mart',
            'Official customer app • Version 2.0.0',
            onTap: _showAboutFlash2Mart,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xffDC2626),
                minimumSize: const Size.fromHeight(52),
                side: const BorderSide(color: Color(0xffFCA5A5)),
              ),
              onPressed: _confirmLogout,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('LOGOUT'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _simpleAppBar(String title) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xffECECF4))),
      ),
      alignment: Alignment.centerLeft,
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: <Color>[purple, blue]),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(_iconForText(title), color: Colors.white, size: 21),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(title, style: const TextStyle(color: ink, fontSize: 20, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(IconData icon, String title, String subtitle, {String? button, VoidCallback? onPressed}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(34),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 92,
              height: 92,
              decoration: const BoxDecoration(color: Color(0xffEAE4FF), shape: BoxShape.circle),
              child: Icon(icon, color: purple, size: 45),
            ),
            const SizedBox(height: 18),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(color: ink, fontSize: 19, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xff7C8496), height: 1.45)),
            if (button != null) ...<Widget>[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onPressed,
                style: FilledButton.styleFrom(backgroundColor: purple),
                icon: Icon(_iconForText(button)),
                label: Text(button),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _profileSummary(
    IconData icon,
    String value,
    String label,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: Material(
        color: const Color(0x24FFFFFF),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Column(
              children: <Widget>[
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(height: 5),
                Text(
                  value,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xffDDE5FF),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileTile(
    IconData icon,
    String title,
    String subtitle, {
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(color: const Color(0xffF0ECFF), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: purple),
        ),
        title: Text(title, style: const TextStyle(color: ink, fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }

  Widget _roundButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: const Color(0xffF3F4F8),
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: SizedBox(width: 43, height: 43, child: Icon(icon, color: ink)),
      ),
    );
  }

  Future<T?> _showAccountSheet<T>({
    required String title,
    required Widget Function(BuildContext sheetContext) builder,
    double heightFactor = .78,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        height: MediaQuery.sizeOf(context).height * heightFactor,
        decoration: const BoxDecoration(
          color: page,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 10),
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xffD8DAE1),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 10, 12),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: <Color>[purple, blue]),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(_iconForText(title), color: Colors.white, size: 21),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: ink,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(child: builder(sheetContext)),
          ],
        ),
      ),
    );
  }

  void _showEditProfile() {
    final name = TextEditingController(text: widget.customerName);
    final mobile = TextEditingController();
    final email = TextEditingController();
    _showAccountSheet<void>(
      title: 'Edit profile',
      heightFactor: .72,
      builder: (sheetContext) => ListView(
        padding: const EdgeInsets.fromLTRB(18, 2, 18, 24),
        children: <Widget>[
          Center(
            child: Stack(
              children: <Widget>[
                const CircleAvatar(
                  radius: 45,
                  backgroundColor: Color(0xffEAE4FF),
                  child: Icon(Icons.person_rounded, color: purple, size: 52),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 31,
                    height: 31,
                    decoration: const BoxDecoration(
                      color: purple,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          TextField(
            controller: name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Full name',
              prefixIcon: Icon(Icons.person_outline_rounded),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: mobile,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            decoration: const InputDecoration(
              labelText: 'Mobile number',
              prefixIcon: Icon(Icons.phone_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email address',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: purple,
              minimumSize: const Size.fromHeight(52),
            ),
            onPressed: () {
              if (name.text.trim().isEmpty) {
                _message('Please enter your name');
                return;
              }
              Navigator.pop(sheetContext);
              _message('Profile details saved');
            },
            icon: const Icon(Icons.check_rounded),
            label: const Text('SAVE CHANGES'),
          ),
        ],
      ),
    ).whenComplete(() {
      name.dispose();
      mobile.dispose();
      email.dispose();
    });
  }

  void _showWallet() {
    _showAccountSheet<void>(
      title: 'Payments & Wallet',
      builder: (sheetContext) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 26),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[Color(0xff4C1D95), Color(0xff2563EB)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Row(
                  children: <Widget>[
                    Icon(Icons.bolt_rounded, color: Colors.white),
                    SizedBox(width: 7),
                    Text(
                      'Flash Wallet',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.shield_rounded, color: Color(0xff86EFAC)),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'AVAILABLE BALANCE',
                  style: TextStyle(
                    color: Color(0xffDDE5FF),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .8,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '₹${_walletBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 17),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: ink,
                  ),
                  onPressed: () {
                    setState(() => _walletBalance += 100);
                    Navigator.pop(sheetContext);
                    _message('₹100 demo balance added');
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('ADD MONEY'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Saved payment methods',
            style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          _accountListCard(
            Icons.qr_code_rounded,
            'UPI',
            'Add any UPI ID or app',
            trailing: 'ADD',
          ),
          _accountListCard(
            Icons.credit_card_rounded,
            'Credit / Debit Cards',
            'No cards saved yet',
            trailing: 'ADD',
          ),
          _accountListCard(
            Icons.payments_rounded,
            'Cash on Delivery',
            'Available on eligible orders',
            trailing: 'READY',
          ),
          const SizedBox(height: 17),
          const Text(
            'Recent wallet activity',
            style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          _walletTransaction('Welcome reward', '+ ₹100', true),
          _walletTransaction('Promotional cashback', '+ ₹25', true),
        ],
      ),
    );
  }

  Widget _walletTransaction(String label, String amount, bool credit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xffECFDF5),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              credit ? Icons.south_west_rounded : Icons.north_east_rounded,
              color: const Color(0xff059669),
              size: 19,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: ink, fontWeight: FontWeight.w800),
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: credit ? const Color(0xff059669) : const Color(0xffDC2626),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _accountListCard(
    IconData icon,
    String title,
    String subtitle, {
    String trailing = '',
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap ?? () => _message('$title selected'),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xffF0ECFF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: purple, size: 21),
        ),
        title: Text(
          title,
          style: const TextStyle(color: ink, fontWeight: FontWeight.w800),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
        trailing: trailing.isEmpty
            ? const Icon(Icons.chevron_right_rounded)
            : Text(
                trailing,
                style: const TextStyle(
                  color: purple,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
      ),
    );
  }

  void _showRewards() {
    _showAccountSheet<void>(
      title: 'Flash Rewards',
      heightFactor: .68,
      builder: (sheetContext) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 24),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[Color(0xffFFF7D6), Color(0xffFFEDD5)],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xffFDE68A)),
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.stars_rounded, color: Color(0xffD97706), size: 54),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'AVAILABLE POINTS',
                        style: TextStyle(
                          color: Color(0xff92400E),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .8,
                        ),
                      ),
                      Text(
                        '$_rewardPoints',
                        style: const TextStyle(
                          color: Color(0xff78350F),
                          fontSize: 29,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text(
                        '100 points = ₹10 reward value',
                        style: TextStyle(color: Color(0xff92400E), fontSize: 10.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Earn more points',
            style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          _accountListCard(Icons.shopping_bag_rounded, 'Place an order', 'Earn points on eligible orders', trailing: '+ POINTS'),
          _accountListCard(Icons.person_add_alt_1_rounded, 'Refer a friend', 'Earn after their first completed order', trailing: '+ 500'),
          _accountListCard(Icons.rate_review_rounded, 'Rate an order', 'Help local partners improve', trailing: '+ 20'),
          const SizedBox(height: 12),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: purple, minimumSize: const Size.fromHeight(50)),
            onPressed: () {
              Navigator.pop(sheetContext);
              setState(() => _tab = 1);
            },
            child: const Text('EXPLORE REWARDS'),
          ),
        ],
      ),
    );
  }

  void _showFlashPass() {
    _showAccountSheet<void>(
      title: 'Flash Pass',
      heightFactor: .72,
      builder: (sheetContext) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 24),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[Color(0xff111827), Color(0xff312E81)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(Icons.workspace_premium_rounded, color: Color(0xffFACC15), size: 42),
                const SizedBox(height: 12),
                Text(
                  _flashPassActive ? 'Your Flash Pass is active' : 'More savings. More convenience.',
                  style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Built for customers who order, book and travel regularly.',
                  style: TextStyle(color: Color(0xffC7D2FE), fontSize: 11.5, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 17),
          _benefitRow(Icons.local_shipping_rounded, 'Free delivery', 'On eligible food, grocery and shop orders'),
          _benefitRow(Icons.local_offer_rounded, 'Members-only offers', 'Extra savings from selected partners'),
          _benefitRow(Icons.support_agent_rounded, 'Priority support', 'Faster help for eligible transactions'),
          _benefitRow(Icons.two_wheeler_rounded, 'Ride benefits', 'Special offers on selected Flash Rides'),
          const SizedBox(height: 14),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _flashPassActive ? const Color(0xffDC2626) : purple,
              minimumSize: const Size.fromHeight(52),
            ),
            onPressed: () {
              setState(() => _flashPassActive = !_flashPassActive);
              Navigator.pop(sheetContext);
              _message(_flashPassActive ? 'Flash Pass activated' : 'Flash Pass paused');
            },
            child: Text(_flashPassActive ? 'PAUSE MEMBERSHIP' : 'START FREE TRIAL'),
          ),
          const SizedBox(height: 8),
          const Text(
            'Demo membership UI. Connect your subscription API before production launch.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xff7C8496), fontSize: 9.5),
          ),
        ],
      ),
    );
  }

  Widget _benefitRow(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: <Widget>[
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(color: const Color(0xffF0ECFF), borderRadius: BorderRadius.circular(13)),
            child: Icon(icon, color: purple, size: 22),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: const TextStyle(color: ink, fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(color: Color(0xff71798A), fontSize: 10.5)),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: Color(0xff10B981), size: 20),
        ],
      ),
    );
  }

  void _showSavedAddresses() {
    _showAccountSheet<void>(
      title: 'Saved Addresses',
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Column(
          children: <Widget>[
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
                itemCount: _savedAddresses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final address = _savedAddresses[index];
                  final selected = _location == address.address;
                  return Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        setState(() => _location = address.address);
                        Navigator.pop(sheetContext);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: selected ? const Color(0xffEAE4FF) : page,
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Icon(address.icon, color: selected ? purple : ink),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(address.label, style: const TextStyle(color: ink, fontWeight: FontWeight.w900)),
                                  const SizedBox(height: 4),
                                  Text(address.address, style: const TextStyle(color: Color(0xff71798A), fontSize: 11, height: 1.35)),
                                ],
                              ),
                            ),
                            if (selected) const Icon(Icons.check_circle_rounded, color: purple),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 11, 16, 16),
              color: Colors.white,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: purple, minimumSize: const Size.fromHeight(52)),
                onPressed: () async {
                  final controller = TextEditingController();
                  final value = await showDialog<String>(
                    context: sheetContext,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Add new address'),
                      content: TextField(
                        controller: controller,
                        autofocus: true,
                        minLines: 2,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'House, street, area, city and pincode',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('CANCEL')),
                        FilledButton(onPressed: () => Navigator.pop(dialogContext, controller.text.trim()), child: const Text('SAVE')),
                      ],
                    ),
                  );
                  controller.dispose();
                  if (value != null && value.isNotEmpty) {
                    setState(() {
                      _savedAddresses.add(_SavedAddress(label: 'Other', address: value, icon: Icons.place_rounded));
                      _location = value;
                    });
                    setSheetState(() {});
                  }
                },
                icon: const Icon(Icons.add_location_alt_rounded),
                label: const Text('ADD NEW ADDRESS'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFavourites() {
    _showAccountSheet<void>(
      title: 'My Favourites',
      builder: (sheetContext) => _favourites.isEmpty
          ? _emptyState(
              Icons.favorite_border_rounded,
              'Nothing saved yet',
              'Tap the heart on a store, service or job to find it here.',
              button: 'EXPLORE NOW',
              onPressed: () {
                Navigator.pop(sheetContext);
                setState(() => _tab = 1);
              },
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 24),
              itemCount: _favourites.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = _favourites.elementAt(index);
                return _wideItemCard(item);
              },
            ),
    );
  }

  void _showReferAndEarn() {
    _showAccountSheet<void>(
      title: 'Refer & Earn',
      heightFactor: .66,
      builder: (sheetContext) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 24),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: <Color>[Color(0xffFDF2F8), Color(0xffEEF2FF)]),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              children: <Widget>[
                Icon(Icons.card_giftcard_rounded, color: purple, size: 64),
                SizedBox(height: 12),
                Text('Invite friends. Earn rewards.', textAlign: TextAlign.center, style: TextStyle(color: ink, fontSize: 20, fontWeight: FontWeight.w900)),
                SizedBox(height: 7),
                Text('Share Flash2Mart and receive reward points after an eligible first order.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xff667085), fontSize: 11.5, height: 1.45)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
            child: const Row(
              children: <Widget>[
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  Text('YOUR REFERRAL CODE', style: TextStyle(color: Color(0xff7C8496), fontSize: 9, fontWeight: FontWeight.w900)),
                  SizedBox(height: 4),
                  Text('FLASH2MART100', style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ])),
                Icon(Icons.copy_rounded, color: purple),
              ],
            ),
          ),
          const SizedBox(height: 15),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: purple, minimumSize: const Size.fromHeight(52)),
            onPressed: () => _message('Referral link ready to share'),
            icon: const Icon(Icons.share_rounded),
            label: const Text('SHARE INVITE'),
          ),
        ],
      ),
    );
  }

  void _showHelpAndSupport() {
    _showAccountSheet<void>(
      title: 'Help & Support',
      builder: (sheetContext) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 24),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xffF0ECFF), borderRadius: BorderRadius.circular(19)),
            child: const Row(children: <Widget>[
              CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.support_agent_rounded, color: purple)),
              SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                Text('How can we help?', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w900)),
                SizedBox(height: 4),
                Text('Choose a topic to start support.', style: TextStyle(color: Color(0xff667085), fontSize: 11)),
              ])),
            ]),
          ),
          const SizedBox(height: 14),
          _accountListCard(Icons.receipt_long_rounded, 'Order help', 'Delivery, cancellation, refund or item issue', onTap: () => _message('Select an order to continue')),
          _accountListCard(Icons.payments_outlined, 'Payment help', 'UPI, card, wallet and refund support', onTap: () => _message('Payment support opened')),
          _accountListCard(Icons.handyman_rounded, 'Service booking help', 'Professional, schedule or service issue', onTap: () => _message('Service support opened')),
          _accountListCard(Icons.two_wheeler_rounded, 'Flash Ride help', 'Driver, fare, safety or trip support', onTap: () => _message('Ride support opened')),
          _accountListCard(Icons.person_outline_rounded, 'Account help', 'Login, profile, privacy and security', onTap: () => _message('Account support opened')),
          const SizedBox(height: 13),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            onPressed: () => _message('Live chat request created'),
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            label: const Text('START LIVE CHAT'),
          ),
        ],
      ),
    );
  }

  void _showAppSettings() {
    _showAccountSheet<void>(
      title: 'App Settings',
      heightFactor: .64,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 24),
          children: <Widget>[
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
              child: SwitchListTile(
                value: _notificationsEnabled,
                activeTrackColor: purple,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                  setSheetState(() {});
                },
                secondary: const Icon(Icons.notifications_outlined, color: purple),
                title: const Text('Notifications', style: TextStyle(color: ink, fontWeight: FontWeight.w800)),
                subtitle: const Text('Orders, offers and account updates', style: TextStyle(fontSize: 11)),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
              child: SwitchListTile(
                value: _darkModeRequested,
                activeTrackColor: purple,
                onChanged: (value) {
                  setState(() => _darkModeRequested = value);
                  setSheetState(() {});
                  _message('Connect this preference to your app ThemeMode');
                },
                secondary: const Icon(Icons.dark_mode_outlined, color: purple),
                title: const Text('Dark appearance', style: TextStyle(color: ink, fontWeight: FontWeight.w800)),
                subtitle: const Text('Saved as your appearance preference', style: TextStyle(fontSize: 11)),
              ),
            ),
            const SizedBox(height: 10),
            _accountListCard(Icons.language_rounded, 'Language', 'English • Telugu can be connected', trailing: 'EN'),
            _accountListCard(Icons.location_on_outlined, 'Location access', 'Used for nearby results and delivery', trailing: 'ON'),
            _accountListCard(Icons.cleaning_services_outlined, 'Clear search history', '${_recentSearches.length} recent searches', onTap: () {
              setState(_recentSearches.clear);
              setSheetState(() {});
              _message('Search history cleared');
            }),
          ],
        ),
      ),
    );
  }

  void _showPrivacyAndSecurity() {
    _showAccountSheet<void>(
      title: 'Privacy & Security',
      heightFactor: .64,
      builder: (sheetContext) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 24),
        children: <Widget>[
          _accountListCard(Icons.lock_outline_rounded, 'Change password', 'Update your login password securely'),
          _accountListCard(Icons.phonelink_lock_rounded, 'Login security', 'OTP and trusted-device settings'),
          _accountListCard(Icons.admin_panel_settings_outlined, 'App permissions', 'Location, notifications, camera and files'),
          _accountListCard(Icons.receipt_long_outlined, 'Download my data', 'Request a copy of your account information'),
          _accountListCard(Icons.delete_outline_rounded, 'Delete account', 'Permanently remove the customer account'),
          const SizedBox(height: 13),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xffECFDF5), borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xffA7F3D0))),
            child: const Row(children: <Widget>[
              Icon(Icons.verified_user_rounded, color: Color(0xff059669)),
              SizedBox(width: 10),
              Expanded(child: Text('Your account is protected with secure sign-in.', style: TextStyle(color: Color(0xff065F46), fontSize: 11, fontWeight: FontWeight.w700))),
            ]),
          ),
        ],
      ),
    );
  }

  void _showAboutFlash2Mart() {
    _showAccountSheet<void>(
      title: 'About Flash2Mart',
      heightFactor: .66,
      builder: (sheetContext) => ListView(
        padding: const EdgeInsets.fromLTRB(18, 2, 18, 24),
        children: <Widget>[
          Center(
            child: Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: <Color>[purple, blue]),
                borderRadius: BorderRadius.circular(27),
                boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x336C3EF4), blurRadius: 20, offset: Offset(0, 8))],
              ),
              child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 52),
            ),
          ),
          const SizedBox(height: 14),
          const Text('Flash2Mart', textAlign: TextAlign.center, style: TextStyle(color: ink, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('Everything nearby. Delivered in a flash.', textAlign: TextAlign.center, style: TextStyle(color: purple, fontSize: 11.5, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          const Text('Flash2Mart connects customers with nearby product sellers, restaurants, grocery stores, service professionals, employers and Flash Ride partners through one customer experience.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xff667085), fontSize: 12, height: 1.55)),
          const SizedBox(height: 20),
          _accountListCard(Icons.new_releases_outlined, 'App version', 'Official customer experience', trailing: '2.0.0'),
          _accountListCard(Icons.description_outlined, 'Terms & Conditions', 'Read platform terms'),
          _accountListCard(Icons.privacy_tip_outlined, 'Privacy Policy', 'How customer data is handled'),
          _accountListCard(Icons.gavel_rounded, 'Legal information', 'Licences and platform disclosures'),
        ],
      ),
    );
  }

  void _showCustomerProtection() {
    _showAccountSheet<void>(
      title: 'Customer Protection',
      heightFactor: .62,
      builder: (sheetContext) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 24),
        children: <Widget>[
          const _ProtectionFeature(icon: Icons.verified_user_rounded, title: 'Verified partner indicators', subtitle: 'See verification information before ordering or booking.'),
          const _ProtectionFeature(icon: Icons.lock_rounded, title: 'Secure checkout', subtitle: 'Use supported payment methods through a protected flow.'),
          const _ProtectionFeature(icon: Icons.receipt_long_rounded, title: 'Clear order records', subtitle: 'Track order, booking and transaction details in one place.'),
          const _ProtectionFeature(icon: Icons.support_agent_rounded, title: 'Customer support', subtitle: 'Raise issues from the relevant order or service booking.'),
          const SizedBox(height: 10),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: purple, minimumSize: const Size.fromHeight(50)),
            onPressed: () {
              Navigator.pop(sheetContext);
              _showHelpAndSupport();
            },
            icon: const Icon(Icons.support_agent_rounded),
            label: const Text('CONTACT SUPPORT'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.logout_rounded, color: Color(0xffDC2626), size: 42),
        title: const Text('Logout from Flash2Mart?'),
        content: const Text('You will need to sign in again to access your customer account.', textAlign: TextAlign.center),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('CANCEL')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xffDC2626)),
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.maybePop(context);
            },
            child: const Text('LOGOUT'),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String amount, {bool strong = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label, style: TextStyle(fontSize: strong ? 16 : 14, fontWeight: strong ? FontWeight.w900 : FontWeight.w500))),
          Text(amount, style: TextStyle(color: strong ? ink : const Color(0xff5F6675), fontSize: strong ? 17 : 14, fontWeight: strong ? FontWeight.w900 : FontWeight.w700)),
        ],
      ),
    );
  }

  void _addToCart(_MarketplaceItem item, {bool silent = false}) {
    setState(() {
      _cart.update(item, (quantity) => quantity + 1, ifAbsent: () => 1);
    });
    if (!silent) _message('${item.title} added to cart');
  }

  void _removeFromCart(_MarketplaceItem item) {
    final quantity = _cart[item] ?? 0;
    setState(() {
      if (quantity <= 1) {
        _cart.remove(item);
      } else {
        _cart[item] = quantity - 1;
      }
    });
  }

  void _toggleFavourite(_MarketplaceItem item) {
    setState(() {
      if (_favourites.contains(item)) {
        _favourites.remove(item);
      } else {
        _favourites.add(item);
      }
    });
  }

  void _showSmartSearch() {
    const popular = <(String, IconData, Color)>[
      ('Biryani', Icons.rice_bowl_rounded, Color(0xffF97316)),
      ('Vegetables', Icons.eco_rounded, Color(0xff22C55E)),
      ('Medicines', Icons.medication_rounded, Color(0xffEF4444)),
      ('AC service', Icons.ac_unit_rounded, Color(0xff3B82F6)),
      ('Electrician', Icons.electrical_services_rounded, Color(0xff0EA5E9)),
      ('Jobs near me', Icons.work_rounded, Color(0xff8B5CF6)),
    ];

    _showAccountSheet<void>(
      title: 'Smart Search',
      heightFactor: .76,
      builder: (sheetContext) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 25),
        children: <Widget>[
          TextField(
            autofocus: true,
            onSubmitted: (value) {
              final term = value.trim();
              if (term.isEmpty) return;
              setState(() {
                _query = term;
                _searchController.text = term;
                _recentSearches.remove(term);
                _recentSearches.insert(0, term);
                if (_recentSearches.length > 6) _recentSearches.removeLast();
              });
              Navigator.pop(sheetContext);
              _openExplore('All');
            },
            decoration: InputDecoration(
              hintText: 'Search food, products, services or jobs',
              prefixIcon: const Icon(Icons.search_rounded, color: purple),
              suffixIcon: const Icon(Icons.graphic_eq_rounded, color: purple),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xffE4E7EF)),
              ),
            ),
          ),
          if (_recentSearches.isNotEmpty) ...<Widget>[
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                const Expanded(
                  child: Text(
                    'Recent searches',
                    style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(_recentSearches.clear);
                    Navigator.pop(sheetContext);
                    _showSmartSearch();
                  },
                  icon: const Icon(Icons.cleaning_services_rounded, size: 17),
                  label: const Text('CLEAR'),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches.map((term) {
                return ActionChip(
                  avatar: const Icon(Icons.history_rounded, size: 16),
                  label: Text(term),
                  onPressed: () {
                    setState(() {
                      _query = term;
                      _searchController.text = term;
                    });
                    Navigator.pop(sheetContext);
                    _openExplore('All');
                  },
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 22),
          const Text(
            'Popular near you',
            style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 11),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: popular.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.75,
              mainAxisSpacing: 9,
              crossAxisSpacing: 9,
            ),
            itemBuilder: (context, index) {
              final item = popular[index];
              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    setState(() {
                      _query = item.$1;
                      _searchController.text = item.$1;
                      _recentSearches.remove(item.$1);
                      _recentSearches.insert(0, item.$1);
                    });
                    Navigator.pop(sheetContext);
                    _openExplore('All');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: item.$3.withAlpha(28),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(item.$2, color: item.$3, size: 19),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.$1,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: ink,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xffF0ECFF),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Row(
              children: <Widget>[
                Icon(Icons.lightbulb_rounded, color: purple),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Try a shop name, dish, product, profession, skill or job title.',
                    style: TextStyle(
                      color: ink,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSortOptions() {
    const options = <(String, IconData)>[
      ('Recommended', Icons.auto_awesome_rounded),
      ('Rating', Icons.star_rounded),
      ('Delivery time', Icons.schedule_rounded),
      ('Price: Low to High', Icons.currency_rupee_rounded),
    ];
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Sort results',
                style: TextStyle(
                  color: ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              ...options.map(
                (option) => RadioListTile<String>(
                  value: option.$1,
                  groupValue: _sort,
                  contentPadding: EdgeInsets.zero,
                  activeColor: purple,
                  secondary: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xffF0ECFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(option.$2, color: purple, size: 20),
                  ),
                  title: Text(option.$1),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _sort = value);
                    Navigator.pop(sheetContext);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExploreFilters() {
    bool fast = _onlyFastDelivery;
    bool rated = _onlyTopRated;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Filters',
                    style: TextStyle(
                      color: ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: purple,
                    secondary: const Icon(Icons.timer_rounded, color: purple),
                    title: const Text('Fast delivery'),
                    subtitle: const Text('Delivery in 30 minutes or less'),
                    value: fast,
                    onChanged: (value) => setSheetState(() => fast = value),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: purple,
                    secondary: const Icon(Icons.star_rounded, color: Color(0xffF59E0B)),
                    title: const Text('Top rated'),
                    subtitle: const Text('Rating 4.5 and above'),
                    value: rated,
                    onChanged: (value) => setSheetState(() => rated = value),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => setSheetState(() {
                            fast = false;
                            rated = false;
                          }),
                          icon: const Icon(Icons.restart_alt_rounded),
                          label: const Text('CLEAR'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(backgroundColor: purple),
                          onPressed: () {
                            setState(() {
                              _onlyFastDelivery = fast;
                              _onlyTopRated = rated;
                            });
                            Navigator.pop(sheetContext);
                          },
                          icon: const Icon(Icons.tune_rounded),
                          label: const Text('APPLY'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCoupons() {
    const coupons = <(String, String, String, IconData, Color)>[
      ('FLASH40', '40% off up to ₹100', 'On your first order', Icons.bolt_rounded, Color(0xff6C3EF4)),
      ('FREEDEL', 'Free delivery', 'On selected local partners', Icons.local_shipping_rounded, Color(0xff10B981)),
      ('LOCAL50', '₹50 off', 'On orders above ₹499', Icons.storefront_rounded, Color(0xffF97316)),
    ];
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Available coupons',
                style: TextStyle(
                  color: ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              ...coupons.map(
                (coupon) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: page,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xffE4E7ED)),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: coupon.$5.withAlpha(24),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Icon(coupon.$4, color: coupon.$5, size: 22),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              coupon.$1,
                              style: const TextStyle(
                                color: ink,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              '${coupon.$2} • ${coupon.$3}',
                              style: const TextStyle(
                                color: Color(0xff71798A),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (coupon.$1 == 'LOCAL50' && _cartSubtotal < 499) {
                            _message('LOCAL50 requires a minimum order of ₹499');
                            return;
                          }
                          setState(() => _appliedCoupon = coupon.$1);
                          Navigator.pop(sheetContext);
                          _message('${coupon.$1} applied');
                        },
                        child: Text(
                          _appliedCoupon == coupon.$1 ? 'APPLIED' : 'APPLY',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startCheckout() {
    if (_location == 'Your location') {
      _message('Please select a delivery address first');
      _chooseLocation();
      return;
    }
    String payment = 'Cash on Delivery';
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final total = _cartTotal;
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                18,
                0,
                18,
                MediaQuery.viewInsetsOf(context).bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Choose payment method',
                    style: TextStyle(
                      color: ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...<(String, IconData, Color)>[
                    ('UPI', Icons.qr_code_2_rounded, Color(0xff6C3EF4)),
                    ('Card', Icons.credit_card_rounded, Color(0xff2F80ED)),
                    ('Cash on Delivery', Icons.payments_rounded, Color(0xff10B981)),
                  ].map(
                    (method) => RadioListTile<String>(
                      value: method.$1,
                      groupValue: payment,
                      activeColor: purple,
                      contentPadding: EdgeInsets.zero,
                      secondary: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: method.$3.withAlpha(24),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Icon(method.$2, color: method.$3, size: 21),
                      ),
                      title: Text(method.$1),
                      onChanged: (value) {
                        if (value != null) {
                          setSheetState(() => payment = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: purple,
                      minimumSize: const Size.fromHeight(52),
                    ),
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _placeOrder(payment, total);
                    },
                    child: Text(
                      'PLACE ORDER • ₹${total.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
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

  void _placeOrder(String payment, double total) {
    final order = _CustomerOrder(
      id: 'F2M${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      itemCount: _cartCount,
      total: total,
      paymentMethod: payment,
      createdAt: DateTime.now(),
    );
    setState(() {
      _customerOrders.insert(0, order);
      _cart.clear();
      _rewardPoints += (total / 10).floor();
      _appliedCoupon = '';
      _selectedInstruction = '';
      _tab = 3;
    });
    _showSuccessDialog(
      title: 'Order confirmed!',
      message: 'Your order ${order.id} has been placed successfully.',
    );
  }

  void _showSuccessDialog({required String title, required String message}) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.check_circle_rounded,
          color: Color(0xff10B981),
          size: 52,
        ),
        title: Text(title, textAlign: TextAlign.center),
        content: Text(message, textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: <Widget>[
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: purple),
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('DONE'),
          ),
        ],
      ),
    );
  }

  void _showNotifications() {
    const notifications = <(IconData, Color, String, String)>[
      (
        Icons.local_offer_rounded,
        Color(0xffF97316),
        'Welcome offer unlocked',
        'Use FLASH40 on your first eligible order.',
      ),
      (
        Icons.verified_rounded,
        Color(0xff10B981),
        'Verified partners near you',
        'Discover trusted shops and professionals nearby.',
      ),
      (
        Icons.work_rounded,
        Color(0xff8B5CF6),
        'New local jobs',
        'Fresh opportunities were added in your area.',
      ),
    ];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .65,
          child: Column(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.fromLTRB(18, 0, 18, 12),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Notifications',
                        style: TextStyle(
                          color: ink,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      'MARK ALL READ',
                      style: TextStyle(
                        color: purple,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 9),
                  itemBuilder: (context, index) {
                    final item = notifications[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: page,
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: item.$2.withAlpha(30),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Icon(item.$1, color: item.$2),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  item.$3,
                                  style: const TextStyle(
                                    color: ink,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.$4,
                                  style: const TextStyle(
                                    color: Color(0xff71798A),
                                    fontSize: 11,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
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
      ),
    );
  }

  void _showRideBooking() {
    final pickup = TextEditingController(
      text: _location == 'Your location' ? '' : _location,
    );
    final drop = TextEditingController();
    String rideType = 'Bike';
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              top: 70,
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 22),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xffD7DAE2),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Row(
                      children: <Widget>[
                        Icon(Icons.bolt_rounded, color: purple, size: 28),
                        SizedBox(width: 8),
                        Text(
                          'Flash Ride',
                          style: TextStyle(
                            color: ink,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: pickup,
                      decoration: const InputDecoration(
                        labelText: 'Pickup location',
                        prefixIcon: Icon(
                          Icons.radio_button_checked_rounded,
                          color: Color(0xff10B981),
                        ),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: drop,
                      decoration: const InputDecoration(
                        labelText: 'Where do you want to go?',
                        prefixIcon: Icon(
                          Icons.location_on_rounded,
                          color: Color(0xffEF4444),
                        ),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Choose your ride',
                      style: TextStyle(color: ink, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        _rideTypeCard(
                          'Bike',
                          Icons.two_wheeler_rounded,
                          '₹49',
                          rideType == 'Bike',
                          () => setSheetState(() => rideType = 'Bike'),
                        ),
                        const SizedBox(width: 9),
                        _rideTypeCard(
                          'Auto',
                          Icons.electric_rickshaw_rounded,
                          '₹89',
                          rideType == 'Auto',
                          () => setSheetState(() => rideType = 'Auto'),
                        ),
                        const SizedBox(width: 9),
                        _rideTypeCard(
                          'Cab',
                          Icons.local_taxi_rounded,
                          '₹149',
                          rideType == 'Cab',
                          () => setSheetState(() => rideType = 'Cab'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: purple,
                        minimumSize: const Size.fromHeight(52),
                      ),
                      onPressed: () {
                        if (pickup.text.trim().isEmpty ||
                            drop.text.trim().isEmpty) {
                          _message('Enter pickup and destination');
                          return;
                        }
                        Navigator.pop(sheetContext);
                        _message(
                          '$rideType ride request is ready for backend booking',
                        );
                      },
                      icon: const Icon(Icons.route_rounded),
                      label: const Text(
                        'CHECK RIDE',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ).whenComplete(() {
      pickup.dispose();
      drop.dispose();
    });
  }

  Widget _rideTypeCard(
    String title,
    IconData icon,
    String price,
    bool selected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: selected ? const Color(0xffF0ECFF) : page,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? purple : const Color(0xffE4E7ED),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: <Widget>[
              Icon(icon, color: selected ? purple : ink, size: 30),
              const SizedBox(height: 7),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              Text(
                price,
                style: const TextStyle(
                  color: Color(0xff71798A),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderTracking(_CustomerOrder order) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Track ${order.id}',
                style: const TextStyle(
                  color: ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              _trackingStep(
                Icons.check_circle_rounded,
                'Order confirmed',
                'Your order was received',
                true,
              ),
              _trackingStep(
                Icons.restaurant_rounded,
                'Preparing your order',
                'Partner is packing your items',
                true,
              ),
              _trackingStep(
                Icons.delivery_dining_rounded,
                'Out for delivery',
                'Delivery partner will be assigned',
                false,
              ),
              _trackingStep(
                Icons.home_rounded,
                'Delivered',
                'Order reaches your address',
                false,
                showLine: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _trackingStep(
    IconData icon,
    String title,
    String subtitle,
    bool complete, {
    bool showLine = true,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: complete
                    ? const Color(0xffECFDF5)
                    : const Color(0xffF3F4F6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: complete
                    ? const Color(0xff059669)
                    : const Color(0xff9CA3AF),
                size: 20,
              ),
            ),
            if (showLine)
              Container(
                width: 2,
                height: 35,
                color: complete
                    ? const Color(0xffA7F3D0)
                    : const Color(0xffE5E7EB),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    color: complete ? ink : const Color(0xff9CA3AF),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xff71798A),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openExplore(String type) {
    setState(() {
      _exploreType = type;
      _tab = 1;
    });
  }

  void _openBusinessHub(String type) {
    final matchingItems = _items.where((item) => item.type == type).toList();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (routeContext) => _BusinessHubScreen(
          type: type,
          items: matchingItems,
          onItemTap: _showDetails,
          onViewAll: () {
            Navigator.of(routeContext).pop();
            _openExplore(type);
          },
        ),
      ),
    );
  }

  Future<void> _chooseLocation() async {
    final controller = TextEditingController(text: _location == 'Your location' ? '' : _location);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Set delivery location'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.location_on_outlined), hintText: 'Area, city or pincode'),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('CANCEL')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, controller.text.trim()), child: const Text('SAVE')),
        ],
      ),
    );
    controller.dispose();
    if (result != null && result.isNotEmpty && mounted) setState(() => _location = result);
  }

  void _showDetails(_MarketplaceItem item) {
    if (item.type == 'Product Seller') {
      _showStoreCatalogue(item);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .82),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 25),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(child: Container(width: 45, height: 5, decoration: BoxDecoration(color: const Color(0xffD8DAE1), borderRadius: BorderRadius.circular(5)))),
              const SizedBox(height: 17),
              Container(
                height: 145,
                width: double.infinity,
                decoration: BoxDecoration(color: item.color, borderRadius: BorderRadius.circular(21)),
                child: Icon(item.icon, color: Colors.white, size: 72),
              ),
              const SizedBox(height: 18),
              Row(
                children: <Widget>[
                  Expanded(child: Text(item.title, style: const TextStyle(color: ink, fontSize: 22, fontWeight: FontWeight.w900))),
                  IconButton(
                    onPressed: () {
                      _toggleFavourite(item);
                      Navigator.pop(sheetContext);
                      _showDetails(item);
                    },
                    icon: Icon(
                      _favourites.contains(item)
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: _favourites.contains(item)
                          ? const Color(0xffEF4444)
                          : ink,
                    ),
                  ),
                  const Icon(Icons.star_rounded, color: Color(0xffF59E0B)),
                  Text('${item.rating} (${item.reviews})', style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 7),
              Text(item.category, style: const TextStyle(color: purple, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Text(item.description, style: const TextStyle(color: Color(0xff626A79), height: 1.5)),
              const SizedBox(height: 14),
              _detailLine(Icons.location_on_outlined, '${item.city} • ${item.distance}'),
              _detailLine(Icons.verified_outlined, 'Verified Flash2Mart partner'),
              _detailLine(
                Icons.schedule_rounded,
                '${item.deliveryMinutes} min estimated time',
              ),
              _detailLine(Icons.payments_outlined, item.priceLabel),
              if (item.tags.isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: item.tags
                      .map(
                        (tag) => Chip(
                          avatar: Icon(
                            _iconForText(tag),
                            color: purple,
                            size: 16,
                          ),
                          label: Text(tag),
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: purple, minimumSize: const Size.fromHeight(52)),
                onPressed: () {
                  Navigator.pop(sheetContext);
                  if (item.type == 'Product Seller') {
                    _addToCart(item);
                  } else if (item.type == 'Service Provider') {
                    _showServiceBooking(item);
                  } else {
                    _showJobApplication(item);
                  }
                },
                icon: Icon(item.actionIcon),
                label: Text(item.actionText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showServiceBooking(_MarketplaceItem provider) {
    final issue = TextEditingController();
    final address = TextEditingController(
      text: _location == 'Your location' ? '' : _location,
    );
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    String selectedSlot = '10:00 AM – 12:00 PM';

    _showAccountSheet<void>(
      title: 'Book ${provider.category}',
      heightFactor: .9,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 25),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(19),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: provider.color.withAlpha(30),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(provider.icon, color: provider.color, size: 29),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                provider.title,
                                style: const TextStyle(
                                  color: ink,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const Icon(Icons.verified_rounded, color: purple, size: 18),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: <Widget>[
                            const Icon(Icons.star_rounded, color: Color(0xffF59E0B), size: 16),
                            Text(' ${provider.rating} • ${provider.reviews} reviews', style: const TextStyle(color: Color(0xff71798A), fontSize: 10.5)),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(provider.priceLabel, style: const TextStyle(color: purple, fontSize: 12, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Describe the requirement', style: TextStyle(color: ink, fontSize: 15, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            TextField(
              controller: issue,
              minLines: 3,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Example: AC is not cooling properly',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Service address', style: TextStyle(color: ink, fontSize: 15, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            TextField(
              controller: address,
              minLines: 2,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter complete service address',
                prefixIcon: const Icon(Icons.location_on_outlined),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Choose date', style: TextStyle(color: ink, fontSize: 15, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50), alignment: Alignment.centerLeft),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: sheetContext,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 60)),
                );
                if (picked != null) setSheetState(() => selectedDate = picked);
              },
              icon: const Icon(Icons.calendar_month_rounded),
              label: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
            ),
            const SizedBox(height: 16),
            const Text('Select time slot', style: TextStyle(color: ink, fontSize: 15, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <(String, IconData)>[
                ('10:00 AM – 12:00 PM', Icons.wb_sunny_outlined),
                ('12:00 PM – 2:00 PM', Icons.wb_sunny_rounded),
                ('3:00 PM – 5:00 PM', Icons.light_mode_rounded),
                ('5:00 PM – 7:00 PM', Icons.nights_stay_outlined),
              ].map((slot) {
                final selected = selectedSlot == slot.$1;
                return ChoiceChip(
                  avatar: Icon(
                    slot.$2,
                    size: 16,
                    color: selected ? Colors.white : purple,
                  ),
                  label: Text(slot.$1),
                  selected: selected,
                  showCheckmark: false,
                  selectedColor: purple,
                  labelStyle: TextStyle(color: selected ? Colors.white : ink, fontSize: 10.5, fontWeight: FontWeight.w700),
                  onSelected: (_) => setSheetState(() => selectedSlot = slot.$1),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(color: const Color(0xffECFDF5), borderRadius: BorderRadius.circular(15)),
              child: const Row(children: <Widget>[
                Icon(Icons.shield_rounded, color: Color(0xff059669), size: 20),
                SizedBox(width: 9),
                Expanded(child: Text('Pay only through supported Flash2Mart payment options.', style: TextStyle(color: Color(0xff065F46), fontSize: 10.5, fontWeight: FontWeight.w700))),
              ]),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: purple, minimumSize: const Size.fromHeight(52)),
              onPressed: () {
                if (issue.text.trim().length < 8) {
                  _message('Please describe the service requirement');
                  return;
                }
                if (address.text.trim().length < 8) {
                  _message('Please enter the complete service address');
                  return;
                }
                final booking = _CustomerOrder(
                  id: 'SRV${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
                  itemCount: 1,
                  total: provider.numericPrice,
                  paymentMethod: 'Pay after service',
                  createdAt: DateTime.now(),
                  kind: 'Service',
                  partnerName: provider.title,
                  status: 'REQUESTED',
                  note: '${selectedDate.day}/${selectedDate.month}/${selectedDate.year} • $selectedSlot',
                );
                setState(() {
                  _customerOrders.insert(0, booking);
                  _tab = 3;
                  _location = address.text.trim();
                });
                Navigator.pop(sheetContext);
                _showSuccessDialog(title: 'Service requested', message: 'Booking ${booking.id} was created. The provider can confirm the schedule after backend connection.');
              },
              icon: const Icon(Icons.calendar_month_rounded),
              label: const Text('REQUEST BOOKING'),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      issue.dispose();
      address.dispose();
    });
  }

  void _showJobApplication(_MarketplaceItem job) {
    final fullName = TextEditingController(text: widget.customerName == 'Customer' ? '' : widget.customerName);
    final mobile = TextEditingController();
    final experience = TextEditingController();
    final skills = TextEditingController();
    bool declaration = false;

    _showAccountSheet<void>(
      title: 'Apply for job',
      heightFactor: .91,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 25),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(19)),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(color: job.color.withAlpha(30), borderRadius: BorderRadius.circular(15)),
                    child: Icon(job.icon, color: job.color, size: 29),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                      Text(job.subtitle, style: const TextStyle(color: ink, fontSize: 15, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text(job.title, style: const TextStyle(color: Color(0xff667085), fontSize: 11)),
                      const SizedBox(height: 5),
                      Text('${job.priceLabel} • ${job.city}', style: const TextStyle(color: purple, fontSize: 11, fontWeight: FontWeight.w900)),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: fullName,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Full name', prefixIcon: Icon(Icons.person_outline_rounded), filled: true, fillColor: Colors.white, border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: mobile,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(labelText: 'Mobile number', prefixIcon: Icon(Icons.phone_outlined), filled: true, fillColor: Colors.white, border: OutlineInputBorder()),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: experience,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Qualification / Experience', hintText: 'Education, company and years of experience', prefixIcon: Icon(Icons.school_outlined), filled: true, fillColor: Colors.white, border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: skills,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Skills', hintText: 'Enter relevant skills separated by commas', prefixIcon: Icon(Icons.psychology_outlined), filled: true, fillColor: Colors.white, border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: const Row(children: <Widget>[
                Icon(Icons.upload_file_rounded, color: purple),
                SizedBox(width: 11),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  Text('Resume', style: TextStyle(color: ink, fontWeight: FontWeight.w900)),
                  SizedBox(height: 3),
                  Text('File picker can be connected with backend storage.', style: TextStyle(color: Color(0xff71798A), fontSize: 10.5)),
                ])),
                Text('ADD', style: TextStyle(color: purple, fontSize: 10, fontWeight: FontWeight.w900)),
              ]),
            ),
            CheckboxListTile(
              value: declaration,
              activeColor: purple,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (value) => setSheetState(() => declaration = value ?? false),
              title: const Text('I confirm that the information provided is correct.', style: TextStyle(color: ink, fontSize: 11.5, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: purple, minimumSize: const Size.fromHeight(52)),
              onPressed: () {
                if (fullName.text.trim().length < 3) {
                  _message('Please enter your full name');
                  return;
                }
                if (mobile.text.trim().length != 10) {
                  _message('Please enter a valid 10-digit mobile number');
                  return;
                }
                if (skills.text.trim().length < 3) {
                  _message('Please enter your relevant skills');
                  return;
                }
                if (!declaration) {
                  _message('Please accept the declaration');
                  return;
                }
                final application = _CustomerOrder(
                  id: 'JOB${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
                  itemCount: 1,
                  total: 0,
                  paymentMethod: 'Application',
                  createdAt: DateTime.now(),
                  kind: 'Job',
                  partnerName: job.title,
                  status: 'APPLIED',
                  note: job.subtitle,
                );
                setState(() {
                  _customerOrders.insert(0, application);
                  _tab = 3;
                });
                Navigator.pop(sheetContext);
                _showSuccessDialog(title: 'Application submitted', message: 'Application ${application.id} has been saved. Connect the employer API to deliver it to ${job.title}.');
              },
              icon: const Icon(Icons.send_rounded),
              label: const Text('SUBMIT APPLICATION'),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      fullName.dispose();
      mobile.dispose();
      experience.dispose();
      skills.dispose();
    });
  }

  void _showStoreCatalogue(_MarketplaceItem store) {
    final products = _catalogueFor(store);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            height: MediaQuery.sizeOf(context).height * .92,
            decoration: const BoxDecoration(
              color: page,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 11, 18, 17),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xffD7DAE2),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: <Widget>[
                          Container(
                            width: 63,
                            height: 63,
                            decoration: BoxDecoration(
                              color: store.color.withAlpha(30),
                              borderRadius: BorderRadius.circular(17),
                            ),
                            child: Icon(
                              store.icon,
                              color: store.color,
                              size: 34,
                            ),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  store.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: ink,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: <Widget>[
                                    const Icon(
                                      Icons.star_rounded,
                                      color: Color(0xffF59E0B),
                                      size: 17,
                                    ),
                                    Text(
                                      '${store.rating} (${store.reviews})',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(
                                      Icons.schedule_rounded,
                                      color: purple,
                                      size: 15,
                                    ),
                                    Text(
                                      ' ${store.deliveryMinutes} min',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${store.category} • ${store.distance}',
                                  style: const TextStyle(
                                    color: Color(0xff71798A),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              _toggleFavourite(store);
                              setSheetState(() {});
                            },
                            icon: Icon(
                              _favourites.contains(store)
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: _favourites.contains(store)
                                  ? const Color(0xffEF4444)
                                  : ink,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 13),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffF0ECFF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: <Widget>[
                            Icon(
                              Icons.local_offer_rounded,
                              color: purple,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '40% OFF up to ₹100 • Use FLASH40',
                                style: TextStyle(
                                  color: ink,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 13, 16, 5),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search in ${store.title}',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: const Icon(Icons.mic_none_rounded),
                      filled: true,
                      fillColor: Colors.white,
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                    children: <Widget>[
                      const Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'Recommended for you',
                              style: TextStyle(
                                color: ink,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          _SmallBadge(
                            label: 'BESTSELLERS',
                            color: Color(0xffEA580C),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...products.map(
                        (product) => _catalogueItemCard(
                          product,
                          refreshSheet: () => setSheetState(() {}),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_cartCount > 0)
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 15),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Color(0x18000000),
                          blurRadius: 16,
                          offset: Offset(0, -4),
                        ),
                      ],
                    ),
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: purple,
                        minimumSize: const Size.fromHeight(52),
                      ),
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        setState(() => _tab = 2);
                      },
                      child: Row(
                        children: <Widget>[
                          Text(
                            '$_cartCount ITEMS',
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const Spacer(),
                          const Text(
                            'VIEW CART',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(width: 5),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _catalogueItemCard(
    _MarketplaceItem product, {
    required VoidCallback refreshSheet,
  }) {
    final quantity = _cart[product] ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const _SmallBadge(
                  label: 'POPULAR',
                  color: Color(0xffEA580C),
                ),
                const SizedBox(height: 8),
                Text(
                  product.title,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '₹${product.numericPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  product.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xff71798A),
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 105,
            child: Column(
              children: <Widget>[
                Container(
                  width: 105,
                  height: 86,
                  decoration: BoxDecoration(
                    color: product.color.withAlpha(30),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(product.icon, color: product.color, size: 42),
                ),
                Transform.translate(
                  offset: const Offset(0, -13),
                  child: quantity == 0
                      ? SizedBox(
                          width: 82,
                          height: 34,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: purple,
                              padding: EdgeInsets.zero,
                              side: const BorderSide(color: purple),
                            ),
                            onPressed: () {
                              _addToCart(product, silent: true);
                              refreshSheet();
                            },
                            child: const Text(
                              'ADD',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        )
                      : Container(
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(color: purple),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              _quantityButton(Icons.remove_rounded, () {
                                _removeFromCart(product);
                                refreshSheet();
                              }),
                              Text(
                                '$quantity',
                                style: const TextStyle(
                                  color: purple,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              _quantityButton(Icons.add_rounded, () {
                                _addToCart(product, silent: true);
                                refreshSheet();
                              }),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<_MarketplaceItem> _catalogueFor(_MarketplaceItem store) {
    final category = store.category.toLowerCase();
    if (category.contains('food') || category.contains('restaurant')) {
      return <_MarketplaceItem>[
        _catalogueProduct(
          store,
          'Chicken Dum Biryani',
          'Aromatic basmati rice with tender chicken and spices.',
          Icons.rice_bowl_rounded,
          249,
        ),
        _catalogueProduct(
          store,
          'Veg Meals',
          'Rice, dal, curry, sambar, curd and fresh pickle.',
          Icons.lunch_dining_rounded,
          149,
        ),
        _catalogueProduct(
          store,
          'Masala Dosa',
          'Crispy dosa with potato masala and chutneys.',
          Icons.breakfast_dining_rounded,
          89,
        ),
        _catalogueProduct(
          store,
          'Paneer Fried Rice',
          'Wok-tossed rice with paneer and fresh vegetables.',
          Icons.ramen_dining_rounded,
          199,
        ),
        _catalogueProduct(
          store,
          'Idli & Vada Combo',
          'Soft idlis, crispy vada, sambar and two chutneys.',
          Icons.breakfast_dining_rounded,
          109,
        ),
        _catalogueProduct(
          store,
          'Chicken 65',
          'Spicy, crispy boneless chicken starter.',
          Icons.tapas_rounded,
          229,
        ),
        _catalogueProduct(
          store,
          'Veg Manchurian',
          'Indo-Chinese vegetable dumplings in signature sauce.',
          Icons.dinner_dining_rounded,
          169,
        ),
        _catalogueProduct(
          store,
          'Curd Rice',
          'Comforting curd rice with a traditional tempering.',
          Icons.rice_bowl_outlined,
          99,
        ),
        _catalogueProduct(
          store,
          'Gulab Jamun',
          'Two warm gulab jamuns in cardamom syrup.',
          Icons.cake_rounded,
          79,
        ),
        _catalogueProduct(
          store,
          'Fresh Lime Soda',
          'Refreshing lime soda served sweet or salted.',
          Icons.local_drink_rounded,
          69,
        ),
      ];
    }
    if (category.contains('pharmacy') || category.contains('medicine')) {
      return <_MarketplaceItem>[
        _catalogueProduct(store, 'Health Essentials', 'Everyday health and wellness pack.', Icons.health_and_safety_rounded, 299),
        _catalogueProduct(store, 'First Aid Kit', 'Compact first aid kit for home and travel.', Icons.medical_services_rounded, 449),
        _catalogueProduct(store, 'Personal Care Pack', 'Daily hygiene and personal care essentials.', Icons.sanitizer_rounded, 249),
        _catalogueProduct(store, 'Nutrition Pack', 'Selected nutrition and wellness products.', Icons.monitor_heart_rounded, 399),
        _catalogueProduct(store, 'Digital Thermometer', 'Fast digital temperature reading for home use.', Icons.thermostat_rounded, 199),
        _catalogueProduct(store, 'Face Masks Pack', 'Disposable protective face masks for everyday use.', Icons.masks_rounded, 149),
        _catalogueProduct(store, 'Hand Sanitizer', 'Everyday hand hygiene and protection.', Icons.sanitizer_rounded, 99),
        _catalogueProduct(store, 'Baby Care Essentials', 'Selected everyday baby care products.', Icons.child_care_rounded, 349),
        _catalogueProduct(store, 'Women Wellness Pack', 'Selected personal wellness essentials.', Icons.health_and_safety_outlined, 449),
        _catalogueProduct(store, 'Oral Care Combo', 'Toothbrush, toothpaste and mouth-care essentials.', Icons.medical_information_outlined, 219),
      ];
    }
    return <_MarketplaceItem>[
      _catalogueProduct(store, 'Fresh Vegetables Pack', 'Selected seasonal vegetables for your kitchen.', Icons.eco_rounded, 199),
      _catalogueProduct(store, 'Fresh Fruits Pack', 'A healthy selection of fresh seasonal fruits.', Icons.apple_rounded, 249),
      _catalogueProduct(store, 'Daily Essentials Combo', 'Frequently used home and kitchen essentials.', Icons.shopping_basket_rounded, 399),
      _catalogueProduct(store, 'Dairy Value Pack', 'Milk and selected dairy essentials.', Icons.local_drink_rounded, 179),
      _catalogueProduct(store, 'Rice 5 kg', 'Everyday quality rice for family meals.', Icons.rice_bowl_rounded, 349),
      _catalogueProduct(store, 'Cooking Oil 1 L', 'Refined cooking oil for daily kitchen use.', Icons.water_drop_rounded, 159),
      _catalogueProduct(store, 'Atta 5 kg', 'Whole-wheat flour for soft homemade rotis.', Icons.bakery_dining_rounded, 289),
      _catalogueProduct(store, 'Breakfast Essentials', 'Cereals, spreads and selected morning staples.', Icons.breakfast_dining_rounded, 329),
      _catalogueProduct(store, 'Cleaning Combo', 'Surface, dish and fabric cleaning essentials.', Icons.cleaning_services_rounded, 399),
      _catalogueProduct(store, 'Personal Care Combo', 'Soap, shampoo and daily personal-care essentials.', Icons.spa_rounded, 299),
    ];
  }

  _MarketplaceItem _catalogueProduct(
    _MarketplaceItem store,
    String title,
    String subtitle,
    IconData icon,
    double price,
  ) {
    return _MarketplaceItem(
      type: 'Product Seller',
      title: title,
      subtitle: subtitle,
      category: store.category,
      city: store.city,
      priceLabel: '₹${price.toStringAsFixed(0)}',
      description: subtitle,
      icon: icon,
      color: store.color,
      tags: <String>[store.title, store.category],
      rating: store.rating,
      reviews: store.reviews,
      distance: store.distance,
      numericPrice: price,
      deliveryMinutes: store.deliveryMinutes,
    );
  }

  Widget _detailLine(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: <Widget>[Icon(icon, size: 19, color: purple), const SizedBox(width: 9), Expanded(child: Text(value, style: const TextStyle(color: ink, fontWeight: FontWeight.w600)))]),
    );
  }

  IconData _iconForText(String source) {
    final value = source.toLowerCase();
    if (value.contains('food') || value.contains('meal') || value.contains('restaurant')) return Icons.restaurant_rounded;
    if (value.contains('biryani') || value.contains('rice')) return Icons.rice_bowl_rounded;
    if (value.contains('grocery') || value.contains('basket')) return Icons.local_grocery_store_rounded;
    if (value.contains('fruit')) return Icons.apple_rounded;
    if (value.contains('vegetable') || value.contains('fresh')) return Icons.eco_rounded;
    if (value.contains('medicine') || value.contains('pharmacy') || value.contains('health')) return Icons.medication_rounded;
    if (value.contains('delivery') || value.contains('logistic')) return Icons.delivery_dining_rounded;
    if (value.contains('electric')) return Icons.electrical_services_rounded;
    if (value.contains('plumb')) return Icons.plumbing_rounded;
    if (value.contains('ac ') || value.contains('cool')) return Icons.ac_unit_rounded;
    if (value.contains('mobile') || value.contains('phone')) return Icons.smartphone_rounded;
    if (value.contains('laptop') || value.contains('computer') || value.contains('software') || value.contains('flutter') || value.contains('dart')) return Icons.laptop_mac_rounded;
    if (value.contains('repair') || value.contains('service') || value.contains('technician')) return Icons.home_repair_service_rounded;
    if (value.contains('driver') || value.contains('ride') || value.contains('bike')) return Icons.two_wheeler_rounded;
    if (value.contains('job') || value.contains('full-time') || value.contains('hiring')) return Icons.business_center_rounded;
    if (value.contains('cashier') || value.contains('retail')) return Icons.point_of_sale_rounded;
    if (value.contains('offer') || value.contains('discount')) return Icons.local_offer_rounded;
    if (value.contains('secure') || value.contains('verified')) return Icons.verified_user_rounded;
    if (value.contains('home')) return Icons.home_rounded;
    if (value.contains('beauty') || value.contains('salon')) return Icons.spa_rounded;
    if (value.contains('fashion') || value.contains('cloth')) return Icons.checkroom_rounded;
    if (value.contains('education') || value.contains('teacher')) return Icons.school_rounded;
    if (value.contains('bank') || value.contains('finance')) return Icons.account_balance_rounded;
    return Icons.auto_awesome_rounded;
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));
  }
}

class _HomeBanner {
  const _HomeBanner({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.button,
    required this.icon,
    required this.colors,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final String button;
  final IconData icon;
  final List<Color> colors;
}

class _HomeCategory {
  const _HomeCategory(this.label, this.icon, this.background);

  final String label;
  final IconData icon;
  final Color background;
}

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
          letterSpacing: .2,
        ),
      ),
    );
  }
}

class _CustomerOrder {
  const _CustomerOrder({
    required this.id,
    required this.itemCount,
    required this.total,
    required this.paymentMethod,
    required this.createdAt,
    this.kind = 'Order',
    this.partnerName = 'Flash2Mart Partner',
    this.status = 'CONFIRMED',
    this.note = '',
  });

  final String id;
  final int itemCount;
  final double total;
  final String paymentMethod;
  final DateTime createdAt;
  final String kind;
  final String partnerName;
  final String status;
  final String note;
}

class _SavedAddress {
  const _SavedAddress({
    required this.label,
    required this.address,
    required this.icon,
  });

  final String label;
  final String address;
  final IconData icon;
}

class _ProtectionFeature extends StatelessWidget {
  const _ProtectionFeature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xffECFDF5),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: const Color(0xff059669), size: 22),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xff172554),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xff71798A),
                    fontSize: 10.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BusinessHubScreen extends StatefulWidget {
  const _BusinessHubScreen({
    required this.type,
    required this.items,
    required this.onItemTap,
    required this.onViewAll,
  });

  final String type;
  final List<_MarketplaceItem> items;
  final ValueChanged<_MarketplaceItem> onItemTap;
  final VoidCallback onViewAll;

  @override
  State<_BusinessHubScreen> createState() => _BusinessHubScreenState();
}

class _BusinessHubScreenState extends State<_BusinessHubScreen> {
  String _query = '';
  String _selectedCategory = 'All';
  bool _showAllCategories = false;

  bool get _isProducts => widget.type == 'Product Seller';
  bool get _isServices => widget.type == 'Service Provider';

  Color get _accent => _isProducts
      ? const Color(0xffF97316)
      : _isServices
          ? const Color(0xff0284C7)
          : const Color(0xff7C3AED);

  Color get _accentDark => _isProducts
      ? const Color(0xffEA580C)
      : _isServices
          ? const Color(0xff0369A1)
          : const Color(0xff5B21B6);

  IconData get _heroIcon => _isProducts
      ? Icons.shopping_bag_rounded
      : _isServices
          ? Icons.home_repair_service_rounded
          : Icons.business_center_rounded;

  String get _title => _isProducts
      ? 'Products Marketplace'
      : _isServices
          ? 'Services Dashboard'
          : 'Employment & Jobs';

  String get _subtitle => _isProducts
      ? 'Discover local shops, products and daily essentials'
      : _isServices
          ? 'Choose a service and book a verified professional'
          : 'Explore openings, employers and apply for the right job';

  String get _searchHint => _isProducts
      ? 'Search products, shops or categories'
      : _isServices
          ? 'Search service, technician or provider'
          : 'Search jobs, skills, company or location';

  List<String> get _categories => _isProducts
      ? _productHubCategories
      : _isServices
          ? _serviceHubCategories
          : _jobHubCategories;

  List<_MarketplaceItem> get _visibleItems {
    final query = _query.trim().toLowerCase();
    return widget.items.where((item) {
      final categoryMatches = _selectedCategory == 'All' ||
          item.category.toLowerCase().contains(
                _selectedCategory.toLowerCase(),
              ) ||
          _selectedCategory.toLowerCase().contains(
                item.category.toLowerCase(),
              );
      final queryMatches = query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          item.subtitle.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query) ||
          item.city.toLowerCase().contains(query) ||
          item.tags.any((tag) => tag.toLowerCase().contains(query));
      return categoryMatches && queryMatches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final categories = _showAllCategories
        ? _categories
        : _categories.take(12).toList();
    final items = _visibleItems;
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _title,
          style: const TextStyle(
            color: Color(0xff172554),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'View all',
            onPressed: widget.onViewAll,
            icon: Icon(Icons.grid_view_rounded, color: _accent),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(child: _hero()),
          SliverToBoxAdapter(child: _search()),
          SliverToBoxAdapter(child: _summaryStrip()),
          SliverToBoxAdapter(
            child: _sectionTitle(
              icon: Icons.category_rounded,
              title: _isProducts
                  ? 'Shop by category'
                  : _isServices
                      ? 'Choose a service'
                      : 'Browse job categories',
              trailing: '${_categories.length} categories',
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: .95,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) =>
                  _categoryCard(categories[index]),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: TextButton.icon(
                onPressed: () => setState(
                  () => _showAllCategories = !_showAllCategories,
                ),
                icon: Icon(
                  _showAllCategories
                      ? Icons.expand_less_rounded
                      : Icons.apps_rounded,
                ),
                label: Text(
                  _showAllCategories
                      ? 'SHOW LESS'
                      : 'VIEW ALL ${_categories.length} CATEGORIES',
                ),
                style: TextButton.styleFrom(
                  foregroundColor: _accent,
                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _sectionTitle(
              icon: Icons.verified_rounded,
              title: _isProducts
                  ? 'Registered shops & products'
                  : _isServices
                      ? 'Verified service providers'
                      : 'Active employers & openings',
              trailing: '${items.length} found',
            ),
          ),
          if (items.isEmpty)
            SliverToBoxAdapter(child: _emptyPartnerState())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
              sliver: SliverList.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 11),
                itemBuilder: (context, index) => _partnerCard(items[index]),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _hero() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[_accentDark, _accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _accent.withAlpha(55),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(35),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'FLASH2MART VERIFIED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _subtitle,
                  style: const TextStyle(
                    color: Color(0xffF3F4FF),
                    fontSize: 12,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(32),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withAlpha(55)),
            ),
            child: Icon(_heroIcon, color: Colors.white, size: 42),
          ),
        ],
      ),
    );
  }

  Widget _search() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 5),
      child: TextField(
        onChanged: (value) => setState(() => _query = value),
        decoration: InputDecoration(
          hintText: _searchHint,
          prefixIcon: Icon(Icons.search_rounded, color: _accent),
          suffixIcon: const Icon(Icons.tune_rounded),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(color: Color(0xffE5E7EF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: BorderSide(color: _accent, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _summaryStrip() {
    final values = _isProducts
        ? <(IconData, String, String)>[
            (Icons.storefront_rounded, '${widget.items.length}', 'Local shops'),
            (Icons.category_rounded, '${_categories.length}', 'Categories'),
            (Icons.delivery_dining_rounded, 'Fast', 'Delivery'),
          ]
        : _isServices
            ? <(IconData, String, String)>[
                (Icons.verified_user_rounded, '${widget.items.length}', 'Experts'),
                (Icons.category_rounded, '${_categories.length}', 'Services'),
                (Icons.calendar_month_rounded, 'Easy', 'Booking'),
              ]
            : <(IconData, String, String)>[
                (Icons.apartment_rounded, '${widget.items.length}', 'Employers'),
                (Icons.category_rounded, '${_categories.length}', 'Job fields'),
                (Icons.send_rounded, 'Quick', 'Apply'),
              ];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xffE8EAF1)),
      ),
      child: Row(
        children: values.map((value) {
          return Expanded(
            child: Column(
              children: <Widget>[
                Icon(value.$1, color: _accent, size: 21),
                const SizedBox(height: 5),
                Text(
                  value.$2,
                  style: const TextStyle(
                    color: Color(0xff172554),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  value.$3,
                  style: const TextStyle(
                    color: Color(0xff7C8496),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _sectionTitle({
    required IconData icon,
    required String title,
    required String trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 19, 16, 11),
      child: Row(
        children: <Widget>[
          Icon(icon, color: _accent, size: 20),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xff172554),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            trailing,
            style: TextStyle(
              color: _accent,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryCard(String category) {
    final selected = _selectedCategory == category;
    final icon = _MarketplaceItem._iconFor(widget.type, category);
    return Material(
      color: selected ? _accent : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => setState(() {
          _selectedCategory = selected ? 'All' : category;
        }),
        child: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? _accent : const Color(0xffE7E8EF),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withAlpha(40)
                      : _accent.withAlpha(18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: selected ? Colors.white : _accent,
                  size: 22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                category,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xff172554),
                  fontSize: 10,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _partnerCard(_MarketplaceItem item) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => widget.onItemTap(item),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(item.icon, color: Colors.white, size: 36),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xff172554),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.verified_rounded,
                          color: Color(0xff2563EB),
                          size: 17,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Color(0xff64748B),
                        ),
                        Expanded(
                          child: Text(
                            item.city,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xffF59E0B),
                          size: 15,
                        ),
                        Text(
                          item.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            item.priceLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xff172554),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Icon(item.actionIcon, color: _accent, size: 16),
                        const SizedBox(width: 3),
                        Text(
                          _isProducts
                              ? 'VIEW'
                              : _isServices
                                  ? 'BOOK'
                                  : 'APPLY',
                          style: TextStyle(
                            color: _accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyPartnerState() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: <Widget>[
          Icon(Icons.manage_search_rounded, color: _accent, size: 45),
          const SizedBox(height: 10),
          Text(
            _selectedCategory == 'All'
                ? 'No matching partners found'
                : '$_selectedCategory partners are coming soon',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xff172554),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'New registered partners will appear here automatically.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xff7C8496), fontSize: 11),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => setState(() {
              _selectedCategory = 'All';
              _query = '';
            }),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('SHOW ALL'),
            style: OutlinedButton.styleFrom(foregroundColor: _accent),
          ),
        ],
      ),
    );
  }
}

const List<String> _productHubCategories = <String>[
  'Grocery', 'Supermarket', 'Food Delivery', 'Restaurants', 'Tiffin Centers',
  'Biryani', 'Bakery', 'Sweets', 'Fruits', 'Vegetables', 'Dairy Products',
  'Milk Delivery', 'Meat & Chicken', 'Fish & Seafood', 'Eggs', 'Beverages',
  'Tea & Coffee', 'Juices', 'Ice Cream', 'Organic Foods', 'Dry Fruits',
  'Spices', 'Rice & Grains', 'Cooking Oils', 'Snacks', 'Pharmacy / Medicines',
  'Ayurveda', 'Healthcare Products', 'Personal Care', 'Baby Care',
  'Beauty & Cosmetics', 'Fashion', 'Men Clothing', 'Women Clothing',
  'Kids Clothing', 'Footwear', 'Jewellery', 'Watches', 'Bags & Luggage',
  'Mobile Phones', 'Mobile Accessories', 'Computers', 'Laptops',
  'Computer Accessories', 'Electronics', 'Home Appliances', 'Kitchen Appliances',
  'Furniture', 'Home Decor', 'Kitchenware', 'Cleaning Products', 'Hardware',
  'Electrical Items', 'Plumbing Materials', 'Paints', 'Construction Materials',
  'Automobile Parts', 'Bike Accessories', 'Car Accessories', 'Tyres & Batteries',
  'Books', 'Stationery', 'School Supplies', 'Office Supplies', 'Toys & Games',
  'Sports & Fitness', 'Gym Equipment', 'Pet Supplies', 'Agriculture Products',
  'Seeds & Fertilizers', 'Pesticides', 'Farm Tools', 'Flowers & Gifts',
  'Cakes & Gifts', 'Pooja Items', 'Handicrafts', 'Tailoring Materials',
  'Industrial Supplies', 'Safety Equipment', 'Medical Equipment',
  'Opticals', 'Home Essentials', 'Party Supplies', 'Travel Accessories',
  'Musical Instruments', 'Photography Equipment', 'CCTV Products',
  'Solar Products', 'Water Purifiers', 'Mattresses', 'Curtains & Furnishings',
  'Sanitary Ware', 'Tiles & Flooring', 'Second-hand Products', 'Local Specials',
  'Wholesale Products', 'Fresh Farm Products', 'Eco-friendly Products',
  'Digital Products', 'Other Products',
];

const List<String> _serviceHubCategories = <String>[
  'AC Technician', 'Electrician', 'Plumber', 'Carpenter', 'Painter',
  'Welder', 'Fitter', 'Mason', 'Tiles Worker', 'False Ceiling',
  'Interior Designer', 'Architect', 'Civil Contractor', 'Home Cleaning',
  'Bathroom Cleaning', 'Kitchen Cleaning', 'Sofa Cleaning', 'Carpet Cleaning',
  'Pest Control', 'Water Tank Cleaning', 'Housekeeping', 'Laundry',
  'Dry Cleaning', 'Ironing Service', 'Gardener', 'Tree Cutting',
  'Appliance Repair', 'Refrigerator Repair', 'Washing Machine Repair',
  'TV Repair', 'Water Purifier Service', 'Geyser Repair', 'Microwave Repair',
  'Mobile Repair', 'Laptop Repair', 'Computer Repair', 'Printer Repair',
  'CCTV Technician', 'Network Technician', 'Internet Setup', 'Software Support',
  'Data Recovery', 'Bike Mechanic', 'Car Mechanic', 'Auto Electrician',
  'Car Washing', 'Bike Washing', 'Tyre Service', 'Battery Service',
  'Driver', 'Cab Driver', 'Truck Driver', 'Packers & Movers', 'Courier Service',
  'Local Delivery', 'Security Guard', 'Bouncer', 'Event Security',
  'Beautician', 'Hair Stylist', 'Makeup Artist', 'Mehndi Artist',
  'Spa & Massage', 'Tailor', 'Fashion Designer', 'Photographer',
  'Videographer', 'Video Editor', 'Graphic Designer', 'Web Designer',
  'Digital Marketing', 'Social Media Manager', 'Content Writer', 'Translator',
  'Tutor', 'Home Tutor', 'Music Teacher', 'Dance Teacher', 'Yoga Trainer',
  'Fitness Trainer', 'Physiotherapist', 'Home Nurse', 'Elder Care',
  'Baby Sitter', 'Cook', 'Catering', 'Event Planner', 'Decorator', 'DJ Service',
  'Wedding Services', 'Priest / Purohit', 'Legal Service', 'CA / Accountant',
  'Insurance Advisor', 'Real Estate Agent', 'Travel Agent', 'Printing Service',
  'Xerox & Documentation', 'RO Service', 'Solar Technician', 'Other Services',
];

const List<String> _jobHubCategories = <String>[
  'IT / Software', 'Flutter Developer', 'Web Developer', 'Mobile App Developer',
  'Data Analyst', 'Data Entry', 'Computer Operator', 'Cyber Security',
  'UI/UX Design', 'Graphic Design', 'Video Editing', 'Digital Marketing',
  'Social Media', 'Content Writing', 'Sales', 'Marketing', 'Telecalling',
  'Customer Support', 'BPO / Call Center', 'Human Resources', 'Administration',
  'Office Assistant', 'Receptionist', 'Accounting', 'Banking & Finance',
  'Insurance', 'Legal', 'Teaching / Education', 'School Teacher',
  'College Lecturer', 'Home Tutor', 'Healthcare', 'Doctor', 'Nursing',
  'Pharmacy', 'Lab Technician', 'Physiotherapy', 'Hospital Staff',
  'Civil Engineering', 'Mechanical Engineering', 'Electrical Engineering',
  'Electronics Engineering', 'Automobile Engineering', 'Telecom',
  'Manufacturing', 'Factory Jobs', 'Production', 'Quality Control',
  'Machine Operator', 'CNC Operator', 'Welder Jobs', 'Fitter Jobs',
  'Warehouse', 'Logistics Jobs', 'Delivery Jobs', 'Delivery Partner',
  'Driver Jobs', 'Cab Driver', 'Truck Driver', 'Bike Rider', 'Security Guard',
  'Housekeeping', 'Cleaning Jobs', 'Electrician Jobs', 'Plumber Jobs',
  'Carpenter Jobs', 'AC Technician Jobs', 'Mobile Repair Jobs',
  'Computer Hardware', 'CCTV Technician', 'Retail Jobs', 'Store Manager',
  'Cashier', 'Sales Executive', 'Supermarket Staff', 'Hotel Jobs',
  'Restaurant Jobs', 'Chef', 'Cook', 'Waiter', 'Bakery Jobs',
  'Travel & Tourism', 'Aviation', 'Airport Staff', 'Agriculture', 'Dairy',
  'Poultry', 'Fisheries', 'Media', 'Journalism', 'Photography',
  'Fashion & Tailoring', 'Beautician Jobs', 'Salon Jobs', 'NGO Jobs',
  'Work From Home', 'Part-Time Jobs', 'Freelance Jobs', 'Internships',
  'Fresher Jobs', 'Other Jobs',
];

class _MarketplaceItem {
  const _MarketplaceItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.city,
    required this.priceLabel,
    required this.description,
    required this.icon,
    required this.color,
    required this.tags,
    this.rating = 4.5,
    this.reviews = 24,
    this.distance = '2.0 km',
    this.numericPrice = 199,
    this.deliveryMinutes = 28,
    this.isVerified = true,
  });

  factory _MarketplaceItem.fromRegistration(Map<String, String> data) {
    final type = data['accountType'] ?? 'Product Seller';
    final category = data['category'] ?? 'General';
    final business = (data['business'] ?? '').trim();
    final owner = (data['owner'] ?? '').trim();
    final charge = (data['serviceCharge'] ?? '').trim();
    final salary = (data['salary'] ?? '').trim();
    final city = (data['city'] ?? '').trim();
    final description = (data['profileDescription'] ?? '').trim();
    final serviceArea = (data['serviceArea'] ?? '').trim();
    final skills = (data['skills'] ?? '').split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    return _MarketplaceItem(
      type: type,
      title: business.isNotEmpty ? business : (owner.isNotEmpty ? owner : 'Flash2Mart Partner'),
      subtitle: owner.isNotEmpty ? 'Contact: $owner' : category,
      category: category,
      city: city.isEmpty ? 'Nearby' : city,
      priceLabel: type == 'Service Provider'
          ? (charge.isEmpty ? 'Ask price' : 'From ₹$charge')
          : type == 'Employer / Job Provider'
              ? (salary.isEmpty ? 'Salary available' : '₹$salary')
              : 'View products',
      description: description.isEmpty
          ? 'Registered Flash2Mart partner offering $category.'
          : description,
      icon: _iconFor(type, category),
      color: _colorFor(type),
      tags: skills.isEmpty ? <String>[category] : skills,
      rating: 4.4,
      reviews: 1,
      distance: serviceArea.isEmpty ? 'Nearby' : serviceArea,
      numericPrice: _numberFromText(
        type == 'Service Provider' ? charge : salary,
        fallback: type == 'Product Seller' ? 199 : 0,
      ),
      deliveryMinutes: type == 'Product Seller' ? 35 : 60,
    );
  }

  final String type;
  final String title;
  final String subtitle;
  final String category;
  final String city;
  final String priceLabel;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> tags;
  final double rating;
  final int reviews;
  final String distance;
  final double numericPrice;
  final int deliveryMinutes;
  final bool isVerified;

  String get actionText => type == 'Product Seller'
      ? 'ADD PRODUCT TO CART'
      : type == 'Service Provider'
          ? 'BOOK SERVICE'
          : 'APPLY FOR JOB';

  IconData get actionIcon => type == 'Product Seller'
      ? Icons.add_shopping_cart_rounded
      : type == 'Service Provider'
          ? Icons.calendar_month_rounded
          : Icons.send_rounded;

  static Color _colorFor(String type) {
    if (type == 'Service Provider') return const Color(0xff0EA5E9);
    if (type == 'Employer / Job Provider') return const Color(0xff8B5CF6);
    return const Color(0xffF97316);
  }

  static double _numberFromText(String source, {required double fallback}) {
    final cleaned = source.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? fallback;
  }

  static IconData _iconFor(String type, String category) {
    final c = category.toLowerCase();
    if (c.contains('grocery')) return Icons.local_grocery_store_rounded;
    if (c.contains('food') || c.contains('restaurant')) return Icons.restaurant_rounded;
    if (c.contains('pharmacy') || c.contains('medicine')) return Icons.medication_rounded;
    if (c.contains('fruit')) return Icons.apple_rounded;
    if (c.contains('vegetable') || c.contains('agriculture')) return Icons.eco_rounded;
    if (c.contains('dairy')) return Icons.local_drink_rounded;
    if (c.contains('fashion') || c.contains('tailor')) return Icons.checkroom_rounded;
    if (c.contains('beauty') || c.contains('salon') || c.contains('spa')) return Icons.spa_rounded;
    if (c.contains('electronic') || c.contains('appliance')) return Icons.devices_rounded;
    if (c.contains('home') || c.contains('furniture')) return Icons.chair_rounded;
    if (c.contains('pet')) return Icons.pets_rounded;
    if (c.contains('electric')) return Icons.electrical_services_rounded;
    if (c.contains('plumb')) return Icons.plumbing_rounded;
    if (c.contains('carpenter')) return Icons.carpenter_rounded;
    if (c.contains('paint')) return Icons.format_paint_rounded;
    if (c.contains('clean') || c.contains('housekeeping')) return Icons.cleaning_services_rounded;
    if (c.contains('security')) return Icons.security_rounded;
    if (c.contains('ac technician') || c.contains('refriger')) return Icons.ac_unit_rounded;
    if (c.contains('mobile repair')) return Icons.phonelink_setup_rounded;
    if (c.contains('computer') || c.contains('hardware')) return Icons.computer_rounded;
    if (c.contains('cctv')) return Icons.videocam_rounded;
    if (c.contains('mechanic') || c.contains('automobile')) return Icons.car_repair_rounded;
    if (c.contains('software') || c.contains('it /') || c.contains('developer')) return Icons.laptop_mac_rounded;
    if (c.contains('education') || c.contains('teacher')) return Icons.school_rounded;
    if (c.contains('health') || c.contains('nursing')) return Icons.health_and_safety_rounded;
    if (c.contains('bank') || c.contains('finance') || c.contains('account')) return Icons.account_balance_rounded;
    if (c.contains('sales') || c.contains('marketing')) return Icons.campaign_rounded;
    if (c.contains('hotel') || c.contains('restaurant job')) return Icons.hotel_rounded;
    if (c.contains('warehouse')) return Icons.warehouse_rounded;
    if (c.contains('factory') || c.contains('manufactur')) return Icons.factory_rounded;
    if (c.contains('photograph')) return Icons.camera_alt_rounded;
    if (c.contains('design')) return Icons.palette_rounded;
    if (c.contains('driver') || c.contains('delivery')) return Icons.two_wheeler_rounded;
    if (type == 'Service Provider') return Icons.handyman_rounded;
    if (type == 'Employer / Job Provider') return Icons.work_rounded;
    return Icons.storefront_rounded;
  }
}

const List<_MarketplaceItem> _demoItems = <_MarketplaceItem>[
  _MarketplaceItem(
    type: 'Product Seller', title: 'Fresh Basket Mart', subtitle: 'Daily essentials delivered', category: 'Grocery', city: 'Nearby', priceLabel: '20% OFF',
    description: 'Fresh groceries, fruits, vegetables and daily essentials from your nearby store.', icon: Icons.local_grocery_store_rounded, color: Color(0xff22C55E), tags: <String>['Grocery', 'Fast delivery'], rating: 4.7, reviews: 189, distance: '1.2 km',
  ),
  _MarketplaceItem(
    type: 'Product Seller', title: 'Sri Food Corner', subtitle: 'Meals and snacks', category: 'Food Delivery', city: 'Nearby', priceLabel: 'From ₹99',
    description: 'Freshly prepared meals, tiffins and snacks delivered to your address.', icon: Icons.restaurant_rounded, color: Color(0xffF97316), tags: <String>['Food', 'Home delivery'], rating: 4.5, reviews: 96, distance: '2.1 km',
  ),
  _MarketplaceItem(
    type: 'Product Seller', title: 'Health Plus Pharmacy', subtitle: 'Medicines and wellness', category: 'Pharmacy / Medicines', city: 'Nearby', priceLabel: '10% OFF',
    description: 'Medicines, personal care and wellness essentials from a verified local pharmacy.', icon: Icons.medication_rounded, color: Color(0xffEF4444), tags: <String>['Medicines', 'Wellness'], rating: 4.8, reviews: 241, distance: '1.8 km',
  ),
  _MarketplaceItem(
    type: 'Service Provider', title: 'Ravi Electricals', subtitle: 'Home electrical repairs', category: 'Electrician', city: 'Nearby', priceLabel: 'From ₹199',
    description: 'Experienced electrician for wiring, fan, switch, inverter and home electrical repairs.', icon: Icons.electrical_services_rounded, color: Color(0xff0EA5E9), tags: <String>['Wiring', 'Fan repair', 'Inverter'], rating: 4.7, reviews: 73, distance: '2.3 km',
  ),
  _MarketplaceItem(
    type: 'Service Provider', title: 'Cool Care Services', subtitle: 'AC repair and maintenance', category: 'AC Technician', city: 'Nearby', priceLabel: 'From ₹399',
    description: 'AC installation, general service, gas filling and repair at your doorstep.', icon: Icons.ac_unit_rounded, color: Color(0xff3B82F6), tags: <String>['AC Service', 'Installation', 'Repair'], rating: 4.6, reviews: 112, distance: '3.0 km',
  ),
  _MarketplaceItem(
    type: 'Service Provider', title: 'Smart Fix Solutions', subtitle: 'Mobile and computer repairs', category: 'Mobile Repair', city: 'Nearby', priceLabel: 'Inspection ₹99',
    description: 'Mobile, laptop and computer hardware diagnosis and doorstep repair service.', icon: Icons.phonelink_setup_rounded, color: Color(0xff14B8A6), tags: <String>['Mobile', 'Laptop', 'Hardware'], rating: 4.4, reviews: 58, distance: '2.7 km',
  ),
  _MarketplaceItem(
    type: 'Employer / Job Provider', title: 'Flash Tech Solutions', subtitle: 'Junior Flutter Developer', category: 'IT / Software', city: 'Hyderabad', priceLabel: '₹25K–₹40K',
    description: 'Hiring Flutter developers with Dart basics. Freshers with good projects may apply.', icon: Icons.laptop_mac_rounded, color: Color(0xff8B5CF6), tags: <String>['Flutter', 'Dart', 'Full-Time'], rating: 4.6, reviews: 18, distance: 'On-site',
  ),
  _MarketplaceItem(
    type: 'Employer / Job Provider', title: 'QuickMove Logistics', subtitle: 'Delivery Partner', category: 'Logistics Jobs', city: 'Vijayawada', priceLabel: '₹18K–₹30K',
    description: 'Delivery partners required for local orders. Bike and valid driving licence preferred.', icon: Icons.delivery_dining_rounded, color: Color(0xff10B981), tags: <String>['Delivery', 'Full-Time', 'Incentives'], rating: 4.5, reviews: 32, distance: 'Field job',
  ),
  _MarketplaceItem(
    type: 'Employer / Job Provider', title: 'City Super Mart', subtitle: 'Cashier and Store Assistant', category: 'Retail Jobs', city: 'Guntur', priceLabel: '₹14K–₹20K',
    description: 'Cashier and store assistant openings. Freshers can apply with basic communication skills.', icon: Icons.point_of_sale_rounded, color: Color(0xffEC4899), tags: <String>['Cashier', 'Retail', 'Fresher'], rating: 4.3, reviews: 11, distance: 'On-site',
  ),
];
