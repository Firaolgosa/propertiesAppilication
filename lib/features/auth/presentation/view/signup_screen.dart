import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:properties/core/utils/colors.dart';
import 'package:properties/core/utils/styles.dart';
import 'package:properties/features/auth/data/services/auth_service.dart';
import 'package:properties/features/auth/presentation/widgets/custom_button.dart';
import 'package:properties/features/auth/presentation/widgets/custom_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  String _selectedUserType = 'Tenant';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        await _authService.signUpWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          name: _nameController.text.trim(),
          userType: _selectedUserType,
        );

        if (mounted) {
          // TODO: Replace with your home screen route
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => const HomeScreen()),
          // );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created successfully!')),
          );
          Navigator.pop(context); // Go back to login screen
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _handleGoogleSignUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signInWithGoogle();

      if (mounted) {
        // TODO: Replace with your home screen route
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => const HomeScreen()),
        // );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google sign up successful!')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToLogin() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Header
                const Text(
                  'Create Account',
                  style: AppStyles.headingLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Join PropertyPro today',
                  style: AppStyles.bodyMedium,
                ),
                const SizedBox(height: 40),

                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),

                // Full Name field
                const Text(
                  'Full Name',
                  style: AppStyles.bodyMedium,
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  hintText: 'Enter your full name',
                  prefixIcon: Icons.person_outline,
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Email field
                const Text(
                  'Email',
                  style: AppStyles.bodyMedium,
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  hintText: 'Enter your email',
                  prefixIcon: Icons.email_outlined,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password field
                const Text(
                  'Password',
                  style: AppStyles.bodyMedium,
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  hintText: 'Create a password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  controller: _passwordController,
                  helperText: 'Password must be at least 8 characters long',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // User type selection
                const Text(
                  'I am a:',
                  style: AppStyles.bodyMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildUserTypeButton('Tenant'),
                    const SizedBox(width: 12),
                    _buildUserTypeButton('Manager'),
                    const SizedBox(width: 12),
                    _buildUserTypeButton('Owner'),
                  ],
                ),
                const SizedBox(height: 32),

                // Create Account button
                CustomButton(
                  text: 'Create Account',
                  onPressed: _handleSignup,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 24),

                // Divider
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Or sign up with',
                        style: TextStyle(color: AppColors.textSecondaryColor),
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),

                // Google sign up
                SocialButton(
                  text: 'Sign up with Google',
                  onPressed: _handleGoogleSignUp,
                  icon: SvgPicture.asset(
                    'assets/images/google_logo.svg',
                    height: 24,
                    width: 24,
                  ),
                ),
                const SizedBox(height: 24),

                // Sign in link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: AppStyles.bodyMedium,
                    ),
                    TextButton(
                      onPressed: _navigateToLogin,
                      child: const Text(
                        'Sign In',
                        style: AppStyles.linkStyle,
                      ),
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

  Widget _buildUserTypeButton(String userType) {
    final isSelected = _selectedUserType == userType;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedUserType = userType;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  isSelected ? AppColors.primaryColor : AppColors.dividerColor,
            ),
          ),
          child: Center(
            child: Text(
              userType,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
