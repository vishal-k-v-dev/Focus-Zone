// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'break_settings.dart';
import '../main.dart';
import '../widgets/widgets.dart';
import 'package:flutter/material.dart';
import '../whitelist_notifications/whitelisted_notifications_list.dart';
import '../whitelist_apps/whitelisted_apps_list.dart';
import '../youtube_videos/yt_videos.dart';
import '../preferences.dart';
import '../permission/device_admin_warning.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import '../permission/notification_access_warning.dart';

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //Whitelist Apps
        CustomListTile(
          title: "Whitelist Apps",
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => WhiteListedAppsList())),
          subtitle: "${allowedApps.length} ${allowedApps.length == 1 ? "app" : "apps"}"
        ),

        const  SizedBox(height: 25),

        CustomListTile(
          title: "Youtube Videos", 
          subtitle: "${youtubeVideosID.length} ${youtubeVideosID.length == 1 ? "video" : "videos"}", 
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AllowYTVideos()))
        ),

        const  SizedBox(height: 25),

        CustomListTile(
          title: "Exit Option", 
          subtitle: "${removeExitButton ? "Disabled" : "Enabled"}", 
          onTap: (){
            setState(() => removeExitButton = !removeExitButton);
            preferenceManager.setBool(key: 'remove_exit_button', value: removeExitButton);
          }
        ),

        const  SizedBox(height: 25),

        CustomListTile(
          title: "Prevent Uninstall", 
          subtitle: deviceAdmin ? "Enabled" : "Disabled", 
          onTap: () async{
            if(!deviceAdmin){
              showModalBottomSheet(
                context: context,
                builder: (context) => const DeviceAdminWarning(),
              );
            }
            else{
              platform.invokeMethod("RemovePermission");
            }
          }
        ),

        const  SizedBox(height: 25),

        const Row(
          children: [
            Expanded(
              child: Text(
                "Notifications",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: .6),
              ),
            ),
            Icon(Icons.notifications, size: 22)
          ],
        ),

        const  SizedBox(height: 25),

        CustomListTile(
          title: "Block Notifications",
          subtitle: blockNotifications ? "blocked" : "Not blocked",
          onTap: () async{
            if(await NotificationListenerService.isPermissionGranted() == false){
              showModalBottomSheet(
                context: context, 
                builder: (context){
                  return NotificationAccessWarning();
                }
              );
            }
            else{
              setState((){
                blockNotifications = !blockNotifications;
              });
              preferenceManager.setBool(key: 'block_notifications', value: blockNotifications);
            }
          }
        ),

        const  SizedBox(height: 25),

        //Block Notifications    
        CustomListTile(
          title: "Whitelist Notifications",
          subtitle: "${allowedNotifications.length} ${allowedNotifications.length == 1 ? "app" : "apps"}",
          disabled: !blockNotifications,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WhitelistedNotificationsList()))
        ),

        const  SizedBox(height: 25),

        const Row(
          children: [
            Expanded(
              child: Text(
                "Breaks",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: .6),
              ),
            ),
            Icon(Icons.pause_circle_outline, size: 22)
          ],
        ),
        
        const  SizedBox(height: 25),

        const BreakSettingsPage(),

        const  SizedBox(height: 25),
      ]
    );
  }
}