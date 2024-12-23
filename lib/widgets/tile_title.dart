import 'package:flutter/material.dart';

class TileTitle extends StatefulWidget {

  final IconData icon;
  final String title;

  const TileTitle({super.key, required this.icon, required this.title});

  @override
  State<TileTitle> createState() => _TileTitleState();
}

class _TileTitleState extends State<TileTitle> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(widget.icon),
        const SizedBox(width: 15),
        Text(widget.title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
      ],
    );
  }
}