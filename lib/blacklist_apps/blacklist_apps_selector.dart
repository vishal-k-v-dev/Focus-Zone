import '../main.dart';
import '../widgets/widgets.dart';
import 'package:flutter/material.dart';
import '../free_limits.dart';
import '../paywall/paywall_reminder.dart';
import '../preferences.dart';

class BlacklistAppSelector extends StatefulWidget {
  final Function onPop;

  const BlacklistAppSelector({super.key, required this.onPop});

  @override
  BlacklistAppSelectorState createState() => BlacklistAppSelectorState();
}

class BlacklistAppSelectorState extends State<BlacklistAppSelector> {

  handleblacklistApps(app){
    
    if (blacklistedApps.contains(app.packageName)) {
      blacklistedApps.remove(app.packageName);
    } else {
      blacklistedApps.add(app.packageName);
    }

    preferenceManager.setStringList(key: 'blacklisted_apps', value: blacklistedApps);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.onPop();
        Navigator.pop(context);
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
                              "Blacklist Apps",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: .6),
                            ),
                          ),
                          GestureDetector(
                            onTap: (){
                              widget.onPop();
                              Navigator.pop(context);
                            },
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
                                  bool selected = blacklistedApps.contains(app.packageName);
                                  return Checkbox(
                                    value: selected,
                                    activeColor: Colors.white, checkColor: Colors.black,
                                    onChanged: (changedValue) {
                                      if (app.packageName == phonePackage) {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("This app can not be blacklisted")));
                                      }
                                      else if(app.packageName == "com.android.settings"){
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("This app must be blacklisted")));
                                      }
                                      else{
                                        if(changedValue!){
                                          if(blacklistedApps.length < FreeLimits.blacklistAppsLimit || subscriptionManager.isProUser){
                                            handleblacklistApps(app);
                                            setState((){});
                                          }
                                          else{
                                            showBottomSheet(
                                              context: context,
                                              backgroundColor: const Color.fromARGB(255, 30, 30, 30),
                                              builder: (context) => const PaywallReminder(limitationType: LimitationType.blacklistApps)
                                            );
                                          }
                                        }
                                        if(!changedValue){
                                          handleblacklistApps(app);
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
            ),
          ),
             
        ),
      ),
    );
  }
}