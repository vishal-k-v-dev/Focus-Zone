import '../main.dart';
import '../widgets/widgets.dart';
import '../permission/device_admin_warning.dart';
import '../permission/accessibility_warning.dart';
import 'package:flutter/material.dart';

class StrictnessPage extends StatefulWidget {
  const StrictnessPage({super.key});

  @override
  State<StrictnessPage> createState() => _StrictnessPageState();
}

class _StrictnessPageState extends State<StrictnessPage> {
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
                title: "Remove exit button", 
                icon: Icons.exit_to_app, 
                initialValue: removeExitButton, 
                onChanged: (value) async{
                  settingsPreferences.setBool('remove_exit_button', value);
          
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
                  if (value) {
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
                    return false;
                  }
                }
              ),
          
              const SizedBox(height: 25),
    
              //Prevent Uninstall
              Container(
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
              )
            ])
          )
        )
      ),
    );
  }
}