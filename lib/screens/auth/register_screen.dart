import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/zego_service.dart';
import '../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  final TextEditingController nameController =
  TextEditingController();

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  final TextEditingController confirmPasswordController =
  TextEditingController();

  final TextEditingController otpController =
  TextEditingController();

  final FocusNode nameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();
  final FocusNode otpFocusNode = FocusNode();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isPhoneMode = false;
  bool otpSent = false;
  bool isLoading = false;

  String? verificationId;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    otpController.dispose();

    nameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    otpFocusNode.dispose();

    super.dispose();
  }

  void onEmailChanged(String value) {
    final String input = value.trim();

    final bool phoneDetected =
    RegExp(r'^\d{10}$').hasMatch(input);

    if (phoneDetected != isPhoneMode) {
      setState(() {
        isPhoneMode = phoneDetected;
      });
    }

    if (!phoneDetected && otpSent) {
      setState(() {
        otpSent = false;
        verificationId = null;
        otpController.clear();
      });
    }
  }

  Future<void> register() async {
    if (isLoading) {
      return;
    }

    final String name =
    nameController.text.trim();

    final String input =
    emailController.text.trim();

    final String password =
        passwordController.text;

    final String confirmPassword =
        confirmPasswordController.text;

    if (name.isEmpty) {
      showMessage('Please enter your name');
      nameFocusNode.requestFocus();
      return;
    }

    if (input.isEmpty) {
      showMessage(
        isPhoneMode
            ? 'Please enter your phone number'
            : 'Please enter your email',
      );
      emailFocusNode.requestFocus();
      return;
    }

    if (isPhoneMode) {
      if (!RegExp(r'^\d{10}$').hasMatch(input)) {
        showMessage(
          'Please enter a valid 10-digit phone number',
        );
        emailFocusNode.requestFocus();
        return;
      }

      if (!otpSent) {
        await sendOtp();
        return;
      }

      await verifyOtp();
      return;
    }

    if (!_isValidEmail(input)) {
      showMessage('Please enter a valid email');
      emailFocusNode.requestFocus();
      return;
    }

    if (password.isEmpty) {
      showMessage('Please enter your password');
      passwordFocusNode.requestFocus();
      return;
    }

    if (password.length < 6) {
      showMessage(
        'Password must be at least 6 characters',
      );
      passwordFocusNode.requestFocus();
      return;
    }

    if (confirmPassword.isEmpty) {
      showMessage(
        'Please confirm your password',
      );
      confirmPasswordFocusNode.requestFocus();
      return;
    }

    if (password != confirmPassword) {
      showMessage('Passwords do not match');
      confirmPasswordFocusNode.requestFocus();
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final UserCredential userCredential =
      await _authService.registerWithEmail(
        email: input,
        password: password,
      );

      final User? firebaseUser =
          userCredential.user;

      if (firebaseUser == null) {
        showMessage('Unable to create user');
        return;
      }

      await createUserProfile(
        firebaseUser: firebaseUser,
        name: name,
        email: input,
      );
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

  Future<void> sendOtp() async {
    final String phoneInput =
    emailController.text.trim();

    if (!RegExp(r'^\d{10}$').hasMatch(phoneInput)) {
      showMessage(
        'Please enter a valid 10-digit phone number',
      );
      emailFocusNode.requestFocus();
      return;
    }

    final String phoneNumber =
        '+91$phoneInput';

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
        showMessage(
          'Unable to verify OTP',
        );
        return;
      }

      await createUserProfile(
        firebaseUser: firebaseUser,
        name: nameController.text.trim(),
        email: '',
      );
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

  Future<void> resendOtp() async {
    setState(() {
      otpSent = false;
      verificationId = null;
      otpController.clear();
    });

    await sendOtp();
  }

  Future<void> createUserProfile({
    required User firebaseUser,
    required String name,
    required String email,
  }) async {
    final UserModel user = UserModel(
      uid: firebaseUser.uid,
      name: name,
      email: email,
      isOnline: true,
      createdAt: DateTime.now(),
    );

    await _userService.createUserProfile(user);

    await ZegoService.initialize(
      userID: firebaseUser.uid,
      userName: name,
    );

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const HomeScreen(),
      ),
          (route) => false,
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email);
  }

  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account already exists with this email';

      case 'invalid-email':
        return 'Invalid email address';

      case 'weak-password':
        return 'Password is too weak';

      case 'invalid-phone-number':
        return 'Invalid phone number';

      case 'invalid-verification-code':
        return 'Invalid OTP. Please check and try again';

      case 'session-expired':
        return 'OTP expired. Please request a new OTP';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later';

      case 'quota-exceeded':
        return 'OTP limit exceeded. Please try again later';

      case 'network-request-failed':
        return 'Network error. Check your internet connection';

      default:
        return 'Registration failed. Please try again';
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Create your ConnectCall account',
              ),

              const SizedBox(height: 35),

              TextField(
                controller: nameController,
                focusNode: nameFocusNode,
                textInputAction:
                TextInputAction.next,
                enabled: !isLoading,
                onSubmitted: (_) {
                  emailFocusNode.requestFocus();
                },
                decoration:
                const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter your name',
                  prefixIcon:
                  Icon(Icons.person_outline),
                  border:
                  OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                controller: emailController,
                focusNode: emailFocusNode,
                keyboardType:
                TextInputType.emailAddress,
                textInputAction:
                TextInputAction.next,
                enabled: !isLoading,
                onChanged: onEmailChanged,
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
                      : 'Enter your email',
                  prefixIcon: Icon(
                    isPhoneMode
                        ? Icons.phone_outlined
                        : Icons.email_outlined,
                  ),
                  border:
                  const OutlineInputBorder(),
                ),
              ),

              if (isPhoneMode) ...[
                const SizedBox(height: 18),

                TextField(
                  controller: otpController,
                  focusNode: otpFocusNode,
                  keyboardType:
                  TextInputType.number,
                  textInputAction:
                  TextInputAction.done,
                  maxLength: 6,
                  enabled:
                  !isLoading && otpSent,
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
                    Icon(Icons.lock_outline),
                    border:
                    OutlineInputBorder(),
                    counterText: '',
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed:
                    isLoading
                        ? null
                        : register,
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
                          ? 'Verify OTP & Register'
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

              const SizedBox(height: 18),

              TextField(
                controller: passwordController,
                focusNode: passwordFocusNode,
                obscureText:
                !isPasswordVisible,
                textInputAction:
                TextInputAction.next,
                enabled: !isLoading,
                onSubmitted: (_) {
                  confirmPasswordFocusNode
                      .requestFocus();
                },
                decoration:
                InputDecoration(
                  labelText: 'Password',
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

              const SizedBox(height: 18),

              TextField(
                controller:
                confirmPasswordController,
                focusNode:
                confirmPasswordFocusNode,
                obscureText:
                !isConfirmPasswordVisible,
                textInputAction:
                TextInputAction.done,
                enabled: !isLoading,
                onSubmitted: (_) {
                  register();
                },
                decoration:
                InputDecoration(
                  labelText:
                  'Confirm Password',
                  prefixIcon:
                  const Icon(
                    Icons.lock_outline,
                  ),
                  border:
                  const OutlineInputBorder(),
                  suffixIcon:
                  IconButton(
                    icon: Icon(
                      isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed:
                    isLoading
                        ? null
                        : () {
                      setState(() {
                        isConfirmPasswordVisible =
                        !isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 25),

              if (!isPhoneMode)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed:
                    isLoading
                        ? null
                        : register,
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
                      'Create Account',
                      style:
                      TextStyle(
                        fontSize: 17,
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
}