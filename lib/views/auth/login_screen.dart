import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roamly_app/core/providers/auth_provider.dart';
import 'package:roamly_app/core/services/secure_storage.dart';
import 'package:roamly_app/views/auth/signup_screen.dart';
import 'package:roamly_app/views/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //// Controllers for managing text input fields
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  //// Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // // State variables for UI behavior
  bool _isPasswordHidden = true; //Toggle password visibility.
  late final TapGestureRecognizer _signUpRecognizer;

  // Constants for better maintainability
  static const double _fieldWidth = 350;
  static const double _fieldSpacing = 15;

  @override
  //Initializes controllers when the widget is created.
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _signUpRecognizer = TapGestureRecognizer()..onTap = _navigateToSignUp;
  }

  @override
  //Frees up memory by disposing controllers when widget is removed.
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _signUpRecognizer.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Validate all form fields
    //_formKey.currentState - Accesses the current state of the Form widget
    //.validate() - Runs all validator functions in the form (calls _validateEmail and _validatePassword)
    if (!_formKey.currentState!.validate()) return;

    // Unfocus keyboard
    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();

    try {
      await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Check if widget is still mounted and authentication succeeded
      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Successful'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Login failed: ${authProvider.errorMessage ?? e.toString()}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  //// Navigate to forgot password page
  void _navigateToForgotPassword() {
    // Navigator.of(
    //   context,
    // ).push(MaterialPageRoute(builder: (context) => UserForgetpasswordpage()));
  }

  void _navigateToSignUp() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => SignupScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dark blue background
      //// SafeArea prevents overlap with system UI
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A), // slate-900 (top-left)
              Color(0xFF1E3A8A), // blue-900 (bottom-right)
            ],
          ),
        ),
        child: SafeArea(
          //prevents overflow
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Form(
                        //Wraps input fields for validation.
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 90),

                            // Welcome Title
                            const Text(
                              'Welcome to Roamly',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Your AI travel companion',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Login Container
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Color.fromARGB(
                                  255,
                                  80,
                                  92,
                                  127,
                                ), // Slightly lighter blue
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                children: [
                                  // Email Input Field
                                  Consumer<AuthProvider>(
                                    builder: (context, authProvider, child) {
                                      return TextFormField(
                                        controller: _emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        enabled: !authProvider.isLoading,
                                        validator: _validateEmail,

                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          hintText: 'Enter Email',
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 16,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: _fieldSpacing),

                                  // Password Input Field
                                  Consumer<AuthProvider>(
                                    builder: (context, authProvider, child) {
                                      return TextFormField(
                                        controller: _passwordController,
                                        obscureText: _isPasswordHidden,
                                        textInputAction: TextInputAction.done,
                                        enabled: !authProvider.isLoading,
                                        onFieldSubmitted: (_) => _handleLogin(),
                                        validator: _validatePassword,

                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          hintText: 'Enter Password',

                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 16,
                                              ),
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _isPasswordHidden =
                                                    !_isPasswordHidden;
                                              });
                                            },
                                            icon: Icon(
                                              _isPasswordHidden
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 24),

                                  // Sign In Button
                                  Consumer<AuthProvider>(
                                    builder: (context, authProvider, child) {
                                      return SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF5C6BC0,
                                            ),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            disabledBackgroundColor:
                                                Colors.grey.shade400,
                                          ),
                                          onPressed: authProvider.isLoading
                                              ? null
                                              : _handleLogin,
                                          child: authProvider.isLoading
                                              ? const SizedBox(
                                                  height: 24,
                                                  width: 24,
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2,
                                                      ),
                                                )
                                              : const Text(
                                                  'Sign In',
                                                  style: TextStyle(
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Forgot Password
                                  Consumer<AuthProvider>(
                                    builder: (context, authProvider, child) {
                                      return TextButton(
                                        onPressed: authProvider.isLoading
                                            ? null
                                            : _navigateToForgotPassword,
                                        child: const Text(
                                          'Forgot password?',
                                          style: TextStyle(
                                            fontSize: 17,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            //Navigation to Signup
                            Consumer<AuthProvider>(
                              builder: (context, authProvider, child) {
                                return RichText(
                                  text: TextSpan(
                                    text: "Don't have an account? ",
                                    style: const TextStyle(
                                      fontSize: 17,
                                      color: Colors.white70,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Sign up free',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: authProvider.isLoading
                                              ? Colors.grey
                                              : Colors.blue,
                                        ),
                                        recognizer: authProvider.isLoading
                                            ? null
                                            : _signUpRecognizer,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            // Terms and Privacy
                            const Text(
                              'By continuing, you agree to our Terms and Privacy',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white60,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  //validate email fromat
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email address';
    }
    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  //validate password requirements
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }
}
