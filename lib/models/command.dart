abstract class Command {}

class TextCommand extends Command {
  final String text;

  TextCommand(this.text);
}

class JumpCommand extends Command {
  final String targetScript;

  JumpCommand(this.targetScript);
}

class IfCommand extends Command {
  final String operator;
  final int value;

  IfCommand(this.operator,this.value);
}

// more commands from script here