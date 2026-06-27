import 'package:flutter/material.dart';

class SpriteLayer extends StatelessWidget {
  final Map<String, Map<String, int>> sprites;

  const SpriteLayer({super.key, required this.sprites});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: sprites.entries.map((entry) {
        final path = entry.key;
        final x = entry.value['x']?.toDouble() ?? 0.0;
        final y = entry.value['y']?.toDouble() ?? 0.0;

        return Positioned(
          left: x,
          top: y,
          child: Image.asset(
              path,
            gaplessPlayback: true,
          ),
        );
      }).toList(),
    );
  }
}