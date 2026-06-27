import '../../models/command.dart';

class ScriptParser {
  static List<Command> parse(String scriptContent) {
    List<Command> commands = [];
    List<String> lines = scriptContent.split('\n');

    for (String line in lines) {
      line = line.trim();
      // skip empty and comment line in scripts
      if (line.isEmpty || line.startsWith('#')) continue;

      // Handle 'text' command
      if (line.startsWith('text ')) {
        commands.add(TextCommand(line.substring(5).trim()));
        continue;
      }

      // Handle other commands
      List<String> parts = line.split(RegExp(r'\s+'));
      String commandName = parts[0].toLowerCase();
      List<String> args = parts.sublist(1);

      switch (commandName) {
        case 'bgload':
          if (args.isNotEmpty) commands.add(BgLoadCommand(args[0]));
          break;
        case 'setimg':
          if (args.length >= 3) {
            commands.add(
              SetImgCommand(args[0], int.parse(args[1]), int.parse(args[2])),
            );
          }
          break;
        case 'music':
          commands.add(MusicCommand(args.isNotEmpty ? args[0] : '~'));
          break;
        case 'sound':
          if (args.isNotEmpty) {
            commands.add(
              SoundCommand(args[0], args.length > 1 ? args[1] : '1'),
            );
          }
          break;
        case 'delay':
          if (args.isNotEmpty) commands.add(DelayCommand(int.parse(args[0])));
          break;
        case 'jump':
          if (args.isNotEmpty) commands.add(JumpCommand(args[0]));
          break;
        case 'setvar':
          // Syntax: setvar var = 1
          if (args.length >= 3)
            commands.add(SetVarCommand(args[0], int.parse(args[2])));
          break;
        case 'gsetvar':
          if (args.length >= 3) {
            commands.add(GSetVarCommand(args[0], int.parse(args[2])));
          }
          break;
        case 'choice':
          commands.add(ChoiceCommand(args.join(' ').split('|')));
          break;
        case 'if':
          if (args.length >= 3)
            commands.add(IfCommand(args[0], args[1], int.parse(args[2])));
          break;
        case 'fi':
          commands.add(FiCommand());
          break;
      }
    }

    return commands;
  }
}
