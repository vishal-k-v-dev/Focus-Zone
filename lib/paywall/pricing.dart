import 'package:flutter/material.dart';
import 'package:focus/subscription.dart';
import '../main.dart';
import 'paywall.dart';

class PricingPlans extends StatefulWidget {
  const PricingPlans({super.key});

  @override
  State<PricingPlans> createState() => _PricingPlansState();
}

class _PricingPlansState extends State<PricingPlans> {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 15, bottom: 15, left: 10, right: 10),
      decoration:  BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey, width: .7)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          true ?
          const Text("Free for first 3 days", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))
          :
          const SizedBox(),
          
          
          SizedBox(height: true ? 15 : 0),

          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: .7),
              borderRadius: BorderRadius.circular(4)
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(width: 10),
                Expanded(
                  child: Text("${subscriptionManager.monthlySubscriptionLocalizedPrice} / month", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                ),
                Radio<int>(
                  value: 1,
                  groupValue: preferedSubscription == SubscriptionType.yearly ? 2 : 1,
                  onChanged: (changedValue){setState((){preferedSubscription = SubscriptionType.monthly;});},
                  activeColor: Colors.greenAccent,
                )
              ],
            )
          ),
          const SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: .7),
              borderRadius: BorderRadius.circular(4)
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(width: 10),
                Expanded(
                  child: Text("${subscriptionManager.yearlySubscriptionLocalizedPrice} / year", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                ),
                Row(
                  children: [
                    Container(
                      height: 16, color: Colors.greenAccent,
                      padding: const EdgeInsets.only(left: 3, right: 3),
                      alignment: Alignment.center,
                      child: Text(
                        "-${((((subscriptionManager.monthlySubscriptionPrice*12) - subscriptionManager.yearlySubscriptionPrice)/(subscriptionManager.monthlySubscriptionPrice*12))*100).toString().substring(0, 5)}%", 
                        style: TextStyle(fontSize: 13,  fontWeight: FontWeight.w900, color: Colors.black)
                      )
                    ),
                    Radio<int>(
                      value: 2,
                      groupValue: preferedSubscription == SubscriptionType.yearly ? 2 : 1,
                      onChanged: (changedValue){setState((){preferedSubscription = SubscriptionType.yearly;});},
                      activeColor: Colors.greenAccent,
                    ),
                  ],
                )
              ],
            )
          ),
          const SizedBox(height: 16),
          const FittedBox(child: Text("Auto renews until cancelled ,  cancel anytime.", textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}