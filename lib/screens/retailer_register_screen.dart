import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const productCategories = <String>[
  'Grocery', 'Food Delivery', 'Restaurant', 'Bakery', 'Fruits & Vegetables',
  'Dairy', 'Meat & Fish', 'Pharmacy / Medicines', 'Flowers', 'Gifts', 'Cakes',
  'Courier', 'Parcel Delivery', 'Documents', 'E-commerce Products',
  'Electronics', 'Mobile Accessories', 'Computer Accessories',
  'Fashion & Clothing', 'Footwear', 'Beauty & Cosmetics',
  'Books & Stationery', 'Pet Supplies', 'Home Essentials', 'Furniture (Local)',
  'Hardware & Electrical Items', 'AC Spare Parts', 'Automobile Spare Parts',
  'Toys', 'Sports Goods', 'Office Supplies',
];

const serviceCategories = <String>[
  'Electrician', 'Plumber', 'Carpenter', 'Welder', 'Fitter', 'AC Technician',
  'Mobile Repair', 'Computer Hardware Service', 'CCTV Technician', 'Tailor',
  'Beautician', 'Hair Stylist', 'Spa & Salon', 'Housekeeping', 'Cleaning',
  'Automobile Technician', 'Photography', 'Video Editing', 'Graphic Design',
  'UI/UX Design', 'Digital Marketing', 'Social Media Service',
  'Content Writing', 'Translation', 'Legal Service', 'Event Management',
  'Gym & Fitness', 'Real Estate', 'Insurance Service', 'Travel & Tourism',
  'Domestic Helper', 'Others',
];

const jobCategories = <String>[
  'IT / Software', 'Banking & Finance', 'Accounting', 'Sales', 'Marketing',
  'Customer Support', 'BPO / Call Center', 'Human Resources (HR)',
  'Administration', 'Data Entry', 'Teaching / Education', 'Healthcare',
  'Nursing', 'Lab Technician', 'Engineering', 'Civil Engineering',
  'Mechanical Engineering', 'Electrical Engineering',
  'Electronics Engineering', 'Manufacturing', 'Factory Jobs', 'Production',
  'Quality Control', 'Warehouse Jobs', 'Logistics Jobs', 'Driver', 'Cab Driver',
  'Truck Driver', 'Bike Rider', 'Security Guard', 'Hotel Jobs', 'Chef', 'Cook',
  'Waiter', 'Aviation', 'Airport Staff', 'Agriculture', 'Poultry', 'Fisheries',
  'Telecom', 'Media', 'Journalism', 'NGO Jobs', 'Retail Jobs', 'Cashier',
  'Showroom Sales', 'Freelancing', 'Work From Home', 'Part-Time', 'Internship',
  'Fresher Jobs', 'Daily Wage Jobs', 'Contract Jobs', 'Full-Time Jobs',
  'Research & Development', 'Startup Jobs', 'Office Assistant', 'Receptionist',
  'Helper', 'Others',
];

class RetailerRegisterScreen extends StatefulWidget {
  const RetailerRegisterScreen({super.key});

  @override
  State<RetailerRegisterScreen> createState() => _RetailerRegisterScreenState();
}

class _RetailerRegisterScreenState extends State<RetailerRegisterScreen> {
  static const orange = Color(0xffFF6500);
  static const navy = Color(0xff172554);
  final formKey = GlobalKey<FormState>();

  final owner = TextEditingController();
  final business = TextEditingController();
  final mobile = TextEditingController();
  final whatsapp = TextEditingController();
  final alternateMobile = TextEditingController();
  final email = TextEditingController();
  final address = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();
  final pincode = TextEditingController();
  final gst = TextEditingController();
  final pan = TextEditingController();
  final license = TextEditingController();
  final businessAge = TextEditingController();
  final openingTime = TextEditingController();
  final closingTime = TextEditingController();
  final profileDescription = TextEditingController();
  final qualification = TextEditingController();
  final specialization = TextEditingController();
  final institute = TextEditingController();
  final passoutYear = TextEditingController();
  final experience = TextEditingController();
  final previousCompany = TextEditingController();
  final previousDesignation = TextEditingController();
  final skills = TextEditingController();
  final serviceArea = TextEditingController();
  final serviceCharge = TextEditingController();
  final languages = TextEditingController();
  final dateOfBirth = TextEditingController();
  final gender = TextEditingController();
  final noticePeriod = TextEditingController();
  final salary = TextEditingController();
  final resumeLink = TextEditingController();
  final bankAccountHolderName = TextEditingController();
  final bankUpi = TextEditingController();
  final ifscCode = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  String accountType = 'Product Seller';
  String workStatus = 'Fresher';
  String preferredJobType = 'Full-Time';
  String? selectedBank;
  String? category;
  final Set<String> selectedSkills = {};
  final Set<String> selectedOptions = {};
  bool accepted = false;
  bool hidePassword = true;
  bool hideConfirm = true;
  bool sameAsMobile = false;

  List<String> get currentCategories => accountType == 'Product Seller'
      ? productCategories
      : accountType == 'Service Provider'
          ? serviceCategories
          : jobCategories;

  String get categoryLabel => accountType == 'Product Seller'
      ? 'Product / Shop Category'
      : accountType == 'Service Provider'
          ? 'Service Category'
          : 'Required Job Category';

