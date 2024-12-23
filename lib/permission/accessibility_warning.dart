import 'package:focus/main.dart';
import 'package:flutter/material.dart';

class AccessibilityWarning extends StatefulWidget {
  const AccessibilityWarning({super.key});

  @override
  State<AccessibilityWarning> createState() => _AccessibilityWarningState();
}

class _AccessibilityWarningState extends State<AccessibilityWarning> {
  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      onClosing: (){}, 
      backgroundColor: const Color.fromARGB(255, 20, 20, 20),
      builder: (context){
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              const Text("Accessibility Permission", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              const Divider(color: Colors.grey),
              const SizedBox(height: 3.5),
              const Text("Accessibility Permission is used to auto start Focus Zone imediately after restart", style: TextStyle(fontSize: 14, height: 1.5)),
              const SizedBox(height: 14),
              const Text("Find Focus Zone from installed apps & enable accessibility permission", style: TextStyle(fontSize: 14, height: 1.5)),
              const SizedBox(height: 5),
              const Divider(color: Colors.grey),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: (){
                      Navigator.pop(context);
                    }, 
                    child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.bold))
                  ),
                  GestureDetector(
                    onTap: (){
                      Navigator.pop(context);
                      platform.invokeMethod('getPermission');
                    }, 
                    child: const Text("Agree & Grant Permission", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold))
                  ),
                ],
              )
            ],
          ),
        );
      }
    );
  }
}