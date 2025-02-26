
import '../main.dart';
import 'package:flutter/material.dart';
import 'package:interactive_slider/interactive_slider.dart';
import '../preferences.dart';

class DurationInputWidget extends StatefulWidget {

  final String packageName;

  final Function onChanged;

  const DurationInputWidget({super.key, required this.packageName, required this.onChanged});

  @override
  State<DurationInputWidget> createState() => _DurationInputWidgetState();
}

class _DurationInputWidgetState extends State<DurationInputWidget> {

  InteractiveSliderController interactiveSliderController = InteractiveSliderController(0.0);

  late int hourvalue;
  late int minuteValue;

  @override
  void initState(){
    super.initState();
    hourValue = durationLimits[allowedApps.indexOf(widget.packageName)] ~/ 3600000;
    minuteValue = (durationLimits[allowedApps.indexOf(widget.packageName)] % 3600000) ~/ 60000;

    int roundedMinuteValue = (minuteValue ~/ 10) * 10;
    interactiveSliderController.value = (((hourValue * 60 + roundedMinuteValue)/(4*60)) * 100)/100;
  }


  @override
  Widget build(BuildContext context) {
    hourValue = durationLimits[allowedApps.indexOf(widget.packageName)] ~/ 3600000;
    minuteValue = (durationLimits[allowedApps.indexOf(widget.packageName)] % 3600000) ~/ 60000;

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
                      if(durationLimits[allowedApps.indexOf(widget.packageName)] ~/ 3600000 != 4) {
                        durationLimits[allowedApps.indexOf(widget.packageName)] = durationLimits[allowedApps.indexOf(widget.packageName)] + 60000;
                      }
                      
                      if((minuteValue + 1) % 10 == 0){
                        interactiveSliderController.value = (((hourValue * 60 + minuteValue)/(4*60)) * 100)/100;                     
                      }

                      preferenceManager.setIntList(key: 'whitelisted_app_usage_limits', value: durationLimits);

                      setState((){});
                      widget.onChanged();
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
                      if(((durationLimits[allowedApps.indexOf(widget.packageName)] % 3600000) ~/ 60000) > 0){
                        durationLimits[allowedApps.indexOf(widget.packageName)] = durationLimits[allowedApps.indexOf(widget.packageName)] - 60000;
                      }

                      if(((durationLimits[allowedApps.indexOf(widget.packageName)] % 3600000) ~/ 60000) % 10 == 0){
                        interactiveSliderController.value = (((hourValue * 60 + minuteValue)/(4*60)) * 100)/100;                     
                      }
          
                      preferenceManager.setIntList(key: 'whitelisted_app_usage_limits', value: durationLimits);

                      setState((){});
                      widget.onChanged();
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
          segmentDividerColor: const Color.fromARGB(255, 30, 30, 30),
          backgroundColor: const Color.fromARGB(255, 100, 100, 100),
          foregroundColor: Colors.greenAccent,
          min: 0.0,
          max: 24.0,
          initialProgress: 0.0,
          onChanged: (value){
            durationLimits[allowedApps.indexOf(widget.packageName)] = value.toInt() * 10 * 60000;
            setState((){});
            widget.onChanged();
          },
          onProgressUpdated: (vl){
            preferenceManager.setIntList(key: 'whitelisted_app_usage_limits', value: durationLimits);
          },
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: (){
                  durationLimits[allowedApps.indexOf(widget.packageName)] = 0;
                  widget.onChanged();
                  setState(() {});
                  interactiveSliderController.value = 0.0;
                  preferenceManager.setIntList(key: 'whitelisted_app_usage_limits', value: durationLimits);
                  Navigator.pop(context);
                }, 

                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
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
                child: const Text("No Limit", style: TextStyle(color: Colors.white))
              ),
            ),

            const SizedBox(width: 20),

            Expanded(
              child: ElevatedButton(
                onPressed: (){
                  Navigator.pop(context);
                }, 

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.black,
                  elevation: 0
                ),

                child: Text("Save", style: TextStyle(fontWeight: FontWeight.w900))
              ),
            ),
          ]
        )
      ],
    );
  }
}
