import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdUnits{
  static const String bannerAdUnit  = "ca-app-pub-7284288989154980/4580319666";
  static const String nativeAdUnit  = "ca-app-pub-7284288989154980/1394186451";
  static const String appOpenAdUnit = "ca-app-pub-7284288989154980/9374918138";
}

//class AdUnits{
//  static const String bannerAdUnit  = "ca-app-pub";
//  static const String nativeAdUnit  = "ca-app-pub";
//  static const String appOpenAdUnit = "ca-app-pub";
//}

class BannerAdWidget extends StatefulWidget {
  @override
  _BannerAdExampleState createState() => _BannerAdExampleState();
}

class _BannerAdExampleState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool adLoaded = false;

  @override
  void initState() {
    super.initState();

    _bannerAd = BannerAd(
      adUnitId: AdUnits.bannerAdUnit,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          adLoaded = true;
          setState(() {});
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (adLoaded) ?
      Padding(
        padding: const EdgeInsets.only(left : 12.0, right: 12.0),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: Colors.white, width: 2.5),
            color: Colors.white,
          ),
          width: MediaQuery.of(context).size.width,
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),        
          ),
      ) : 
    Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0),
      child: Container(
        height: _bannerAd!.size.height.toDouble(),
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: const Color.fromARGB(255, 42, 42, 42), width: 2.5),
          color: const Color.fromARGB(255, 42, 42, 42),
        ),
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: AspectRatio(
            aspectRatio: 1/1,
            child: CircularProgressIndicator(color: Colors.green)
          ),
        ),
      ),      
    );
  }
}



class NativeAdWidget extends StatefulWidget {
  @override
  _NativeAdWidgetState createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadNativeAd();
  }

  void _loadNativeAd() {
    _nativeAd = NativeAd(
      adUnitId: AdUnits.nativeAdUnit,     
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
        callToActionTextStyle: NativeTemplateTextStyle(
          backgroundColor: Colors.green, 
          textColor: Colors.white
        )
      ),
    );

    _nativeAd!.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isAdLoaded
    ? Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        height: 99,
        child: AdWidget(ad: _nativeAd!)
      ),
    )
    : Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        height: 99,
        color: const Color.fromARGB(255, 42, 42, 42),
        child: const CircularProgressIndicator(color: Colors.green)
      ),
    );
  }
}


class AppOpenAdManager {
  AppOpenAd? _appOpenAd;
  bool _isAdAvailable = false;

  void loadAd() {
  
    AppOpenAd.load(
      adUnitId: AdUnits.appOpenAdUnit,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAdAvailable = true;
        },
        onAdFailedToLoad: (error) {
        },
      ),
      orientation: AppOpenAd.orientationPortrait,
    );
  }

  void showAdIfAvailable() {
    if (_isAdAvailable) {
      _appOpenAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          //loadAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          //loadAd();
        },
      );
      _appOpenAd?.show();
      _isAdAvailable = false;
    } else {
      //loadAd();
    }
  }
}