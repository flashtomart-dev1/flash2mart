import 'package:flutter/material.dart';

class RetailerHomeScreen extends StatefulWidget {
  const RetailerHomeScreen({
    super.key,
    required this.account,
  });

  final Map<String, String> account;

  @override
  State<RetailerHomeScreen> createState() => _RetailerHomeScreenState();
}

class _RetailerHomeScreenState extends State<RetailerHomeScreen> {
  int _selectedIndex = 0;
  int _notificationCount = 3;

  String get _type => widget.account['accountType'] ?? 'Product Seller';
  String get _business {
    final value = widget.account['business']?.trim() ?? '';
    return value.isEmpty ? 'My Profile' : value;
  }
  String get _owner => widget.account['owner'] ?? 'Partner';
  String get _category => widget.account['category'] ?? 'General';

  bool get _isSeller => _type == 'Product Seller';
  bool get _isService => _type == 'Service Provider';

  String get _itemName => _isSeller
      ? 'Product'
      : _isService
          ? 'Service'
          : 'Job';
  String get _ordersName => _isSeller
      ? 'Orders'
      : _isService
          ? 'Bookings'
          : 'Applications';

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
      ));
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _homePage(),
      _itemsPage(),
      _addItemPage(),
      _ordersPage(),
      _profilePage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        height: 70,
        indicatorColor: const Color(0xffffe2cc),
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: [
          const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home'),
          NavigationDestination(
              icon: const Icon(Icons.inventory_2_outlined),
              selectedIcon: const Icon(Icons.inventory_2),
              label: 'My ${_itemName}s'),
          NavigationDestination(
              icon: const Icon(Icons.add_circle_outline, size: 31),
              selectedIcon: const Icon(Icons.add_circle, size: 31),
              label: 'Add'),
          NavigationDestination(
              icon: const Icon(Icons.receipt_long_outlined),
              selectedIcon: const Icon(Icons.receipt_long),
              label: _ordersName),
          const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile'),
        ],
      ),
    );
  }

  Widget _pageHeader(String title, {List<Widget>? actions}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
      decoration: const BoxDecoration(
        gradient:
            LinearGradient(colors: [Color(0xffFF8A00), Color(0xffFF5F00)]),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(children: [
          Expanded(
              child: Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold))),
          ...?actions,
        ]),
      ),
    );
  }

  Widget _homePage() {
    return SafeArea(
      top: false,
      child: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: _homeHeader()),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
          sliver: SliverList(
              delegate: SliverChildListDelegate([
            _statusCard(),
            const SizedBox(height: 18),
            const Text('Today Overview',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _statsGrid(),
            const SizedBox(height: 22),
            _sectionTitle('Quick Actions', 'Manage your business'),
            const SizedBox(height: 12),
            _quickActions(),
            const SizedBox(height: 22),
            _sectionTitle('Recent $_ordersName', 'View all'),
            const SizedBox(height: 10),
            ..._recentOrders(),
          ])),
        ),
      ]),
    );
  }

  Widget _homeHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 14, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xffFF9400), Color(0xffFF5800)]),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
      ),
      child: Row(children: [
        CircleAvatar(
            radius: 27,
            backgroundColor: Colors.white,
            child: Text(_business.isEmpty ? 'B' : _business[0].toUpperCase(),
                style: const TextStyle(
                    color: Color(0xffFF6500),
                    fontSize: 23,
                    fontWeight: FontWeight.bold))),
        const SizedBox(width: 13),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Welcome, $_owner',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 3),
          Text(_business,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          Text('$_type • $_category',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ])),
        Stack(clipBehavior: Clip.none, children: [
          IconButton(
              onPressed: () => setState(() => _notificationCount = 0),
              icon: const Icon(Icons.notifications_outlined,
                  color: Colors.white, size: 29)),
          if (_notificationCount > 0)
            Positioned(
                right: 4,
                top: 2,
                child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    child: Text('$_notificationCount',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold)))),
        ]),
      ]),
    );
  }

  Widget _statusCard() {
    final title = _isSeller
        ? 'Store is Online'
        : _isService
            ? 'Services are Available'
            : 'Hiring Profile is Active';
    final subtitle = _isSeller
        ? 'Customers can place orders now'
        : _isService
            ? 'Customers can request service bookings'
            : 'Candidates can view and apply for your jobs';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 12, offset: Offset(0, 4))
          ]),
      child: Row(children: [
        Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: const Color(0xffE6F8EE),
                borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.storefront, color: Color(0xff18A957))),
        const SizedBox(width: 13),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 3),
          Text(subtitle,
              style: const TextStyle(color: Colors.black54, fontSize: 12))
        ])),
        Switch(
            value: true,
            activeThumbColor: const Color(0xff18A957),
            onChanged: (_) => _message('Store status updated')),
      ]),
    );
  }

  Widget _statsGrid() {
    final data = _isSeller
        ? [
            ('₹12,480', 'Sales', Icons.currency_rupee, const Color(0xff7B2FF7)),
            ('24', 'Orders', Icons.shopping_bag, const Color(0xff1976D2)),
            ('18', 'Products', Icons.inventory_2, const Color(0xffFF7200)),
            ('4.8', 'Rating', Icons.star, const Color(0xffF4B400))
          ]
        : _isService
            ? [
                (
                  '₹8,750',
                  'Earnings',
                  Icons.currency_rupee,
                  const Color(0xff7B2FF7)
                ),
                (
                  '14',
                  'Bookings',
                  Icons.event_available,
                  const Color(0xff1976D2)
                ),
                (
                  '8',
                  'Services',
                  Icons.home_repair_service,
                  const Color(0xffFF7200)
                ),
                ('4.7', 'Rating', Icons.star, const Color(0xffF4B400))
              ]
            : [
                ('12', 'Active Jobs', Icons.work, const Color(0xff7B2FF7)),
                ('86', 'Applications', Icons.people, const Color(0xff1976D2)),
                ('5', 'Shortlisted', Icons.how_to_reg, const Color(0xff18A957)),
                ('3', 'Hired', Icons.verified, const Color(0xffF4B400))
              ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.55,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12),
      itemCount: data.length,
      itemBuilder: (_, i) => Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(17)),
          child: Row(children: [
            Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                    color: data[i].$4.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(13)),
                child: Icon(data[i].$3, color: data[i].$4)),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(data[i].$1,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(data[i].$2,
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 12))
                ])),
          ])),
    );
  }

  Widget _sectionTitle(String title, String action) => Row(children: [
        Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold))),
        TextButton(onPressed: () => _message(action), child: Text(action))
      ]);

  Widget _quickActions() {
    final actions = [
      (
        Icons.add_box_outlined,
        'Add $_itemName',
        const Color(0xffFF6500),
        () => setState(() => _selectedIndex = 2)
      ),
      (
        Icons.receipt_long_outlined,
        _ordersName,
        const Color(0xff3A7BFF),
        () => setState(() => _selectedIndex = 3)
      ),
      (
        Icons.account_balance_wallet_outlined,
        'Earnings',
        const Color(0xff18A957),
        () => _message('Earnings selected')
      ),
      (
        Icons.campaign_outlined,
        'Promotions',
        const Color(0xff7B2FF7),
        () => _message('Promotions selected')
      ),
      (
        Icons.bar_chart,
        'Reports',
        const Color(0xffE91E63),
        () => _message('Reports selected')
      ),
      (
        Icons.support_agent,
        'Support',
        const Color(0xff00838F),
        () => _message('Support selected')
      ),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: .95,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10),
      itemCount: actions.length,
      itemBuilder: (_, i) => InkWell(
          onTap: actions[i].$4,
          borderRadius: BorderRadius.circular(16),
          child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                            color: actions[i].$3.withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(14)),
                        child: Icon(actions[i].$1, color: actions[i].$3)),
                    const SizedBox(height: 8),
                    Text(actions[i].$2,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600))
                  ]))),
    );
  }

  List<Widget> _recentOrders() {
    final names = _isSeller
        ? ['Fresh Grocery Order', 'Mobile Accessories', 'Home Essentials']
        : _isService
            ? ['AC Repair Booking', 'Home Cleaning', 'Electrician Visit']
            : ['Delivery Executive', 'Store Manager', 'Cashier'];
    return List.generate(
        names.length,
        (i) => Card(
              color: Colors.white,
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 9),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: CircleAvatar(
                    backgroundColor: const Color(0xffffeadb),
                    child: Icon(
                        _isSeller
                            ? Icons.shopping_bag_outlined
                            : _isService
                                ? Icons.event_note
                                : Icons.work_outline,
                        color: const Color(0xffFF6500))),
                title: Text(names[i],
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle:
                    Text('#F2M10${i + 1} • ${i == 0 ? 'New' : 'Processing'}'),
                trailing: Text(
                    _isSeller || _isService
                        ? '₹${[640, 1250, 390][i]}'
                        : '${[18, 11, 9][i]} Applicants',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ));
  }

  Widget _itemsPage() {
    final titles = _isSeller
        ? ['Rice & Grocery Pack', 'Cooking Oil', 'Daily Essentials']
        : _isService
            ? ['AC Repair', 'Home Cleaning', 'Electrical Service']
            : ['Delivery Partner', 'Sales Executive', 'Store Helper'];
    return Column(children: [
      _pageHeader('My ${_itemName}s', actions: [
        IconButton(
            onPressed: () => setState(() => _selectedIndex = 2),
            icon: const Icon(Icons.add, color: Colors.white))
      ]),
      Expanded(
          child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: titles.length,
              itemBuilder: (_, i) => Card(
                  color: Colors.white,
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17)),
                  child: ListTile(
                      contentPadding: const EdgeInsets.all(13),
                      leading: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                              color: const Color(0xffffeadb),
                              borderRadius: BorderRadius.circular(14)),
                          child: Icon(
                              _isSeller
                                  ? Icons.inventory_2
                                  : _isService
                                      ? Icons.home_repair_service
                                      : Icons.work,
                              color: const Color(0xffFF6500))),
                      title: Text(titles[i],
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          '${i == 2 ? 'Inactive' : 'Active'} • $_category'),
                      trailing: PopupMenuButton<String>(
                          onSelected: (v) => _message('$v: ${titles[i]}'),
                          itemBuilder: (_) => const [
                                PopupMenuItem(
                                    value: 'Edit', child: Text('Edit')),
                                PopupMenuItem(
                                    value: 'Status changed',
                                    child: Text('Change Status')),
                                PopupMenuItem(
                                    value: 'Delete', child: Text('Delete'))
                              ]))))),
    ]);
  }

  Widget _addItemPage() {
    return Column(children: [
      _pageHeader('Add New $_itemName'),
      Expanded(
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: _AddItemForm(
                  itemName: _itemName,
                  isSeller: _isSeller,
                  isService: _isService,
                  category: _category,
                  onSaved: () {
                    _message('$_itemName saved successfully');
                    setState(() => _selectedIndex = 1);
                  }))),
    ]);
  }

  Widget _ordersPage() {
    return Column(children: [
      _pageHeader(_ordersName),
      Expanded(
          child: DefaultTabController(
              length: 3,
              child: Column(children: [
                const TabBar(labelColor: Color(0xffFF6500), tabs: [
                  Tab(text: 'New'),
                  Tab(text: 'Active'),
                  Tab(text: 'Completed')
                ]),
                Expanded(
                    child: TabBarView(
                        children: List.generate(
                            3,
                            (tab) => ListView(
                                padding: const EdgeInsets.all(16),
                                children: _recentOrders())))),
              ]))),
    ]);
  }

  Widget _profilePage() {
    final contactDetails = <(String, String, IconData)>[
      ('Full Name', _owner, Icons.person_outline),
      ('Mobile Number', _value('mobile'), Icons.phone_outlined),
      ('WhatsApp Number', _value('whatsapp'), Icons.chat_outlined),
      ('Alternate Mobile', _value('alternateMobile'), Icons.phone_in_talk_outlined),
      ('Email Address', _value('email'), Icons.email_outlined),
      ('Address', _value('address'), Icons.location_on_outlined),
      ('City / Town', _value('city'), Icons.location_city_outlined),
      ('State', _value('state'), Icons.map_outlined),
      ('Pincode', _value('pincode'), Icons.pin_drop_outlined),
    ];
    final professionalDetails = _isSeller
        ? <(String, String, IconData)>[
            ('Business / Shop Name', _business, Icons.storefront_outlined),
            ('Business Category', _category, Icons.category_outlined),
            ('PAN Number', _value('pan'), Icons.badge_outlined),
            ('GSTIN', _value('gst'), Icons.receipt_long_outlined),
            ('Licence Number', _value('license'), Icons.verified_user_outlined),
            ('Business Experience', _value('businessAge'), Icons.history_outlined),
            ('Opening Time', _value('openingTime'), Icons.schedule_outlined),
            ('Closing Time', _value('closingTime'), Icons.schedule_rounded),
            ('Business Description', _value('profileDescription'), Icons.description_outlined),
          ]
        : _isService
            ? <(String, String, IconData)>[
                ('Service Category', _category, Icons.home_repair_service_outlined),
                ('Qualification', _value('qualification'), Icons.school_outlined),
                ('Specialization', _value('specialization'), Icons.workspace_premium_outlined),
                ('Institute', _value('institute'), Icons.account_balance_outlined),
                ('Experience', _value('experience'), Icons.history_outlined),
                ('Skills / Services', _value('skills'), Icons.handyman_outlined),
                ('Availability', _value('selectedOptions'), Icons.event_available_outlined),
                ('Service Area', _value('serviceArea'), Icons.location_on_outlined),
                ('Visit Charge', _moneyValue('serviceCharge'), Icons.currency_rupee),
                ('Languages Known', _value('languages'), Icons.translate_outlined),
                ('Certificate / Licence', _value('license'), Icons.verified_outlined),
                ('Profile Description', _value('profileDescription'), Icons.description_outlined),
              ]
            : <(String, String, IconData)>[
                ('Required Job Category', _category, Icons.work_outline),
                ('Highest Qualification', _value('qualification'), Icons.school_outlined),
                ('Specialization', _value('specialization'), Icons.workspace_premium_outlined),
                ('College / University', _value('institute'), Icons.account_balance_outlined),
                ('Passout Year', _value('passoutYear'), Icons.calendar_month_outlined),
                ('Experience Status', _value('experienceStatus'), Icons.badge_outlined),
                ('Total Experience', _value('experience'), Icons.history_outlined),
                ('Present Company', _value('previousCompany'), Icons.business_outlined),
                ('Current Designation', _value('previousDesignation'), Icons.assignment_ind_outlined),
                ('Skills', _value('skills'), Icons.psychology_outlined),
                ('Preferred Job Type', _value('preferredJobType'), Icons.work_history_outlined),
                ('Preferred Location', _value('serviceArea'), Icons.location_on_outlined),
                ('Expected Salary', _moneyValue('salary'), Icons.currency_rupee),
                ('Notice Period', _value('noticePeriod'), Icons.event_note_outlined),
                ('Languages Known', _value('languages'), Icons.translate_outlined),
                ('Date of Birth', _value('dateOfBirth'), Icons.cake_outlined),
                ('Gender', _value('gender'), Icons.people_outline),
                ('Resume Link', _value('resumeLink'), Icons.link_outlined),
                ('Profile Summary', _value('profileDescription'), Icons.description_outlined),
              ];
    final bankDetails = <(String, String, IconData)>[
      ('Account Holder Name', _value('bankAccountHolderName'), Icons.person_outline),
      ('Bank Name', _value('bankName'), Icons.account_balance_outlined),
      ('Account Number / UPI ID', _value('bankUpi'), Icons.account_balance_wallet_outlined),
      ('IFSC Code', _value('ifscCode'), Icons.numbers_outlined),
    ];
    return Column(children: [
      _pageHeader('Business Profile', actions: [
        IconButton(
            onPressed: () => _message('Edit profile selected'),
            icon: const Icon(Icons.edit_outlined, color: Colors.white))
      ]),
      Expanded(
          child: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(children: [
              CircleAvatar(
                  radius: 42,
                  backgroundColor: const Color(0xffffeadb),
                  child: Text(
                      _business.isEmpty ? 'B' : _business[0].toUpperCase(),
                      style: const TextStyle(
                          color: Color(0xffFF6500),
                          fontSize: 34,
                          fontWeight: FontWeight.bold))),
              const SizedBox(height: 12),
              Text(_business,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              Text(_type, style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 10),
              Chip(
                  avatar:
                      const Icon(Icons.verified, color: Color(0xff18A957), size: 18),
                  label: Text(_isSeller ? 'Verified Retailer' : _isService ? 'Verified Service Provider' : 'Verified Job Provider'))
            ])),
        const SizedBox(height: 14),
        _profileSection('Contact & Address', Icons.contact_phone_outlined, contactDetails),
        const SizedBox(height: 12),
        _profileSection(
            _isSeller ? 'Business Details' : _isService ? 'Professional Details' : 'Job Profile Details',
            _isSeller ? Icons.storefront_outlined : _isService ? Icons.handyman_outlined : Icons.work_outline,
            professionalDetails),
        if (!_type.contains('Employer')) ...[
          const SizedBox(height: 12),
          _profileSection('Bank Details', Icons.account_balance_outlined, bankDetails),
        ],
        const SizedBox(height: 8),
        OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.logout),
            label: const Text('LOGOUT'),
            style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                minimumSize: const Size.fromHeight(52))),
      ])),
    ]);
  }

  String _value(String key) {
    final value = widget.account[key]?.trim() ?? '';
    return value.isEmpty ? 'Not added' : value;
  }

  String _moneyValue(String key) {
    final value = widget.account[key]?.trim() ?? '';
    return value.isEmpty ? 'Not added' : '₹$value';
  }

  Widget _profileSection(String title, IconData icon,
      List<(String, String, IconData)> details) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: const Color(0xffFF6500)),
          const SizedBox(width: 9),
          Text(title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ]),
        const Divider(height: 24),
        ...details.map((detail) => Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: const Color(0xffffeadb),
                        borderRadius: BorderRadius.circular(12)),
                    child: Icon(detail.$3,
                        size: 21, color: const Color(0xffFF6500))),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(detail.$1,
                      style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 3),
                  Text(detail.$2,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ])),
              ]),
            )),
      ]),
    );
  }
}

