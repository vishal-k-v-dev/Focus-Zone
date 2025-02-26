import 'package:focus/main.dart';
import 'package:flutter/material.dart';

class DeviceAdminWarning extends StatefulWidget {
  const DeviceAdminWarning({super.key});

  @override
  State<DeviceAdminWarning> createState() => _DeviceAdminWarningState();
}

class _DeviceAdminWarningState extends State<DeviceAdminWarning> {


  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      onClosing: (){}, 
      backgroundColor: const Color.fromARGB(255, 20, 20, 20),
      builder: (context){
        return Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 12, left: 18, right: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              const Text("Device Admin Permission", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              const Divider(color: Colors.grey),
              const SizedBox(height: 3.5),
              const Text("Device Admin Permission is used to prevent uninstallation during focus Session.\n\nThe app can be uninstalled when focus session is not active by disabling 'prevent uninstall' or by disabling device admin permission manually", style: TextStyle(fontSize: 14, height: 1.5)),
              const SizedBox(height: 14),
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
                    onTap: () async{
                      Navigator.pop(context);
                      await platform.invokeMethod("GetDeviceAdminPermission");
                    }, 
                    child: const Text("Grant Permission", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold))
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