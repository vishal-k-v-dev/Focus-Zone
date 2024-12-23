import 'package:flutter/material.dart';

class TopBanner extends StatelessWidget {
  const TopBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: const TextSpan(
              text: "Focus Zone ",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              children: [
                TextSpan(
                  text: "Pro",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.greenAccent),
                )
              ]
            )
          ),
        ),
        GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: const Icon(Icons.close)
        )
      ],
    );
  }
}
