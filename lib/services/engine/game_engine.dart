import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saya_no_uta/services/asset_service.dart';
import 'package:saya_no_uta/services/audio_service.dart';
import 'package:saya_no_uta/services/engine/global_variables.dart';
import '../../models/command.dart';
import '../../models/game_state.dart';
import 'parser.dart';

class GameEngine extends ChangeNotifier {
  final GameState state = GameState();
  final AudioService _audio = AudioService();
  List<Command> _commands = [];
  int _skipDepth = 0;
  Timer? _delayTimer;
  Timer? _textTimer;
  String _targetText = "";
  int _charIndex = 0;

  // Helper to check if text is currently animating
  bool get isCrawling => _textTimer != null && _textTimer!.isActive;


  Command? get currentCommand =>
      (_commands.isNotEmpty && state.commandIndex > 0)
          ? _commands[state.commandIndex - 1]
          : null;

  Future<void> loadScript(String scriptName) async {
    // 1. Reset ALL engine state
    state.reset();
    state.currentScript = scriptName;
    _skipDepth = 0; // CRITICAL: Reset the conditional skip depth
    _delayTimer?.cancel();
    _textTimer?.cancel();

    // Wipe the old script commands immediately so stray inputs do nothing
    _commands.clear();

    // 1. Try to load globals, but don't let it crash the engine if global.json is missing
    try {
      state.globalVariables = await GlobalVariables.load();
    } catch (e) {
      debugPrint("Warning: Global variables could not be loaded: $e");
      state.globalVariables = {};
    }

    // 2. Load and parse the script
    try {
      String content = await rootBundle.loadString('assets/script/$scriptName');
      _commands = ScriptParser.parse(content);
    } catch (e) {
      debugPrint("Error: Script $scriptName not found or failed to parse: $e");
      return;
    }



    executeNext();
  }

  void executeNext() {
    if (state.commandIndex >= _commands.length) return;

    Command cmd = _commands[state.commandIndex];
    debugPrint("[ENGINE] Executing Index ${state.commandIndex}: ${cmd.rawLine}");
    state.commandIndex++;

    // Conditional skipping logic
    // Track nested depth while skipping
    if (_skipDepth > 0) {
      if (cmd is IfCommand) _skipDepth++;
      if (cmd is FiCommand) _skipDepth--;

      executeNext();
      return;
    }

    _processCommand(cmd);

    // Refined Blocking logic
    bool isBlocking = false;
    if (cmd is TextCommand) {
      // Only block if it's NOT instant text
      isBlocking = !cmd.isInstant;
    } else if (cmd is ChoiceCommand || cmd is DelayCommand || cmd is JumpCommand) {
      // Add JumpCommand here to halt the loop!
      isBlocking = true;
    }

    if (isBlocking) {
      notifyListeners();
    } else {
      // Use microtask to avoid stack overflow
      Future.microtask(() => executeNext());
    }
  }

  void _startCrawl(String target) {
    _textTimer?.cancel();
    _targetText = target;
    _charIndex = 0;
    state.currentText = "";

    // Adjust milliseconds (e.g., 30ms) to change text speed
    _textTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_charIndex < _targetText.length) {
        _charIndex++;
        state.currentText = _targetText.substring(0, _charIndex);
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  void _finishCrawl() {
    _textTimer?.cancel();
    state.currentText = _targetText;
    notifyListeners();
  }

  void _processCommand(Command cmd) {
    if (cmd is TextCommand) {
      if (cmd.isWait) {
        // Manual Wait: Keep existing text as is
      } else if (cmd.isInstant) {
        // text @: Stop any crawl and append immediately
        _textTimer?.cancel();
        if (state.currentText.isEmpty) {
          state.currentText = cmd.content;
        } else {
          state.currentText += "\n${cmd.content}";
        }
      } else {
        // Regular text: Start the crawling effect
        _startCrawl(cmd.content);
      }
    }

    else if (cmd is BgLoadCommand) {
      state.backgroundPath = cmd.filename;
      // Wipes all sprites when a background is drawn
      state.foregroundImages.clear();
    }

    else if (cmd is SetImgCommand) {
      String fullPath = AssetService.getForegroundPath(cmd.filename);

      // Scale coordinates from DS (256x192) to PC (800x600)
      const double scaleFactor = 3.125;

      state.foregroundImages[fullPath] = {
        'x': (cmd.x * scaleFactor).toInt(),
        'y': (cmd.y * scaleFactor).toInt(),
      };
    }

    else if (cmd is MusicCommand) {
      state.currentMusic = cmd.path;
      _audio.playMusic(cmd.path);
    }

    else if (cmd is SoundCommand) {
      _audio.playSound(cmd.path, cmd.type);
    }

    else if (cmd is SetVarCommand) {
      state.variables[cmd.variable] = cmd.value;
    }

    else if (cmd is GSetVarCommand) {
      state.globalVariables[cmd.variable] = cmd.value;
      GlobalVariables.save(state.globalVariables);
    }

    else if (cmd is JumpCommand) {
      loadScript(cmd.targetScript);
    }

    else if (cmd is DelayCommand) {
      _delayTimer = Timer(Duration(milliseconds: cmd.duration), executeNext);
    }

    else if (cmd is IfCommand) {
      int val = state.variables[cmd.variable] ?? state.globalVariables[cmd.variable] ?? 0;
      bool conditionMet = false;
      if (cmd.operator == '==' ) conditionMet = (val == cmd.value);
      if (cmd.operator == '>=' ) conditionMet = (val >= cmd.value);
      if (cmd.operator == '<=' ) conditionMet = (val <= cmd.value);

      if (!conditionMet) _skipDepth = 1; // Start skipping at depth 1
    }
  }

  void next() {
    // 1. If text is still crawling, complete it instantly on first click
    if (isCrawling) {
      _finishCrawl();
      return;
    }

    // 2. Stop voice when moving to the next line of text (leave ambient SFX alone)
    _audio.stopVoice();

    // 3. Skip delays if user clicks during a wait
    if (_delayTimer != null && _delayTimer!.isActive) {
      _delayTimer!.cancel();
      executeNext();
      return;
    }

    // 4. Standard advance logic
    if (state.commandIndex > 0) {
      Command lastCmd = _commands[state.commandIndex - 1];
      if (lastCmd is ChoiceCommand) return;
    }

    executeNext();
  }

  void makeChoice(int index) {
    // 1-based index
    state.variables['selected'] = index + 1;
    executeNext();
  }

  @override
  void dispose() {
    _textTimer?.cancel();
    _delayTimer?.cancel();
    _audio.dispose();
    super.dispose();
  }
}