import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const TerminalApp());
}

class TerminalApp extends StatelessWidget {
  const TerminalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'prithvi.dev',
      theme: ThemeData(
        primaryColor: const Color(0xFF00FF00),
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'FiraCode',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF00FF00), fontSize: 16),
          bodyMedium: TextStyle(color: Color(0xFF00FF00), fontSize: 16),
        ),
      ),
      home: const TerminalScreen(),
    );
  }
}

class TerminalScreen extends StatefulWidget {
  const TerminalScreen({super.key});

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<Widget> _terminalOutput = [];
  final ScrollController _scrollController = ScrollController();
  List<String> _commandHistory = [];
  int _historyIndex = 0;

  // --- Virtual File System ---
  final Map<String, dynamic> _fileSystem = {
    'about_me.txt': '''
Hello! I'm PRITHVI,

I'm a passionate developer who loves creating digital experiences.
When I'm not coding, you can find me exploring new technologies,
contributing to open source projects, or sharing knowledge with
the developer community.

Tech Stack: Flutter, Dart, JavaScript, Python, React
Interests: Mobile Development, Web Technologies, UI/UX Design

Feel free to explore my projects and get in touch!
''',
    'contact_info.txt': '''
[+] Email: your.email@example.com
[+] LinkedIn: linkedin.com/in/yourprofile
[+] GitHub: github.com/yourusername
''',
    'projects': {
      'project1': {
        'README.md': 'This is the first cool project.',
      },
      'project2': {
        'README.md': 'This is another awesome project.',
      }
    },
  };
  String _currentPath = '~';

  @override
  void initState() {
    super.initState();
    _startBootSequence();
  }

  void _startBootSequence() {
    _terminalOutput.add(
      const Text(
        r'''


   ___  ___  ____________ ___   ______
  / _ \/ _ \/  _/_  __/ // / | / /  _/
 / ___/ , _// /  / / / _  /| |/ // /  
/_/  /_/|_/___/ /_/ /_//_/ |___/___/  
                                      
 

Welcome to my interactive terminal portfolio.
Type "help" to see a list of available commands.
''',
        style: TextStyle(color: Color(0xFF00FF00)),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onCommandSubmitted(String command) {
    setState(() {
      _terminalOutput.add(_buildPrompt(command));
      _commandHistory.add(command);
      _historyIndex = _commandHistory.length;
      _processCommand(command.trim().toLowerCase());
      _controller.clear();
      // Scroll to the bottom after a command is processed
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    });
  }

  void _processCommand(String command) {
    final parts = command.split(' ');
    final cmd = parts[0];

    switch (cmd) {
      case 'help':
        _terminalOutput.add(const Text(
          '''
Available Commands:
  ls          - list files and directories
  cat [file]  - display file content
  cd [dir]    - change directory
  pwd         - show current directory path
  clear       - clear the terminal screen
  whoami      - display user information
  date        - show the current date and time
  help        - display this help message
''',
          style: TextStyle(color: Color(0xFF00DD00)),
        ));
        break;
      case 'ls':
        _terminalOutput.add(_buildFileSystemList());
        break;
      case 'cat':
        if (parts.length > 1) {
          final content = _readFile(parts[1]);
          _terminalOutput.add(Text(
            content,
            style: const TextStyle(color: Color(0xFF00DD00)),
          ));
        } else {
          _terminalOutput.add(const Text(
            'cat: missing operand',
            style: TextStyle(color: Colors.red),
          ));
        }
        break;
      case 'clear':
        _terminalOutput.clear();
        break;
      case 'whoami':
        _terminalOutput.add(const Text(
          'user: visitor\nname: Prithvi',
          style: TextStyle(color: Color(0xFF00DD00)),
        ));
        break;
      case 'date':
        _terminalOutput.add(Text(
          DateTime.now().toString(),
          style: const TextStyle(color: Color(0xFF00DD00)),
        ));
        break;
      case 'pwd':
        _terminalOutput.add(Text(
          _currentPath,
          style: const TextStyle(color: Color(0xFF00DD00)),
        ));
        break;
      case 'cd':
      // Basic CD implementation, does not support .. or full paths yet
        _terminalOutput.add(const Text(
          'cd: functionality coming soon!',
          style: TextStyle(color: Colors.yellow),
        ));
        break;
      case '':
        break; // Do nothing on empty command
      default:
        _terminalOutput.add(Text(
          'bash: command not found: $cmd',
          style: const TextStyle(color: Colors.red),
        ));
    }
  }

  Widget _buildFileSystemList() {
    // This is a simplified version. A real one would parse _currentPath
    final items = _fileSystem.keys.map((name) {
      final isDir = _fileSystem[name] is Map;
      return Text(
        name,
        style: TextStyle(color: isDir ? Colors.blue : const Color(0xFF00DD00)),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
    );
  }

  String _readFile(String fileName) {
    // This is a simplified version. A real one would parse _currentPath
    if (_fileSystem.containsKey(fileName) && _fileSystem[fileName] is String) {
      return _fileSystem[fileName];
    }
    return 'cat: $fileName: No such file or directory';
  }


  Widget _buildPrompt(String command) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
            fontFamily: 'FiraCode', color: Color(0xFF00FF00), fontSize: 16),
        children: [
          const TextSpan(
            text: 'user@prithvi-portfolio:~\$ ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: command),
        ],
      ),
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          if (_historyIndex > 0) {
            _historyIndex--;
            _controller.text = _commandHistory[_historyIndex];
            _controller.selection = TextSelection.fromPosition(
                TextPosition(offset: _controller.text.length));
          }
        });
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          if (_historyIndex < _commandHistory.length - 1) {
            _historyIndex++;
            _controller.text = _commandHistory[_historyIndex];
            _controller.selection = TextSelection.fromPosition(
                TextPosition(offset: _controller.text.length));
          } else {
            _historyIndex = _commandHistory.length;
            _controller.clear();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => _focusNode.requestFocus(),
            child: Container(
              color: Colors.black,
              padding: const EdgeInsets.all(12.0),
              child: ListView(
                controller: _scrollController,
                children: [
                  ..._terminalOutput,
                  KeyboardListener(
                    focusNode: FocusNode(), // Separate focus node for keys
                    onKeyEvent: _handleKeyEvent,
                    child: Row(
                      children: [
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontFamily: 'FiraCode',
                              color: Color(0xFF00FF00),
                              fontSize: 16,
                            ),
                            children: [
                              TextSpan(
                                text: 'user@prithvi-portfolio:~\$ ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            autofocus: true,
                            onSubmitted: _onCommandSubmitted,
                            cursorColor: const Color(0xFF00FF00),
                            style: const TextStyle(
                                color: Color(0xFF00FF00), fontSize: 16),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const CommandInfoPanel(),
        ],
      ),
    );
  }
}

class CommandInfoPanel extends StatelessWidget {
  const CommandInfoPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 15,
      right: 15,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          border: Border.all(color: const Color(0xFF00FF00)),
        ),
        child: const Text(
          '''
┌─[ COMMANDS ]──────────────┐
│ ls     - list files       │
│ cat    - read file        │
│ cd     - change dir       │
│ pwd    - current path     │
│ clear  - clear screen     │
│ help   - show help        │
│ whoami - user info        │
│ date   - current time     │
└───────────────────────────┘''',
          style: TextStyle(
              color: Color(0xFF00DD00), fontSize: 14, fontFamily: 'FiraCode'),
        ),
      ),
    );
  }
}