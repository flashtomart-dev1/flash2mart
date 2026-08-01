import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const productCategories = <String>[
  'Grocery',
  'Food Delivery',
  'Restaurant',
  'Bakery',
  'Fruits & Vegetables',
  'Dairy',
  'Meat & Fish',
  'Pharmacy / Medicines',
  'Flowers',
  'Gifts',
  'Cakes',
  'Courier',
  'Parcel Delivery',
  'Documents',
  'E-commerce Products',
  'Electronics',
  'Mobile Accessories',
  'Computer Accessories',
  'Fashion & Clothing',
  'Footwear',
  'Beauty & Cosmetics',
  'Books & Stationery',
  'Pet Supplies',
  'Home Essentials',
  'Furniture (Local)',
  'Hardware & Electrical Items',
  'AC Spare Parts',
  'Automobile Spare Parts',
  'Toys',
  'Sports Goods',
  'Office Supplies',
];

const serviceCategories = <String>[
  'Electrician',
  'Plumber',
  'Carpenter',
  'Welder',
  'Fitter',
  'AC Technician',
  'Mobile Repair',
  'Computer Hardware Service',
  'CCTV Technician',
  'Tailor',
  'Beautician',
  'Hair Stylist',
  'Spa & Salon',
  'Housekeeping',
  'Cleaning',
  'Automobile Technician',
  'Photography',
  'Video Editing',
  'Graphic Design',
  'UI/UX Design',
  'Digital Marketing',
  'Social Media Service',
  'Content Writing',
  'Translation',
  'Legal Service',
  'Event Management',
  'Gym & Fitness',
  'Real Estate',
  'Insurance Service',
  'Travel & Tourism',
  'Domestic Helper',
  'Others',
];

const jobCategories = <String>[
  'IT / Software',
  'Banking & Finance',
  'Accounting',
  'Sales',
  'Marketing',
  'Customer Support',
  'BPO / Call Center',
  'Human Resources (HR)',
  'Administration',
  'Data Entry',
  'Teaching / Education',
  'Healthcare',
  'Nursing',
  'Lab Technician',
  'Engineering',
  'Civil Engineering',
  'Mechanical Engineering',
  'Electrical Engineering',
  'Electronics Engineering',
  'Manufacturing',
  'Factory Jobs',
  'Production',
  'Quality Control',
  'Warehouse Jobs',
  'Logistics Jobs',
  'Driver',
  'Cab Driver',
  'Truck Driver',
  'Bike Rider',
  'Security Guard',
  'Hotel Jobs',
  'Chef',
  'Cook',
  'Waiter',
  'Aviation',
  'Airport Staff',
  'Agriculture',
  'Poultry',
  'Fisheries',
  'Telecom',
  'Media',
  'Journalism',
  'NGO Jobs',
  'Retail Jobs',
  'Cashier',
  'Showroom Sales',
  'Freelancing',
  'Work From Home',
  'Part-Time',
  'Internship',
  'Fresher Jobs',
  'Daily Wage Jobs',
  'Contract Jobs',
  'Full-Time Jobs',
  'Research & Development',
  'Startup Jobs',
  'Office Assistant',
  'Receptionist',
  'Helper',
  'Others',
];

class RetailerRegisterScreen extends StatefulWidget {
  const RetailerRegisterScreen({super.key});

  @override
  State<RetailerRegisterScreen> createState() => _RetailerRegisterScreenState();
}

