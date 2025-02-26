// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:notification_listener_service/notification_listener_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:usage_stats/usage_stats.dart';
import 'dart:async';
import '../main.dart';
import 'permission_item.dart';

class PermissionGetter extends StatefulWidget {
  const PermissionGetter({super.key});

  @override
  State<PermissionGetter> createState() => _PermissionGetterState();
}

class _PermissionGetterState extends State<PermissionGetter> {

  void checkAllPermissions() {
    if (displayOverOtherApps && usageStats) {
      Navigator.pushNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 16, 16, 16),
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Permissions required", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 5),
                  
                  PermissionItem(
                    visible: !displayOverOtherApps,
                    title: 'Display over other apps',
                    onGrantPressed: () async {
                      PermissionStatus status = await Permission.systemAlertWindow.request();
                      if (status.isGranted) {
                        setState(() {
                          displayOverOtherApps = true;
                          checkAllPermissions();
                        });
                      }
                    },
                  ),

                  PermissionItem(
                    visible: !usageStats,
                    title: 'Usage access',
                    onGrantPressed: () async {
                      Timer.periodic(const Duration(seconds: 1), (timer) async {
                        bool permissionGranted = await UsageStats.checkUsagePermission() ?? false;
                        if (permissionGranted) {
                          setState(() {
                            usageStats = true;
                            checkAllPermissions();
                          });
                          timer.cancel();
                        }
                      });
                      await UsageStats.grantUsagePermission();
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
