// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'main.dart';

class TimeInputWidget extends StatefulWidget {
   const TimeInputWidget({super.key});
 
   @override
   State<TimeInputWidget> createState() => _TimeInputWidgetState();
 }
 
 class _TimeInputWidgetState extends State<TimeInputWidget>{
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select duration for lock : ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        Container(
          decoration: BoxDecoration(
            //border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(5),
            color: const Color.fromARGB(255, 42, 42, 42),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 22.0, right: 22.0),
                child: Column(
                  children: [
                    Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         Column(
                           children: [
                             NumberPicker(
                               minValue: 0, 
                               maxValue: 23, 
                               infiniteLoop: true,
                               value: hour_value, 
                               selectedTextStyle: const TextStyle(color: Colors.white, fontSize: 26.5, fontWeight: FontWeight.bold),
                               decoration: BoxDecoration(
                                 borderRadius: const BorderRadius.all(Radius.circular(10)),
                                 border: Border.all(color: Colors.white, width: 1.5)
                               ),
                               onChanged: (vall){
                                 setState(() {
                                   hour_value = vall;
                                 });
                               }
                             ),
                           ],
                         ),
                                   
                         const SizedBox(width: 20),
              
                         Column(
                           children: [
                             NumberPicker(
                               minValue: 0, 
                               maxValue: 59, 
                               infiniteLoop: true,
                               value: minute_value, 
                               selectedTextStyle: const TextStyle(color: Colors.white, fontSize: 26.5, fontWeight: FontWeight.bold),
                               decoration: BoxDecoration(
                                 borderRadius: const BorderRadius.all(Radius.circular(10)),
                                 border: Border.all(color: Colors.white, width: 1.5)
                               ),
                               onChanged: (val){
                                 setState(() {
                                   minute_value = val;
                                 });
                               }
                             ),
                           ],
                         ),             
                       ],
                     ),                        
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Text(
          "Your phone will be locked for $hour_value hours and $minute_value minutes",
          style: const TextStyle(
            color: Color.fromARGB(255, 202, 202, 202)
          ),
        )
      ],
    );
  }
 }
