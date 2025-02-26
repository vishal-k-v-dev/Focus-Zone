import 'package:flutter/material.dart';

// CustomListTile Widget
class CustomListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool disabled;

  CustomListTile({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.disabled = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
        )
      ).copyWith(
        overlayColor: MaterialStateProperty.resolveWith(
          (states){
            if(states.contains(MaterialState.pressed)){
              return Colors.grey.withOpacity(.3);
            }
            return null;
          }
        )
      ),

      onPressed: (){
        if(!disabled){
          onTap();
        }
      },

      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: .7),
          borderRadius: BorderRadius.circular(10)
        ),
        padding: const EdgeInsets.only(
          left: 10, right: 4, top: 14, bottom: 14
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: disabled ? Colors.grey : Colors.white,
                  letterSpacing: .6
                )
              ),
            ),
            Row(
              children: [
                !disabled ? FittedBox(
                  child: Text(
                    subtitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900, 
                      fontSize: 14, 
                      color: Colors.grey,
                    )
                  ),
                ) : SizedBox(),
                Icon(
                  Icons.chevron_right, 
                  color: disabled ? Colors.grey : Colors.white,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

