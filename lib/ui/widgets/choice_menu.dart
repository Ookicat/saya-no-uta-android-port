import 'package:flutter/material.dart';

class ChoiceMenu extends StatelessWidget {
  final List<String> options;
  final Function(int) onSelect;

  const ChoiceMenu({super.key, required this.options, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black45, // Dim background
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(options.length, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[900],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(300, 60),
                  side: const BorderSide(color: Colors.white54),
                ),
                onPressed: () => onSelect(index),
                child: Text(
                  options[index],
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}