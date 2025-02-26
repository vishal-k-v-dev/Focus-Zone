import 'package:focus/main.dart';
import 'package:flutter/material.dart';
import 'package:notification_listener_service/notification_listener_service.dart';

class NotificationAccessWarning extends StatefulWidget {
  const NotificationAccessWarning({super.key});

  @override
  State<NotificationAccessWarning> createState() => _NotificationAccessWarningState();
}

class _NotificationAccessWarningState extends State<NotificationAccessWarning> {

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      onClosing: (){}, 
      backgroundColor: const Color.fromARGB(255, 20, 20, 20),
      builder: (context){
        return Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              const Text("Notification Access Permission", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              const Divider(color: Colors.grey),
              const SizedBox(height: 4),
              const Text("Notification Access Permission is used to block notifications during focus Session. Whitelisted apps' notifications will not be blocked. \n\nWe do not read/save your notifications.", style: TextStyle(fontSize: 14, height: 1.5)),
              const SizedBox(height: 5),
              const Divider(color: Colors.grey),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: (){
                      Navigator.pop(context);
                    }, 
                    child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.bold))
                  ),
                  GestureDetector(
                    onTap: () async{
                      Navigator.pop(context);
                      await NotificationListenerService.requestPermission();
                    }, 
                    child: const Text("Grant Permission", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold))
                  ),
                ],
              )
            ],
          ),
        );
      }
    );
  }
}