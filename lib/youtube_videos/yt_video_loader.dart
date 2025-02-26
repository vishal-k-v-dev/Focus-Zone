// ignore_for_file: use_build_context_synchronously

import 'package:ogp_data_extract/ogp_data_extract.dart';
import '../preferences.dart';
import 'yt_videos.dart';
import 'package:focus/main.dart';
import 'package:flutter/material.dart';

class YTVideoLoader extends StatefulWidget {
  final String videoID;
  final String videoLink;

  const YTVideoLoader({super.key, required this.videoLink, required this.videoID});

  @override
  State<YTVideoLoader> createState() => _YTVideoLoaderState();
}

class _YTVideoLoaderState extends State<YTVideoLoader> {
  @override
  void initState() {
    super.initState();
    loadUrl();    
  }

  @override
  void dispose() {
    super.dispose();
  }

  loadUrl() async{
    if(youtubeVideosID.contains(widget.videoID)){
      await Future.delayed(const Duration(seconds: 2));
      Navigator.push(context, MaterialPageRoute(builder: ((context) => const AllowYTVideos())));
    }
    else{
      OgpData? ogpData = await OgpDataExtract.execute(widget.videoLink);
      if(ogpData == null){ //ERROR
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Something went wrong"), duration: Duration(seconds: 2)));
        await Future.delayed(const Duration(seconds: 2));
        Navigator.push(context, MaterialPageRoute(builder: ((context) => const AllowYTVideos())));
      }
      else{ //ERROR
        if(ogpData.title == null || ogpData.image == null){
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Something went wrong")));
          await Future.delayed(const Duration(seconds: 2));
          Navigator.push(context, MaterialPageRoute(builder: ((context) => const AllowYTVideos())));
        }
        else{ //SUCCESS
          youtubeVideosID.insert(0, widget.videoID);
          youtubeVideosTitle.insert(0, ogpData.title!);
          youtubeVideosThumbnailLink.insert(0, ogpData.image!);  
          
          //update preferences
          preferenceManager.setStringList(key: "youtube_videos_ID", value: youtubeVideosID);
          preferenceManager.setStringList(key: "youtube_videos_title", value: youtubeVideosTitle);
          preferenceManager.setStringList(key: "youtube_videos_thumbnail_link", value: youtubeVideosThumbnailLink);

          Navigator.push(context, MaterialPageRoute(builder: ((context) => const AllowYTVideos())));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{return false;},
      child: const Scaffold(
        backgroundColor: Color.fromARGB(255, 16, 16, 16),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: SizedBox(
                width: 35,
                height: 35, 
                child: CircularProgressIndicator(
                  color: Colors.greenAccent
                )
              )
            ),
          ],
        ),
      ),
    );
  }
}