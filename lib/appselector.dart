import 'package:flutter/material.dart';
import 'package:focus/main.dart';
import '/ads.dart';

class AppListScreen extends StatefulWidget {
 
  const AppListScreen({super.key});

  @override
  _AppListScreenState createState() => _AppListScreenState();
}

class _AppListScreenState extends State<AppListScreen> {

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        Navigator.pushNamed(context, '/whitelistapps');
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 16, 16, 16),
          body: SingleChildScrollView(
            child: Column(
              children: List.generate(
                pri_apps!.length,
                (index) {
                var app = pri_apps![index];
                return 
                index % 20 != 0 ? 
                  Visibility(
                    child: ListTile(
                      contentPadding: const EdgeInsets.only(left: 12, right: 12, top: 5, bottom: 5),
                      leading: SizedBox(height: 30, width: 30, child: Image(image: MemoryImage(app.icon))),
                      title: Text(app.appName),
                      trailing: Selector(value: app.packageName, name: app.appName),
                    ),
                  ): 
                  Column(
                    children: [
                      BannerAdWidget(),
                      Visibility(
                        child: ListTile(
                          contentPadding: const EdgeInsets.only(left: 12, right: 12),
                          leading: SizedBox(height: 30, width: 30, child: Image(image: MemoryImage(app.icon))),
                          title: Text(app.appName),
                          trailing: Selector(value: app.packageName, name: app.appName),
                        ),
                      )
                    ],
                  );
                }
              )
            ),
          )
        ),
      ),
    );        
  }
}

class Selector extends StatefulWidget {
  final String value;
  final String name;

  Selector({required this.value, required this.name});

  @override
  State<Selector> createState() => _SelectorState();
}

class _SelectorState extends State<Selector> {
  @override
  Widget build(BuildContext context) {
    bool selected = selectedApps.contains(widget.value);
    return Switch(
      value: selected, 
      activeColor: Colors.green,
      onChanged: (changedValue){
        setState((){
          selected = changedValue;
          
          if(selectedApps.contains(widget.value)){
          usageTimeLimits.removeAt(selectedApps.indexOf(widget.value));
          selectedApps.remove(widget.value);
          selectedAppnames.remove(widget.name);
          }
          else{
            usageTimeLimits.add(0);
            selectedApps.add(widget.value);
            selectedAppnames.add(widget.name);
          }
          
        });
      }
    );
  }
}