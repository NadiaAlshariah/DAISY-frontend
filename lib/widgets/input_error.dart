import 'package:flutter/material.dart';

class InputError extends StatelessWidget {
  final String message;

  const InputError({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha((255 * 0.1).round()),
        border: Border.all(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
                fontSize: 14.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