  String get licenseHint {
    if (['Food Delivery', 'Restaurant', 'Bakery', 'Cakes', 'Dairy',
      'Meat & Fish'].contains(category)) return 'FSSAI Licence Number';
    if (category == 'Pharmacy / Medicines') return 'Drug Licence Number';
    return 'Business / Professional Licence (optional)';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: navy,
        title: const Text('Retailer Registration',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _hero(),
            const SizedBox(height: 18),
            _section('1', 'Choose Account Type',
                'Select how you want to use Flash2Mart', Icons.widgets_outlined),
            _accountTypeCards(),
            const SizedBox(height: 14),
            _categoryDropdown(),
            if (category != null) ...[
              const SizedBox(height: 12),
              _selectedCategoryCard(),
            ],
            const SizedBox(height: 20),
            _section('2', 'Basic Information',
                'Enter your contact and location details', Icons.person_outline),
            _basicFields(),
            const SizedBox(height: 20),
            _section('3', _detailsTitle(), _detailsSubtitle(),
                accountType == 'Product Seller'
                    ? Icons.storefront_outlined
                    : accountType == 'Service Provider'
                        ? Icons.home_repair_service_outlined
                        : Icons.badge_outlined),
            if (accountType == 'Product Seller') _productFields(),
            if (accountType == 'Service Provider') _serviceFields(),
            if (accountType == 'Employer / Job Provider') _jobFields(),
            const SizedBox(height: 20),
            if (accountType != 'Employer / Job Provider') ...[
              _section('4', 'Bank Details',
                  'Add your settlement bank account or UPI details',
                  Icons.account_balance_rounded),
              _bankDetailsCard(),
              const SizedBox(height: 20),
              _section('5', 'Account Security',
                  'Create a secure password', Icons.shield_outlined),
            ] else
              _section('4', 'Account Security',
                  'Create a secure password', Icons.shield_outlined),
            _passwordField(password, 'Password', hidePassword,
                () => _showForFiveSeconds(true)),
            _passwordField(confirmPassword, 'Confirm Password', hideConfirm,
                () => _showForFiveSeconds(false), confirm: true),
            _terms(),
            const SizedBox(height: 14),
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.how_to_reg_rounded),
                label: const Text('CREATE ACCOUNT',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xffFF6500), Color(0xffFF9A3D)]),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: orange.withValues(alpha: .22),
              blurRadius: 22, offset: const Offset(0, 9))],
        ),
        child: const Row(children: [
          DecoratedBox(
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Padding(padding: EdgeInsets.all(13),
              child: Icon(Icons.person_add_alt_1_rounded, color: orange, size: 30)),
          ),
          SizedBox(width: 15),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create Your Profile', style: TextStyle(color: Colors.white,
                  fontSize: 22, fontWeight: FontWeight.w900)),
              SizedBox(height: 4),
              Text('Register in a few simple steps',
                  style: TextStyle(color: Colors.white, fontSize: 13)),
            ])),
        ]),
      );

  Widget _section(String number, String title, String subtitle, IconData icon) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 38, height: 38,
            decoration: BoxDecoration(color: orange.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: orange, size: 21)),
          const SizedBox(width: 11),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$number. $title', style: const TextStyle(fontSize: 17,
                  fontWeight: FontWeight.w800, color: navy)),
              Text(subtitle, style: const TextStyle(fontSize: 12,
                  color: Colors.black54)),
            ])),
        ]),
      );

  Widget _accountTypeCards() {
    final types = [
      ('Product Seller', 'Shop / Products', Icons.storefront_rounded),
      ('Service Provider', 'Skills / Services', Icons.home_repair_service_rounded),
      ('Employer / Job Provider', 'Job Profile', Icons.work_rounded),
    ];
    return Column(children: types.map((item) {
      final selected = accountType == item.$1;
      return Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _changeAccountType(item.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected ? orange.withValues(alpha: .07) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: selected ? orange : const Color(0xffE3E8F0),
                  width: selected ? 1.7 : 1),
              boxShadow: selected ? [BoxShadow(color: orange.withValues(alpha: .1),
                  blurRadius: 12)] : null,
            ),
            child: Row(children: [
              Container(width: 45, height: 45,
                decoration: BoxDecoration(color: selected ? orange : const Color(0xffEEF2F7),
                    borderRadius: BorderRadius.circular(13)),
                child: Icon(item.$3, color: selected ? Colors.white : navy)),
              const SizedBox(width: 13),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w800)),
                  Text(item.$2, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                ])),
              Icon(selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: selected ? orange : Colors.black26),
            ]),
          ),
        ),
      );
    }).toList());
  }

  Widget _categoryDropdown() => DropdownButtonFormField<String>(
        key: ValueKey(accountType),
        initialValue: category,
        isExpanded: true,
        menuMaxHeight: 420,
        decoration: _decoration(categoryLabel, Icons.category_outlined),
        items: currentCategories.map((item) => DropdownMenuItem(
          value: item,
          child: Row(children: [
            Icon(_categoryIcon(item), size: 22, color: orange),
            const SizedBox(width: 12),
            Expanded(child: Text(item, overflow: TextOverflow.ellipsis)),
          ]),
        )).toList(),
        onChanged: (value) => setState(() {
          category = value;
          selectedSkills.clear();
          selectedOptions.clear();
        }),
        validator: (value) => value == null ? 'Please select a category' : null,
      );

  Widget _selectedCategoryCard() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xffFFF7ED),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xffFED7AA))),
        child: Row(children: [
          Container(width: 46, height: 46,
            decoration: BoxDecoration(color: Colors.white,
                borderRadius: BorderRadius.circular(13)),
            child: Icon(_categoryIcon(category!), color: orange, size: 27)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(category!, style: const TextStyle(fontWeight: FontWeight.w800,
                  color: navy)),
              Text(_categoryDescription(category!),
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ])),
          const Icon(Icons.verified_rounded, color: orange),
        ]),
      );

  Widget _basicFields() => _card([
        _field(owner, accountType == 'Employer / Job Provider'
            ? 'Full Name' : 'Owner / Contact Person Name', Icons.person_outline,
            requiredField: true),
        if (accountType != 'Employer / Job Provider')
          _field(business, accountType == 'Service Provider'
              ? 'Service / Professional Name' : 'Shop / Business Name',
              accountType == 'Service Provider'
                  ? Icons.handyman_outlined : Icons.store_outlined,
              requiredField: true),
        _field(mobile, 'Mobile Number', Icons.phone_android_rounded,
            keyboard: TextInputType.phone,
            formatters: [FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10)], validator: (v) =>
                v == null || v.length != 10 ? 'Enter valid 10-digit mobile number' : null),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          value: sameAsMobile,
          activeColor: orange,
          title: const Text('WhatsApp number is same as mobile',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          onChanged: (value) => setState(() {
            sameAsMobile = value ?? false;
            whatsapp.text = sameAsMobile ? mobile.text : '';
          }),
        ),
        _field(whatsapp, 'WhatsApp Number', Icons.chat_outlined,
            keyboard: TextInputType.phone,
            formatters: [FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10)], validator: (v) =>
                v == null || v.length != 10 ? 'Enter valid 10-digit WhatsApp number' : null),
        _field(alternateMobile, 'Alternate Mobile (optional)', Icons.phone_outlined,
            keyboard: TextInputType.phone,
            formatters: [FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10)], validator: (v) {
              if (v == null || v.isEmpty) return null;
              return v.length == 10 ? null : 'Enter valid 10-digit mobile number';
            }),
        _field(email, 'Email Address', Icons.alternate_email_rounded,
            keyboard: TextInputType.emailAddress, validator: (v) =>
                v == null || !v.contains('@') ? 'Enter valid email address' : null),
        _field(address, accountType == 'Product Seller' ? 'Shop / Business Address'
            : accountType == 'Service Provider' ? 'Current / Service Address'
            : 'Current Address', Icons.location_on_outlined,
            maxLines: 2, requiredField: true),
        _field(city, 'City / Town', Icons.location_city_outlined,
            requiredField: true),
        _field(state, 'State', Icons.map_outlined, requiredField: true),
        _field(pincode, 'Pincode', Icons.pin_drop_outlined,
            keyboard: TextInputType.number,
            formatters: [FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6)], validator: (v) =>
                v == null || v.length != 6 ? 'Enter valid 6-digit pincode' : null),
      ]);

  Widget _productFields() => _card([
        _field(pan, 'PAN Number (optional)', Icons.badge_outlined,
            formatters: [LengthLimitingTextInputFormatter(10), UpperCaseTextFormatter()],
            validator: _panValidator),
        _field(gst, 'GSTIN (optional)', Icons.receipt_long_outlined,
            formatters: [LengthLimitingTextInputFormatter(15), UpperCaseTextFormatter()],
            validator: _gstValidator),
        _field(license, licenseHint, Icons.verified_user_outlined,
            requiredField: category == 'Pharmacy / Medicines'),
        _field(businessAge, 'Business Experience in Years',
            Icons.timeline_outlined, keyboard: TextInputType.number,
            formatters: [FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2)], requiredField: true),
        Row(children: [
          Expanded(child: _field(openingTime, 'Opening Time', Icons.schedule_outlined,
              requiredField: true)),
          const SizedBox(width: 10),
          Expanded(child: _field(closingTime, 'Closing Time', Icons.schedule_rounded,
              requiredField: true)),
        ]),
        _field(profileDescription, 'About Your Shop / Products',
            Icons.description_outlined, maxLines: 3, requiredField: true),
      ]);

  static const List<String> indianBanks = [
    'State Bank of India (SBI)',
    'Union Bank of India',
    'HDFC Bank',
    'ICICI Bank',
    'Axis Bank',
    'Punjab National Bank (PNB)',
    'Bank of Baroda',
    'Canara Bank',
    'Bank of India',
    'Indian Bank',
    'Central Bank of India',
    'Indian Overseas Bank',
    'UCO Bank',
    'Bank of Maharashtra',
    'Punjab & Sind Bank',
    'Kotak Mahindra Bank',
    'IndusInd Bank',
    'IDBI Bank',
    'IDFC FIRST Bank',
    'YES Bank',
    'Federal Bank',
    'South Indian Bank',
    'Karnataka Bank',
    'Karur Vysya Bank',
    'City Union Bank',
    'Tamilnad Mercantile Bank',
    'RBL Bank',
    'DCB Bank',
    'Bandhan Bank',
    'CSB Bank',
    'Jammu & Kashmir Bank',
    'AU Small Finance Bank',
    'Equitas Small Finance Bank',
    'Ujjivan Small Finance Bank',
    'Jana Small Finance Bank',
    'ESAF Small Finance Bank',
    'Suryoday Small Finance Bank',
    'Utkarsh Small Finance Bank',
    'India Post Payments Bank',
    'Airtel Payments Bank',
    'Fino Payments Bank',
    'Paytm Payments Bank',
    'Other Bank',
  ];

  Widget _bankDetailsCard() => _card([
        _field(
          bankAccountHolderName,
          'Account Holder Full Name',
          Icons.person_outline_rounded,
          requiredField: true,
        ),
        DropdownButtonFormField<String>(
          value: selectedBank,
          isExpanded: true,
          decoration: _decoration('Select Bank Name', Icons.account_balance_rounded),
          hint: const Text('Choose your bank'),
          items: indianBanks.map((bank) => DropdownMenuItem<String>(
                value: bank,
                child: Row(children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xffFFF1E6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _bankShortName(bank),
                      style: const TextStyle(
                        color: orange,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(bank, overflow: TextOverflow.ellipsis),
                  ),
                ]),
              )).toList(),
          onChanged: (value) => setState(() => selectedBank = value),
          validator: (value) => value == null ? 'Please select your bank' : null,
        ),
        const SizedBox(height: 12),
        _field(
          bankUpi,
          'Bank Account Number / UPI ID',
          Icons.account_balance_wallet_outlined,
          requiredField: true,
        ),
        _field(
          ifscCode,
          'IFSC Code',
          Icons.pin_outlined,
          formatters: [
            LengthLimitingTextInputFormatter(11),
            UpperCaseTextFormatter(),
          ],
          validator: _ifscValidator,
        ),
      ]);

  String _bankShortName(String bank) {
    const shortNames = <String, String>{
      'State Bank of India (SBI)': 'SBI',
      'Union Bank of India': 'UBI',
      'HDFC Bank': 'HDFC',
      'ICICI Bank': 'ICICI',
      'Axis Bank': 'AXIS',
      'Punjab National Bank (PNB)': 'PNB',
      'Bank of Baroda': 'BOB',
      'Canara Bank': 'CB',
      'Bank of India': 'BOI',
      'Indian Bank': 'IB',
    };
    return shortNames[bank] ?? bank.substring(0, bank.length >= 2 ? 2 : 1).toUpperCase();
  }

  Widget _serviceFields() => _card([
        _field(qualification, _serviceQualificationLabel(), Icons.school_outlined,
            requiredField: true),
        _field(specialization, _serviceSpecializationLabel(),
            _categoryIcon(category ?? 'Service Provider'), requiredField: true),
        _field(institute, 'Institute / Training Centre',
            Icons.account_balance_outlined, requiredField: true),
        _experienceStatus(),
        _field(experience, 'Experience in Years', Icons.workspace_premium_outlined,
            keyboard: TextInputType.number,
            formatters: [FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2)], requiredField: true),
        if (workStatus == 'Experienced') ...[
          _field(previousCompany, 'Previous / Current Company', Icons.apartment_outlined,
              requiredField: true),
          _field(previousDesignation, 'Designation / Job Role', Icons.badge_outlined,
              requiredField: true),
        ],
        _choiceGroup('Select Your Services / Skills', _categoryIcon(category ?? ''),
            _skillOptions(category)),
        _field(skills, 'Other Skills (optional)', Icons.add_circle_outline, maxLines: 2),
        _choiceGroup('How Do You Provide Service?', Icons.room_service_outlined,
            ['Customer Location', 'My Shop', 'Online / Remote', 'Emergency Service']),
        _choiceGroup('Availability', Icons.schedule_outlined,
            ['Weekdays', 'Weekends', 'Morning', 'Evening']),
        _field(serviceArea, 'Service Area / City', Icons.location_city_outlined,
            requiredField: true),
        _field(serviceCharge, 'Minimum Service / Visit Charge', Icons.currency_rupee,
            keyboard: TextInputType.number,
            formatters: [FilteringTextInputFormatter.digitsOnly], requiredField: true),
        _field(languages, 'Languages Known (Example: Telugu, Hindi)',
            Icons.translate_outlined, requiredField: true),
        _field(profileDescription, 'About Your Service Experience',
            Icons.description_outlined, maxLines: 3, requiredField: true),
        _field(license, _serviceCertificateLabel(), Icons.workspace_premium_outlined),
      ]);

  Widget _jobFields() => _card([
        _field(dateOfBirth, 'Date of Birth (DD/MM/YYYY)', Icons.cake_outlined,
            keyboard: TextInputType.datetime, validator: _dateValidator),
        _genderDropdown(),
        _field(qualification, 'Highest Qualification', Icons.school_outlined,
            requiredField: true),
        _field(specialization, _jobSpecializationLabel(), Icons.menu_book_outlined,
            requiredField: true),
        _field(institute, 'College / University Name', Icons.account_balance_outlined,
            requiredField: true),
        _field(passoutYear, 'Passout Year (Example: 2025)',
            Icons.calendar_month_outlined, keyboard: TextInputType.number,
            formatters: [FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4)], validator: _passoutValidator),
        _experienceStatus(),
        _field(experience, 'Total Experience in Years (0 for Fresher)',
            Icons.timeline_outlined, keyboard: TextInputType.number,
            formatters: [FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2)], requiredField: true),
        if (workStatus == 'Experienced') ...[
          _field(previousCompany, 'Present Company Name', Icons.apartment_outlined,
              requiredField: true),
          _field(previousDesignation, 'Current Designation / Job Role',
              Icons.badge_outlined, requiredField: true),
        ],
        _choiceGroup('Key Skills', Icons.psychology_outlined, _skillOptions(category)),
        _field(skills, 'Other Skills (comma separated)', Icons.add_circle_outline,
            maxLines: 2),
        _jobTypeDropdown(),
        _choiceGroup('Work Preference', Icons.tune_outlined,
            ['Work From Office', 'Work From Home', 'Hybrid', 'Night Shift']),
        _field(serviceArea, 'Preferred Job Location', Icons.location_city_outlined,
            requiredField: true),
        _field(languages, 'Languages Known', Icons.translate_outlined,
            requiredField: true),
        if (workStatus == 'Experienced')
          _field(noticePeriod, 'Notice Period (Example: 30 Days)',
              Icons.event_available_outlined, requiredField: true),
        _field(salary, 'Expected Monthly Salary', Icons.currency_rupee,
            keyboard: TextInputType.number,
            formatters: [FilteringTextInputFormatter.digitsOnly], requiredField: true),
        _field(resumeLink, 'Resume Link (optional)', Icons.description_outlined),
        _field(profileDescription, 'Career Profile Summary', Icons.notes_outlined,
            maxLines: 3, requiredField: true),
      ]);

  Widget _genderDropdown() => Padding(
        padding: const EdgeInsets.only(bottom: 13),
        child: DropdownButtonFormField<String>(
          initialValue: gender.text.isEmpty ? null : gender.text,
          decoration: _decoration('Gender', Icons.person_pin_outlined),
          items: const ['Male', 'Female', 'Other', 'Prefer not to say']
              .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (value) => gender.text = value ?? '',
          validator: (value) => value == null ? 'Please select gender' : null,
        ),
      );

  Widget _card(List<Widget> children) => Container(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 4),
        decoration: BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xffE7EBF1)),
            boxShadow: const [BoxShadow(color: Color(0x0D0F172A),
                blurRadius: 16, offset: Offset(0, 6))]),
        child: Column(children: children),
      );

  Widget _field(TextEditingController controller, String label, IconData icon, {
    TextInputType? keyboard, List<TextInputFormatter>? formatters,
    String? Function(String?)? validator, int maxLines = 1,
    bool requiredField = false,
  }) => Padding(
        padding: const EdgeInsets.only(bottom: 13),
        child: TextFormField(
          controller: controller, keyboardType: keyboard,
          inputFormatters: formatters, maxLines: maxLines,
          validator: validator ?? (requiredField ? _required : null),
          decoration: _decoration(label, icon),
        ),
      );

  Widget _passwordField(TextEditingController controller, String label,
      bool hidden, VoidCallback reveal, {bool confirm = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 13),
        child: TextFormField(
          controller: controller, obscureText: hidden,
          validator: (value) {
            if (value == null || value.length < 6) return 'Minimum 6 characters required';
            if (confirm && value != password.text) return 'Passwords do not match';
            return null;
          },
          decoration: _decoration(label, Icons.lock_outline).copyWith(
            suffixIcon: IconButton(onPressed: reveal,
              icon: Icon(hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined)),
          ),
        ),
      );

  Widget _choiceGroup(String title, IconData icon, List<String> options) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(icon, color: orange, size: 20), const SizedBox(width: 8),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800,
                color: navy)))]),
          const SizedBox(height: 9),
          Wrap(spacing: 8, runSpacing: 8, children: options.map((option) {
            final isSkill = title.contains('Skill') || title.contains('Services');
            final selected = (isSkill ? selectedSkills : selectedOptions).contains(option);
            return FilterChip(
              selected: selected,
              avatar: Icon(selected ? Icons.check_rounded : _optionIcon(option), size: 17,
                  color: selected ? Colors.white : orange),
              label: Text(option),
              labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : navy),
              selectedColor: orange, backgroundColor: const Color(0xffF8FAFC),
              side: BorderSide(color: selected ? orange : const Color(0xffDDE3EB)),
              checkmarkColor: Colors.white, showCheckmark: false,
              onSelected: (_) => setState(() {
                final set = isSkill ? selectedSkills : selectedOptions;
                selected ? set.remove(option) : set.add(option);
              }),
            );
          }).toList()),
        ]),
      );

  Widget _experienceStatus() => Padding(
        padding: const EdgeInsets.only(bottom: 13),
        child: DropdownButtonFormField<String>(
          initialValue: workStatus,
          decoration: _decoration('Experience Status', Icons.work_history_outlined),
          items: const [DropdownMenuItem(value: 'Fresher', child: Text('Fresher')),
            DropdownMenuItem(value: 'Experienced', child: Text('Experienced'))],
          onChanged: (value) => setState(() => workStatus = value!),
        ),
      );

  Widget _jobTypeDropdown() => Padding(
        padding: const EdgeInsets.only(bottom: 13),
        child: DropdownButtonFormField<String>(
          initialValue: preferredJobType,
          decoration: _decoration('Preferred Job Type', Icons.work_outline),
          items: ['Full-Time', 'Part-Time', 'Contract', 'Internship', 'Work From Home']
              .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (value) => setState(() => preferredJobType = value!),
        ),
      );

  Widget _terms() => Container(
        decoration: BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: accepted ? orange : const Color(0xffE3E8F0))),
        child: CheckboxListTile(
          value: accepted, activeColor: orange, controlAffinity: ListTileControlAffinity.leading,
          onChanged: (v) => setState(() => accepted = v ?? false),
          title: const Text('I confirm all details are correct and accept Terms & Conditions',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
      );

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
        labelText: label, filled: true, fillColor: const Color(0xffFAFBFD),
        prefixIcon: Icon(icon, color: orange),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xffDDE3EB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: orange, width: 1.7)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red, width: 1.5)),
      );

  void _changeAccountType(String value) => setState(() {
        accountType = value; category = null; workStatus = 'Fresher';
        selectedBank = null;
        selectedSkills.clear(); selectedOptions.clear();
        sameAsMobile = false;
        for (final c in [gst, pan, license, businessAge, openingTime, closingTime,
          profileDescription, qualification, specialization, institute,
          passoutYear, experience, previousCompany, previousDesignation, skills,
          serviceArea, serviceCharge, languages, dateOfBirth, gender, noticePeriod,
          salary, resumeLink, bankAccountHolderName, bankUpi,
          ifscCode]) { c.clear(); }
      });

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (category == null) return _show('Please select a category');
    if (accountType != 'Product Seller' && selectedSkills.isEmpty) {
      return _show('Please select at least one skill / service');
    }
    if (!accepted) return _show('Please accept Terms & Conditions');
    Navigator.pop(context, <String, String>{
      'owner': owner.text.trim(),
      'business': accountType == 'Employer / Job Provider'
          ? (previousCompany.text.trim().isEmpty ? owner.text.trim() : previousCompany.text.trim())
          : business.text.trim(),
      'mobile': mobile.text.trim(), 'whatsapp': whatsapp.text.trim(),
      'alternateMobile': alternateMobile.text.trim(), 'email': email.text.trim(),
      'address': address.text.trim(), 'city': city.text.trim(),
      'state': state.text.trim(), 'pincode': pincode.text.trim(),
      'pan': pan.text.trim().toUpperCase(), 'gst': gst.text.trim(),
      'license': license.text.trim(), 'businessAge': businessAge.text.trim(),
      'openingTime': openingTime.text.trim(), 'closingTime': closingTime.text.trim(),
      'profileDescription': profileDescription.text.trim(),
      'qualification': qualification.text.trim(),
      'specialization': specialization.text.trim(), 'institute': institute.text.trim(),
      'passoutYear': passoutYear.text.trim(), 'experience': experience.text.trim(),
      'experienceStatus': workStatus, 'previousCompany': previousCompany.text.trim(),
      'previousDesignation': previousDesignation.text.trim(),
      'skills': [...selectedSkills, skills.text.trim()].where((e) => e.isNotEmpty).join(', '),
      'selectedOptions': selectedOptions.join(', '), 'serviceArea': serviceArea.text.trim(),
      'serviceCharge': serviceCharge.text.trim(), 'languages': languages.text.trim(),
      'dateOfBirth': dateOfBirth.text.trim(), 'gender': gender.text.trim(),
      'noticePeriod': noticePeriod.text.trim(),
      'salary': salary.text.trim(), 'resumeLink': resumeLink.text.trim(),
      'preferredJobType': preferredJobType,
      'bankAccountHolderName': accountType == 'Employer / Job Provider'
          ? '' : bankAccountHolderName.text.trim(),
      'bankName': accountType == 'Employer / Job Provider'
          ? '' : (selectedBank ?? ''),
      'bankUpi': accountType == 'Employer / Job Provider'
          ? '' : bankUpi.text.trim(),
      'ifscCode': accountType == 'Employer / Job Provider'
          ? '' : ifscCode.text.trim().toUpperCase(),
      'password': password.text, 'accountType': accountType, 'category': category!,
    });
  }

  void _show(String text) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));

  void _showForFiveSeconds(bool first) {
    setState(() { if (first) hidePassword = false; else hideConfirm = false; });
    Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() { if (first) hidePassword = true; else hideConfirm = true; });
    });
  }

  String _detailsTitle() => accountType == 'Product Seller'
      ? 'Business Details' : accountType == 'Service Provider'
          ? 'Professional Details' : 'Career Profile';
  String _detailsSubtitle() => accountType == 'Product Seller'
      ? 'Business licence and registration information'
      : accountType == 'Service Provider'
          ? 'Qualifications, skills and service availability'
          : 'Naukri-style education, experience and job preferences';

  String _serviceQualificationLabel() => category == 'Legal Service'
      ? 'Law Degree / Bar Qualification' : category == 'Gym & Fitness'
          ? 'Fitness Certification / Qualification'
          : 'Qualification (ITI / Diploma / Degree / Course)';
  String _serviceSpecializationLabel() => category == 'AC Technician'
      ? 'AC Type (Split / Window / Central / VRF)'
      : category == 'Beautician' || category == 'Hair Stylist'
          ? 'Beauty / Hair Specialization' : 'Trade / Specialization';
  String _serviceCertificateLabel() => category == 'Electrician'
      ? 'Electrical Licence / Certificate (optional)'
      : category == 'Legal Service' ? 'Bar Council Number (optional)'
          : 'Professional Licence / Certificate (optional)';
  String _jobSpecializationLabel() => category == 'IT / Software'
      ? 'Course / Technology / Specialization'
      : ['Driver', 'Cab Driver', 'Truck Driver', 'Bike Rider'].contains(category)
          ? 'Driving Licence Type / Vehicle Experience'
          : 'Course / Branch / Specialization';

  List<String> _skillOptions(String? name) {
    const map = <String, List<String>>{
      'Electrician': ['Wiring', 'Switchboard Repair', 'Fan Installation', 'Inverter', 'Industrial Work'],
      'Plumber': ['Tap Repair', 'Pipe Fitting', 'Leak Repair', 'Bathroom Fitting', 'Water Tank'],
      'Carpenter': ['Furniture Repair', 'Door Work', 'Modular Furniture', 'Polishing', 'Custom Work'],
      'AC Technician': ['Installation', 'Repair', 'Gas Filling', 'Servicing', 'VRF / Central AC'],
      'Mobile Repair': ['Android Repair', 'iPhone Repair', 'Display', 'Software', 'Chip Level'],
      'Computer Hardware Service': ['Desktop', 'Laptop', 'Printer', 'Networking', 'Data Recovery'],
      'CCTV Technician': ['Camera Installation', 'DVR / NVR', 'Networking', 'Maintenance', 'Remote View'],
      'Beautician': ['Facial', 'Makeup', 'Bridal', 'Waxing', 'Manicure'],
      'Hair Stylist': ['Hair Cut', 'Colouring', 'Styling', 'Hair Spa', 'Bridal Hair'],
      'Cleaning': ['Home Cleaning', 'Bathroom', 'Kitchen', 'Office', 'Deep Cleaning'],
      'Photography': ['Wedding', 'Product', 'Portrait', 'Event', 'Photo Editing'],
      'Graphic Design': ['Logo', 'Poster', 'Branding', 'Photoshop', 'Illustrator'],
      'Digital Marketing': ['SEO', 'Google Ads', 'Social Ads', 'Analytics', 'Content Strategy'],
      'IT / Software': ['Flutter', 'Java', 'Python', 'Web Development', 'SQL', 'Testing'],
      'Accounting': ['Tally', 'GST', 'Excel', 'Bookkeeping', 'Tax Filing'],
      'Sales': ['Field Sales', 'Inside Sales', 'Lead Generation', 'CRM', 'Negotiation'],
      'Customer Support': ['Voice Process', 'Chat Support', 'Email Support', 'CRM', 'Languages'],
      'Data Entry': ['Typing', 'MS Excel', 'MS Word', 'Data Verification', 'Internet Research'],
      'Driver': ['LMV', 'Commercial Licence', 'GPS', 'Local Routes', 'Long Distance'],
      'Chef': ['Indian', 'Chinese', 'Bakery', 'Fast Food', 'Kitchen Management'],
      'Teaching / Education': ['Teaching', 'Lesson Planning', 'Online Classes', 'Subject Expert', 'Student Care'],
    };
    return map[name] ?? (accountType == 'Service Provider'
        ? ['Installation', 'Repair', 'Maintenance', 'Consultation', 'On-site Service']
        : ['Communication', 'Computer Knowledge', 'Team Work', 'Problem Solving', 'Time Management']);
  }

  String _categoryDescription(String name) => accountType == 'Product Seller'
      ? 'Register your $name business and start receiving orders.'
      : accountType == 'Service Provider'
          ? 'Add your $name skills so customers can identify you easily.'
          : 'Build your $name career profile and job preferences.';

  IconData _categoryIcon(String name) {
    const exact = <String, IconData>{
      'Grocery': Icons.local_grocery_store_rounded, 'Food Delivery': Icons.delivery_dining_rounded,
      'Restaurant': Icons.restaurant_rounded, 'Bakery': Icons.bakery_dining_rounded,
      'Fruits & Vegetables': Icons.eco_rounded, 'Dairy': Icons.water_drop_rounded,
      'Meat & Fish': Icons.set_meal_rounded, 'Pharmacy / Medicines': Icons.local_pharmacy_rounded,
      'Flowers': Icons.local_florist_rounded, 'Gifts': Icons.card_giftcard_rounded,
      'Cakes': Icons.cake_rounded, 'Courier': Icons.local_shipping_rounded,
      'Parcel Delivery': Icons.inventory_2_rounded, 'Documents': Icons.description_rounded,
      'Electronics': Icons.devices_rounded, 'Mobile Accessories': Icons.phone_android_rounded,
      'Fashion & Clothing': Icons.checkroom_rounded, 'Footwear': Icons.hiking_rounded,
      'Beauty & Cosmetics': Icons.face_retouching_natural_rounded,
      'Books & Stationery': Icons.menu_book_rounded, 'Pet Supplies': Icons.pets_rounded,
      'Home Essentials': Icons.home_rounded, 'Furniture (Local)': Icons.chair_rounded,
      'Toys': Icons.toys_rounded, 'Sports Goods': Icons.sports_cricket_rounded,
      'Electrician': Icons.electrical_services_rounded, 'Plumber': Icons.plumbing_rounded,
      'Carpenter': Icons.carpenter_rounded, 'Welder': Icons.hardware_rounded,
      'Fitter': Icons.settings_rounded,
      'AC Technician': Icons.ac_unit_rounded, 'Mobile Repair': Icons.mobile_friendly_rounded,
      'Computer Hardware Service': Icons.computer_rounded, 'CCTV Technician': Icons.videocam_rounded,
      'Tailor': Icons.content_cut_rounded, 'Beautician': Icons.face_retouching_natural_rounded,
      'Hair Stylist': Icons.content_cut_rounded, 'Spa & Salon': Icons.spa_rounded,
      'Housekeeping': Icons.house_rounded, 'Cleaning': Icons.cleaning_services_rounded,
      'Automobile Technician': Icons.car_repair_rounded, 'Photography': Icons.camera_alt_rounded,
      'Video Editing': Icons.video_settings_rounded, 'Graphic Design': Icons.palette_rounded,
      'UI/UX Design': Icons.design_services_rounded, 'Digital Marketing': Icons.campaign_rounded,
      'Social Media Service': Icons.share_rounded,
      'Content Writing': Icons.edit_note_rounded, 'Translation': Icons.translate_rounded,
      'Legal Service': Icons.gavel_rounded, 'Event Management': Icons.celebration_rounded,
      'Gym & Fitness': Icons.fitness_center_rounded, 'Real Estate': Icons.apartment_rounded,
      'Insurance Service': Icons.policy_rounded,
      'Travel & Tourism': Icons.flight_takeoff_rounded, 'Domestic Helper': Icons.support_agent_rounded,
      'IT / Software': Icons.code_rounded, 'Banking & Finance': Icons.account_balance_rounded,
      'Accounting': Icons.calculate_rounded, 'Sales': Icons.trending_up_rounded,
      'Marketing': Icons.campaign_rounded, 'Customer Support': Icons.headset_mic_rounded,
      'BPO / Call Center': Icons.call_rounded, 'Human Resources (HR)': Icons.groups_rounded,
      'Administration': Icons.admin_panel_settings_rounded, 'Data Entry': Icons.keyboard_rounded,
      'Teaching / Education': Icons.school_rounded, 'Healthcare': Icons.health_and_safety_rounded,
      'Nursing': Icons.medical_services_rounded, 'Lab Technician': Icons.science_rounded,
      'Engineering': Icons.engineering_rounded, 'Civil Engineering': Icons.construction_rounded,
      'Warehouse Jobs': Icons.warehouse_rounded, 'Logistics Jobs': Icons.local_shipping_rounded,
      'Driver': Icons.drive_eta_rounded, 'Cab Driver': Icons.local_taxi_rounded,
      'Truck Driver': Icons.local_shipping_rounded, 'Bike Rider': Icons.two_wheeler_rounded,
      'Security Guard': Icons.security_rounded, 'Hotel Jobs': Icons.hotel_rounded,
      'Chef': Icons.restaurant_menu_rounded, 'Cook': Icons.soup_kitchen_rounded,
      'Waiter': Icons.room_service_rounded, 'Aviation': Icons.flight_rounded,
      'Agriculture': Icons.agriculture_rounded, 'Telecom': Icons.cell_tower_rounded,
      'Media': Icons.perm_media_rounded, 'Journalism': Icons.newspaper_rounded,
      'Cashier': Icons.point_of_sale_rounded, 'Work From Home': Icons.home_work_rounded,
      'Internship': Icons.school_rounded, 'Receptionist': Icons.support_agent_rounded,
    };
    if (exact.containsKey(name)) return exact[name]!;
    if (name.contains('Electrical')) return Icons.electrical_services_rounded;
    if (name.contains('Mechanical')) return Icons.precision_manufacturing_rounded;
    if (name.contains('Factory') || name.contains('Production')) return Icons.factory_rounded;
    return accountType == 'Product Seller' ? Icons.shopping_bag_rounded
        : accountType == 'Service Provider' ? Icons.handyman_rounded : Icons.work_rounded;
  }

  IconData _optionIcon(String option) {
    final o = option.toLowerCase();
    if (o.contains('home')) return Icons.home_outlined;
    if (o.contains('online') || o.contains('upi')) return Icons.language_rounded;
    if (o.contains('cash')) return Icons.payments_outlined;
    if (o.contains('card')) return Icons.credit_card_outlined;
    if (o.contains('delivery')) return Icons.delivery_dining_outlined;
    if (o.contains('morning')) return Icons.wb_sunny_outlined;
    if (o.contains('evening') || o.contains('night')) return Icons.nights_stay_outlined;
    return Icons.check_circle_outline_rounded;
  }

  String? _required(String? value) => value == null || value.trim().isEmpty
      ? 'This field is required' : null;
  String? _gstValidator(String? value) {
    final v = value?.trim().toUpperCase() ?? '';
    if (v.isEmpty) return null;
    return RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][A-Z0-9]Z[A-Z0-9]$').hasMatch(v)
        ? null : 'Enter a valid 15-character GSTIN';
  }
  String? _panValidator(String? value) {
    final v = value?.trim().toUpperCase() ?? '';
    if (v.isEmpty) return null;
    return RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(v)
        ? null : 'Enter a valid PAN number';
  }
  String? _dateValidator(String? value) {
    final v = value?.trim() ?? '';
    if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(v)) {
      return 'Enter date as DD/MM/YYYY';
    }
    final parts = v.split('/').map(int.parse).toList();
    try {
      final date = DateTime(parts[2], parts[1], parts[0]);
      if (date.day != parts[0] || date.month != parts[1] ||
          date.year != parts[2] || date.isAfter(DateTime.now())) {
        return 'Enter a valid date of birth';
      }
    } catch (_) { return 'Enter a valid date of birth'; }
    return null;
  }
  String? _ifscValidator(String? value) {
    final v = value?.trim().toUpperCase() ?? '';
    if (v.isEmpty) return 'IFSC Code is required';
    return RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(v)
        ? null
        : 'Enter a valid IFSC Code (example: SBIN0001234)';
  }
  String? _passoutValidator(String? value) {
    final year = int.tryParse(value?.trim() ?? '');
    return year == null || year < 1950 || year > DateTime.now().year + 6
        ? 'Enter a valid passout year' : null;
  }

  @override
  void dispose() {
    for (final c in [owner, business, mobile, whatsapp, alternateMobile, email,
      address, city, state, pincode, pan, gst, license, businessAge, openingTime,
      closingTime, profileDescription,
      qualification, specialization, institute, passoutYear, experience,
      previousCompany, previousDesignation, skills, serviceArea, salary,
      serviceCharge, languages, dateOfBirth, gender, noticePeriod, resumeLink,
      bankAccountHolderName, bankUpi, ifscCode, password,
      confirmPassword]) { c.dispose(); }
    super.dispose();
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) =>
      newValue.copyWith(text: newValue.text.toUpperCase(), selection: newValue.selection);
}
