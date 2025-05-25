import 'package:flutter/material.dart';
import 'package:daisy_frontend/widgets/password_input_field.dart';
import 'package:daisy_frontend/widgets/input_error.dart';
import 'package:daisy_frontend/auth/service/auth_service.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? errorMessage;
  bool isLoading = false;

  void _submit() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final current = currentPasswordController.text;
    final newPass = newPasswordController.text;
    final confirm = confirmPasswordController.text;

    try {
      await AuthService.changePassword(current, newPass, confirm);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password changed successfully")),
      );
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst("Exception: ", "");
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            if (errorMessage != null) InputError(message: errorMessage!),
            PasswordInputField(
              controller: currentPasswordController,
              hintText: "Current Password",
              icon: Icons.lock,
            ),
            const SizedBox(height: 16),
            PasswordInputField(
              controller: newPasswordController,
              hintText: "New Password",
              icon: Icons.lock_outline,
            ),
            const SizedBox(height: 16),
            PasswordInputField(
              controller: confirmPasswordController,
              hintText: "Confirm New Password",
              icon: Icons.lock_outline,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : _submit,
              child:
                  isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Update Password"),
            ),
          ],
        ),
      ),
    );
  }
}
