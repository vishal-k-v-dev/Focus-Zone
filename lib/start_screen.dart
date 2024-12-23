import 'ads.dart';
import 'main.dart';
import 'active_screen/active.dart';
import 'package:flutter/material.dart';
import 'package:action_slider/action_slider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:is_first_run/is_first_run.dart';

class WarningScreen extends StatefulWidget {
  const WarningScreen({super.key});

  @override
  State<WarningScreen> createState() => _WarningScreenState();
}

class _WarningScreenState extends State<WarningScreen> {
  bool isRewarded = false;
  bool canceled = false;

  @override
  void initState() {
    super.initState();
    canceled = false;
    _loadRewardedAd();
  }

  void _loadRewardedAd() async{
    if(await IsFirstRun.isFirstCall()){
      startFocusSession();
    }
    else if(subscriptionManager.isProUser){
      startFocusSession();
    }
    else{
      await RewardedAd.load(
        adUnitId: AdUnits.rewardedAdUnit,     
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) async{
            if(!canceled){
              await ad.show(onUserEarnedReward: (AdWithoutView ad, RewardItem item){
                ad.dispose(); 
                setState((){isRewarded = true;});
              });
            }
          }, 
          onAdFailedToLoad: (LoadAdError error){
            setState((){isRewarded = true;});
          }
        )
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    canceled = true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: 
            !isRewarded ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 17, width: 17, child: CircularProgressIndicator()),
                Text(
                  "   Focus session will start after ad",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ],
            ) : 
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Slide to start focus session", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 18),
                ActionSlider.standard(
                  height: 45,
                  boxShadow: const [BoxShadow()],
                  backgroundBorderRadius: BorderRadius.circular(10),
                  action: (e) => startFocusSession(),
                  child: const Text("Start now", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            )
          )
        ]
    );
  }

  startFocusSession() async{

    platform.invokeMethod(
      'start',
      {
        "list": whitelistAppNames,
        'packagelist': whitelistApps,
        'milliseconds': (hourValue * 60 * 60 * 1000) + (minuteValue * 60000),
        'exitbutton': removeExitButton ? 0 : 1,
        'is_block_notification_enabled': 1,
        'block_notifications': whitelistNotifications,
        'break_duration': breakDuration * 20000,
        'break_session': breakSession,
        'auto_start': autoStart ? 1 : 0,
        'blacklist_apps': blacklistApps,
        "usage_limits": usageTimeLimits.map((x) => x == 0 ? 4320000 : x).toList()
      },
    );
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ActiveScreen()));
  }
}
