import '../ads.dart';
import '../main.dart';
import '../widgets/widgets.dart';
import 'package:flutter/material.dart';
import '../free_limits.dart';
import '../paywall/paywall_reminder.dart';

class WhitelistedNotificationList extends StatefulWidget {
  const WhitelistedNotificationList({super.key});

  @override
  State<WhitelistedNotificationList> createState() => _WhitelistedNotificationListState();
}

class _WhitelistedNotificationListState extends State<WhitelistedNotificationList> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 16, 16, 16),
        floatingActionButton: FloatingActionButton.small(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => BlockNotifications(onPop: () => setState((){})))), //onStartPress, 
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
                whitelistNotifications.length, 
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
                          AppIcon(packageName: whitelistNotifications[index]),
                          const SizedBox(width: 12.5),
                          Expanded(
                            child: Text(
                              appsList!.firstWhere((element) => element.packageName == whitelistNotifications[index]).appName,
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



class BlockNotifications extends StatefulWidget {

  final Function onPop;

  const BlockNotifications({super.key, required this.onPop});

  @override
  BlockNotificationsState createState() => BlockNotificationsState();
}

class BlockNotificationsState extends State<BlockNotifications> {

  handleWhitelistNotifications(app){
    if (whitelistNotifications.contains(app.packageName)) {
      whitelistNotifications.remove(app.packageName);
    } else {
      whitelistNotifications.add(app.packageName);
    }
    settingsPreferences.setStringList('whitelist_app_notification_packages', whitelistNotifications);
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
                  padding: const EdgeInsets.only(left: 24, right: 24, top: 10, bottom: 10),
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
                        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 25),
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
                                  bool selected = whitelistNotifications.contains(app.packageName);
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
                                          if(whitelistNotifications.length < FreeLimits.whitelistNotificationsLimit || subscriptionManager.isProUser){
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