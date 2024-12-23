// ignore_for_file: use_build_context_synchronously

import 'package:focus/pages/break_settings.dart';
import 'package:focus/pages/pages.dart';
import 'strictness_page.dart';
import '../main.dart';
import '../widgets/widgets.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../app_selectors/notification_app_selector.dart';
import '../app_selectors/whitelist_app_selector.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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

  int getStrictness(){
    int strictness = 0;

    if(removeExitButton){
      strictness++;
    }
    if(autoStart){
      strictness++;
    }
    if(deviceAdmin){
      strictness++;
    }
    return strictness;
  }

  @override
  Widget build(BuildContext context) {
    return 
       Column(
        children: [
          //Whitelist Apps
          CustomListTile(
            title: "Whitelist Apps",
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => WhiteListedAppsList())),
            subtitle: "${whitelistApps.length} ${whitelistApps.length == 1 ? "app" : "apps"}"
          ),


          const  SizedBox(height: 25),

          //Block Notifications    
          CustomListTile(
            title: "Whitelist Notifications",
            subtitle: "${whitelistNotifications.length} ${whitelistNotifications.length == 1 ? "app" : "apps"}",
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WhitelistedNotificationList()))
          ),

          const  SizedBox(height: 25),

          //Break Settings
          CustomListTile(
            title: "Breaks", 
            subtitle: breakSession == 0 ? "none" : "$breakSession x $breakDuration min", 
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BreakSettingsPage()))
          ),

          const  SizedBox(height: 25),

          //Break Settings
          CustomListTile(
            title: "Strictness", 
            subtitle: "${getStrictness()} / 3", 
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StrictnessPage()))
          ),
    
          // //Hide Exit Button
          // ToggleTile(
          //   title: "Remove exit button", 
          //   icon: Icons.exit_to_app, 
          //   initialValue: removeExitButton, 
          //   onChanged: (value) async{
          //     settingsPreferences.setBool('remove_exit_button', value);

          //     setState(() => removeExitButton = value);
          //     return removeExitButton;
          //   }
          // ),


          // //Auto start    
          // ToggleTile(
          //   title: "Auto Start", 
          //   icon: Icons.restart_alt, 
          //   initialValue: autoStart, 
          //   onChanged: (value) async{
          //     if (value) {
          //       bool accessibilityEnabled = await platform.invokeMethod('AccessibilityEnabled');
          //       if (!accessibilityEnabled) {
          //         showModalBottomSheet(
          //           context: context,
          //           builder: (context) => const AccessibilityWarning(),
          //         );
          //         return false;
          //       } 
          //       else{
          //         setState(() => autoStart = value);
          //         return true;
          //       }
          //     }
          //     else{
          //       setState(() => autoStart = value);
          //       return false;
          //     }
          //   }
          // ),


          // //Prevent Uninstall
          // SwitchListTile(
          //   title: const TileTitle(icon: Icons.delete_forever, title: "Prevent Uninstall"),
          //   contentPadding: const EdgeInsets.only(left: 12, right: 2),
          //   subtitle: deviceAdmin ? const Padding(padding: EdgeInsets.only(left: 39), child: Text("Disable to uninstall")) : null,
          //   value: deviceAdmin, activeColor: Colors.greenAccent,
          //   onChanged: (value) async{
          //     if (value) {
          //       if (!deviceAdmin) {
          //         showModalBottomSheet(
          //           context: context,
          //           builder: (context) => const DeviceAdminWarning(),
          //         );
          //       } 
          //       else{
          //         setState(() => deviceAdmin = value);
          //       }
          //     }
          //     else{
          //       setState(() => deviceAdmin = value);
          //       await platform.invokeMethod("RemovePermission");
          //     }
          //   }
          // ),
        ]
    //  ),
    );
  }
}