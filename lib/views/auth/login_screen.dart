import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roamly_app/core/providers/auth_provider.dart';
import 'package:roamly_app/core/services/secure_storage.dart';

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
  static const double _topSpacing = 70;
  static const double _logoSpacing = 40;
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
    // Navigator.of(
    //   context,
    // ).pushReplacement(MaterialPageRoute(builder: (context) => SignupPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //// SafeArea prevents overlap with system UI
      body: SafeArea(
        //prevents overflow
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            //Wraps input fields for validation.
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: _topSpacing),
                // TODO: Add your app logo here
                // Image.asset('assets/images/logo.png', height: 100),
                const SizedBox(height: _logoSpacing),

                Text(
                  'LOGIN',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 32),

                // Email Input Field
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _fieldWidth),
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        enabled: !authProvider.isLoading,
                        validator: _validateEmail,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Email',
                          hintText: 'Enter Your Email',
                          prefixIcon: Icon(Icons.email_rounded),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: _fieldSpacing),

                // Password Input Field
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: _fieldWidth),
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return TextFormField(
                        controller: _passwordController,
                        obscureText: _isPasswordHidden,
                        textInputAction: TextInputAction.done,
                        // is a property of TextFormField that controls whether the user can interact with the input field
                        enabled: !authProvider.isLoading,
                        //onFieldSubmitted is a callback function that gets triggered when the user presses the action button on the keyboard (in this case, the "Done" button).
                        onFieldSubmitted: (_) => _handleLogin(),
                        validator: _validatePassword,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Password',
                          hintText: 'Enter Your Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _isPasswordHidden = !_isPasswordHidden;
                              });
                            },
                            icon: Icon(
                              _isPasswordHidden
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Forgot Password
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _fieldWidth),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return TextButton(
                          onPressed: authProvider.isLoading
                              ? null
                              : _navigateToForgotPassword,
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Login Button
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _fieldWidth),
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            disabledBackgroundColor: Colors.grey.shade400,
                          ),
                          onPressed: authProvider.isLoading
                              ? null
                              : _handleLogin,
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'LOGIN',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                //Navigation to Signup
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: _fieldWidth),
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return RichText(
                        text: TextSpan(
                          text: "Don't have an account?",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[700],
                          ),
                          children: [
                            TextSpan(
                              text: 'Sign Up',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: authProvider.isLoading
                                    ? Colors.grey
                                    : Colors.deepPurple,
                                decoration: TextDecoration.underline,
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
                ),
              ],
            ),
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
