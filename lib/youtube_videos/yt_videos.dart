import '../main.dart';
import '../youtube_videos/yt_video_input.dart';
import '../preferences.dart';
import 'package:flutter/material.dart';
import 'yt_video_preview.dart';
import '../free_limits.dart';
import '../paywall/paywall.dart';

class AllowYTVideos extends StatefulWidget {
  const AllowYTVideos({super.key});

  @override
  State<AllowYTVideos> createState() => _AllowYTVideosState();
}

class _AllowYTVideosState extends State<AllowYTVideos> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        Navigator.push(context, MaterialPageRoute(builder: ((context) => const HomeScreen())));
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 16, 16, 16),
    
          body: Padding(
            padding: const EdgeInsets.only(bottom: 15, top: 15, left: 18, right: 18),
            child: 
              youtubeVideosID.isNotEmpty ?
              SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Youtube videos",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: .6),
                          ),
                        ),
                        GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: ((context) => const HomeScreen())));
                          },
                          child: const Icon(Icons.close)
                        )
                      ],
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Some videos where the uploader disabled embed option can't be viewed. please click on view button and check if the video can be viewed.",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 15
                      )
                    ),

                    const SizedBox(height: 20),

                    ...List.generate(
                      youtubeVideosID.length, 
                      <Widget> (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: VideoWidget(
                            title: youtubeVideosTitle[index], 
                            thumbnailLink: youtubeVideosThumbnailLink[index],
                            videoID: youtubeVideosID[index],
                            onRemoved: (){
                              setState((){});
                            },
                          ),
                        );
                      }
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height/100*25)
                  ] 
                ),
              ) :
              Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Youtube videos",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: .6),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: ((context) => const HomeScreen())));
                        },
                        child: const Icon(Icons.close)
                      )
                    ],
                  ),
                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("No videos yet")
                      ]
                    )
                  )
                ]
              )
            ),

    
          floatingActionButton: FloatingActionButton.small(
            onPressed: (){
              if(youtubeVideosID.length < FreeLimits.ytVideosLimit || subscriptionManager.isProUser){
                Navigator.push(context, MaterialPageRoute(builder: (context) => const YTVideoInput()));
              }
              else{
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PayWall()));
              }
            },
            backgroundColor: Colors.greenAccent,
            child: const Icon(Icons.add, color: Colors.black),
          ),
        ),
      ),
    );
  }
}

class VideoWidget extends StatefulWidget {
  final String videoID;
  final String title;
  final String thumbnailLink;
  final Function onRemoved;

  const VideoWidget({super.key, required this.title, required this.thumbnailLink, required this.videoID, required this.onRemoved});

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: .7),
        borderRadius: BorderRadius.circular(10)
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(            
            padding: const EdgeInsets.only(
              left: 10, right: 10, top: 14, bottom: 0
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                widget.thumbnailLink,
                width: double.infinity
              ),
            ),
          ),
          
          const SizedBox(height: 15),

          Padding(
            padding: const EdgeInsets.only(
              left: 10, right: 10, top: 0, bottom: 14
            ),
            child: Row(
              children: [
                Expanded(child: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w500, height: 1.5, overflow: TextOverflow.ellipsis), maxLines: 2)),
              ],
            ),
          ),
          const SizedBox(height: 2.5),
          const Divider(
            color: Colors.grey, thickness: .7, height: .7
          ),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: (){
                          showDialog(
                            context: context, 
                            builder: (context){
                              return AlertDialog(
                                backgroundColor: Color.fromARGB(255, 30, 30, 30),
                                title: const Text("Remove Video"),
                                content: const Text("Would you like to remove this video from list?", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),),
                                actions: [
                                  GestureDetector(
                                    onTap: (){
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Cancel", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold))
                                  ),
                                  const SizedBox(),
                                  GestureDetector(
                                    onTap: (){
                                      setState((){
                                        youtubeVideosID.remove(widget.videoID);
                                        youtubeVideosThumbnailLink.remove(widget.thumbnailLink);
                                        youtubeVideosTitle.remove(widget.title);

                                        //update preferences
                                        preferenceManager.setStringList(key: "youtube_videos_ID", value: youtubeVideosID);
                                        preferenceManager.setStringList(key: "youtube_videos_title", value: youtubeVideosTitle);
                                        preferenceManager.setStringList(key: "youtube_videos_thumbnail_link", value: youtubeVideosThumbnailLink);

                                      });
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Remove", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold))
                                  ),
                                  const SizedBox(),
                                  const SizedBox()
                                ],
                                actionsPadding: const EdgeInsets.only(
                                  right: 10,
                                  bottom: 15
                                ),
                              );
                            }
                          ).then((value) {
                            widget.onRemoved();
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(0)
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.close, size: 18, color: Colors.white),
                            SizedBox(width: 5),
                            Text("Remove", style: TextStyle(fontSize: 16, color: Colors.white))
                          ],
                        )
                      ),
                    ],
                  ),
                ),
          
                 
                const VerticalDivider(
                  color: Colors.grey,
                  thickness: .7,
                  width: .7,
                ),
                  
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: ((context) => VideoPreview(uri: "https://www.youtube.com/embed/${widget.videoID}"))));
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(0),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.remove_red_eye, size: 18, color: Colors.white),
                            SizedBox(width: 5),
                            Text("View", style: TextStyle(fontSize: 16, color: Colors.white))
                          ],
                        )
                      ),
                    ],
                  ),
                ),
              ]
            ),
          )
        ],
      )
    );
  }
}
