import 'header.dart';
import '../main.dart';
import 'pricing.dart';
import 'pro_features.dart';
import '../subscription.dart';
import 'package:flutter/material.dart';

SubscriptionType preferedSubscription = SubscriptionType.yearly;

class PayWall extends StatefulWidget {
  const PayWall({super.key});

  @override
  State<PayWall> createState() => _PayWallState();
}

class _PayWallState extends State<PayWall> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: !subscriptionManager.error ? const Scaffold(
        backgroundColor: Color.fromARGB(255, 16, 16, 16),
        body: Padding(
          padding: EdgeInsets.only(left: 18, right: 18, top: 10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TopBanner(),
                SizedBox(height: 20),
                PricingPlans(),
                SizedBox(height: 20),
                ProFeatures(),
                SizedBox(height: 20)
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
    );
  }
}