import 'package:flutter/widgets.dart';
import '../models/command_output.dart';
import 'virtual_file_system.dart';
import '../utils/commands.dart';
import 'package:url_launcher/url_launcher.dart';

class CommandRunner {
  final VirtualFileSystem _fs = VirtualFileSystem();
  final TextEditingController controller = TextEditingController();

  String get currentPath => _fs.currentPath;

  CommandOutput run(String command) {
    final parts = command.trim().split(' ');
    final cmd = parts[0].toLowerCase();
    final args = parts.length > 1 ? parts.sublist(1) : <String>[];

    if (cmd == 'clear') {
      // This is a special case handled by the UI
      return CommandOutput(type: OutputType.text, textContent: 'clear');
    }

    switch (cmd) {
      case 'help':
        return CommandOutput(
            widgetContent: Help.widget, type: OutputType.widget);
      case 'ls':
        return CommandOutput(
            widgetContent: _fs.listDirectory(), type: OutputType.widget);
      case 'cat':
        if (args.isEmpty) {
          return CommandOutput(
              textContent: 'cat: missing operand', type: OutputType.error);
        }
        return _fs.readFile(args[0]);
      case 'cd':
        if (args.isEmpty) {
          _fs.changeDirectory('~');
          return CommandOutput(textContent: '', type: OutputType.text);
        }
        final result = _fs.changeDirectory(args[0]);
        if (result != null) {
          return CommandOutput(textContent: result, type: OutputType.error);
        }
        return CommandOutput(textContent: '', type: OutputType.text);
      case 'whoami':
        return CommandOutput(
            textContent: WhoAmI.text, type: OutputType.text);
      case 'date':
        return CommandOutput(
            textContent: DateTime.now().toString(), type: OutputType.text);
      case 'pwd':
        return CommandOutput(
            textContent: _fs.currentPath, type: OutputType.text);
      case 'github':
        launchUrl(Uri.parse("https://github.com/8bitSaiyan"));
        return CommandOutput(
            textContent: 'Opening GitHub profile...', type: OutputType.text);
      case 'tree':
        return CommandOutput(
            textContent: _fs.generateTree(), type: OutputType.text);
      case 'sudo':
        return CommandOutput(
            textContent: Sudo.text, type: OutputType.error);
      case 'coffee':
        return CommandOutput(
            widgetContent: Coffee.widget, type: OutputType.widget);
      case '':
        return CommandOutput(textContent: '', type: OutputType.text);
      default:
        return CommandOutput(
            textContent: 'bash: command not found: $cmd',
            type: OutputType.error);
    }
  }

  void dispose() {
    controller.dispose();
  }
}