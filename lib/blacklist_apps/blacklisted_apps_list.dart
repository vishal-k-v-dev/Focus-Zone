import '../main.dart';
import '../widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'blacklist_apps_selector.dart';


class BlacklistedApps extends StatefulWidget {
  const BlacklistedApps({super.key});

  @override
  State<BlacklistedApps> createState() => _BlacklistedAppsState();
}

class _BlacklistedAppsState extends State<BlacklistedApps> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        Navigator.push(context, MaterialPageRoute(builder: ((context) => const HomeScreen())));
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 16, 16, 16),
          floatingActionButton: FloatingActionButton.small(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => BlacklistAppSelector(onPop: () => setState((){})))), //onStartPress, 
            backgroundColor: Colors.greenAccent,
            child: const Icon(Icons.edit, color: Colors.black)
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Blacklisted Apps",
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
                  blacklistedApps.length, 
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
                            AppIcon(packageName: blacklistedApps[index]),
                            const SizedBox(width: 12.5),
                            Expanded(
                              child: Text(
                                appsList!.firstWhere((element) => element.packageName == blacklistedApps[index]).appName,
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
      ),
    );
  }
}




