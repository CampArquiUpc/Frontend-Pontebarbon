import 'package:flutter/material.dart';
import 'package:pontebarbon/services/database_helper.dart';
import 'package:pontebarbon/screens/home_page.dart';
import 'package:pontebarbon/providers/user_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Text controllers for the input fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Loading state
  bool _isLoading = false;

  // Database helper instance
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    // Initialize the database and insert a test user if it doesn't exist
    _initDatabase();
  }

  // Initialize database and insert a test user
  Future<void> _initDatabase() async {
    await _databaseHelper.initDatabase();
    // Check if any users exist, if not insert a test user
    final users = await _databaseHelper.getUsers();
    if (users.isEmpty) {
      await _databaseHelper.insertUser({
        'email': 'test@example.com',
        'password': 'password123',
      });
    }
  }

  // Handle login process
  Future<void> _login() async {
    // Validate form
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Check credentials against the database
        final isValid = await _databaseHelper.validateUser(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (!mounted) return; // Check if still mounted after async operation

        if (isValid) {
          final email = _emailController.text.trim();

          // Get user provider
          final userProvider = Provider.of<UserProvider>(context, listen: false);

          // Load all user data including monthly budget
          await userProvider.loadUser(email);

          if (!mounted) return; // Check after another async operation

          // Show welcome message
          if (userProvider.fullName != null && userProvider.fullName!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Welcome back, ${userProvider.fullName}!'),
                backgroundColor: Colors.green,
              ),
            );
          }

          // Navigate to home page
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        } else {
          // Show error for invalid credentials
          _showErrorSnackBar('Invalid email or password');
        }
      } catch (e) {
        if (!mounted) return; // Safety check
        _showErrorSnackBar('An error occurred: ${e.toString()}');
      } finally {
        if (mounted) { // Safety check
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  // Show error message in a snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    // Clean up controllers
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),

                // Logo
                Image.asset(
                  'lib/assets/images/Logo_PonteBarbon.png',
                  height: 120,
                ),

                const SizedBox(height: 32),

                // Email field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Buttons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Forgot password button
                    TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password functionality
                      },
                      child: const Text('Forgot password?'),
                    ),

                    // Login button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                          : const Text('Log In'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
