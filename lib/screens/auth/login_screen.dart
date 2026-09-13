import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/zego_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  final TextEditingController emailPhoneController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  final TextEditingController otpController =
  TextEditingController();

  final FocusNode emailPhoneFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode otpFocusNode = FocusNode();

  bool isPasswordVisible = false;
  bool isLoading = false;

  bool isPhoneMode = false;
  bool otpSent = false;

  String? verificationId;

  @override
  void dispose() {
    emailPhoneController.dispose();
    passwordController.dispose();
    otpController.dispose();

    emailPhoneFocusNode.dispose();
    passwordFocusNode.dispose();
    otpFocusNode.dispose();

    super.dispose();
  }

  // =========================
  // INPUT CHANGE
  // =========================

  void onEmailPhoneChanged(String value) {
    final String text = value.trim();

    final bool phoneDetected =
    RegExp(r'^\d{10}$').hasMatch(text);

    if (phoneDetected != isPhoneMode) {
      setState(() {
        isPhoneMode = phoneDetected;
      });
    }
  }

  // =========================
  // LOGIN
  // =========================

  Future<void> login() async {
    if (isLoading) {
      return;
    }

    final String input =
    emailPhoneController.text.trim();

    // PHONE LOGIN
    if (isPhoneMode) {
      if (!otpSent) {
        await sendOtp();
      } else {
        await verifyOtp();
      }

      return;
    }

    // EMAIL LOGIN
    final String email = input;
    final String password = passwordController.text;

    if (email.isEmpty) {
      showMessage('Please enter your email');
      emailPhoneFocusNode.requestFocus();
      return;
    }

    if (!_isValidEmail(email)) {
      showMessage('Please enter a valid email');
      emailPhoneFocusNode.requestFocus();
      return;
    }

    if (password.isEmpty) {
      showMessage('Please enter your password');
      passwordFocusNode.requestFocus();
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final UserCredential userCredential =
      await _authService.loginWithEmail(
        email: email,
        password: password,
      );

      final User? firebaseUser =
          userCredential.user;

      if (firebaseUser == null) {
        showMessage('Unable to login');
        return;
      }

      await loginUserSuccessfully(firebaseUser);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      showMessage(
        _getFirebaseErrorMessage(e.code),
      );
    } catch (e) {
      if (!mounted) return;

      showMessage(
        'Something went wrong. Please try again.',
      );
    } finally {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  // =========================
  // SEND PHONE OTP
  // =========================

  Future<void> sendOtp() async {
    final String input =
    emailPhoneController.text.trim();

    if (!RegExp(r'^\d{10}$').hasMatch(input)) {
      showMessage(
        'Please enter a valid 10-digit phone number',
      );
      emailPhoneFocusNode.requestFocus();
      return;
    }

    final String phoneNumber = '+91$input';

    setState(() {
      isLoading = true;
    });

    try {
      await _authService.sendPhoneOtp(
        phoneNumber: phoneNumber,

        onCodeSent: (
            String receivedVerificationId,
            ) {
          if (!mounted) return;

          setState(() {
            verificationId =
                receivedVerificationId;
            otpSent = true;
            isLoading = false;
          });

          showMessage('OTP sent successfully');

          Future.delayed(
            const Duration(milliseconds: 300),
                () {
              if (mounted) {
                otpFocusNode.requestFocus();
              }
            },
          );
        },

        onVerificationFailed: (
            FirebaseAuthException error,
            ) {
          if (!mounted) return;

          setState(() {
            isLoading = false;
          });

          showMessage(
            _getFirebaseErrorMessage(error.code),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showMessage(
        'Unable to send OTP. Please try again.',
      );
    }
  }

  // =========================
  // VERIFY PHONE OTP
  // =========================

  Future<void> verifyOtp() async {
    final String otp =
    otpController.text.trim();

    if (verificationId == null) {
      showMessage(
        'Please request OTP first',
      );
      return;
    }

    if (otp.length != 6) {
      showMessage(
        'Please enter the 6-digit OTP',
      );
      otpFocusNode.requestFocus();
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final UserCredential userCredential =
      await _authService.verifyPhoneOtp(
        verificationId: verificationId!,
        smsCode: otp,
      );

      final User? firebaseUser =
          userCredential.user;

      if (firebaseUser == null) {
        showMessage('Unable to verify OTP');
        return;
      }

      await loginUserSuccessfully(firebaseUser);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      showMessage(
        _getFirebaseErrorMessage(e.code),
      );
    } catch (e) {
      if (!mounted) return;

      showMessage(
        'OTP verification failed. Please try again.',
      );
    } finally {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  // =========================
  // SUCCESSFUL LOGIN
  // =========================

  Future<void> loginUserSuccessfully(
      User firebaseUser,
      ) async {
    await _userService.updateOnlineStatus(
      firebaseUser.uid,
      true,
    );

    final UserModel? userProfile =
    await _userService.getUserProfile(
      firebaseUser.uid,
    );

    final String userName =
    userProfile?.name.isNotEmpty == true
        ? userProfile!.name
        : (firebaseUser.displayName ??
        firebaseUser.email ??
        'User');

    await ZegoService.initialize(
      userID: firebaseUser.uid,
      userName: userName,
    );

    if (!mounted) return;

    showMessage('Login successful');
  }

  // =========================
  // RESET PHONE OTP
  // =========================

  Future<void> resendOtp() async {
    setState(() {
      otpSent = false;
      verificationId = null;
      otpController.clear();
    });

    await sendOtp();
  }

  // =========================
  // EMAIL VALIDATION
  // =========================

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email);
  }

  // =========================
  // FIREBASE ERROR MESSAGE
  // =========================

  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Invalid email address';

      case 'user-not-found':
        return 'No account found with this email';

      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password';

      case 'user-disabled':
        return 'This account has been disabled';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later';

      case 'network-request-failed':
        return 'Network error. Check your internet connection';

      case 'invalid-verification-code':
        return 'Invalid OTP. Please check and try again';

      case 'session-expired':
        return 'OTP expired. Please request a new OTP';

      case 'invalid-phone-number':
        return 'Invalid phone number';

      case 'quota-exceeded':
        return 'OTP limit exceeded. Please try again later';

      default:
        return 'Authentication failed. Please try again';
    }
  }

  // =========================
  // FORGOT PASSWORD
  // =========================

  Future<void> forgotPassword() async {
    final String email =
    emailPhoneController.text.trim();

    if (isPhoneMode) {
      showMessage(
        'Phone login uses OTP. No password reset is required.',
      );
      return;
    }

    if (email.isEmpty) {
      showMessage(
        'Enter your email first',
      );
      emailPhoneFocusNode.requestFocus();
      return;
    }

    if (!_isValidEmail(email)) {
      showMessage(
        'Please enter a valid email',
      );
      emailPhoneFocusNode.requestFocus();
      return;
    }

    try {
      await _authService.sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) return;

      showMessage(
        'Password reset email sent',
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      showMessage(
        _getFirebaseErrorMessage(e.code),
      );
    }
  }

  // =========================
  // MESSAGE
  // =========================

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 30),

              const Icon(
                Icons.call,
                size: 70,
              ),

              const SizedBox(height: 20),

              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Sign in to continue to ConnectCall',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 35),

              // =========================
              // EMAIL / PHONE FIELD
              // =========================

              TextField(
                controller:
                emailPhoneController,
                focusNode:
                emailPhoneFocusNode,
                keyboardType:
                TextInputType.emailAddress,
                textInputAction:
                isPhoneMode
                    ? TextInputAction.next
                    : TextInputAction.next,
                enabled: !isLoading,
                onChanged:
                onEmailPhoneChanged,
                onSubmitted: (_) {
                  if (isPhoneMode) {
                    otpFocusNode.requestFocus();
                  } else {
                    passwordFocusNode.requestFocus();
                  }
                },
                decoration:
                InputDecoration(
                  labelText:
                  isPhoneMode
                      ? 'Phone Number'
                      : 'Email',

                  hintText:
                  isPhoneMode
                      ? 'Enter 10-digit phone number'
                      : 'Enter your email or Phone no.',

                  prefixIcon: Icon(
                    isPhoneMode
                        ? Icons.phone_outlined
                        : Icons.email_outlined,
                  ),

                  border:
                  const OutlineInputBorder(),
                ),
              ),

              // =========================
              // OTP FIELD
              // =========================

              if (isPhoneMode) ...[
                const SizedBox(height: 18),

                TextField(
                  controller:
                  otpController,
                  focusNode:
                  otpFocusNode,
                  keyboardType:
                  TextInputType.number,
                  textInputAction:
                  TextInputAction.done,
                  maxLength: 6,
                  enabled: !isLoading &&
                      otpSent,
                  onSubmitted: (_) {
                    if (otpSent) {
                      verifyOtp();
                    }
                  },
                  decoration:
                  const InputDecoration(
                    labelText: 'OTP',
                    hintText:
                    'Enter 6-digit OTP',
                    prefixIcon:
                    Icon(
                      Icons.lock_outline,
                    ),
                    border:
                    OutlineInputBorder(),
                    counterText: '',
                  ),
                ),

                const SizedBox(height: 10),

                // =========================
                // SEND / VERIFY BUTTON
                // =========================

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed:
                    isLoading
                        ? null
                        : () {
                      if (otpSent) {
                        verifyOtp();
                      } else {
                        sendOtp();
                      }
                    },
                    child: isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : Text(
                      otpSent
                          ? 'Verify OTP'
                          : 'Send OTP',
                      style:
                      const TextStyle(
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),

                if (otpSent) ...[
                  const SizedBox(height: 8),

                  TextButton(
                    onPressed:
                    isLoading
                        ? null
                        : resendOtp,
                    child:
                    const Text(
                      'Resend OTP',
                    ),
                  ),
                ],
              ],

              // =========================
              // PASSWORD
              // =========================

              if (!isPhoneMode) ...[
                const SizedBox(height: 18),

                TextField(
                  controller:
                  passwordController,
                  focusNode:
                  passwordFocusNode,
                  obscureText:
                  !isPasswordVisible,
                  textInputAction:
                  TextInputAction.done,
                  enabled: !isLoading,
                  onSubmitted: (_) {
                    login();
                  },
                  decoration:
                  InputDecoration(
                    labelText: 'Password',
                    hintText:
                    'Enter your password',
                    prefixIcon:
                    const Icon(
                      Icons.lock_outline,
                    ),
                    border:
                    const OutlineInputBorder(),
                    suffixIcon:
                    IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed:
                      isLoading
                          ? null
                          : () {
                        setState(() {
                          isPasswordVisible =
                          !isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Align(
                  alignment:
                  Alignment.centerRight,
                  child: TextButton(
                    onPressed:
                    isLoading
                        ? null
                        : forgotPassword,
                    child:
                    const Text(
                      'Forgot Password?',
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed:
                    isLoading
                        ? null
                        : login,
                    child: isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Login',
                      style:
                      TextStyle(
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 15),

              // =========================
              // REGISTER
              // =========================

              TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                      const RegisterScreen(),
                    ),
                  );
                },
                child:
                const Text(
                  'Create Account',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}