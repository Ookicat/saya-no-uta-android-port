import 'package:flutter/services.dart';
import 'package:saya_no_uta/services/asset_service.dart';
import 'package:saya_no_uta/services/audio_service.dart';
import 'package:saya_no_uta/services/engine/global_variables.dart';
import '../../models/command.dart';
import '../../models/game_state.dart';
import 'parser.dart';

class GameEngine {
  final GameState state = GameState();
  final AudioService _audio = AudioService();
  List<Command> _commands = [];
  bool _isSkipping = false;

  Future<void> loadScript(String scriptName) async {
    state.reset();
    state.currentScript = scriptName;
    state.commandIndex = 0;
    state.globalVariables = await GlobalVariables.load();

    String content = await rootBundle.loadString('assets/script/$scriptName');
    _commands = ScriptParser.parse(content);
    executeNext();
  }

  void executeNext() {
    if (state.commandIndex >= _commands.length) return;

    Command cmd = _commands[state.commandIndex];
    state.commandIndex++;

    // Conditional skipping logic
    if (_isSkipping) {
      if (cmd is FiCommand) _isSkipping = false;
      executeNext();
      return;
    }

    _processCommand(cmd);

    // Auto-advance for non-blocking commands
    // Text, Choice, and Delay are "blocking" commands that wait for user/timer
    if (cmd is! TextCommand && cmd is! ChoiceCommand && cmd is! DelayCommand) {
      executeNext();
    }
  }

  void _processCommand(Command cmd) {
    if (cmd is TextCommand) {
      state.currentText = cmd.content;
    }

    else if (cmd is BgLoadCommand) {
      state.backgroundPath = cmd.filename;
    }

    else if (cmd is SetImgCommand) {
      String fullPath = AssetService.getForegroundPath(cmd.filename);
      state.foregroundImages[fullPath] = {'x': cmd.x, 'y': cmd.y};
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
      Future.delayed(Duration(milliseconds: cmd.duration), executeNext);
    }

    else if (cmd is IfCommand) {
      int val = state.variables[cmd.variable] ?? state.globalVariables[cmd.variable] ?? 0;
      bool conditionMet = false;
      if (cmd.operator == '==' ) conditionMet = (val == cmd.value);
      if (cmd.operator == '>=' ) conditionMet = (val >= cmd.value);
      if (cmd.operator == '<=' ) conditionMet = (val <= cmd.value);

      if (!conditionMet) _isSkipping = true;
    }
  }
}