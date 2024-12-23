// ignore_for_file: prefer_interpolation_to_compose_strings

import '../main.dart';
import 'package:flutter/material.dart';
import 'package:interactive_slider/interactive_slider.dart';

class DurationInputWidget extends StatefulWidget {
  const DurationInputWidget({super.key});

  @override
  State<DurationInputWidget> createState() => _DurationInputWidgetState();
}

class _DurationInputWidgetState extends State<DurationInputWidget> {

  InteractiveSliderController interactiveSliderController = InteractiveSliderController(0.0);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 4,
              child: Container(
                height: 75,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10)
                ),
                alignment: Alignment.center,
                child: FittedBox(
                  child: Column(
                    children: [
                      RichText(
                        text: TextSpan(
                          text: hourValue < 9 ? "0$hourValue" : hourValue.toString(),
                          style: const TextStyle(fontSize: 35, fontWeight: FontWeight.w900),
                          children: const [
                            TextSpan(
                              text: " H",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey),
                            )
                          ]
                        )
                      ),
                      //const Text("hours")
                    ],
                  )
                )
              )
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 4,
              child: Container(
                height: 75,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10)
                ),
                alignment: Alignment.center,
                child: FittedBox(
                  child: Column(
                    children: [
                      RichText(
                        text: TextSpan(
                          text: minuteValue < 9 ? "0$minuteValue" : minuteValue.toString(),
                          style: const TextStyle(fontSize: 35, fontWeight: FontWeight.w900),
                          children: const [
                            TextSpan(
                              text: " M",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey),
                            )
                          ]
                        )
                      ),
                      //const Text("minutes")
                    ],
                  )
                )
              )
            ),

            const SizedBox(width: 10),

            Expanded(
              flex: 3,
              child: Column(
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)))
                    ).copyWith(
                      overlayColor: MaterialStateProperty.resolveWith(
                        (states){
                          if(states.contains(MaterialState.pressed)){
                            return Colors.grey.withOpacity(.3);
                          }
                          return null;
                        }
                      )
                    ),
                    onPressed: (){
                      if(minuteValue < 50 && hourValue <= 11){
                        setState((){minuteValue = minuteValue + 10;});
                      }
                      else if(minuteValue == 50 && hourValue < 11){
                        setState((){hourValue = hourValue + 1;});
                        setState((){minuteValue = 0;});
                      }
                      else if(minuteValue == 50 && hourValue == 11){
                        setState(() {hourValue = 12; minuteValue = 0;});
                      }
                      
                      if(minuteValue == 30 || minuteValue == 0){
                        interactiveSliderController.value = (((hourValue * 60 + minuteValue)/(12*60)) * 100)/100;                     
                      }
                    },
                    child: Container(
                      height: 33.75, width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))
                      ),
                      alignment: Alignment.center,
                      child: const Icon(color:Colors.white, Icons.keyboard_arrow_up)
                    ),
                  ),

                  const SizedBox(height: 7.5),
                  
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(0), 
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)))
                    ).copyWith(
                      overlayColor: MaterialStateProperty.resolveWith(
                        (states){
                          if(states.contains(MaterialState.pressed)){
                            return Colors.grey.withOpacity(.3);
                          }
                          return null;
                        }
                      )
                    ),
                    onPressed: (){
                      if(minuteValue > 0){
                        setState((){minuteValue = minuteValue - 10;});
                      }
                      else if(minuteValue == 0 && hourValue > 0){
                        setState((){hourValue = hourValue - 1; minuteValue = 50;});
                      }

                      if(minuteValue == 30 || minuteValue == 0){
                        interactiveSliderController.value = (((hourValue * 60 + minuteValue)/(12*60)) * 100)/100;                     
                      }
                    },
                    child: Container(
                      height: 33.75, width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10))
                      ),
                      alignment: Alignment.center,
                      child: const Icon(color:Colors.white, Icons.keyboard_arrow_down)
                    ),
                  ),
                ]
              )
            )
          ]
        ),

        const SizedBox(height: 25),

        InteractiveSlider(
          controller: interactiveSliderController,
          padding: const EdgeInsets.all(0),
          unfocusedMargin: const EdgeInsets.symmetric(horizontal: 0),
          focusedMargin: const EdgeInsets.symmetric(horizontal: 0),
          focusedHeight: 20,
          unfocusedHeight: 20,
          disabledOpacity: 10,
          shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
          unfocusedOpacity: 1.0,
          numberOfSegments: 24,
          segmentDividerWidth: ((MediaQuery.of(context).size.width - 40) / 1.15)/44,
          segmentDividerColor: Color.fromARGB(255, 16, 16, 16),
          backgroundColor: Color.fromARGB(255, 100, 100, 100),
          foregroundColor: Colors.greenAccent,
          min: 0.0,
          max: 24.0,
          initialProgress: 0.0,
          onChanged: (value){
            //print(value);
            setState((){
              hourValue = (value.toInt()/2).toInt();
              minuteValue = value.toInt().remainder(2) != 0 ? 30 : 0;
            });
          },
        )
      ],
    );
  }
}
