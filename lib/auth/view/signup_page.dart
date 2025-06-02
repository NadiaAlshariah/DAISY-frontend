import 'package:flutter/material.dart';
import 'package:daisy_frontend/widgets/password_input_field.dart';
import 'package:daisy_frontend/widgets/auth_input_field.dart';
import 'package:daisy_frontend/widgets/input_error.dart';
import 'package:daisy_frontend/auth/service/auth_service.dart';
import 'package:daisy_frontend/auth/view/login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? errorMessage;
  bool isLoading = false;

  void _signup() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await AuthService.signup(
        email: emailController.text.trim(),
        username: usernameController.text.trim(),
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('error: ', '');
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ListView(
            children: [
              const SizedBox(height: 24.0),
              Center(
                child: Image.asset(
                  "assets/images/logo.png",
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              Text(
                'Create New Account',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 32.0,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),

              if (errorMessage != null) InputError(message: errorMessage!),
              const SizedBox(height: 16.0),

              AuthInputField(
                controller: usernameController,
                hintText: 'Username',
                icon: Icons.person,
              ),
              const SizedBox(height: 16.0),

              AuthInputField(
                controller: emailController,
                hintText: 'Email',
                icon: Icons.email,
              ),
              const SizedBox(height: 16.0),

              PasswordInputField(
                controller: passwordController,
                hintText: 'Password',
                icon: Icons.lock,
              ),
              const SizedBox(height: 16.0),

              PasswordInputField(
                controller: confirmPasswordController,
                hintText: 'Confirm Password',
                icon: Icons.lock,
              ),
              const SizedBox(height: 24.0),

              SizedBox(
                height: 56.0,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child:
                      isLoading
                          ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          )
                          : const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?'),
                  TextButton(
                    onPressed:
                        () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        ),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
