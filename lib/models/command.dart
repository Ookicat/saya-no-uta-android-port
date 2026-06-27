abstract class Command {
 String rawLine = "";
}

class TextCommand extends Command {
  final String content;
  final bool isInstant; // True for 'text @...'
  final bool isWait;    // True for 'text !'

  TextCommand(this.content, {this.isInstant = false, this.isWait = false});
}

class BgLoadCommand extends Command {
  final String filename;
  BgLoadCommand(this.filename);
}

class SetImgCommand extends Command {
  final String filename;
  final int x;
  final int y;
  SetImgCommand(this.filename, this.x, this.y);
}

class MusicCommand extends Command {
  final String path; // '~' means stop
  MusicCommand(this.path);
}

class SoundCommand extends Command {
  final String path;
  final String type;
  SoundCommand(this.path, this.type);
}

class SetVarCommand extends Command {
  final String variable;
  final int value;
  SetVarCommand(this.variable, this.value);
}

class GSetVarCommand extends Command {
  final String variable;
  final int value;
  GSetVarCommand(this.variable, this.value);
}

class JumpCommand extends Command {
  final String targetScript;
  JumpCommand(this.targetScript);
}

class ChoiceCommand extends Command {
  final List<String> options;
  ChoiceCommand(this.options);
}

class IfCommand extends Command {
  final String variable;
  final String operator;
  final int value;
  IfCommand(this.variable, this.operator, this.value);
}

class FiCommand extends Command {}

class DelayCommand extends Command {
  final int duration;
  DelayCommand(this.duration);
}