import 'widgets.dart';
import 'package:flutter/material.dart';

class ToggleTile extends StatefulWidget {
  final String title;
  final IconData icon;
  final bool initialValue;
  final Future<bool> Function(bool) onChanged;

  const ToggleTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  _ToggleTileState createState() => _ToggleTileState();
}

class _ToggleTileState extends State<ToggleTile> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue; // Set initial value
  }

  void _handleToggle(bool newValue) async{
    bool value = await widget.onChanged(newValue); // Call the callback
    setState(() {
      _value = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: .7),
        //color: const Color.fromARGB(255, 30, 30, 30),
        borderRadius: BorderRadius.circular(10)
      ),
      padding: const EdgeInsets.only(
        left: 10, top: 14, bottom: 14
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: .6
              )
            ),
          ),

          Switch(
            value: _value,
            activeColor: Colors.greenAccent,
            onChanged: _handleToggle,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      )
      
    );
  }
}
