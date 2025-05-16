import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:properties/core/utils/colors.dart';
import 'package:properties/core/utils/styles.dart';
import 'package:properties/features/auth/data/services/auth_service.dart';
import 'package:properties/features/auth/presentation/widgets/custom_button.dart';
import 'package:properties/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:properties/features/auth/presentation/view/signup_screen.dart';
import 'package:properties/features/home/presentation/view/tenant_home.dart';
import 'package:properties/features/home/presentation/view/owner_home.dart';
import 'package:properties/features/home/presentation/view/manager_tenant.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  String _selectedUserType = 'Tenant';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateBasedOnRole(String? userType) {
    if (!mounted) return;

    Widget homeScreen;
    switch (userType) {
      case 'Tenant':
        homeScreen = const TenantHomeScreen();
        break;
      case 'Owner':
        homeScreen = const OwnerHomeScreen();
        break;
      case 'Manager':
        homeScreen = const ManagerTenantScreen();
        break;
      default:
        // Handle unknown user type
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid user type')),
        );
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => homeScreen),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final result = await _authService.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (mounted) {
          _navigateBasedOnRole(result['userType']);
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

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.signInWithGoogle(
        userType: _selectedUserType,
      );

      if (mounted) {
        _navigateBasedOnRole(result['userType']);
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

  void _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address')),
      );
      return;
    }

    try {
      await _authService.resetPassword(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );
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
                  'Welcome Back',
                  style: AppStyles.headingLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to continue to PropertyPro',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Password',
                      style: AppStyles.bodyMedium,
                    ),
                    TextButton(
                      onPressed: _handleForgotPassword,
                      child: const Text(
                        'Forgot Password?',
                        style: AppStyles.linkStyle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  hintText: 'Enter your password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
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

                // Login button
                CustomButton(
                  text: 'Sign In',
                  onPressed: _handleLogin,
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
                        'Or continue with',
                        style: TextStyle(color: AppColors.textSecondaryColor),
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),

                // Google sign in
                SocialButton(
                  text: 'Sign in with Google',
                  onPressed: _handleGoogleSignIn,
                  icon: SvgPicture.asset(
                    'assets/images/google_logo.svg',
                    height: 24,
                    width: 24,
                  ),
                ),
                const SizedBox(height: 24),

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don\'t have an account?',
                      style: AppStyles.bodyMedium,
                    ),
                    TextButton(
                      onPressed: _navigateToSignUp,
                      child: const Text(
                        'Sign Up',
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