class _RetailerRegisterScreenState extends State<RetailerRegisterScreen> {
  final formKey = GlobalKey<FormState>();
  final owner = TextEditingController();
  final business = TextEditingController();
  final mobile = TextEditingController();
  final email = TextEditingController();
  final address = TextEditingController();
  final pincode = TextEditingController();
  final gst = TextEditingController();
  final license = TextEditingController();
  final qualification = TextEditingController();
  final specialization = TextEditingController();
  final institute = TextEditingController();
  final experience = TextEditingController();
  final previousCompany = TextEditingController();
  final previousDesignation = TextEditingController();
  final skills = TextEditingController();
  final serviceArea = TextEditingController();
  final companyRegistration = TextEditingController();
  final jobTitle = TextEditingController();
  final vacancies = TextEditingController();
  final requiredQualification = TextEditingController();
  final salary = TextEditingController();
  final jobDescription = TextEditingController();
  final resumeLink = TextEditingController();
  final bankUpi = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  String accountType = 'Product Seller';
  String jobRole = 'Job Seeker';
  String workStatus = 'Fresher';
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
    if (category == 'Food Delivery' ||
        category == 'Restaurant' ||
        category == 'Bakery') return 'FSSAI License Number (if applicable)';
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
      'qualification': qualification.text.trim(),
      'specialization': specialization.text.trim(),
      'institute': institute.text.trim(),
      'experience': experience.text.trim(),
      'experienceStatus': workStatus,
      'previousCompany': previousCompany.text.trim(),
      'previousDesignation': previousDesignation.text.trim(),
      'skills': skills.text.trim(),
      'serviceArea': serviceArea.text.trim(),
      'companyRegistration': companyRegistration.text.trim(),
      'jobRole':
          accountType == 'Employer / Job Provider' ? jobRole : 'Not Applicable',
      'jobTitle': jobTitle.text.trim(),
      'vacancies': vacancies.text.trim(),
      'requiredQualification': requiredQualification.text.trim(),
      'salary': salary.text.trim(),
      'jobDescription': jobDescription.text.trim(),
      'resumeLink': resumeLink.text.trim(),
      'bankUpi': bankUpi.text.trim(),
      'password': password.text,
      'accountType': accountType,
      'category': category!,
      'deliveryMode': accountType == 'Product Seller'
          ? (ownDelivery ? 'Own Delivery' : 'Flash2Mart Delivery')
          : 'Not Applicable',
    });
  }

  void show(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),
      appBar: AppBar(
        title: const Text('Partner Registration'),
        backgroundColor: const Color(0xffFF6500),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Icon(Icons.add_business, size: 70, color: Color(0xffFF6500)),
            const Text(
              'Create Business Account',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 7),
            const Text(
              'Choose the correct account type for your work',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 22),
            DropdownButtonFormField<String>(
              initialValue: accountType,
              decoration: inputDecoration(
                'Account Type',
                Icons.account_tree_outlined,
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Product Seller',
                  child: Text('Product Seller / Shop'),
                ),
                DropdownMenuItem(
                  value: 'Service Provider',
                  child: Text('Service Provider'),
                ),
                DropdownMenuItem(
                  value: 'Employer / Job Provider',
                  child: Text('Jobs - Employer / Job Seeker'),
                ),
              ],
              onChanged: (value) => setState(() {
                accountType = value!;
                category = null;
                gst.clear();
                license.clear();
                experience.clear();
                qualification.clear();
                specialization.clear();
                institute.clear();
                previousCompany.clear();
                previousDesignation.clear();
                skills.clear();
                serviceArea.clear();
                companyRegistration.clear();
                jobTitle.clear();
                vacancies.clear();
                requiredQualification.clear();
                salary.clear();
                jobDescription.clear();
                resumeLink.clear();
              }),
            ),
            if (accountType == 'Employer / Job Provider') ...[
              gap(),
              DropdownButtonFormField<String>(
                initialValue: jobRole,
                decoration: inputDecoration(
                  'I want to',
                  Icons.work_outline,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Job Seeker',
                    child: Text('Apply for a Job'),
                  ),
                  DropdownMenuItem(
                    value: 'Job Provider',
                    child: Text('Post a Job / Hire Employees'),
                  ),
                ],
                onChanged: (value) => setState(() => jobRole = value!),
              ),
            ],
            gap(),
            DropdownButtonFormField<String>(
              key: ValueKey(accountType),
              initialValue: category,
              isExpanded: true,
              decoration: inputDecoration(
                'Business Category',
                Icons.category_outlined,
              ),
              items: currentCategories
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => category = value),
              validator: (value) => value == null ? 'Select a category' : null,
            ),
            gap(),
            field(
              owner,
              'Owner / Contact Person Name',
              Icons.person_outline,
              validator: required,
            ),
            gap(),
            field(
              business,
              accountType == 'Employer / Job Provider'
                  ? jobRole == 'Job Provider'
                      ? 'Company Name'
                      : 'Professional Title / Desired Job'
                  : accountType == 'Service Provider'
                      ? 'Service / Business Name'
                      : 'Shop / Business Name',
              Icons.business_outlined,
              validator: required,
            ),
            gap(),
            field(
              mobile,
              'Mobile Number',
              Icons.phone_android,
              keyboard: TextInputType.phone,
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              validator: (v) => v == null || v.length != 10
                  ? 'Enter valid 10-digit mobile number'
                  : null,
            ),
            gap(),
            field(
              email,
              'Email Address',
              Icons.email_outlined,
              keyboard: TextInputType.emailAddress,
              validator: (v) => v == null || !v.contains('@')
                  ? 'Enter valid email address'
                  : null,
            ),
            gap(),
            field(
              address,
              'Business Address',
              Icons.location_on_outlined,
              maxLines: 3,
              validator: required,
            ),
            gap(),
            field(
              pincode,
              'Pincode',
              Icons.pin_drop_outlined,
              keyboard: TextInputType.number,
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              validator: (v) => v == null || v.length != 6
                  ? 'Enter valid 6-digit pincode'
                  : null,
            ),
            gap(),
            if (accountType == 'Product Seller') ...[
              field(
                gst,
                'GSTIN (if registered)',
                Icons.receipt_long_outlined,
                formatters: [
                  LengthLimitingTextInputFormatter(15),
                  UpperCaseTextFormatter(),
                ],
                validator: optionalGstValidator,
              ),
              gap(),
              field(license, licenseHint, Icons.verified_user_outlined),
            ],
            if (accountType == 'Service Provider') ...[
              field(
                qualification,
                'Qualification (ITI / Diploma / Degree / Course)',
                Icons.school_outlined,
                validator: required,
              ),
              gap(),
              field(
                specialization,
                category == 'AC Technician'
                    ? 'AC Specialization (Split / Window / Central / VRF)'
                    : 'Trade / Specialization',
                Icons.build_circle_outlined,
                validator: required,
              ),
              gap(),
              field(
                institute,
                'Institute / Training Centre Name',
                Icons.account_balance_outlined,
                validator: required,
              ),
              gap(),
              DropdownButtonFormField<String>(
                initialValue: workStatus,
                decoration: inputDecoration(
                  'Experience Status',
                  Icons.work_history_outlined,
                ),
                items: const [
                  DropdownMenuItem(value: 'Fresher', child: Text('Fresher')),
                  DropdownMenuItem(
                    value: 'Experienced',
                    child: Text('Experienced'),
                  ),
                ],
                onChanged: (value) => setState(() => workStatus = value!),
              ),
              gap(),
              field(
                experience,
                'Experience in Years',
                Icons.workspace_premium_outlined,
                keyboard: TextInputType.number,
                formatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                validator: required,
              ),
              gap(),
              if (workStatus == 'Experienced') ...[
                field(
                  previousCompany,
                  'Previous / Current Company Name',
                  Icons.apartment_outlined,
                  validator: required,
                ),
                gap(),
                field(
                  previousDesignation,
                  'Previous Designation / Job Role',
                  Icons.badge_outlined,
                  validator: required,
                ),
                gap(),
              ],
              field(
                skills,
                category == 'AC Technician'
                    ? 'Skills (Installation, Repair, Gas Filling, Servicing)'
                    : 'Main Skills / Services',
                Icons.handyman_outlined,
                maxLines: 2,
                validator: required,
              ),
              gap(),
              field(
                serviceArea,
                'Service Area / City',
                Icons.location_city_outlined,
                validator: required,
              ),
              gap(),
              field(
                gst,
                'GSTIN (optional, if registered)',
                Icons.receipt_long_outlined,
                formatters: [
                  LengthLimitingTextInputFormatter(15),
                  UpperCaseTextFormatter(),
                ],
                validator: optionalGstValidator,
              ),
              gap(),
              field(
                license,
                'Professional Licence / Certificate (optional)',
                Icons.verified_user_outlined,
              ),
            ],
            if (accountType == 'Employer / Job Provider') ...[
              if (jobRole == 'Job Seeker') ...[
                field(
                  qualification,
                  'Highest Qualification',
                  Icons.school_outlined,
                  validator: required,
                ),
                gap(),
                field(
                  specialization,
                  'Course / Branch / Specialization',
                  Icons.menu_book_outlined,
                  validator: required,
                ),
                gap(),
                DropdownButtonFormField<String>(
                  initialValue: workStatus,
                  decoration: inputDecoration(
                    'Experience Status',
                    Icons.work_history_outlined,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Fresher', child: Text('Fresher')),
                    DropdownMenuItem(
                      value: 'Experienced',
                      child: Text('Experienced'),
                    ),
                  ],
                  onChanged: (value) => setState(() => workStatus = value!),
                ),
                gap(),
                field(
                  experience,
                  'Total Experience in Years (0 for fresher)',
                  Icons.timeline_outlined,
                  keyboard: TextInputType.number,
                  formatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  validator: required,
                ),
                gap(),
                if (workStatus == 'Experienced') ...[
                  field(
                    previousCompany,
                    'Previous / Current Company Name',
                    Icons.apartment_outlined,
                    validator: required,
                  ),
                  gap(),
                  field(
                    previousDesignation,
                    'Previous Designation / Job Role',
                    Icons.badge_outlined,
                    validator: required,
                  ),
                  gap(),
                ],
                field(
                  skills,
                  'Skills',
                  Icons.psychology_outlined,
                  maxLines: 2,
                  validator: required,
                ),
                gap(),
                field(
                  serviceArea,
                  'Preferred Job Location',
                  Icons.location_city_outlined,
                  validator: required,
                ),
                gap(),
                field(
                  salary,
                  'Expected Monthly Salary',
                  Icons.currency_rupee,
                  keyboard: TextInputType.number,
                  formatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: required,
                ),
                gap(),
                field(
                  resumeLink,
                  'Resume Link (optional)',
                  Icons.description_outlined,
                ),
              ],
              if (jobRole == 'Job Provider') ...[
                field(
                  companyRegistration,
                  'Company Registration / CIN (optional)',
                  Icons.domain_verification_outlined,
                ),
                gap(),
                field(
                  jobTitle,
                  'Job Title / Position',
                  Icons.work_outline,
                  validator: required,
                ),
                gap(),
                field(
                  vacancies,
                  'Number of Vacancies',
                  Icons.groups_outlined,
                  keyboard: TextInputType.number,
                  formatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: required,
                ),
                gap(),
                field(
                  requiredQualification,
                  'Required Qualification',
                  Icons.school_outlined,
                  validator: required,
                ),
                gap(),
                field(
                  experience,
                  'Minimum Experience in Years',
                  Icons.work_history_outlined,
                  keyboard: TextInputType.number,
                  formatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  validator: required,
                ),
                gap(),
                field(
                  skills,
                  'Required Skills',
                  Icons.psychology_outlined,
                  maxLines: 2,
                  validator: required,
                ),
                gap(),
                field(
                  salary,
                  'Monthly Salary / Salary Range',
                  Icons.currency_rupee,
                  validator: required,
                ),
                gap(),
                field(
                  serviceArea,
                  'Job Location',
                  Icons.location_city_outlined,
                  validator: required,
                ),
                gap(),
                field(
                  jobDescription,
                  'Job Description and Responsibilities',
                  Icons.description_outlined,
                  maxLines: 4,
                  validator: required,
                ),
              ],
            ],
            gap(),
            field(
              bankUpi,
              'Bank Account / UPI ID',
              Icons.account_balance_outlined,
              validator: required,
            ),
            if (accountType == 'Product Seller') ...[
              gap(),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                title: Text(
                  ownDelivery
                      ? 'I have my own delivery staff'
                      : 'Use Flash2Mart delivery partners',
                ),
                subtitle: const Text('You can change this later'),
                value: ownDelivery,
                onChanged: (value) => setState(() => ownDelivery = value),
              ),
            ],
            gap(),
            passwordField(
              password,
              'Password',
              hidePassword,
              () => showForFiveSeconds(true),
            ),
            gap(),
            passwordField(
              confirmPassword,
              'Confirm Password',
              hideConfirm,
              () => showForFiveSeconds(false),
              confirm: true,
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: accepted,
              activeColor: const Color(0xffFF6500),
              onChanged: (value) => setState(() => accepted = value ?? false),
              title: const Text(
                'I confirm that the details are correct and accept Terms & Conditions',
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                onPressed: submit,
                icon: const Icon(Icons.how_to_reg),
                label: const Text(
                  'CREATE ACCOUNT',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
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

  String? required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;

  String? optionalGstValidator(String? value) {
    final gstin = value?.trim().toUpperCase() ?? '';
    if (gstin.isEmpty) {
      return null;
    }
    final validGstin = RegExp(
      r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][A-Z0-9]Z[A-Z0-9]$',
    );
    return validGstin.hasMatch(gstin)
        ? null
        : 'Enter a valid 15-character GSTIN';
  }

  Widget gap() => const SizedBox(height: 15);

  Widget field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboard,
    List<TextInputFormatter>? formatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      inputFormatters: formatters,
      validator: validator,
      maxLines: maxLines,
      decoration: inputDecoration(
        label,
        icon,
      ).copyWith(filled: true, fillColor: Colors.white),
    );
  }

  Widget passwordField(
    TextEditingController controller,
    String label,
    bool hidden,
    VoidCallback reveal, {
    bool confirm = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: hidden,
      validator: (value) {
        if (value == null || value.length < 6) {
          return 'Minimum 6 characters required';
        }
        if (confirm && value != password.text) {
          return 'Passwords do not match';
        }
        return null;
      },
      decoration: inputDecoration(label, Icons.lock_outline).copyWith(
        filled: true,
        fillColor: Colors.white,
        suffixIcon: IconButton(
          onPressed: reveal,
          icon: Icon(hidden ? Icons.visibility_off : Icons.visibility),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in [
      owner,
      business,
      mobile,
      email,
      address,
      pincode,
      gst,
      license,
      qualification,
      specialization,
      institute,
      experience,
      previousCompany,
      previousDesignation,
      skills,
      serviceArea,
      companyRegistration,
      jobTitle,
      vacancies,
      requiredQualification,
      salary,
      jobDescription,
      resumeLink,
      bankUpi,
      password,
      confirmPassword,
    ]) {
      controller.dispose();
    }
    super.dispose();
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

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
