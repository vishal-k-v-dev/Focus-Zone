// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:usage_stats/usage_stats.dart';
import 'main.dart';
import 'dart:async';

class PermissionGetter extends StatefulWidget {
  const PermissionGetter({super.key});

  @override
  State<PermissionGetter> createState() => _PermissionGetterState();
}

class _PermissionGetterState extends State<PermissionGetter> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 24, 24, 24),
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Visibility(
                  visible: !permission1,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Display over other apps',
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          onPressed: () async{
                            PermissionStatus status = await Permission.systemAlertWindow.request();
                            if(status.isGranted){
                              setState(() {
                                permission1 = true;
                              });
                              if(permission1 && permission2 && permission3 && permission4){Navigator.pushNamed(context, '/');}
                            }                        
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Grant permission', style: TextStyle(fontSize: 17)),
                            ],
                          )
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Visibility(
                  visible: !permission2,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Usage access',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          onPressed: () async{
                            Timer.periodic(Duration(seconds: 1), (timer) async{
                              bool permissionGive = false;
                              permissionGive = await UsageStats.checkUsagePermission() ?? false;
                              if(permissionGive){
                                setState(() {
                                  permission2 = true;
                                });
                                if(permission1 && permission2 && permission3 && permission4){timer.cancel(); Navigator.pushNamed(context, '/');}
                                timer.cancel();
                              }
                            });
                            await UsageStats.grantUsagePermission();              
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Grant permission', style: TextStyle(fontSize: 17)),
                            ],
                          )
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Visibility(
                  visible: !permission3,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ignore battery optimization',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          onPressed: () async{
                            PermissionStatus status = await Permission.ignoreBatteryOptimizations.request();
                            if(status.isGranted){
                              setState(() {
                                permission3 = true;
                              });
                              if(permission1 && permission2 && permission3 && permission4){Navigator.pushNamed(context, '/');}
                            }
    
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Grant permission', style: TextStyle(fontSize: 17)),
                            ],
                          )
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Visibility(
                  visible: !permission4,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Accessibilty',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          onPressed: () async{
                            bool permissionGive = false;
                            Timer.periodic(Duration(seconds: 1), (timer) async{
                              permissionGive = await platform.invokeMethod("AccessibilityEnabled");
                              if(permissionGive){
                                permission4 = true;
                                if(permission1 && permission2 && permission3 && permission4){
                                  Navigator.pushNamed(context, '/');
                                  timer.cancel();
                                }
                                else{
                                  setState(() {                                  
                                  });                      
                                  timer.cancel();
                                }
                              }
                            });
    
                            await platform.invokeMethod("getPermission");                         
    
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Grant permission', style: TextStyle(fontSize: 17)),
                            ],
                          )
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),        
        ),
      ),
    );
  }
}