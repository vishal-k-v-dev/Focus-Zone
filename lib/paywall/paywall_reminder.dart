import 'package:flutter/material.dart';
import 'package:focus/free_limits.dart';
import 'paywall.dart';

class PaywallReminder extends StatefulWidget {
  final LimitationType limitationType;

  const PaywallReminder({super.key, required this.limitationType});

  @override
  State<PaywallReminder> createState() => _PaywallReminderState();
}

class _PaywallReminderState extends State<PaywallReminder> {
  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      onClosing: (){}, 
      backgroundColor: const Color.fromARGB(255, 35, 35, 35),
      builder: (context){
        return Container(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              getReminderScreen(widget.limitationType),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (){
                        Navigator.pop(context);
                      }, 
                      style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: Colors.transparent, side: BorderSide(color: Colors.grey, width: .7)),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(child: Text("Cancel", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                        ],
                      )
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const PayWall()));
                      }, 
                      style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: Colors.greenAccent),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(child: Text("Get Pro", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black))),
                        ],
                      )
                    ),
                  ),
                ],
              )
            ],
          )
        );
      }
    );
  }

  Widget getReminderScreen(LimitationType limitationType){
    if(limitationType == LimitationType.whitelistApps){
      return whitelistAppsReminder();
    }
    else if(limitationType == LimitationType.whitelistNotifications){
      return whitelistNotificationsReminder();
    }
    else{
      return blacklistAppsReminder();
    }
  }

  Widget whitelistAppsReminder(){
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: double.infinity),
        Row(
          children: [
            Expanded(child: Text("Limit reached", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            Icon(Icons.diamond_outlined, size: 20),
          ],
        ),
        SizedBox(height: 7.5),
        Divider(color: Colors.white),
        SizedBox(height: 7.5),
        Text("You can whitelist only ${FreeLimits.whitelistAppsLimit} apps in free version.", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 15),
        Text("Get focus zone pro and whitelist unlimited apps.", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
      ],
    );
  }

  Widget whitelistNotificationsReminder(){
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: double.infinity),
        Row(
          children: [
            Expanded(child: Text("Limit reached", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            Icon(Icons.diamond_outlined, size: 20),
          ],
        ),
        SizedBox(height: 7.5),
        Divider(color: Colors.white),
        SizedBox(height: 7.5),
        Text("You can whitelist only ${FreeLimits.whitelistNotificationsLimit} apps' notifications in free version.", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 15),
        Text("Get focus zone pro and whitelist unlimited apps' notifications.", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
      ],
    );
  }

  blacklistAppsReminder(){
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: double.infinity),
        Row(
          children: [
            Expanded(child: Text("Limit reached", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            Icon(Icons.diamond_outlined, size: 20),
          ],
        ),
        SizedBox(height: 7.5),
        Divider(color: Colors.white),
        SizedBox(height: 7.5),
        Text("You can blacklist only ${FreeLimits.blacklistAppsLimit} app in free version.", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 15),
        Text("Get focus zone pro and blacklist unlimited apps", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
      ],
    );
  }
}

enum LimitationType{
  whitelistApps,
  whitelistNotifications,
  breakSessions,
  breakDuration,
  blacklistApps,
}