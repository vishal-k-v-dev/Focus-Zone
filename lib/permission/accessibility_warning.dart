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
    return SafeArea(
      child: Scaffold(
      backgroundColor: const Color.fromARGB(255, 16, 16, 16),
        body: Padding(
          padding: const EdgeInsets.only(
            top: 12,  bottom: 12, left: 18, right: 18
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text("Accessibility Permission", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  GestureDetector(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.close)
                  )
                ],
              ),
              const SizedBox(height: 17),
              const Divider(color: Colors.grey, thickness: .7, height: .7),
              const SizedBox(height: 17),

              const Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text("Accessibility Permission is neccessary for focus zone, accessibility service is used for the following.", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.35)),
                      SizedBox(height: 17),
                      Row(
                        children: [
                          Text("-  ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.35, color: Colors.grey)),
                          Expanded(child: Text("To block settings app during focus session.", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.35, color: Colors.grey))),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Text("-  ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.35, color: Colors.grey)),
                          Expanded(child: Text("To block blacklisted apps during breaks.", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.35, color: Colors.grey))),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Text("-  ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.35, color: Colors.grey)),
                          Expanded(child: Text("To auto start focus session immediately after device restart.", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.35, color: Colors.grey))),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Text("-  ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.35, color: Colors.grey)),
                          Expanded(child: Text("To automatically bring you to home screen when you open settings app or blacklisted app during break.", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.35, color: Colors.grey))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // const SizedBox(height: 7.5),
              // const Text("Accessibility service is not used to collect or share any personal data.", style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, height: 1.35, color: Color.fromARGB(216, 255, 255, 255)), textAlign: TextAlign.center),
              // const SizedBox(height: 7.5),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                      ),
                      onPressed: (){
                        Navigator.pop(context);
                        platform.invokeMethod("get_permission");
                      }, 
                      child: const Row(
                        mainAxisSize: MainAxisSize.max, 
                        mainAxisAlignment: MainAxisAlignment.center, 
                        children: [
                          SizedBox(height: 42.5), 
                          Text("Agree & Grant Permission", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Colors.black))
                        ]
                      )
                    ),
                  ),
                ],
              ),

              Center(
                child: TextButton(
                  child: const Text("cancel", style: TextStyle(color: Colors.greenAccent)),
                  onPressed: (){
                    Navigator.pop(context);
                  }
                ),
              )
            ],
          ),
        )
      ),
    );
  }
}