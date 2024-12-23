// ignore_for_file: usebuild_context_synchronously, use_build_context_synchronously

import 'package:focus/widgets/top_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/pages.dart';
import 'active_screen/active.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:usage_stats/usage_stats.dart';
import 'permission/permission_page.dart';
import 'widgets/time_selector.dart';
import 'package:device_apps/device_apps.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'start_screen.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import 'subscription.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import '../paywall/subscription_manager.dart';

late MethodChannel platform;

//Permissions
bool displayOverOtherApps = false;
bool usageStats = false;
bool ignoreBatteryOptimizations = false;
bool notificationAccess = false;
bool deviceAdmin = false;

//focus session Details
bool removeExitButton = false;
bool autoStart = false;

int breakSession = 0; 
int breakDuration = 1;
int minuteValue = 0; 
int hourValue = 0;

List<String> whitelistApps = []; 
List<String> whitelistAppNames = []; 
List<String> whitelistNotifications = [];
List<String> blacklistApps = [];
List<int> usageTimeLimits = [];

//apps
List? appsList;
String phonePackage = "";

//page controller
late PageController pageController;

//shared pereferences
late SharedPreferences settingsPreferences;

// subscription manager
SubscriptionManager subscriptionManager = SubscriptionManager();


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeApp();
  runApp(const MyApp());
}

Future<void> initializeApp() async {
  await subscriptionManager.initalize();

  //UI preferences
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color.fromARGB(255, 16, 16, 16),
      systemNavigationBarColor: Color.fromARGB(255, 16, 16, 16)
    )
  );

  //ads initalization
  MobileAds.instance.initialize();

  //Shared Preferences initalization
  settingsPreferences = await SharedPreferences.getInstance();

  //platform initalzation
  platform = const MethodChannel("com.lock.focus");

  phonePackage = await platform.invokeMethod('dialer');

  //Add preferences to lists
  if(settingsPreferences.getStringList("whitelisted_app_packages") != null){
    whitelistApps.addAll(settingsPreferences.getStringList("whitelisted_app_packages")!.toList());
    whitelistAppNames.addAll(settingsPreferences.getStringList("whitelisted_app_names")!.toList());
    
    List<int> usageLimitsPreferences = settingsPreferences.getStringList("whitelisted_app_usage_limits")!.map((e) => int.parse(e)).toList();
    usageTimeLimits.addAll(usageLimitsPreferences);
  }

  if(settingsPreferences.getStringList("whitelist_app_notification_packages") != null){
    whitelistNotifications.addAll(settingsPreferences.getStringList("whitelist_app_notification_packages")!.toList());
  }

  if(settingsPreferences.getStringList("blacklisted_apps") != null){
    blacklistApps.addAll(settingsPreferences.getStringList("blacklisted_apps")!.toList());
  } else {
    blacklistApps = ["com.android.settings"];
  }
  
  if(settingsPreferences.getBool('remove_exit_button') != null){
    removeExitButton = settingsPreferences.getBool('remove_exit_button')!;
  }
  else{
    removeExitButton = false;
  }

  if(settingsPreferences.getInt('break_sessions') != null){
    breakSession = settingsPreferences.getInt('break_sessions')!;
  }
  else{
    breakSession = 0;
  }

  if(settingsPreferences.getInt('break_duration') != null){
    breakDuration = settingsPreferences.getInt('break_duration')!;
  }
  else{
    breakDuration = 1;
  }

  //Add phone package name
  if(!whitelistApps.contains(phonePackage)){
    whitelistApps.add(phonePackage);
    whitelistAppNames.add("Phone");
    usageTimeLimits.add(0);
  }
  if(!whitelistNotifications.contains(phonePackage)){
    whitelistNotifications.add(phonePackage);
  }
  
  //Permission handling
  displayOverOtherApps = await Permission.systemAlertWindow.isGranted;
  usageStats = await UsageStats.checkUsagePermission() ?? false;
  ignoreBatteryOptimizations = await Permission.ignoreBatteryOptimizations.isGranted;
  notificationAccess = await NotificationListenerService.isPermissionGranted();
  deviceAdmin = await platform.invokeMethod('DeiceAdminEnabled');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: (displayOverOtherApps && usageStats && ignoreBatteryOptimizations && notificationAccess) ? '/' : '/permissions',
      theme: ThemeData(brightness: Brightness.dark, primarySwatch: Colors.green),
      routes: {
        '/': (context) => const HomeScreen(),
        '/permissions': (context) => const PermissionGetter(),
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

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
    FlutterInappPurchase.purchaseUpdated.listen((event) async{
      if(event != null){
        if(event.isAcknowledgedAndroid != null){
          if(!(event.isAcknowledgedAndroid!)){
            await subscriptionManager.refresh();
            subscriptionManager.isProUser = true;
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionManagementPage()));
          }
        }
      }
    });
    getApps();
  }

  @override
  void dispose(){
    pageController.dispose();
    super.dispose();
  }

  Future<void> getApps() async {
    pageController = PageController();

    if(appsList == null){
      appsList = await DeviceApps.getInstalledApplications(
        includeSystemApps: true,
        includeAppIcons: true,
        onlyAppsWithLaunchIntent: true,
      );

      appsList?.sort((a, b) => a.appName.compareTo(b.appName));

      String homeScreenPackage = await platform.invokeMethod('getHomePackage');
      appsList?.removeWhere((app) => [homeScreenPackage].contains(app.packageName));
    }

    if (await platform.invokeMethod("isActive")) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ActiveScreen()));
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 16, 16, 16),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: appsList != null ? ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
            onPressed: onStartPress, //onStartPress, 
            child: const Row(
              mainAxisSize: MainAxisSize.max, 
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [
                //Icon(Icons.arrow_right, size: 25, color: Colors.black),
                SizedBox(height: 42.5), 
                Text("Start Focusing", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Colors.black))
              ]
            )
          ) : const SizedBox()
        ),
        body: appsList == null ? 
          loadingScreen() : 
          homePage()
      ),
    );
  }

  Widget loadingScreen() {
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.greenAccent,
      ),
    );
  }

  Widget homePage() {
    return WillPopScope(
      onWillPop: () async{
        pageController.jumpToPage(0);
        return false;
      },
      child: const Padding(
        padding: EdgeInsets.only(left: 22, right: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 7.5),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: TopBar()
            ),
            
            SizedBox(height: 5),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  child: Column(
                    children: [
                      DurationInputWidget(),
                      SizedBox(height: 30),
                      SettingsPage(),
                    ],
                  ),
                ),
              ),
            )
          ],    
        ),
      ),
    );
  }

  Future<void> onStartPress() async {
    if (await platform.invokeMethod('isActive')) {
      _showSnackbar("Focus Zone is already active");
    } else if (hourValue + minuteValue != 0) {
      showModalBottomSheet(
        context: context,
        backgroundColor: const Color.fromARGB(255, 30, 30, 30),
        builder: (context) => const WarningScreen(),
      );
    } else {
      _showSnackbar("Please select duration");
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

