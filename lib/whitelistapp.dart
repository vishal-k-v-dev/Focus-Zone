// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'main.dart';
import 'ads.dart';

class WhiteListApps extends StatefulWidget {
  const WhiteListApps({super.key});

  @override
  State<WhiteListApps> createState() => _WhiteListAppsState();
}

class _WhiteListAppsState extends State<WhiteListApps> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        Navigator.pushNamed(context, '/');
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 16, 16, 16),
          bottomNavigationBar: BannerAdWidget(),
          body: Column(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NativeAdWidget(),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                    child: ElevatedButton(
                      onPressed: (){Navigator.pushNamed(context, '/addwhitelistapps');},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: Colors.white),
                          SizedBox(width: 7.5),
                          Text("Add Apps", style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700))
                        ]
                      )
                    ),
                  )
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(
                      selectedApps.length, 
                      (index) {
                        return AppLimitListTile(packageName: selectedApps[index]);
                      }
                    )
                  )
                ),
              )
            ],
          )
        )
      ),
    );
  }
}

class AppLimitListTile extends StatefulWidget {
  final String packageName;

  const AppLimitListTile({required this.packageName});

  @override
  State<AppLimitListTile> createState() => _AppLimitListTileState();
}

class _AppLimitListTileState extends State<AppLimitListTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 12, right: 12),
      leading: SizedBox(height: 30, width: 30, child: Image(image: MemoryImage(pri_apps![pri_apps!.indexWhere((element) => element.packageName == widget.packageName)].icon))),
      title: Text(selectedAppnames[selectedApps.indexWhere((element) => element == widget.packageName)], style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
      trailing: SizedBox(
        height: 30,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white, width: 1.5)
          ),
          onPressed: (){
            if(true){
              showModalBottomSheet(
                context: context, 
                builder: (context) {
                  return BottomSheet(
                    onClosing: (){}, 
                    backgroundColor: const Color.fromARGB(255, 20, 20, 20),
                    builder: (context){
                      return SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 10),
                            BannerAdWidget(),
                            const SizedBox(height: 10),
                            NativeAdWidget(),
                            DurationLimitInput(packageName: widget.packageName, onSelected: (){setState((){});}),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.white, width: 1.2)),
                                      onPressed: (){
                                        usageTimeLimits[selectedApps.indexWhere((element) => element == widget.packageName)] = 0;
                                        setState(() {});
                                        Navigator.pop(context);
                                      },
                                      child: const Text("No limits", style: TextStyle(color: Colors.white))
                                    )
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                      onPressed: (){
                                        Navigator.pop(context);
                                      },
                                      child: const Text(" Save ", style: TextStyle(color: Colors.white))
                                    )
                                  )
                                ]
                              ),
                            )
                          ],
                        )
                      );
                    }
                  );
                }
              );
            }
          }, 
          child: usageTimeLimits[selectedApps.indexWhere((element) => element == widget.packageName)] < 1 ? 
            const Text("No limits", style: TextStyle(color: Colors.white)) :
            Text(
                (usageTimeLimits[selectedApps.indexWhere((element) => element == widget.packageName)] ~/ (1000*60*60)).toString() + 
                " H  " + 
                ((usageTimeLimits[selectedApps.indexWhere((element) => element == widget.packageName)] % (1000*60*60)) ~/ 60000).toString() + 
                " M ",

              style: const TextStyle(color: Colors.white),
            )
        ),
      ),
    );
  }
}

class DurationLimitInput extends StatefulWidget {
  final packageName;
  final Function onSelected;

  const DurationLimitInput({required this.packageName, required this.onSelected});

  @override
  State<DurationLimitInput> createState() => _DurationLimitInputState();
}


class _DurationLimitInputState extends State<DurationLimitInput> {  
  int hours = 0;
  int minutes = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: BoxDecoration(
          color:const Color.fromARGB(255, 42, 42, 42),
          borderRadius: BorderRadius.circular(10)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NumberPicker(
              minValue: 0, 
              maxValue: 23, 
              infiniteLoop: true,
              value: hours, 
              selectedTextStyle: const TextStyle(color: Colors.white, fontSize: 26.5, fontWeight: FontWeight.bold),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: Border.all(color: Colors.white, width: 1.5)
              ),
              onChanged: (val){
                setState(() {
                  hours = val;
                });
                usageTimeLimits[selectedApps.indexWhere((element) => element == widget.packageName)] = (hours * 60 * 60 * 1000) + (minutes * 60 * 1000);
                widget.onSelected();
              }
            ),
            const SizedBox(width: 15),
            NumberPicker(
              minValue: 0, 
              maxValue: 59, 
              infiniteLoop: true,
              value: minutes, 
              selectedTextStyle: const TextStyle(color: Colors.white, fontSize: 26.5, fontWeight: FontWeight.bold),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: Border.all(color: Colors.white, width: 1.5)
              ),
              onChanged: (val){
                setState(() {
                  minutes = val;
                });
                usageTimeLimits[selectedApps.indexWhere((element) => element == widget.packageName)] = (hours * 60 * 60 * 1000) + (minutes * 60 * 1000);
                widget.onSelected();                
              }
            )
          ]
        )
      ),
    );
  }
}