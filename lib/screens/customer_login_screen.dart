import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomerLoginScreen extends StatefulWidget {
  const CustomerLoginScreen({super.key});

  @override
  State<CustomerLoginScreen> createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends State<CustomerLoginScreen> {
  bool obscurePassword = true;

  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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

  void loginCustomer() {
    FocusScope.of(context).unfocus();

    final String mobileNumber = mobileController.text.trim();
    final String password = passwordController.text.trim();

    if (mobileNumber.isEmpty) {
      showMessage("Please enter mobile number");
      return;
    }

    if (mobileNumber.length != 10) {
      showMessage("Please enter valid 10-digit mobile number");
      return;
    }

    if (password.isEmpty) {
      showMessage("Please enter password");
      return;
    }

    if (password.length < 6) {
      showMessage("Password must contain at least 6 characters");
      return;
    }

    showMessage("Login successful");

    // Customer Home Screen create chesina tarvata ikkada navigation add cheyyali.
    //
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => const CustomerHomeScreen(),
    //   ),
    // );
  }

  void openRegisterScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CustomerRegisterScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              //================ HEADER =================//

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(25, 30, 25, 40),
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
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: Color(0xff3A7BFF),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Customer Login",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Welcome Back to Flash2Mart",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  elevation: 6,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        //================ MOBILE NUMBER =================//

                        TextField(
                          controller: mobileController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          decoration: InputDecoration(
                            labelText: "Mobile Number",
                            hintText: "Enter 10-digit Mobile Number",
                            counterText: "",
                            prefixIcon: const Icon(
                              Icons.phone_android,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                color: Color(0xff3A7BFF),
                                width: 2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        //================ PASSWORD =================//

                        TextField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) {
                            loginCustomer();
                          },
                          decoration: InputDecoration(
                            labelText: "Password",
                            hintText: "Enter your password",
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                color: Color(0xff3A7BFF),
                                width: 2,
                              ),
                            ),
                          ),
                        ),

                        //================ FORGOT PASSWORD =================//

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              showMessage(
                                "Forgot Password screen will be added next",
                              );
                            },
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: Color(0xff3A7BFF),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        //================ LOGIN BUTTON =================//

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xff7B2FF7),
                                  Color(0xff3A7BFF),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueAccent.withOpacity(0.30),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: loginCustomer,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: const Text(
                                "LOGIN",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        //================ LOGIN WITH OTP =================//

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              showMessage(
                                "OTP Login screen will be added next",
                              );
                            },
                            icon: const Icon(
                              Icons.sms_outlined,
                            ),
                            label: const Text(
                              "Login with OTP",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xff3A7BFF),
                              side: const BorderSide(
                                color: Color(0xff3A7BFF),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Divider(),

                        const SizedBox(height: 15),

                        const Text(
                          "Don't have an account?",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),

                        const SizedBox(height: 15),

                        //================ CREATE ACCOUNT =================//

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            onPressed: openRegisterScreen,
                            icon: const Icon(
                              Icons.person_add_alt_1,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "CREATE NEW ACCOUNT",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Row(
                          children: [
                            Expanded(
                              child: Divider(),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Text("OR"),
                            ),
                            Expanded(
                              child: Divider(),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        //================ GOOGLE LOGIN =================//

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              showMessage(
                                "Google Login will be connected later",
                              );
                            },
                            icon: const Icon(
                              Icons.g_mobiledata,
                              color: Colors.red,
                              size: 35,
                            ),
                            label: const Text(
                              "Continue with Google",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        TextButton(
                          onPressed: () {
                            showMessage("Continuing as Guest");
                          },
                          child: const Text(
                            "Continue as Guest",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff3A7BFF),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "By continuing, you agree to Flash2Mart's\n"
                  "Terms & Conditions and Privacy Policy.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    mobileController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

//======================================================================//
//                     CUSTOMER REGISTER SCREEN                         //
//======================================================================//

class CustomerRegisterScreen extends StatefulWidget {
  const CustomerRegisterScreen({super.key});

  @override
  State<CustomerRegisterScreen> createState() =>
      _CustomerRegisterScreenState();
}

class _CustomerRegisterScreenState extends State<CustomerRegisterScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController referralController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool acceptTerms = false;
  bool isLoading = false;

  String selectedGender = "Male";

  final List<String> genderList = [
    "Male",
    "Female",
    "Other",
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

  String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter full name";
    }

    if (value.trim().length < 3) {
      return "Name must contain at least 3 characters";
    }

    return null;
  }

  String? validateMobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter mobile number";
    }

    if (value.trim().length != 10) {
      return "Enter valid 10-digit mobile number";
    }

    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter email address";
    }

    final RegExp emailPattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailPattern.hasMatch(value.trim())) {
      return "Please enter valid email address";
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter password";
    }

    if (value.length < 6) {
      return "Password must contain at least 6 characters";
    }

    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please confirm password";
    }

    if (value != passwordController.text) {
      return "Passwords do not match";
    }

    return null;
  }

  Future<void> createAccount() async {
    FocusScope.of(context).unfocus();

    if (!formKey.currentState!.validate()) {
      return;
    }

    if (!acceptTerms) {
      showMessage("Please accept Terms & Conditions");
      return;
    }

    setState(() {
      isLoading = true;
    });

    await Future.delayed(
      const Duration(seconds: 1),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      isLoading = false;
    });

    showRegistrationSuccessDialog();
  }

  void showRegistrationSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 25, 24, 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xffE8F8EE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xff16A34A),
                  size: 55,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Account Created!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff111827),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Welcome ${fullNameController.text.trim()}!\n"
                "Your Flash2Mart customer account has been created successfully.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff3A7BFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "GO TO LOGIN",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  InputDecoration fieldDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xffF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xff3A7BFF),
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xff7B2FF7),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Create Account",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              //================ REGISTER HEADER =================//

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(25, 15, 25, 35),
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
                child: const Column(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person_add_alt_1,
                        size: 45,
                        color: Color(0xff3A7BFF),
                      ),
                    ),
                    SizedBox(height: 18),
                    Text(
                      "Join Flash2Mart",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 7),
                    Text(
                      "Create your customer account",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                ),
                child: Card(
                  elevation: 5,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Personal Information",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff111827),
                            ),
                          ),

                          const SizedBox(height: 6),

                          const Text(
                            "Enter your details to create an account",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),

                          const SizedBox(height: 22),

                          //================ FULL NAME =================//

                          TextFormField(
                            controller: fullNameController,
                            textCapitalization: TextCapitalization.words,
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            validator: validateFullName,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r"[a-zA-Z\s]"),
                              ),
                            ],
                            decoration: fieldDecoration(
                              label: "Full Name",
                              hint: "Enter your full name",
                              icon: Icons.person_outline,
                            ),
                          ),

                          const SizedBox(height: 18),

                          //================ MOBILE NUMBER =================//

                          TextFormField(
                            controller: mobileController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            maxLength: 10,
                            validator: validateMobile,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            decoration: fieldDecoration(
                              label: "Mobile Number",
                              hint: "Enter 10-digit mobile number",
                              icon: Icons.phone_android,
                            ).copyWith(
                              counterText: "",
                            ),
                          ),

                          const SizedBox(height: 18),

                          //================ EMAIL =================//

                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: validateEmail,
                            decoration: fieldDecoration(
                              label: "Email Address",
                              hint: "Enter your email address",
                              icon: Icons.email_outlined,
                            ),
                          ),

                          const SizedBox(height: 18),

                          //================ GENDER =================//

                          DropdownButtonFormField<String>(
                            value: selectedGender,
                            decoration: fieldDecoration(
                              label: "Gender",
                              hint: "Select gender",
                              icon: Icons.wc_outlined,
                            ),
                            items: genderList.map((gender) {
                              return DropdownMenuItem<String>(
                                value: gender,
                                child: Text(gender),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectedGender = newValue;
                                });
                              }
                            },
                          ),

                          const SizedBox(height: 18),

                          //================ PASSWORD =================//

                          TextFormField(
                            controller: passwordController,
                            obscureText: obscurePassword,
                            textInputAction: TextInputAction.next,
                            validator: validatePassword,
                            decoration: fieldDecoration(
                              label: "Create Password",
                              hint: "Minimum 6 characters",
                              icon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscurePassword = !obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          //================ CONFIRM PASSWORD =================//

                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: obscureConfirmPassword,
                            textInputAction: TextInputAction.next,
                            validator: validateConfirmPassword,
                            decoration: fieldDecoration(
                              label: "Confirm Password",
                              hint: "Re-enter your password",
                              icon: Icons.lock_reset_outlined,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscureConfirmPassword =
                                        !obscureConfirmPassword;
                                  });
                                },
                                icon: Icon(
                                  obscureConfirmPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          //================ REFERRAL CODE =================//

                          TextFormField(
                            controller: referralController,
                            textCapitalization: TextCapitalization.characters,
                            textInputAction: TextInputAction.done,
                            decoration: fieldDecoration(
                              label: "Referral Code (Optional)",
                              hint: "Enter referral code",
                              icon: Icons.card_giftcard_outlined,
                            ),
                          ),

                          const SizedBox(height: 15),

                          //================ TERMS CHECKBOX =================//

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: acceptTerms,
                                activeColor: const Color(0xff3A7BFF),
                                onChanged: (bool? value) {
                                  setState(() {
                                    acceptTerms = value ?? false;
                                  });
                                },
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 11,
                                  ),
                                  child: Wrap(
                                    children: [
                                      const Text(
                                        "I agree to Flash2Mart's ",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          showMessage(
                                            "Terms & Conditions selected",
                                          );
                                        },
                                        child: const Text(
                                          "Terms & Conditions",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xff3A7BFF),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const Text(
                                        " and ",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          showMessage(
                                            "Privacy Policy selected",
                                          );
                                        },
                                        child: const Text(
                                          "Privacy Policy",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xff3A7BFF),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          //================ CREATE ACCOUNT BUTTON =================//

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xff7B2FF7),
                                    Color(0xff3A7BFF),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueAccent.withOpacity(0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: isLoading ? null : createAccount,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  disabledBackgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 25,
                                        height: 25,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.person_add_alt_1,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            "CREATE ACCOUNT",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already have an account?",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black54,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Color(0xff3A7BFF),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Secure registration powered by Flash2Mart",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    fullNameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    referralController.dispose();
    super.dispose();
  }
}