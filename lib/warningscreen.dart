import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focus/main.dart';
import '/ads.dart';
import 'package:timer_button/timer_button.dart';

class WarningScreen extends StatefulWidget {
  const WarningScreen({super.key});

  @override
  State<WarningScreen> createState() => _WarningScreenState();
}

class _WarningScreenState extends State<WarningScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8), 
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(height: 5, width: 35, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5))),
            ],
          ),
          const SizedBox(height: 8), 
          BannerAdWidget(),
          const SizedBox(height: 8),          
          NativeAdWidget(),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.only(right: 12.0, left: 12.0),
            child: Text("Are you sure?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(right: 12.0, left: 12.0),
            child: Text(
              "Your phone will be locked for $hour_value hours and $minute_value minutes",
              style: const TextStyle(height: 1.6),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.only(right: 12.0, left: 12.0),
            child: Text(
              "You can only access the whitelisted apps during lock period",
              style: TextStyle(height: 1.6),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white, width: 1.2)),
                    child: const Text("cancel", style: TextStyle(color: Colors.white)),
                  )
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TimerButton(
                    onPressed: (){
                      
                      List<int> usageLimits = usageTimeLimits;

                      usageLimits.asMap().forEach((key, value) {
                        if(value == 0){usageTimeLimits[key] = 604800009;}
                      });
                      
                      platform.invokeMethod(
                        'start', {
                          "list": selectedAppnames, 
                          'packagelist': selectedApps, 
                          'milliseconds': (hour_value*60*60*1000)+(minute_value*60000),
                          'usage_limits' : usageLimits
                        }
                      );

                      Navigator.pop(context);
                    },
                    resetTimerOnPressed: false,
                    color: Colors.green,
                    buttonType: ButtonType.textButton,
                    timeOutInSeconds: 5,
                    label: "  Lock now  ",
                  )
                ),
              ],
            ),
          )
        ],
      )
    );
  }
}



