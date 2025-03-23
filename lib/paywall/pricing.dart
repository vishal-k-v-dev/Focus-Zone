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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: .7),
            borderRadius: BorderRadius.circular(8)
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
            borderRadius: BorderRadius.circular(8)
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
        ElevatedButton(
          onPressed: (){
            subscriptionManager.purchaseSubscription(preferedSubscription);
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
                "Subscribe now"
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text("Auto renews until cancelled , cancel anytime from your Google Play account subscription settings.", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, height: 1.30, fontSize: 13), textAlign: TextAlign.center),
      ],
    );
  }
}
