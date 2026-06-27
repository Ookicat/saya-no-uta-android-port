import 'package:flutter/material.dart';

class TextWindow extends StatelessWidget {
  final String text;

  const TextWindow({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          border: Border.all(color: Colors.white24, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: 'default',
            height: 1.5,
          ),
        ),
      ),
    );
  }
}