import 'package:flutter/material.dart';
import '../../services/engine/game_engine.dart';
import '../widgets/background_layer.dart';
import '../widgets/sprite_layer.dart';
import '../widgets/text_window.dart';
import '../widgets/choice_menu.dart';
import '../../models/command.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameEngine _engine = GameEngine();

  @override
  void initState() {
    super.initState();
    _engine.loadScript('main.scr');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Set Scaffold to black to hide the letterboxing/pillarboxing bars
      backgroundColor: Colors.black,
      body: ListenableBuilder(
        listenable: _engine,
        builder: (context, _) {
          final state = _engine.state;
          final currentCommand = _engine.currentCommand;

          return Center(
            child: FittedBox(
              fit: BoxFit.contain, // Scales the child to fit while keeping aspect ratio
              child: SizedBox(
                // Force the internal logical resolution to always be 800x600
                width: 800.0,
                height: 600.0,
                child: GestureDetector(
                  // only register taps inside the game view, not on the black letterbox bars.
                  onTap: _engine.next,
                  child: Stack(
                    children: [
                      // 1. Background
                      BackgroundLayer(imagePath: state.backgroundPath),

                      // 2. Sprites
                      SpriteLayer(sprites: state.foregroundImages),

                      // 3. Text Window
                      Visibility(
                        visible: true,
                        maintainState: true,
                        maintainAnimation: true,
                        maintainSize: true, // Keeps the box in memory so it doesn't flicker
                        child: TextWindow(text: state.currentText),
                      ),

                      // 4. Choices (Overlay)
                      if (currentCommand is ChoiceCommand)
                        ChoiceMenu(
                          options: currentCommand.options,
                          onSelect: _engine.makeChoice,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}