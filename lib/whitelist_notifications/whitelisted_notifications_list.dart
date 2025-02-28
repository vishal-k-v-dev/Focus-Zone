import '../main.dart';
import '../widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'whitelisted_notifications_selector.dart';

class WhitelistedNotificationsList extends StatefulWidget {
  const WhitelistedNotificationsList({super.key});

  @override
  State<WhitelistedNotificationsList> createState() => _WhitelistedNotificationsListState();
}

class _WhitelistedNotificationsListState extends State<WhitelistedNotificationsList> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 16, 16, 16),
        floatingActionButton: FloatingActionButton.small(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => WhitelistNotificationsSelector(onPop: () => setState((){})))), //onStartPress, 
          backgroundColor: Colors.greenAccent,
          child: const Icon(Icons.edit)
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
              [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Whitelisted Notifications",
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
              ] 
              +
              List.generate(
                allowedNotifications.length, 
                (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: .7),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      padding: const EdgeInsets.only(
                        left: 10, right: 4, top: 14, bottom: 14
                      ),
                      child: Row(
                        children: [
                          AppIcon(packageName: allowedNotifications[index]),
                          const SizedBox(width: 12.5),
                          Expanded(
                            child: Text(
                              appsList!.firstWhere((element) => element.packageName == allowedNotifications[index]).appName,
                              style: const TextStyle(color: Colors.white)
                            )
                          ),
                          const SizedBox(width: 5)
                        ],
                      )
                    ),
                  );
                }
              )
              +
              [
                SizedBox(height: MediaQuery.of(context).size.height/100*25)
              ]
            ),
          ),
        )
      ),
    );
  }
}