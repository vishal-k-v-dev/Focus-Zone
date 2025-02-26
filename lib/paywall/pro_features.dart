import "package:flutter/material.dart";

class ProFeatures extends StatelessWidget {
  const ProFeatures({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 15, bottom: 15, left: 10, right: 10),
      decoration: BoxDecoration(
        //color: const Color.fromARGB(255, 30, 30, 30),
        border: Border.all(color: Colors.grey, width: .7),
        borderRadius: BorderRadius.circular(10)
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text("Pro Features", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              Icon(Icons.diamond_outlined, size: 18)
            ],
          ),
          SizedBox(height: 10),
          Divider(color: Colors.white),
          SizedBox(height: 10),
          Feature(
            feature: "No advertisements",
            freeLimit: "The Free version requires you to watch an ad before starting the focus session",
          ),
          SizedBox(height: 25),
          Feature(
            feature: "Whitelist unlimited apps",
            freeLimit: "You can whitelist up to 3 apps in the Free version",
          ),
          SizedBox(height: 25),
          Feature(
            feature: "Whitelist unlimited Notifications",
            freeLimit: "You can whitelist up to 3 apps' notifications in the Free version",
          ),
          SizedBox(height: 25),
          Feature(
            feature: "Unlimited youtube videos",
            freeLimit: "You can add up only 1 youtube video in the Free version, videos where the youtuber disabled embed option can't be viewed",
          ),
          SizedBox(height: 25),
          Feature(
            feature: "Up to 25 break sessions",
            freeLimit: "You can have only one break session in the Free version",
          ),
          SizedBox(height: 25),
          Feature(
            feature: "Up to 60 minutes of break duration",
            freeLimit: "You can have a break duration of up to 5 minutes in the Free version",
          ),
          SizedBox(height: 25),
          Feature(
            feature: "Blacklist unlimited apps",
            freeLimit: "You can block up to 3 apps in the Free version, blacklisted apps can't be accessed during breaks",
          ),
        ],
      ),
    );
  }
}

class Feature extends StatelessWidget {
  final String feature;
  final String freeLimit;
  const Feature({super.key, required this.feature, required this.freeLimit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(feature, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: .45)),
        const SizedBox(height: 7),
        Text(freeLimit, style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold, height: 1.33))
      ],
    );
  }
}
