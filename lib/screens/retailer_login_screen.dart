import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const productCategories = <String>[
  'Grocery', 'Food Delivery', 'Restaurant', 'Bakery',
  'Fruits & Vegetables', 'Dairy', 'Meat & Fish',
  'Pharmacy / Medicines', 'Flowers', 'Gifts', 'Cakes', 'Courier',
  'Parcel Delivery', 'Documents', 'E-commerce Products', 'Electronics',
  'Mobile Accessories', 'Computer Accessories', 'Fashion & Clothing',
  'Footwear', 'Beauty & Cosmetics', 'Books & Stationery', 'Pet Supplies',
  'Home Essentials', 'Furniture (Local)', 'Hardware & Electrical Items',
  'AC Spare Parts', 'Automobile Spare Parts', 'Toys', 'Sports Goods',
  'Office Supplies',
];

const serviceCategories = <String>[
  'Electrician', 'Plumber', 'Carpenter', 'Welder', 'Fitter',
  'AC Technician', 'Mobile Repair', 'Computer Hardware Service',
  'CCTV Technician', 'Tailor', 'Beautician', 'Hair Stylist', 'Spa & Salon',
  'Housekeeping', 'Cleaning', 'Automobile Technician', 'Photography',
  'Video Editing', 'Graphic Design', 'UI/UX Design', 'Digital Marketing',
  'Social Media Service', 'Content Writing', 'Translation', 'Legal Service',
  'Event Management', 'Gym & Fitness', 'Real Estate', 'Insurance Service',
  'Travel & Tourism', 'Domestic Helper', 'Others',
];

const jobCategories = <String>[
  'IT / Software', 'Banking & Finance', 'Accounting', 'Sales', 'Marketing',
  'Customer Support', 'BPO / Call Center', 'Human Resources (HR)',
  'Administration', 'Data Entry', 'Teaching / Education', 'Healthcare',
  'Nursing', 'Lab Technician', 'Engineering', 'Civil Engineering',
  'Mechanical Engineering', 'Electrical Engineering',
  'Electronics Engineering', 'Manufacturing', 'Factory Jobs', 'Production',
  'Quality Control', 'Warehouse Jobs', 'Logistics Jobs', 'Driver',
  'Cab Driver', 'Truck Driver', 'Bike Rider', 'Security Guard', 'Hotel Jobs',
  'Chef', 'Cook', 'Waiter', 'Aviation', 'Airport Staff', 'Agriculture',
  'Poultry', 'Fisheries', 'Telecom', 'Media', 'Journalism', 'NGO Jobs',
  'Retail Jobs', 'Cashier', 'Showroom Sales', 'Freelancing',
  'Work From Home', 'Part-Time', 'Internship', 'Fresher Jobs',
  'Daily Wage Jobs', 'Contract Jobs', 'Full-Time Jobs',
  'Research & Development', 'Startup Jobs', 'Office Assistant',
  'Receptionist', 'Helper', 'Others',
];

class RetailerLoginScreen extends StatefulWidget {
  const RetailerLoginScreen({super.key});

  @override
  State<RetailerLoginScreen> createState() => _RetailerLoginScreenState();
}

class _RetailerLoginScreenState extends State<RetailerLoginScreen> {
  final mobile = TextEditingController();
  final password = TextEditingController();
  bool hidePassword = true;
  Map<String, String>? account;

