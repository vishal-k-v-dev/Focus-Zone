import 'package:focus/free_limits.dart';
import 'package:focus/main.dart';
import '../widgets/widgets.dart';
import 'package:flutter/material.dart';
import '../paywall/paywall_reminder.dart';
import '../preferences.dart';

class WhitelistAppsSelector extends StatefulWidget {
  final Function onPop;

  const WhitelistAppsSelector({super.key, required this.onPop});

  @override
  _WhitelistAppsSelectorState createState() => _WhitelistAppsSelectorState();
}

class _WhitelistAppsSelectorState extends State<WhitelistAppsSelector> {

  handleWhitelistApps(app){
    if(allowedApps.contains(app.packageName)) {
      durationLimits.removeAt(allowedApps.indexOf(app.packageName));
      allowedApps.remove(app.packageName);
      allowedAppNames.remove(app.appName);

    } else {
      durationLimits.add(0);
      allowedApps.add(app.packageName);
      allowedAppNames.add(app.appName);
    }
  
    preferenceManager.setStringList(key: 'whitelisted_app_packages', value: allowedApps);
    preferenceManager.setStringList(key: 'whitelisted_app_names', value: allowedAppNames);
    preferenceManager.setIntList(key: 'whitelisted_app_usage_limits', value: durationLimits);
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
              children: <Widget> [
                Padding(
                  padding: const EdgeInsets.only(left: 18, right: 18, top: 10, bottom: 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Whitelist Apps",
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
                                  bool selected = allowedApps.contains(app.packageName);
                                  return Checkbox(
                                    value: selected,
                                    side: const BorderSide(width: 1, color: Colors.grey),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    activeColor: Colors.white, checkColor: Colors.black,
                                    onChanged: (changedValue) {
                                      if (app.packageName == phonePackage) {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("This app must be whitelisted")));
                                      }
                                      else if(app.packageName == "com.android.settings"){
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("you can't whitelist this app")));
                                      }
                                      else{
                                        if(changedValue!){
                                          if(allowedApps.length < FreeLimits.whitelistAppsLimit || subscriptionManager.isProUser){
                                            handleWhitelistApps(app);
                                            setState((){});
                                          }
                                          else{
                                            showBottomSheet(context: context, builder: (context) => const PaywallReminder(limitationType: LimitationType.whitelistApps));
                                          }
                                        }
                                        if(!changedValue){
                                          handleWhitelistApps(app);
                                          setState((){});
                                        }
                                      }
                                    },
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