import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VideoPreview extends StatefulWidget {
  final String uri;

  const VideoPreview({super.key, required this.uri});

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.uri))
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request){
            if(request.url != widget.uri){
              return NavigationDecision.prevent;
            }
            else{
              return NavigationDecision.navigate;
            }
          }
        )
      );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: WebViewWidget(
          controller: _controller,
        ),
      ),
    );
  }
}