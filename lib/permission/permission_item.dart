import 'package:flutter/material.dart';

class PermissionItem extends StatelessWidget {
  final bool visible;
  final String title;
  final VoidCallback onGrantPressed;

  const PermissionItem({
    required this.visible,
    required this.title,
    required this.onGrantPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextButton(
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          onPressed: onGrantPressed,
          child: const Text('Grant permission', style: TextStyle(fontSize: 17, color: Colors.greenAccent)),
        ),
        const Divider(color: Colors.grey),
        const SizedBox(height: 5),
      ],
    );
  }
}
