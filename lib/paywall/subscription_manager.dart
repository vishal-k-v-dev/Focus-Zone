import 'package:flutter/material.dart';
import 'package:focus/subscription.dart';
import '../main.dart';

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
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.only(left: 22, right: 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  child: const Text("Manage Subscription"),
                  onPressed: (){
                    subscriptionManager.openPlayStoreSubscriptions();
                  },
                ),
                TextButton(
                  child: Text("Go back"),
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                  },
                )
              ],
            )
          ),
          body: Padding(
            padding: const EdgeInsets.only(left: 22, right: 22, top: 10, bottom: 5),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Your current subscription plan :", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.circle, size: 5),
                      const SizedBox(width: 7.5),
                      Expanded(
                        child: subscriptionManager.activeSubscriptionType == SubscriptionType.monthly ?
                        Text("${subscriptionManager.monthlySubscriptionLocalizedPrice} / month", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)) :
                        Text("${subscriptionManager.yearlySubscriptionLocalizedPrice} / year", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Icon(Icons.circle, size: 5),
                      SizedBox(width: 7.5),
                      Expanded(
                        child: Text("Auto renews until canceled.", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ) :
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