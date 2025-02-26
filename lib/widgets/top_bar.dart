import 'package:focus/main.dart';
import '../paywall/paywall.dart';
import 'package:flutter/material.dart';
import '../paywall/subscription_manager.dart';

class TopBar extends StatefulWidget {
  const TopBar({super.key});

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Text("Focus", style: TextStyle(color: Colors.greenAccent, fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(width: 7.5),
            const Text("Zone", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
            const Spacer(),
            GestureDetector(
              //child: Shimmer.fromColors(
              //  baseColor: Colors.green, 
              //  highlightColor: const Color.fromARGB(255, 91, 255, 105),
              //  child: const Icon(Icons.diamond_outlined, size: 24, color: Colors.green),
              //),
              child: const Icon(Icons.diamond_outlined, size: 24, color: Colors.greenAccent),
              onTap: (){
                if(!subscriptionManager.isProUser){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const PayWall()));
                }
                else{
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionManagementPage()));
                }
              }
            ),
          ],
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
