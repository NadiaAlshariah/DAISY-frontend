import 'package:flutter/material.dart';
import 'package:daisy_frontend/auth/service/auth_service.dart';
import 'package:daisy_frontend/views/settings/change_password_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _handleLogout(BuildContext context) async {
    await AuthService.logout();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _handleChangePassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Change Password'),
              onTap: () => _handleChangePassword(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => _handleLogout(context),
            ),
          ],
        ),
      ),
    );
  }
}
