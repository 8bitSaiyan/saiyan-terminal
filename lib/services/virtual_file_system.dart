import 'package:flutter/material.dart';
import '../models/command_output.dart';
import '../widgets/typing_text.dart';

class VirtualFileSystem {
  String currentPath = '~';
  final Map<String, dynamic> _structure = {
    '~': {
      'about_me.txt': '''
I'm 8bitSaiyan,

I've spent years in the background — learning, building, refining.

No noise. No spotlight. Just consistent work and quiet growth.  
Every line, every idea, every failure — part of the process.

This isn’t about proving anything.  
It’s about precision. Discipline. Momentum.

If you're here, explore.  
Everything else reveals itself through action.
''',
      'contact_info.txt': '''
[+] GitHub: https://github.com/8bitSaiyan (or type 'github')
''',
      'projects': {
        'portfolio_v1': {
          'README.md':
              'The terminal you are using right now. Built with Flutter for Web.',
        },
        'stealth_runner': {
          'README.md':
              'A 2D infinite runner game with a stealth mechanic. Built with Godot Engine.',
        },
      },
    },
  };

  dynamic _resolvePath(String path) {
    // A more robust resolver
    if (path == '~') return _structure['~'];
    // Start from home for paths like '~/projects'
    final parts =
        path.startsWith('~/') ? path.substring(2).split('/') : path.split('/');
    dynamic current = _structure['~'];

    for (var part in parts) {
      if (part.isEmpty) continue;
      if (current is Map<String, dynamic> && current.containsKey(part)) {
        current = current[part];
      } else {
        return null; // Path does not exist
      }
    }
    return current;
  }

  Widget listDirectory() {
    final currentDir = _resolvePath(currentPath);
    if (currentDir == null || currentDir is! Map<String, dynamic>) {
      return Text(
        'ls: cannot access \'$currentPath\': No such file or directory',
        style: const TextStyle(color: Colors.red),
      );
    }

    if (currentDir.keys.isEmpty) {
      return const SizedBox.shrink(); // Return empty widget for empty dir
    }

    final items =
        currentDir.keys.map((name) {
          final isDir = currentDir[name] is Map;
          return Text(
            name,
            style: TextStyle(
              color: isDir ? Colors.blueAccent : const Color(0xFF00DD00),
            ),
          );
        }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
    );
  }

  CommandOutput readFile(String fileName) {
    final currentDir = _resolvePath(currentPath);
    if (currentDir != null &&
        currentDir is Map<String, dynamic> &&
        currentDir.containsKey(fileName) &&
        currentDir[fileName] is String) {
      return CommandOutput(
        type: OutputType.widget,
        widgetContent: TypingText(text: currentDir[fileName]),
      );
    }
    return CommandOutput(
      type: OutputType.error,
      textContent: 'cat: $fileName: No such file or directory',
    );
  }

  String? changeDirectory(String dirName) {
    // Priority 1: Handle `cd` or `cd ~` to go home. This is the simple logic you wanted.
    if (dirName == '~') {
      currentPath = '~';
      return null;
    }

    // Priority 2: Handle `cd ..` to go up one directory
    if (dirName == '..') {
      if (currentPath == '~') return null; // Already at root
      var parts = currentPath.split('/');
      parts.removeLast();
      currentPath = parts.join('/');
      return null;
    }

    // Priority 3: Handle navigating into a subdirectory
    final newPath =
        (currentPath == '~')
            ? '~/$dirName'
            : '$currentPath/$dirName';
    final target = _resolvePath(newPath);

    if (target is Map<String, dynamic>) {
      currentPath = newPath;
    } else {
      return 'cd: no such file or directory: $dirName';
    }
    return null;
  }

  String generateTree() {
    return _generateTreeRecursive(_structure['~']!, '~');
  }

  String _generateTreeRecursive(
    Map<String, dynamic> dir,
    String prefix, [
    String header = '',
  ]) {
    var buffer = StringBuffer(header);
    var entries = dir.keys.toList();
    for (int i = 0; i < entries.length; i++) {
      var key = entries[i];
      var isLast = i == entries.length - 1;
      buffer.write('$prefix${isLast ? '└── ' : '├── '}$key\n');
      var value = dir[key];
      if (value is Map<String, dynamic>) {
        buffer.write(
          _generateTreeRecursive(value, '$prefix${isLast ? '    ' : '│   '}'),
        );
      }
    }
    return buffer.toString();
  }
}
