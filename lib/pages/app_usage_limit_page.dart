import '../main.dart';
import '../widgets/widgets.dart';
import 'package:flutter/material.dart';

class AppUsageLimitPage extends StatefulWidget {
  const AppUsageLimitPage({super.key});

  @override
  State<AppUsageLimitPage> createState() => _AppUsageLimitPageState();
}

class _AppUsageLimitPageState extends State<AppUsageLimitPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 16, 16, 16),
        body: Padding(
          padding: const EdgeInsets.only(left: 23, right: 23, top: 5, bottom: 5),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Limit App Usage",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Set duration limit and/or app-open limit for whitelisted apps",
                  style: TextStyle(fontSize: 14.5, height: 1.6, color: Colors.grey),
                ),
                const SizedBox(height: 15),
                Column(
                  children: List.generate(
                    whitelistApps.length, 
                    (index){
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: 
                        whitelistApps[index] != phonePackage ?
                        LimitAppWidget(
                          packageName: whitelistApps[index],
                        ) :
                        const SizedBox()
                      );
                    }
                  )
                )    
              ],
            ),
          )
        )
      ),
    );
  }
}

class LimitAppWidget extends StatefulWidget {
  final String packageName;

  const LimitAppWidget({super.key, required this.packageName});

  @override
  State<LimitAppWidget> createState() => _LimitAppWidgetState();
}

class _LimitAppWidgetState extends State<LimitAppWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(      
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 30, 30, 30),
        borderRadius: BorderRadius.circular(7.5)
      ),
      child: Column(        
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, top: 10, bottom: 0),
            child: Column(
              children: [
                Row(
                  children: [
                    AppIcon(packageName: widget.packageName),
                    const SizedBox(width: 12),
                    Text(
                      appsList!.firstWhere((element) => element.packageName == widget.packageName).appName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)
                    )
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(color: Colors.white),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.only(left: 8, right: 2),
            child: Row(
              children: [
                const Text("Duration Limit", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                GestureDetector(
                  onTap: (){
          
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Set limit", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.greenAccent)),
                      Icon(Icons.chevron_right, color: Colors.white, size: 20, opticalSize: 20)
                    ],
                  )
                )
              ],
            ),
          ),

          const SizedBox(height: 15),

          Padding(
            padding: const EdgeInsets.only(left: 8, right: 2),
            child: Row(
              children: [
                const Text("App-open Limit", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                GestureDetector(
                  onTap: (){
          
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Set limit", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.greenAccent)),
                      Icon(Icons.chevron_right, color: Colors.white, size: 20, opticalSize: 20)
                    ],
                  )
                )
              ],
            ),
          ),

          const SizedBox(height: 10)
        ],
      ),
    );
  }
}

