import '../main.dart';
import '../widgets/widgets.dart';
import 'package:flutter/material.dart';
import '../free_limits.dart';
import '../paywall/paywall_reminder.dart';
import '../preferences.dart';

class WhitelistNotificationsSelector extends StatefulWidget {

  final Function onPop;

  const WhitelistNotificationsSelector({super.key, required this.onPop});

  @override
  WhitelistNotificationsSelectorState createState() => WhitelistNotificationsSelectorState();
}

class WhitelistNotificationsSelectorState extends State<WhitelistNotificationsSelector> {

  handleWhitelistNotifications(app){
    if (allowedNotifications.contains(app.packageName)) {
      allowedNotifications.remove(app.packageName);
    } else {
      allowedNotifications.add(app.packageName);
    }
    preferenceManager.setStringList(key: 'whitelist_app_notification_packages', value: allowedNotifications);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        widget.onPop();
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 16, 16, 16),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 18, right: 18, top: 10, bottom: 10),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Whitelist Notifications",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: .6),
                            ),
                          ),
                          GestureDetector(
                            onTap: (){Navigator.pop(context);},
                            child: const Icon(Icons.close)
                          )
                        ],
                      ),
                      const SizedBox(height: 15)
                    ],
                  ),
                ),
              ] +
              List.generate(
                appsList!.length,
                (index) {
                  var app = appsList![index];
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 18, right: 18, bottom: 25),
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
                              AppIcon(packageName: app.packageName),
                              const SizedBox(width: 12.5),
                              Expanded(child: Text(app.appName, style: const TextStyle(color: Colors.white))),
                              StatefulBuilder(
                                builder: (context, setState) {
                                  bool selected = allowedNotifications.contains(app.packageName);
                                  return Checkbox(
                                    value: selected,
                                    side: BorderSide(width: 1, color: Colors.grey),
                                    activeColor: Colors.white, checkColor: Colors.black,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    onChanged: (changedValue) {
                                      if (app.packageName == phonePackage) {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("This app must be whitelisted")));
                                      }
                                      else if(app.packageName == "com.android.settings"){
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("you can't whitelist this app")));
                                      }
                                      else{
                                        if(changedValue!){
                                          if(allowedNotifications.length < FreeLimits.whitelistNotificationsLimit || subscriptionManager.isProUser){
                                            handleWhitelistNotifications(app);
                                            setState((){});
                                          }
                                          else{
                                            showBottomSheet(context: context, builder: (context) => const PaywallReminder(limitationType: LimitationType.whitelistNotifications));
                                          }
                                        }
                                        if(!changedValue){
                                          handleWhitelistNotifications(app);
                                          setState((){});
                                        }
                                      }
                                    }
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              )
              //+
              //<Widget>[
              //  !subscriptionManager.isProUser ? Padding(
              //    padding: const EdgeInsets.only(left: 25, right: 25, top: 10, bottom: 10),
              //    child: NativeAdWidget(),
              //  ) :
              //  const SizedBox()
              //]
            ),
          ),
             
        ),
      ),
    );
  }
}