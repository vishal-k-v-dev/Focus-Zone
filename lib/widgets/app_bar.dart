import 'package:focus/main.dart';
import '../paywall/paywall.dart';
import 'package:flutter/material.dart';
import '../paywall/subscription_manager.dart';

class CustomAppBar extends StatefulWidget {
  const CustomAppBar({super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
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
