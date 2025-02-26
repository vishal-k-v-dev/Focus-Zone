import 'yt_video_loader.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';


class YTVideoInput extends StatefulWidget {
  const YTVideoInput({super.key});

  @override
  State<YTVideoInput> createState() => _YTVideoInputState();
}

class _YTVideoInputState extends State<YTVideoInput> {
  TextEditingController textEditingController = TextEditingController();

  bool isUrlVerified = false;

  final youtubeRegex = RegExp(
    r'^(https?:\/\/)?(www\.|m\.)?(youtube\.com\/watch\?v=|youtu\.be\/)[\w\-]{11}(\?.*)?$',
    caseSensitive: false,
  );

  String? extractYouTubeVideoId(String url) {
    final videoIdRegex = RegExp(
      r'(?:(?:\?v=|\/)([\w\-]{11}))(?:\?|&|$)',
    );
    final match = videoIdRegex.firstMatch(url);
    return match?.group(1); // Returns the first capturing group (video ID)
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 16, 16, 16),
        body: Padding(
          padding: const EdgeInsets.only(left: 18, right: 18, top: 5, bottom: 5),
          child: Column(
            children: [
              const SizedBox(height: 5),

              TextField(
                controller: textEditingController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  contentPadding: const EdgeInsets.only(top: 0, bottom: 0, left: 10, right: 5),
                  labelText: "Enter video link",
                  labelStyle: const TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.bold),
                  suffixIcon: const Icon(Icons.verified, size: 20),
                  suffixIconColor: isUrlVerified ? Colors.greenAccent :  Colors.white70,
                  suffixIconConstraints: BoxConstraints.tight(const Size(40, 20))         
                ),
                cursorColor: Colors.white,
                autofocus: true,
                onChanged: (value){                  
                  setState((){
                    isUrlVerified = youtubeRegex.hasMatch(value);
                  });
                },
              ),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: (){
                      if(textEditingController.text == ""){
                        Navigator.pop(context);
                      }
                      else{
                        textEditingController.text = "";
                        setState(() {
                          isUrlVerified = false;
                        });
                      }
                    }, 
                    child: Container(
                      height: 40, width: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey)
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 20)
                    )
                  ),

                  const SizedBox(width: 12.5),
                  
                  GestureDetector(
                    onTap: () async{
                      await Clipboard.getData(Clipboard.kTextPlain).then(
                        (value)
                        {
                          if(value != null){
                            if(value.text != null){
                              textEditingController.text = value.text!;
                              setState((){
                                isUrlVerified = youtubeRegex.hasMatch(value.text!);
                              });
                            }
                          }
                        }
                      );
                    }, 
                    child: Container(
                      height: 40, width: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey)
                      ),
                      child: const Icon(Icons.paste, color: Colors.white, size: 17.5)
                    )
                  ),

                  const Spacer(),

                  GestureDetector(
                    onTap: (){
                      if(isUrlVerified){
                        Navigator.push(context, MaterialPageRoute(builder: ((context) => YTVideoLoader(videoLink: textEditingController.text, videoID: extractYouTubeVideoId(textEditingController.text)!))));
                      }
                    }, 
                    child: Container(
                      height: 40, width: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.greenAccent
                      ),
                      child: const Icon(Icons.arrow_forward, color: Colors.black, size: 20)
                    )
                  ),
                ]
              ),

              const SizedBox(height: 5)
            ],
          ),
        ),
      ),
    );
  }
}