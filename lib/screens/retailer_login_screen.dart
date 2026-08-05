import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sms_autofill/sms_autofill.dart';

import 'retailer_home_screen.dart';
import 'retailer_register_screen.dart';

enum OtpVerificationResult { verified, invalid }

typedef SendRetailerOtp = Future<bool> Function(String mobileNumber);
typedef VerifyRetailerOtp = Future<OtpVerificationResult> Function(
  String mobileNumber,
  String otp,
);

class RetailerLoginScreen extends StatefulWidget {
  const RetailerLoginScreen({
    super.key,
    this.sendOtp,
    this.verifyOtp,
  });

  /// Connect these callbacks to Firebase Phone Auth or your backend OTP API.
  /// Keeping them nullable prevents any demo/fake OTP from logging in.
  final SendRetailerOtp? sendOtp;
  final VerifyRetailerOtp? verifyOtp;

  @override
  State<RetailerLoginScreen> createState() => _RetailerLoginScreenState();
}

class _RetailerLoginScreenState extends State<RetailerLoginScreen>
    with CodeAutoFill {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  Map<String, String>? _registeredAccount;
  Timer? _passwordTimer;
  bool _useOtpLogin = false;
  bool _hidePassword = true;
  bool _isBusy = false;
  bool _otpSent = false;
  bool _isOtpVerified = false;
  String? _otpStatusMessage;
  bool _otpStatusIsError = false;
  String? _lastVerificationOtp;

  void _showMessage(
    String message, {
    bool isError = false,
    bool isSuccess = false,
  }) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError
              ? Colors.red.shade700
              : isSuccess
                  ? Colors.green.shade700
                  : null,
        ),
      );
  }

  void _selectLoginType(bool useOtp) {
    if (_useOtpLogin == useOtp) return;

    // Change the selected login type immediately. Keeping focus/reset work out
    // of the way makes the tab react on the first tap on every platform.
    FocusManager.instance.primaryFocus?.unfocus();
    _passwordTimer?.cancel();
    setState(() {
      _useOtpLogin = useOtp;
      _otpSent = false;
      _otpController.clear();
      _isOtpVerified = false;
      _otpStatusMessage = null;
      _otpStatusIsError = false;
      _lastVerificationOtp = null;
      _hidePassword = true;
    });
  }

  void _togglePasswordVisibility() {
    _passwordTimer?.cancel();

    if (!_hidePassword) {
      setState(() => _hidePassword = true);
      return;
    }

    setState(() => _hidePassword = false);
    _passwordTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _hidePassword = true);
    });
  }

  Future<void> _createNewAccount() async {
    FocusScope.of(context).unfocus();

    final account = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (_) => const RetailerRegisterScreen(),
      ),
    );

    if (!mounted || account == null) return;

    setState(() {
      _registeredAccount = Map<String, String>.from(account);
      _mobileController.text = account['mobile'] ?? '';
      _passwordController.text = account['password'] ?? '';
      _otpController.clear();
      _useOtpLogin = false;
      _otpSent = false;
      _isOtpVerified = false;
      _otpStatusMessage = null;
      _otpStatusIsError = false;
      _lastVerificationOtp = null;
      _hidePassword = true;
    });

    _showMessage('Account created successfully. You can now login.');
  }

  Map<String, String>? _findRegisteredAccount() {
    final account = _registeredAccount;
    if (account == null) {
      _showMessage('First create a new partner account', isError: true);
      return null;
    }

    if (_mobileController.text.trim() != (account['mobile'] ?? '')) {
      _showMessage('This mobile number is not registered', isError: true);
      return null;
    }

    return account;
  }

  Future<void> _passwordLogin() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final account = _findRegisteredAccount();
    if (account == null) return;

    if (_passwordController.text != (account['password'] ?? '')) {
      _showMessage('Incorrect password', isError: true);
      return;
    }

    await _openDashboard(account);
  }

  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_findRegisteredAccount() == null || _isBusy) return;

    final otpSender = widget.sendOtp;
    if (otpSender == null) {
      _showMessage(
        'Real OTP backend is not connected yet. Please use Password Login.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isBusy = true;
      _otpController.clear();
      _isOtpVerified = false;
      _otpStatusMessage = 'Sending OTP...';
      _otpStatusIsError = false;
      _lastVerificationOtp = null;
    });

    try {
      listenForCode();
      final sent = await otpSender(_mobileController.text.trim())
          .timeout(const Duration(seconds: 30));
      if (!mounted) return;

      setState(() {
        _isBusy = false;
        _otpSent = sent;
        _otpStatusMessage = sent
            ? 'Waiting for SMS OTP...'
            : 'OTP could not be sent. Please try again.';
        _otpStatusIsError = !sent;
      });

      if (!sent) {
        _showMessage('OTP could not be sent. Please try again.', isError: true);
      } else if (_otpController.text.length == 6) {
        _verifyOtp();
      }
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _isBusy = false;
        _otpSent = false;
        _otpStatusMessage = 'Backend is taking too long. Please try again.';
        _otpStatusIsError = true;
      });
      _showMessage('Backend timeout. Please try again.', isError: true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isBusy = false;
        _otpSent = false;
        _otpStatusMessage = 'Unable to send OTP. Please try again.';
        _otpStatusIsError = true;
      });
      _showMessage('Unable to send OTP. Please try again.', isError: true);
    }
  }

  Future<void> _verifyOtp() async {
    if (!_otpSent || _isBusy || _isOtpVerified) return;
    final enteredOtp = _otpController.text.trim();
    if (enteredOtp.length != 6 || _lastVerificationOtp == enteredOtp) return;
    final account = _findRegisteredAccount();
    if (account == null) return;

    final otpVerifier = widget.verifyOtp;
    if (otpVerifier == null) {
      _showMessage('OTP verification backend is not connected.', isError: true);
      return;
    }

    setState(() {
      _isBusy = true;
      _lastVerificationOtp = enteredOtp;
      _otpStatusMessage = 'Verifying OTP...';
      _otpStatusIsError = false;
    });

    try {
      final result = await otpVerifier(
        _mobileController.text.trim(),
        enteredOtp,
      ).timeout(const Duration(seconds: 30));
      if (!mounted) return;

      if (result == OtpVerificationResult.verified) {
        setState(() {
          _isBusy = false;
          _isOtpVerified = true;
          _otpStatusMessage = 'OTP Verified Successfully';
          _otpStatusIsError = false;
        });
        _showMessage(
          'OTP Verified Successfully',
          isSuccess: true,
        );
        await Future<void>.delayed(const Duration(milliseconds: 650));
        if (mounted) await _openDashboard(account);
      } else {
        setState(() {
          _isBusy = false;
          _isOtpVerified = false;
          _otpStatusMessage = 'Invalid OTP';
          _otpStatusIsError = true;
          _otpController.clear();
          _lastVerificationOtp = null;
        });
        _showMessage('Invalid OTP', isError: true);
      }
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _isBusy = false;
        _lastVerificationOtp = null;
        _otpStatusMessage = 'Backend is taking too long. Please try again.';
        _otpStatusIsError = true;
      });
      _showMessage('Backend timeout. Please try again.', isError: true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isBusy = false;
        _lastVerificationOtp = null;
        _otpStatusMessage = 'OTP verification failed. Please try again.';
        _otpStatusIsError = true;
      });
      _showMessage('OTP verification failed.', isError: true);
    }
  }

  @override
  void codeUpdated() {
    final receivedCode = code?.replaceAll(RegExp(r'\D'), '') ?? '';
    if (!mounted || receivedCode.length < 6) return;

    final otp = receivedCode.substring(0, 6);
    _handleOtpChanged(otp, receivedAutomatically: true);
  }

  void _handleOtpChanged(
    String value, {
    bool receivedAutomatically = false,
  }) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final normalized = digits.length > 6 ? digits.substring(0, 6) : digits;

    if (_otpController.text != normalized) {
      _otpController.value = TextEditingValue(
        text: normalized,
        selection: TextSelection.collapsed(offset: normalized.length),
      );
    }

    if (!mounted) return;
    setState(() {
      _isOtpVerified = false;
      _otpStatusIsError = false;
      if (normalized.length < 6) {
        _lastVerificationOtp = null;
        _otpStatusMessage = receivedAutomatically
            ? 'OTP received...'
            : 'Enter the 6-digit OTP';
      } else {
        _otpStatusMessage = receivedAutomatically
            ? 'OTP received. Verifying...'
            : 'OTP entered. Verifying...';
      }
    });

    if (_otpSent && normalized.length == 6) {
      Future<void>.microtask(_verifyOtp);
    }
  }

  Future<void> _openDashboard(Map<String, String> account) async {
    if (_isBusy) return;
    setState(() => _isBusy = true);

    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RetailerHomeScreen(
          account: Map<String, String>.from(account),
        ),
      ),
    );
  }

  void _forgotPassword() {
    _selectLoginType(true);
    _showMessage(
      'Use SMS OTP after the real OTP service is connected.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                child: Card(
                  elevation: 4,
                  color: Colors.white,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Login to your partner account',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xff172554),
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 18),
                          _buildLoginTypeSelector(),
                          const SizedBox(height: 22),
                          _buildMobileField(),
                          const SizedBox(height: 17),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: _useOtpLogin
                                ? _buildOtpSection()
                                : _buildPasswordSection(),
                          ),
                          const SizedBox(height: 20),
                          const Row(
                            children: [
                              Expanded(child: Divider()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'OR',
                                  style: TextStyle(
                                    color: Color(0xff8A8F9C),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            "Don't have a partner account?",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xff666B78)),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed: _isBusy ? null : _createNewAccount,
                              icon: const Icon(Icons.person_add_alt_1),
                              label: const Text(
                                'CREATE NEW ACCOUNT',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xffFF6500),
                                side: const BorderSide(
                                  color: Color(0xffFF6500),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xffFF8A00), Color(0xffFF5F00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
      ),
      child: const Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.storefront_rounded,
              size: 40,
              color: Color(0xffFF6500),
            ),
          ),
          SizedBox(height: 14),
          Text(
            'Business Partner Login',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Seller  •  Service Provider  •  Job Provider',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginTypeSelector() {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xffF1F2F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildLoginTypeButton(
              label: 'Password Login',
              icon: Icons.lock_outline_rounded,
              selected: !_useOtpLogin,
              onTap: () => _selectLoginType(false),
            ),
          ),
          Expanded(
            child: _buildLoginTypeButton(
              label: 'OTP Login',
              icon: Icons.sms_outlined,
              selected: _useOtpLogin,
              onTap: () => _selectLoginType(true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginTypeButton({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _isBusy ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ]
                : const [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? const Color(0xffFF6500)
                    : const Color(0xff7A7F8C),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected
                        ? const Color(0xff172554)
                        : const Color(0xff7A7F8C),
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileField() {
    return TextFormField(
      controller: _mobileController,
      enabled: !_isBusy && !_otpSent,
      keyboardType: TextInputType.phone,
      textInputAction:
          _useOtpLogin ? TextInputAction.done : TextInputAction.next,
      maxLength: 10,
      autofillHints: const [AutofillHints.telephoneNumber],
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      onFieldSubmitted: (_) {
        if (_useOtpLogin) _sendOtp();
      },
      validator: (value) {
        final mobile = (value ?? '').trim();
        if (mobile.isEmpty) return 'Enter mobile number';
        if (mobile.length != 10) {
          return 'Enter a valid 10-digit mobile number';
        }
        return null;
      },
      decoration: _inputDecoration(
        'Mobile Number',
        Icons.phone_android,
      ).copyWith(counterText: ''),
    );
  }

  Widget _buildPasswordSection() {
    return Column(
      key: const ValueKey('password-section'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _passwordController,
          obscureText: _hidePassword,
          enabled: !_isBusy,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          onFieldSubmitted: (_) => _passwordLogin(),
          validator: (value) {
            if (_useOtpLogin) return null;
            if ((value ?? '').isEmpty) return 'Enter password';
            if ((value ?? '').length < 6) {
              return 'Password must contain at least 6 characters';
            }
            return null;
          },
          decoration: _inputDecoration(
            'Password',
            Icons.lock_outline,
          ).copyWith(
            suffixIcon: IconButton(
              tooltip: _hidePassword
                  ? 'Show password for 5 seconds'
                  : 'Hide password',
              onPressed: _isBusy ? null : _togglePasswordVisibility,
              icon: Icon(
                _hidePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xffFF6500),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _isBusy ? null : _forgotPassword,
            child: const Text('Forgot Password?'),
          ),
        ),
        const SizedBox(height: 8),
        _buildPrimaryButton(
          label: 'LOGIN',
          icon: Icons.login_rounded,
          onPressed: _passwordLogin,
        ),
      ],
    );
  }

  Widget _buildOtpSection() {
    return Column(
      key: const ValueKey('otp-section'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_otpSent) ...[
          const Text(
            'OTP auto-fills from SMS. You can also enter it manually.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xff666B78),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          _buildOtpBoxes(),
          const SizedBox(height: 14),
          _buildOtpStatus(),
          const SizedBox(height: 6),
          TextButton(
            onPressed: _isBusy ? null : _sendOtp,
            child: const Text('Resend OTP'),
          ),
        ] else
          _buildPrimaryButton(
            label: 'SEND OTP',
            icon: Icons.send_to_mobile_rounded,
            onPressed: _sendOtp,
          ),
      ],
    );
  }

  Widget _buildOtpBoxes() {
    final otp = _otpController.text;
    final borderColor = _isOtpVerified
        ? Colors.green.shade600
        : _otpStatusIsError
            ? Colors.red.shade600
            : const Color(0xffD8DCE6);

    return SizedBox(
      height: 54,
      child: Stack(
        children: [
          IgnorePointer(
            child: Row(
              children: List.generate(11, (itemIndex) {
                if (itemIndex.isOdd) return const SizedBox(width: 6);
                final index = itemIndex ~/ 2;
                final digit = index < otp.length ? otp[index] : '';
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _isOtpVerified
                          ? const Color(0xffECFDF3)
                          : const Color(0xffF8F9FD),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: borderColor, width: 1.5),
                    ),
                    child: Text(
                      digit,
                      style: TextStyle(
                        color: _isOtpVerified
                            ? Colors.green.shade800
                            : const Color(0xff172554),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.01,
              child: TextField(
                controller: _otpController,
                enabled: !_isBusy && !_isOtpVerified,
                autofocus: true,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.oneTimeCode],
                maxLength: 6,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                enableInteractiveSelection: false,
                cursorColor: Colors.transparent,
                style: const TextStyle(color: Colors.transparent),
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: _handleOtpChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpStatus() {
    if (_isBusy) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 19,
            height: 19,
            child: CircularProgressIndicator(
              strokeWidth: 2.3,
              color: Color(0xffFF6500),
            ),
          ),
          SizedBox(width: 10),
          Text(
            'Verifying OTP...',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      );
    }

    final message = _otpStatusMessage;
    if (message == null) return const SizedBox.shrink();

    final success = _isOtpVerified;
    final color = success
        ? Colors.green.shade700
        : _otpStatusIsError
            ? Colors.red.shade700
            : const Color(0xff666B78);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (success || _otpStatusIsError)
          Icon(
            success ? Icons.check_circle_rounded : Icons.error_rounded,
            color: color,
            size: 20,
          ),
        if (success || _otpStatusIsError) const SizedBox(width: 7),
        Flexible(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required Future<void> Function() onPressed,
  }) {
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _isBusy ? null : onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xffFF6500),
          disabledBackgroundColor: const Color(0xffFFB37E),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: _isBusy
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Icon(icon),
        label: Text(
          _isBusy ? 'PLEASE WAIT...' : label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xffFF6500)),
      filled: true,
      fillColor: const Color(0xffF8F9FD),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xffE2E5EC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xffFF6500), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  @override
  void dispose() {
    cancel();
    unregisterListener();
    _passwordTimer?.cancel();
    _mobileController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}
