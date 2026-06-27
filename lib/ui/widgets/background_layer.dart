import 'package:flutter/material.dart';
import '../../services/asset_service.dart';

class BackgroundLayer extends StatelessWidget {
  final String imagePath;

  const BackgroundLayer({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 800.0,
      height: 600.0,
      color: Colors.black, // Fallback if image is loading or missing
      child: imagePath.isEmpty
          ? null
          : Image.asset(
        AssetService.getBackgroundPath(imagePath),
        fit: BoxFit.none,
        gaplessPlayback: true,
      ),
    );
  }
}