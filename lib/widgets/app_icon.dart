// ignore_for_file: must_be_immutable

import '../main.dart';
import "package:flutter/material.dart";

class AppIcon extends StatelessWidget {

  String packageName;

  AppIcon({super.key, required this.packageName});

  @override
  Widget build(BuildContext context) {
    var app = appsList?.firstWhere((app) => app.packageName == packageName);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: SizedBox(height: 25, width: 25, child: Image(image: MemoryImage(app.icon))),
    );
  }
}