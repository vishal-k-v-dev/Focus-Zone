import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdUnits{
  static const String bannerAdUnit   = "ca-app-pub-7284288989154980/4580319666";
  static const String nativeAdUnit   = "ca-app-pub-7284288989154980/1394186451";
  static const String appOpenAdUnit  = "ca-app-pub-7284288989154980/7094715986";
  static const String rewardedAdUnit = "ca-app-pub-7284288989154980/7641381017";
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
      padding: const EdgeInsets.all(0),
      child: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        height: 99,
        child: AdWidget(ad: _nativeAd!)
      ),
    )
    : const SizedBox();
  }
}