  void notice(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));
  }

  Future<void> createNewAccount() async {
    final data = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (_) => const PartnerRegisterScreen()),
    );
    if (data == null || !mounted) return;
    setState(() {
      account = data;
      mobile.text = data['mobile']!;
      password.text = data['password']!;
    });
    notice('Account created successfully. Please login.');
  }

  void login() {
    FocusScope.of(context).unfocus();
    if (mobile.text.trim().length != 10) {
      notice('Enter a valid 10-digit mobile number');
      return;
    }
    if (password.text.length < 6) {
      notice('Enter a valid password');
      return;
    }
    if (account == null) {
      notice('First create a new partner account');
      return;
    }
    if (mobile.text.trim() != account!['mobile'] ||
        password.text != account!['password']) {
      notice('Incorrect mobile number or password');
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => PartnerDashboardScreen(account: account!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 34, 24, 42),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xffFF8A00), Color(0xffFF5F00)]),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(36), bottomRight: Radius.circular(36)),
                ),
                child: const Column(children: [
                  CircleAvatar(radius: 45, backgroundColor: Colors.white, child: Icon(Icons.business_center, size: 49, color: Color(0xffFF6500))),
                  SizedBox(height: 17),
                  Text('Business Partner Login', style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text('Seller • Service Provider • Employer', style: TextStyle(color: Colors.white70)),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(children: [
                      TextField(
                        controller: mobile,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                        decoration: inputDecoration('Mobile Number', Icons.phone_android).copyWith(counterText: ''),
                      ),
                      const SizedBox(height: 17),
                      TextField(
                        controller: password,
                        obscureText: hidePassword,
                        onSubmitted: (_) => login(),
                        decoration: inputDecoration('Password', Icons.lock_outline).copyWith(
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => hidePassword = !hidePassword),
                            icon: Icon(hidePassword ? Icons.visibility_off : Icons.visibility),
                          ),
                        ),
                      ),
                      Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => notice('Forgot Password will be connected with Firebase'), child: const Text('Forgot Password?'))),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: login,
                          style: orangeButton(),
                          child: const Text('LOGIN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text("Don't have a partner account?"),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: createNewAccount,
                          icon: const Icon(Icons.person_add_alt_1),
                          label: const Text('CREATE NEW ACCOUNT', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(foregroundColor: const Color(0xffFF6500), side: const BorderSide(color: Color(0xffFF6500)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    mobile.dispose();
    password.dispose();
    super.dispose();
  }
}

class PartnerRegisterScreen extends StatefulWidget {
  const PartnerRegisterScreen({super.key});

  @override
  State<PartnerRegisterScreen> createState() => _PartnerRegisterScreenState();
}

class _PartnerRegisterScreenState extends State<PartnerRegisterScreen> {
  final formKey = GlobalKey<FormState>();
  final owner = TextEditingController();
  final business = TextEditingController();
  final mobile = TextEditingController();
  final email = TextEditingController();
  final address = TextEditingController();
  final pincode = TextEditingController();
  final gst = TextEditingController();
  final license = TextEditingController();
  final bankUpi = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  String accountType = 'Product Seller';
  String? category;
  bool ownDelivery = true;
  bool accepted = false;
  bool hidePassword = true;
  bool hideConfirm = true;

  List<String> get currentCategories {
    if (accountType == 'Product Seller') return productCategories;
    if (accountType == 'Service Provider') return serviceCategories;
    return jobCategories;
  }

  String get licenseHint {
    if (category == 'Food Delivery' || category == 'Restaurant' || category == 'Bakery') return 'FSSAI License Number (if applicable)';
    if (category == 'Pharmacy / Medicines') return 'Drug License Number';
    return 'Business/Professional License (optional)';
  }

  void submit() {
    FocusScope.of(context).unfocus();
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (category == null) {
      show('Please select a category');
      return;
    }
    if (!accepted) {
      show('Please accept Terms & Conditions');
      return;
    }
    Navigator.pop(context, {
      'owner': owner.text.trim(),
      'business': business.text.trim(),
      'mobile': mobile.text.trim(),
      'email': email.text.trim(),
      'address': address.text.trim(),
      'pincode': pincode.text.trim(),
      'gst': gst.text.trim(),
      'license': license.text.trim(),
      'bankUpi': bankUpi.text.trim(),
      'password': password.text,
      'accountType': accountType,
      'category': category!,
      'deliveryMode': accountType == 'Product Seller'
          ? (ownDelivery ? 'Own Delivery' : 'Flash2Mart Delivery')
          : 'Not Applicable',
    });
  }

  void show(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),
      appBar: AppBar(title: const Text('Partner Registration'), backgroundColor: const Color(0xffFF6500), foregroundColor: Colors.white),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Icon(Icons.add_business, size: 70, color: Color(0xffFF6500)),
            const Text('Create Business Account', textAlign: TextAlign.center, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            const SizedBox(height: 7),
            const Text('Choose the correct account type for your work', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 22),
            DropdownButtonFormField<String>(
              initialValue: accountType,
              decoration: inputDecoration('Account Type', Icons.account_tree_outlined),
              items: const [
                DropdownMenuItem(value: 'Product Seller', child: Text('Product Seller / Shop')),
                DropdownMenuItem(value: 'Service Provider', child: Text('Service Provider')),
                DropdownMenuItem(value: 'Employer / Job Provider', child: Text('Employer / Job Provider')),
              ],
              onChanged: (value) => setState(() {
                accountType = value!;
                category = null;
              }),
            ),
            gap(),
            DropdownButtonFormField<String>(
              key: ValueKey(accountType),
              initialValue: category,
              isExpanded: true,
              decoration: inputDecoration('Business Category', Icons.category_outlined),
              items: currentCategories.map((item) => DropdownMenuItem(value: item, child: Text(item, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (value) => setState(() => category = value),
              validator: (value) => value == null ? 'Select a category' : null,
            ),
            gap(),
            field(owner, 'Owner / Contact Person Name', Icons.person_outline, validator: required),
            gap(),
            field(business, accountType == 'Employer / Job Provider' ? 'Company Name' : 'Business / Shop Name', Icons.business_outlined, validator: required),
            gap(),
            field(mobile, 'Mobile Number', Icons.phone_android, keyboard: TextInputType.phone, formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)], validator: (v) => v == null || v.length != 10 ? 'Enter valid 10-digit mobile number' : null),
            gap(),
            field(email, 'Email Address', Icons.email_outlined, keyboard: TextInputType.emailAddress, validator: (v) => v == null || !v.contains('@') ? 'Enter valid email address' : null),
            gap(),
            field(address, 'Business Address', Icons.location_on_outlined, maxLines: 3, validator: required),
            gap(),
            field(pincode, 'Pincode', Icons.pin_drop_outlined, keyboard: TextInputType.number, formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)], validator: (v) => v == null || v.length != 6 ? 'Enter valid 6-digit pincode' : null),
            gap(),
            field(gst, 'GST Number (optional)', Icons.receipt_long_outlined),
            gap(),
            field(license, licenseHint, Icons.verified_user_outlined),
            gap(),
            field(bankUpi, 'Bank Account / UPI ID', Icons.account_balance_outlined, validator: required),
            if (accountType == 'Product Seller') ...[
              gap(),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                title: Text(ownDelivery ? 'I have my own delivery staff' : 'Use Flash2Mart delivery partners'),
                subtitle: const Text('You can change this later'),
                value: ownDelivery,
                onChanged: (value) => setState(() => ownDelivery = value),
              ),
            ],
            gap(),
            passwordField(password, 'Password', hidePassword, () => showForFiveSeconds(true)),
            gap(),
            passwordField(confirmPassword, 'Confirm Password', hideConfirm, () => showForFiveSeconds(false), confirm: true),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: accepted,
              activeColor: const Color(0xffFF6500),
              onChanged: (value) => setState(() => accepted = value ?? false),
              title: const Text('I confirm that the details are correct and accept Terms & Conditions'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                onPressed: submit,
                icon: const Icon(Icons.how_to_reg),
                label: const Text('CREATE ACCOUNT', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                style: orangeButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showForFiveSeconds(bool first) {
    setState(() {
      if (first) hidePassword = false;
      if (!first) hideConfirm = false;
    });
    Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() {
        if (first) hidePassword = true;
        if (!first) hideConfirm = true;
      });
    });
  }

  String? required(String? value) => value == null || value.trim().isEmpty ? 'This field is required' : null;
  Widget gap() => const SizedBox(height: 15);

  Widget field(TextEditingController controller, String label, IconData icon,
      {TextInputType? keyboard, List<TextInputFormatter>? formatters, String? Function(String?)? validator, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      inputFormatters: formatters,
      validator: validator,
      maxLines: maxLines,
      decoration: inputDecoration(label, icon).copyWith(filled: true, fillColor: Colors.white),
    );
  }

  Widget passwordField(TextEditingController controller, String label, bool hidden, VoidCallback reveal, {bool confirm = false}) {
    return TextFormField(
      controller: controller,
      obscureText: hidden,
      validator: (value) {
        if (value == null || value.length < 6) return 'Minimum 6 characters required';
        if (confirm && value != password.text) return 'Passwords do not match';
        return null;
      },
      decoration: inputDecoration(label, Icons.lock_outline).copyWith(
        filled: true,
        fillColor: Colors.white,
        suffixIcon: IconButton(onPressed: reveal, icon: Icon(hidden ? Icons.visibility_off : Icons.visibility)),
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in [owner, business, mobile, email, address, pincode, gst, license, bankUpi, password, confirmPassword]) {
      controller.dispose();
    }
    super.dispose();
  }
}

class PartnerDashboardScreen extends StatelessWidget {
  final Map<String, String> account;
  const PartnerDashboardScreen({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    final type = account['accountType']!;
    final actions = type == 'Product Seller'
        ? const [('Products', Icons.inventory_2_outlined), ('Orders', Icons.receipt_long_outlined), ('Add Product', Icons.add_box_outlined), ('Delivery', Icons.delivery_dining), ('Earnings', Icons.wallet_outlined), ('Shop Profile', Icons.store_outlined)]
        : type == 'Service Provider'
            ? const [('Services', Icons.home_repair_service_outlined), ('Bookings', Icons.calendar_month_outlined), ('Add Service', Icons.add_circle_outline), ('Service Area', Icons.location_on_outlined), ('Earnings', Icons.wallet_outlined), ('Profile', Icons.person_outline)]
            : const [('Job Posts', Icons.work_outline), ('Applications', Icons.people_outline), ('Post New Job', Icons.post_add), ('Interviews', Icons.event_available_outlined), ('Company', Icons.business_outlined), ('Profile', Icons.person_outline)];

    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),
      appBar: AppBar(title: Text(account['business']!), backgroundColor: const Color(0xffFF6500), foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xffFF8A00), Color(0xffFF5F00)]), borderRadius: BorderRadius.circular(20)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Welcome, ${account['owner']}', style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('$type • ${account['category']}', style: const TextStyle(color: Colors.white70)),
              if (type == 'Product Seller') Text(account['deliveryMode']!, style: const TextStyle(color: Colors.white70)),
            ]),
          ),
          const SizedBox(height: 20),
          Text(type == 'Employer / Job Provider' ? 'Employer Dashboard' : 'Business Dashboard', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
          const SizedBox(height: 13),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: actions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.16),
            itemBuilder: (_, index) {
              final action = actions[index];
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${action.$1} selected'))),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(action.$2, size: 42, color: const Color(0xffFF6500)),
                    const SizedBox(height: 10),
                    Text(action.$1, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

InputDecoration inputDecoration(String label, IconData icon) => InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );

ButtonStyle orangeButton() => ElevatedButton.styleFrom(
      backgroundColor: const Color(0xffFF6500),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
