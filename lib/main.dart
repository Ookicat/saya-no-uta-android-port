import 'package:flutter/material.dart';
import 'package:saya_no_uta/ui/screens/game_screen.dart';

void main() {
  runApp(SayaNoUta());
}

class SayaNoUta extends StatelessWidget {
  const SayaNoUta({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saya no Uta',
      debugShowCheckedModeBanner: false,
      home: GameScreen(),
    );
  }
}