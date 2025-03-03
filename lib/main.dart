// ignore_for_file: usebuild_context_synchronously, use_build_context_synchronously

import 'package:focus/widgets/app_bar.dart';
import 'pages/settings_page.dart';
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
import 'preferences.dart';
import 'package:widget_size/widget_size.dart';
import 'permission/accessibility_warning.dart';

MethodChannel platform = const MethodChannel("com.lock.focus");

//Permissions
bool displayOverOtherApps = false;
bool usageStats = false;
bool ignoreBatteryOptimizations = false;
bool notificationAccess = false;
bool deviceAdmin = false;
bool accessibility = false;

//focus session Details
int breakSession = 0; 
int breakDuration = 1;
int minuteValue = 0; 
int hourValue = 0;
List<String> allowedApps = []; 
List<String> allowedAppNames = []; 
List<String> allowedNotifications = [];
List<String> youtubeVideosID = [];
List<String> youtubeVideosTitle = [];
List<String> youtubeVideosThumbnailLink = [];
List<String> blacklistedApps = [];
List<int> durationLimits = [];
bool autoStart = false;
bool removeExitButton = false;
bool blockNotifications = false;

//apps
List? appsList;
String phonePackage = "";

// subscription manager
SubscriptionManager subscriptionManager = SubscriptionManager();

double sheight = 0.0;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setSystemChromePreferences();
  await initializeApp();
  await getPermissions();
  await getSettings();
  runApp(const MyApp());
}

setSystemChromePreferences(){
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color.fromARGB(255, 16, 16, 16),
      systemNavigationBarColor: Color.fromARGB(255, 16, 16, 16)
    )
  );
}

Future<void> initializeApp() async {
  //ads initalization
  MobileAds.instance.initialize();

  //subscriptionManager initalization
  await subscriptionManager.initalize();

  //SharedPreferences initalization
  await preferenceManager.initalise();

  //get default phone package
  phonePackage = await platform.invokeMethod('dialer');
}

Future<void> getPermissions() async{
  displayOverOtherApps = await Permission.systemAlertWindow.isGranted;

  usageStats = await UsageStats.checkUsagePermission() ?? false;

  ignoreBatteryOptimizations = await Permission.ignoreBatteryOptimizations.isGranted;

  notificationAccess = await NotificationListenerService.isPermissionGranted();

  deviceAdmin = await platform.invokeMethod('DeiceAdminEnabled');

  accessibility = await platform.invokeMethod('AccessibilityEnabled');
}

Future<void> getSettings() async{
  allowedApps = preferenceManager.getStringList(key: "whitelisted_app_packages", defaultValue: [phonePackage]);

  allowedAppNames = preferenceManager.getStringList(key: "whitelisted_app_names", defaultValue: ["Phone"]);

  durationLimits = preferenceManager.getIntList(key: "whitelisted_app_usage_limits", defaultValue: [0]);

  allowedNotifications = preferenceManager.getStringList(key: "whitelist_app_notification_packages", defaultValue: [phonePackage]);

  youtubeVideosID = preferenceManager.getStringList(key: "youtube_videos_ID", defaultValue: []);

  youtubeVideosTitle = preferenceManager.getStringList(key: "youtube_videos_title", defaultValue: []);

  youtubeVideosThumbnailLink = preferenceManager.getStringList(key: "youtube_videos_thumbnail_link", defaultValue: []);
  
  blacklistedApps = preferenceManager.getStringList(key: "blacklisted_apps", defaultValue: ["com.android.settings"]);

  breakSession = preferenceManager.getInt(key: "break_sessions", defaultValue: 1);

  breakDuration = preferenceManager.getInt(key: "break_duration", defaultValue: 5);

  removeExitButton = preferenceManager.getBool(key: "remove_exit_button", defaultValue: false);

  blockNotifications = preferenceManager.getBool(key: "block_notifications", defaultValue: false) && notificationAccess;

  autoStart = (preferenceManager.getBool(key: "auto_start", defaultValue: false)) && accessibility;

  if(!subscriptionManager.isProUser){
    durationLimits = List.generate(allowedApps.length, (index) => 0);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), 
          child: child!
        );
      },

      initialRoute: (
        displayOverOtherApps && usageStats
      ) ? '/' : '/permissions',

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
    super.dispose();
  }

  Future<void> getApps() async {

    if(appsList == null){
      appsList = await DeviceApps.getInstalledApplications(
        includeAppIcons: true,
        includeSystemApps: true,
        onlyAppsWithLaunchIntent: true,
      );

      appsList?.sort((a, b) => a.appName.compareTo(b.appName));

      String homeScreenPackage = await platform.invokeMethod('getHomePackage');
      appsList?.removeWhere((app) => [homeScreenPackage, "com.lock.focus"].contains(app.packageName));
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WidgetSize(
        onChange: (Size size) {
          sheight = size.height;
        },
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 16, 16, 16),
          body: appsList == null ? 
            loadingScreen() : 
            homePage()
        ),
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
        return false;
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 18, right: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 7.5),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: CustomAppBar()
            ),
            const SizedBox(height: 5),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Column(
                    children: [
                      const DurationInputWidget(),
                      const SizedBox(height: 26),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.greenAccent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                              ),
                              onPressed: onStartPress, //onStartPress, 
                              child: const Row(
                                mainAxisSize: MainAxisSize.max, 
                                mainAxisAlignment: MainAxisAlignment.center, 
                                children: [
                                Icon(Icons.arrow_right, size: 25, color: Colors.black),
                                  SizedBox(height: 42.5), 
                                  Text("Start Focusing", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Colors.black))
                                ]
                              )
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      const SettingsPage()
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

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> onStartPress() async {
    bool accessibilityEnabled = await platform.invokeMethod('AccessibilityEnabled');
    if (!accessibilityEnabled) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const AccessibilityWarning()));
    } 
    else{
      if (hourValue + minuteValue != 0) {
        showModalBottomSheet(
          context: context,
          backgroundColor: const Color.fromARGB(255, 30, 30, 30),
          builder: (context) => const WarningScreen(),
        );
      }
      else {
        _showSnackbar("Please select duration");
      }
    }
  }
}