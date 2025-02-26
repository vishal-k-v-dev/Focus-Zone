import 'package:focus/free_limits.dart';
import 'package:focus/main.dart';
import '../widgets/widgets.dart';
import '../widgets/time_limit_input.dart';
import 'package:flutter/material.dart';
import '../paywall/paywall_reminder.dart';
import '../preferences.dart';


class WhiteListedAppsList extends StatefulWidget {
  const WhiteListedAppsList({super.key});

  @override
  State<WhiteListedAppsList> createState() => _WhiteListedAppsListState();
}

class _WhiteListedAppsListState extends State<WhiteListedAppsList> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 16, 16, 16),
        floatingActionButton: FloatingActionButton.small(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AppListScreen(onPop: () => setState((){})))),
          backgroundColor: Colors.greenAccent,
          child: const Icon(Icons.edit)
        ),

        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          child: SingleChildScrollView(
            child: Column(
              children: 
              <Widget>[
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Whitelisted Apps",
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
              <Widget> [
                Container(
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
                      AppIcon(packageName: phonePackage),
                      const SizedBox(width: 12.5),
                      Expanded(
                        child: Text(
                          appsList!.firstWhere((element) => element.packageName == phonePackage).appName,
                          style: const TextStyle(color: Colors.white)
                        )
                      ),
                      const SizedBox(width: 5)
                    ],
                  )
                ),
                const SizedBox(height: 20)
              ]
              +
              List.generate(
                allowedApps.length, 
                (index) {
                  if(allowedApps[index] == phonePackage){
                    return const SizedBox();
                  }
                  else{
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: .7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.only(
                          left: 10, top: 14, bottom: 9
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                AppIcon(packageName: allowedApps[index]),
                                const SizedBox(width: 12.5),
                                Expanded(
                                  child: Text(
                                    appsList!.firstWhere((element) => element.packageName == allowedApps[index]).appName,
                                    style: const TextStyle(color: Colors.white)
                                  )
                                ),
                                const SizedBox(width: 5)
                              ],
                            ),
                            const SizedBox(height: 7.5),
                            const Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Divider(color: Colors.grey, thickness: .7),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Expanded(
                                  child: Text("Duration limit", style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold, color: Color.fromARGB(239, 255, 255, 255), letterSpacing: .6))
                                ),
                                StatefulBuilder(
                                  builder: (context, setState) {
                                    return TextButton(
                                      onPressed: (){
                                        showModalBottomSheet(
                                          context: context, 
                                          backgroundColor: const Color.fromARGB(255, 30, 30, 30),
                                          builder: ((context) {
                                            int previousLimit = durationLimits[index];
                                            return Padding(
                                              padding: const EdgeInsets.only(left: 23, right: 23, top: 17.5, bottom: 10),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Expanded(child: Text("Set Duration Limit", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold))),
                                                      GestureDetector(
                                                        onTap: (){
                                                          durationLimits[index] = previousLimit;
                                                          preferenceManager.setIntList(key: 'whitelisted_app_usage_limits', value: durationLimits);
                                                          setState((){});
                                                          Navigator.pop(context);
                                                        },
                                                        child: const Icon(Icons.close)
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(height: 20),
                                                  DurationInputWidget(
                                                    packageName: allowedApps[index], 
                                                    onChanged: (){
                                                      setState((){}); 
                                                    }
                                                  )
                                                ],
                                              ),
                                            );
                                          })
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.all(0),
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ).copyWith(
                                        overlayColor: MaterialStateProperty.resolveWith(
                                          (states){
                                            if(states.contains(MaterialState.pressed)){
                                              return Colors.transparent;
                                            }
                                            return null;
                                          }
                                        )
                                      ),
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 5.5),

                                          durationLimits[index] == 0 ? 
                                          const Text(
                                            "Set Limit",
                                            style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: .6)
                                          )
                                          :
                                          Text(
                                            "${durationLimits[index] ~/ 3600000}H:${(durationLimits[index] % 3600000) ~/ 60000}M", 
                                            style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2.2)
                                          ),

                                          const Icon(Icons.chevron_right, color: Color.fromARGB(211, 255, 255, 255)),
                                        ],
                                      ),
                                    );
                                  }
                                ),
                                const SizedBox(width: 3)
                              ]
                            ),
                          ],
                        )
                      ),
                    );
                  }
                }
              ) +
              [
                SizedBox(height: MediaQuery.of(context).size.height / 100 * 25)
              ]
            )
          ),
        )
      )
    );
  }
}














class AppListScreen extends StatefulWidget {
  final Function onPop;

  const AppListScreen({super.key, required this.onPop});

  @override
  _AppListScreenState createState() => _AppListScreenState();
}

class _AppListScreenState extends State<AppListScreen> {

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