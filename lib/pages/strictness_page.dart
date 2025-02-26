// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import '../main.dart';
import '../widgets/widgets.dart';
import 'package:flutter/material.dart';
import '../permission/device_admin_warning.dart';
import '../permission/accessibility_warning.dart';
import '../preferences.dart';

class StrictnessPage extends StatefulWidget {
  const StrictnessPage({super.key});

  @override
  State<StrictnessPage> createState() => _StrictnessPageState();
}

class _StrictnessPageState extends State<StrictnessPage> {
  late Timer timer;
  
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
      const Duration(milliseconds: 250), 
      (timer) async{
                
        deviceAdmin = await platform.invokeMethod('DeiceAdminEnabled');   
        setState((){});
        
      }
    );
  }

  @override
  void dispose(){
    timer.cancel();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async{
        Navigator.push(context, MaterialPageRoute(builder: ((context) => const HomeScreen())));
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 16, 16, 16),
          body: Padding(
            padding: const EdgeInsets.only(left: 22, right: 22, top: 15, bottom: 15),
            child: Column(
              children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Strictness",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: .6),
                    ),
                  ),
                  GestureDetector(
                    onTap: (){Navigator.pop(context);},
                    child: const Icon(Icons.close)
                  )
                ],
              ),

              const SizedBox(height: 25),
              
              //Hide Exit Button
              ToggleTile(
                title: "Disable exiting", 
                icon: Icons.exit_to_app, 
                initialValue: removeExitButton, 
                onChanged: (value) async{
                  preferenceManager.setBool(key: 'remove_exit_button', value: value);
          
                  setState(() => removeExitButton = value);
                  return removeExitButton;
                }
              ),
          
              const SizedBox(height: 25),
    
              //Auto start    
              ToggleTile(
                title: "Auto Start", 
                icon: Icons.restart_alt, 
                initialValue: autoStart, 
                onChanged: (value) async{
                  if(value) {
                    bool accessibilityEnabled = await platform.invokeMethod('AccessibilityEnabled');
                    if (!accessibilityEnabled) {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => const AccessibilityWarning(),
                      );
                      return false;
                    } 
                    else{
                      setState(() => autoStart = value);
                      return true;
                    }
                  }
                  else{
                    setState(() => autoStart = value);
                    preferenceManager.setBool(key: "auto_start", value: false);
                    return false;
                  }
                }
              ),
          
              const SizedBox(height: 25),
    
              //Prevent Uninstall
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                  )
                ).copyWith(
                  overlayColor: MaterialStateProperty.resolveWith(
                    (states){
                      if(states.contains(MaterialState.pressed)){
                        return Colors.grey.withOpacity(.3);
                      }
                      return null;
                    }
                  )
                ),

                onPressed: () async{
                  bool value = !deviceAdmin;

                  if (value) {
                    if (!deviceAdmin) {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => const DeviceAdminWarning(),
                      );
                    }
                    else{
                      setState(() => deviceAdmin = value);
                    }
                  }

                  else{
                    setState(() => deviceAdmin = value);
                    await platform.invokeMethod("RemovePermission");
                  }
                },

                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: .7),
                    //color: const Color.fromARGB(255, 30, 30, 30),
                    borderRadius: BorderRadius.circular(10)
                  ),
                  padding: const EdgeInsets.only(
                    left: 10, top: 14, bottom: 14
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Prevent uninstall",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: .6
                          )
                        ),
                      ),
                      Switch(
                        value: deviceAdmin, 
                        activeColor: Colors.greenAccent,
                        onChanged: (value) async{
                          if (value) {
                            if (!deviceAdmin) {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => const DeviceAdminWarning(),
                              );
                            } 
                            else{
                              setState(() => deviceAdmin = value);
                            }
                          }
                          else{
                            setState(() => deviceAdmin = value);
                            await platform.invokeMethod("RemovePermission");
                          }
                        }
                      ),
                    ],
                  ),
                ),
              )
            ])
          )
        )
      ),
    );
  }
}