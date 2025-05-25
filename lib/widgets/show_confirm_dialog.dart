import 'package:flutter/material.dart';

Future<bool?> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String cancelText = 'Cancel',
  String confirmText = 'Confirm',
}) {
  return showDialog<bool>(
    context: context,
    builder:
        (_) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(cancelText),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(confirmText),
            ),
          ],
        ),
  );
}
