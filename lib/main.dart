import 'package:flutter/material.dart';
import 'appselector.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:usage_stats/usage_stats.dart';
import 'permission.dart';
import 'timeselector.dart';
import 'package:device_apps/device_apps.dart';
import 'whitelistapp.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'warningscreen.dart';
import 'ads.dart';

late MethodChannel platform;
bool permission1 = false;
bool permission2 = false;
bool permission3 = false;
bool permission4 = false;

List? pri_apps;

List<String> selectedApps = [];
List<String> selectedAppnames = [];
List<int> usageTimeLimits = [];

int minute_value = 0;
int hour_value = 0;

String initialRoute = "/";

AppOpenAdManager appOpenAdManager = AppOpenAdManager();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  
  MobileAds.instance.initialize();  

  platform = const MethodChannel('com.example.your_flutter_app/toast');

  appOpenAdManager.loadAd();

  var homeScreenPackage = await platform.invokeMethod('getHomePackage');
  
  pri_apps = await DeviceApps.getInstalledApplications(
    includeSystemApps: true,
    includeAppIcons: true,
    onlyAppsWithLaunchIntent: true,
  );
  pri_apps?.removeWhere((element) => (element.packageName == homeScreenPackage || element.packageName == "com.android.settings" || element.packageName == "com.android.vending" || element.packageName == "com.focus.lock"));
  
  permission1 = await Permission.systemAlertWindow.isGranted;
  permission2 = await UsageStats.checkUsagePermission() ?? false;
  permission3 = await Permission.ignoreBatteryOptimizations.isGranted;
  permission4 = await platform.invokeMethod("AccessibilityEnabled");

  if((!permission1 || !permission2 || !permission3 || !permission4)){
    initialRoute = '/permissions';
  } else {
    initialRoute = '/';
  }
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: initialRoute,
      theme: ThemeData.dark(),
      routes: {
        '/': (context) => const HomeScreen(),
        '/whitelistapps': (context) => const WhiteListApps(),
        '/permissions': (context) => const PermissionGetter(),
        '/addwhitelistapps': (context) => const AppListScreen(),
        '/warningscreen': (context) => const WarningScreen()
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{

  @override
  void initState(){
    super.initState();
    appOpenAdManager.showAdIfAvailable();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 16, 16, 16),        
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 12.0),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ElevatedButton(
                    onPressed: (){Navigator.pushNamed(context, '/whitelistapps');}, 
                    style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 42, 42, 42)),
                    child: const Text("whitelist apps")
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: (){
                    if(hour_value + minute_value != 0)
                    {                      
                      showModalBottomSheet(
                        context: context, 
                        builder: (context) {
                          return BottomSheet(
                            onClosing: (){}, 
                            backgroundColor: const Color.fromARGB(255, 30, 30, 30),
                            builder: (context) {
                              return const WarningScreen();
                            }
                          );
                        }
                      );
                    }
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_clock),
                      Text("  Lock", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              
              NativeAdWidget(),

              const Padding(
                padding: EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 12),
                child: TimeInputWidget(),
              ),

              BannerAdWidget()

            ],
          ),            
        ),
      ),
    );
  }
}

