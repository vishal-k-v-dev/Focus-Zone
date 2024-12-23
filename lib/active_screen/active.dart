// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import '../main.dart';
import 'end_break_warning.dart';
import 'package:flutter/material.dart';

late Timer timer;
bool isBreakActive = false;
bool isServiceActive = true;

class ActiveScreen extends StatefulWidget {
  const ActiveScreen({super.key});

  @override
  State<ActiveScreen> createState() => _ActiveScreenState();
}

class _ActiveScreenState extends State<ActiveScreen> {

  @override
  void initState() {
    super.initState();
    initalizeTimer();
  }

  void initalizeTimer() async{
    await Future.delayed(const Duration(seconds: 5));
    timer = Timer.periodic(
      const Duration(milliseconds: 250), 
      (timer) async{
        //Double check if service is not active
        if(await platform.invokeMethod('isActive') == false && isServiceActive){
          isServiceActive = false;
        }        
        if(await platform.invokeMethod('isActive') == false && !isServiceActive){
          Navigator.pushNamed(context, '/');
          timer.cancel();
        }        

        isBreakActive = await platform.invokeMethod('isBreakActive');
        setState((){});        
      }
    );
  }

  @override
  void dispose(){
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 16, 16, 16),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Center(
                child: Text("Focus Zone is Active.", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
              ),

              SizedBox(height: isBreakActive ? 10 : 0),

              isBreakActive ? TextButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context){
                      return const EndBreakWarning();
                    }
                  );
                },
                child: const Text("End break session")
              )  : const SizedBox()
            ]
          )
        )
      ),
    );
  }
}
