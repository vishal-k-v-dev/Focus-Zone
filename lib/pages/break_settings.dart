import 'package:focus/paywall/paywall.dart';
import 'package:focus/preferences.dart';
import 'package:focus/widgets/widgets.dart';
import '../main.dart';
import 'package:flutter/material.dart';
import '../blacklist_apps/blacklisted_apps_list.dart';

class BreakSettingsPage extends StatefulWidget {
  const BreakSettingsPage({super.key});

  @override
  State<BreakSettingsPage> createState() => _BreakSettingsPageState();
}

class _BreakSettingsPageState extends State<BreakSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  CustomListTile(
                    title: "Number of breaks", 
                    subtitle: (breakSession != 1 || breakSession != 0) ? "$breakSession breaks" : (breakDuration == 1 ? "1 break" : "no breaks"), 
                    onTap: (){
                      showDialog(
                        context: context,
                        builder: (context){
                          return AlertDialog(
                            scrollable: true,
                            backgroundColor: const Color.fromARGB(255, 30, 30, 30),
                            title: const Text("Number of breaks", style: TextStyle(fontWeight: FontWeight.bold)),
                            content: Column(
                              children: List.generate(
                              26, 
                              (index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.all(0),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)
                                      )
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
                                
                                    onPressed: () async{   
                                      if(subscriptionManager.isProUser || index <= 1){
                                        breakSession = index;
                                        preferenceManager.setInt(key: "break_sessions", value: breakSession);
                                        Navigator.pop(context);
                                        setState((){});
                                      }                 
                                      else{
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => const PayWall()));
                                      }                  
                                    },
                                
                                    child: Container(
                                      width: double.infinity,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey, width: .7),
                                        //color: const Color.fromARGB(255, 30, 30, 30),
                                        borderRadius: BorderRadius.circular(10)
                                      ),
                                      padding: const EdgeInsets.only(
                                        left: 10, right: 4, top: 14, bottom: 14
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              index == 0 ? "No breaks" :
                                              index == 1 ? "1 break" :
                                              "$index breaks",
                                  
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                letterSpacing: .6
                                              )
                                            ),
                                          ),
                                          subscriptionManager.isProUser || index <= 1  ? 
                                          const Icon(
                                            Icons.chevron_right, 
                                            color: Colors.white
                                          )        
                                          :     
                                          const Padding(
                                            padding: EdgeInsets.only(right: 4),
                                            child: Icon(
                                              Icons.diamond_outlined, 
                                              size: 17,
                                              color: Colors.white
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                            ),
                            )
                          );
                        }
                      );
                    }
                  ),
    
                  const SizedBox(height: 25),

                  CustomListTile(
                    title: "Maximum duration", 
                    subtitle: "$breakDuration minutes",
                    disabled: breakSession == 0,
                    onTap: (){
                      showDialog(
                        context: context,
                        builder: (context){
                          return AlertDialog(
                            scrollable: true,
                            backgroundColor: const Color.fromARGB(255, 30, 30, 30),
                            title: const Text("Break duration", style: TextStyle(fontWeight: FontWeight.bold)),
                            content: Column(
                              children: List.generate(
                              12, 
                              (index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.all(0),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)
                                      )
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
                                      if(subscriptionManager.isProUser || index <= 0){
                                        breakDuration = (index + 1) * 5;
                                        preferenceManager.setInt(key: "break_duration", value: breakDuration);
                                        setState((){});
                                        Navigator.pop(context);
                                      }
                                      else{
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => const PayWall()));
                                      }
                                    },
                                
                                    child: Container(
                                      width: double.infinity,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey, width: .7),
                                        //color: const Color.fromARGB(255, 30, 30, 30),
                                        borderRadius: BorderRadius.circular(10)
                                      ),
                                      padding: const EdgeInsets.only(
                                        left: 10, right: 4, top: 14, bottom: 14
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "${(index + 1) * 5} minutes",
                                  
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                letterSpacing: .6
                                              )
                                            ),
                                          ),
                                          subscriptionManager.isProUser || index <= 0  ? 
                                          const Icon(
                                            Icons.chevron_right, 
                                            color: Colors.white
                                          )        
                                          :     
                                          const Padding(
                                            padding: EdgeInsets.only(right: 4),
                                            child: Icon(
                                              Icons.diamond_outlined, 
                                              size: 17,
                                              color: Colors.white
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                            ),
                            )
                          );
                        }
                      );
                    }
                  ),

                  const SizedBox(height: 25),
    
                  CustomListTile(
                    title: "Blacklist apps", 
                    disabled: breakSession == 0,
                    subtitle: blacklistedApps.length == 1 ? "1 app" : "${blacklistedApps.length} apps",
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const BlacklistedApps()));
                    }
                  )
                ]
    );
  }
}
