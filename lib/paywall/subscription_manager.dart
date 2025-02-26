import 'package:flutter/material.dart';
import 'package:focus/subscription.dart';
import '../main.dart';
import 'header.dart';

class SubscriptionManagementPage extends StatefulWidget {
  const SubscriptionManagementPage({super.key});

  @override
  State<SubscriptionManagementPage> createState() => _SubscriptionManagementPageState();
}

class _SubscriptionManagementPageState extends State<SubscriptionManagementPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async{
          Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
          return true;
        },
        child:
        !subscriptionManager.error ? 
        Scaffold(
          backgroundColor: const Color.fromARGB(255, 16, 16, 16),
          body: Padding(
            padding: const EdgeInsets.only(left: 18, right: 18, top: 10, bottom: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: const TextSpan(
                          text: "Focus Zone ",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                          children: [
                            TextSpan(
                              text: "Pro",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.greenAccent),
                            )
                          ]
                        )
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                      },
                      child: const Icon(Icons.close)
                    )
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("You have subscribed to Focus Zone Pro, the subscription auto renews until cancelled, click on Manage Subscription button to cancel subscription", style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey), textAlign: TextAlign.center,),
                ),

                ElevatedButton(
                  onPressed: (){
                    subscriptionManager.openPlayStoreSubscriptions();
                  }, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Manage Subscription", style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              ]
            ),
          )
        ) 
        :
        const Scaffold(
          backgroundColor: Color.fromARGB(255, 16, 16, 16),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Center(child: Text("something went wrong..."))]
          )
        )
      ),
    );
  }
}