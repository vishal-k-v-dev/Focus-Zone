import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsAndPrivacyText extends StatelessWidget {
  void _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.start,
      text: TextSpan(
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, height: 1.50, fontSize: 13),
        children: [
          TextSpan(text: "By using this app you agree to "),
          TextSpan(
            text: "Terms of use",
            style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
            recognizer: TapGestureRecognizer()
              ..onTap = () => _launchURL("https://sites.google.com/view/focus-zone-terms/home"),
          ),
          const TextSpan(text: " and "),
          TextSpan(
            text: "privacy\u00A0policy",
            style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
            recognizer: TapGestureRecognizer()
              ..onTap = () => _launchURL("https://sites.google.com/view/focus-zone-privacy-policy/home"),
          ),
          const TextSpan(text: "\n"),
        ],
      ),
    );
  }
}