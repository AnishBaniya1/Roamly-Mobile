import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roamly_app/core/providers/auth_provider.dart';
import 'package:roamly_app/views/auth/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;
  late final TapGestureRecognizer _loginRecognizer;
  String __selectedRole = 'USER';

  // Constants for better maintainability
  static const double _fieldSpacing = 15;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _loginRecognizer = TapGestureRecognizer()..onTap = _navigateToLogin;
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _loginRecognizer.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    final authProvider = context.read<AuthProvider>();

    try {
      await authProvider.register(
        name: _usernameController.text,
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: __selectedRole,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User registered successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Signup failed: ${authProvider.errorMessage ?? e.toString()}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A), // slate-900
              Color(0xFF1E3A8A), // blue-900
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 60),

                            // Title
                            const Text(
                              'Join Roamly',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Create your account',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Signup Container
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Color.fromARGB(
                                  255,
                                  80,
                                  92,
                                  127,
                                ), // indigo-900
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                children: [
                                  // Name Field
                                  Consumer<AuthProvider>(
                                    builder: (context, authProvider, child) {
                                      return TextFormField(
                                        controller: _usernameController,
                                        textInputAction: TextInputAction.next,
                                        enabled: !authProvider.isLoading,
                                        validator: _validateName,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                        ),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          hintText: 'Name',
                                          hintStyle: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
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

                                  // Email Field
                                  Consumer<AuthProvider>(
                                    builder: (context, authProvider, child) {
                                      return TextFormField(
                                        controller: _emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        enabled: !authProvider.isLoading,
                                        validator: _validateEmail,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                        ),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          hintText: 'Email',
                                          hintStyle: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
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

                                  // Password Field
                                  Consumer<AuthProvider>(
                                    builder: (context, authProvider, child) {
                                      return TextFormField(
                                        controller: _passwordController,
                                        obscureText: _isPasswordHidden,
                                        textInputAction: TextInputAction.next,
                                        enabled: !authProvider.isLoading,
                                        validator: _validatePassword,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                        ),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          hintText: 'Password',
                                          hintStyle: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
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
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: _fieldSpacing),

                                  // Confirm Password Field
                                  Consumer<AuthProvider>(
                                    builder: (context, authProvider, child) {
                                      return TextFormField(
                                        controller: _confirmPasswordController,
                                        obscureText: _isConfirmPasswordHidden,
                                        textInputAction: TextInputAction.done,
                                        enabled: !authProvider.isLoading,
                                        onFieldSubmitted: (_) =>
                                            _handleSignup(),
                                        validator: _validateConfirmPassword,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                        ),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          hintText: 'Confirm Password',
                                          hintStyle: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 16,
                                              ),
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _isConfirmPasswordHidden =
                                                    !_isConfirmPasswordHidden;
                                              });
                                            },
                                            icon: Icon(
                                              _isConfirmPasswordHidden
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: _fieldSpacing),
                                  //role field
                                  Consumer<AuthProvider>(
                                    builder: (context, authProvider, child) {
                                      return DropdownButtonFormField<String>(
                                        initialValue: __selectedRole,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 16,
                                              ),
                                        ),
                                        dropdownColor: Colors.white,
                                        style: TextStyle(
                                          color: Colors.grey.shade800,
                                          fontSize: 16,
                                        ),
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                          color: Colors.grey.shade700,
                                        ),
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'USER',
                                            child: Text('USER'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'BUSINESS',
                                            child: Text('BUSINESS'),
                                          ),
                                        ],
                                        onChanged: authProvider.isLoading
                                            ? null
                                            : (String? newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    __selectedRole = newValue;
                                                  });
                                                }
                                              },
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 24),

                                  // Create Account Button
                                  Consumer<AuthProvider>(
                                    builder: (context, authProvider, child) {
                                      return SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF5C6BC0,
                                            ), // blue-900
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            disabledBackgroundColor:
                                                Colors.grey.shade400,
                                            elevation: 4,
                                          ),
                                          onPressed: authProvider.isLoading
                                              ? null
                                              : _handleSignup,
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
                                                  'Create Account',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Already have account
                            Consumer<AuthProvider>(
                              builder: (context, authProvider, child) {
                                return RichText(
                                  text: TextSpan(
                                    text: "Already have an account? ",
                                    style: const TextStyle(
                                      fontSize: 17,
                                      color: Colors.white70,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Sign in',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: authProvider.isLoading
                                              ? Colors.grey
                                              : Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: authProvider.isLoading
                                            ? null
                                            : _loginRecognizer,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const Spacer(),
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

  //validate Name format
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please Enter a Username';
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

  //validate confirm password
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }
}
