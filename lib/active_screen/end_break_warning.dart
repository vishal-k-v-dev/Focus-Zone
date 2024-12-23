import '../main.dart';
import 'package:flutter/material.dart';

class EndBreakWarning extends StatefulWidget {
  const EndBreakWarning({super.key});

  @override
  State<EndBreakWarning> createState() => _EndBreakWarningState();
}

class _EndBreakWarningState extends State<EndBreakWarning> {
  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      onClosing: (){}, 
      backgroundColor: const Color.fromARGB(255, 20, 20, 20),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Are you sure?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              const Text("This action will end break session, the remaining break time can't be used again", style: TextStyle(height: 1.5)),
              const SizedBox(height: 0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(padding: const EdgeInsets.all(0)),
                    child: const Text("Cancel       "),
                  ),
                  TextButton(
                    onPressed: () async{
                      await platform.invokeMethod("endBreak");
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(padding: const EdgeInsets.all(0)),
                    child: const Text("End break session"),
                  ),
                ],
              ),
            ]
          ),
        );
      }
    );
  }
}