class _AddItemForm extends StatefulWidget {
  const _AddItemForm(
      {required this.itemName,
      required this.isSeller,
      required this.isService,
      required this.category,
      required this.onSaved});
  final String itemName;
  final bool isSeller;
  final bool isService;
  final String category;
  final VoidCallback onSaved;

  @override
  State<_AddItemForm> createState() => _AddItemFormState();
}

class _AddItemFormState extends State<_AddItemForm> {
  final _formKey = GlobalKey<FormState>();
  bool _active = true;

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none));

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(children: [
          InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(18),
              child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: const Color(0xffffeadb),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xffFFB27A))),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                            widget.isSeller
                                ? Icons.add_photo_alternate_outlined
                                : widget.isService
                                    ? Icons.home_repair_service
                                    : Icons.business_center,
                            size: 46,
                            color: const Color(0xffFF6500)),
                        const SizedBox(height: 8),
                        Text(
                            widget.isSeller
                                ? 'Add Product Image'
                                : 'Add ${widget.itemName} Details',
                            style: const TextStyle(fontWeight: FontWeight.bold))
                      ]))),
          const SizedBox(height: 16),
          TextFormField(
              decoration: _decoration('${widget.itemName} Name', Icons.title),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Enter ${widget.itemName.toLowerCase()} name'
                  : null),
          const SizedBox(height: 13),
          TextFormField(
              initialValue: widget.category,
              readOnly: true,
              decoration: _decoration('Category', Icons.category_outlined)),
          const SizedBox(height: 13),
          TextFormField(
              maxLines: 3,
              decoration:
                  _decoration('Description', Icons.description_outlined),
              validator: (v) => v == null || v.trim().length < 10
                  ? 'Enter at least 10 characters'
                  : null),
          const SizedBox(height: 13),
          if (widget.isSeller || widget.isService)
            TextFormField(
                keyboardType: TextInputType.number,
                decoration: _decoration(
                    widget.isSeller
                        ? 'Selling Price (₹)'
                        : 'Service Charge (₹)',
                    Icons.currency_rupee),
                validator: (v) => double.tryParse(v ?? '') == null
                    ? 'Enter valid amount'
                    : null),
          if (!widget.isSeller && !widget.isService)
            TextFormField(
                decoration: _decoration('Salary Range', Icons.currency_rupee),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Enter salary range'
                    : null),
          const SizedBox(height: 13),
          TextFormField(
              decoration: _decoration(
                  widget.isSeller
                      ? 'Stock Quantity'
                      : widget.isService
                          ? 'Service Area / Pincode'
                          : 'Job Location',
                  widget.isSeller
                      ? Icons.inventory
                      : Icons.location_on_outlined),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'This field is required'
                  : null),
          const SizedBox(height: 10),
          SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Make ${widget.itemName} active'),
              subtitle: const Text('Customers can see this listing'),
              value: _active,
              activeThumbColor: const Color(0xffFF6500),
              onChanged: (v) => setState(() => _active = v)),
          const SizedBox(height: 10),
          SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) widget.onSaved();
                  },
                  icon: const Icon(Icons.save_outlined),
                  label: Text('SAVE ${widget.itemName.toUpperCase()}'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffFF6500),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14))))),
        ]));
  }
}
