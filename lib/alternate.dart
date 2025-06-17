import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(TerminalPortfolioApp());
}

class TerminalPortfolioApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PRITHVI - Terminal Portfolio',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Courier',
      ),
      home: TerminalScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TerminalScreen extends StatefulWidget {
  @override
  _TerminalScreenState createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  List<TerminalLine> _lines = [];
  List<String> _commandHistory = [];
  int _historyIndex = -1;
  String _currentDirectory = '~';
  bool _showCursor = true;
  bool _isBooting = true;
  bool _showCommandPanel = true;

  late AnimationController _cursorController;
  late AnimationController _matrixController;

  final FileSystem _fileSystem = FileSystem();

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _matrixController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    _startBootSequence();
  }

  @override
  void dispose() {
    _cursorController.dispose();
    _matrixController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startBootSequence() async {
    // Matrix effect
    _matrixController.forward();
    await Future.delayed(Duration(seconds: 3));

    setState(() {
      _isBooting = false;
    });

    // Boot messages
    await _typeBootMessages();

    // ASCII Banner
    await _showASCIIBanner();

    // Welcome message
    await _typeWelcomeMessage();

    _focusNode.requestFocus();
  }

  Future<void> _typeBootMessages() async {
    List<String> bootMessages = [
      'Starting PRITHVI Terminal Portfolio...',
      'Loading user interface... [OK]',
      'Initializing file system... [OK]',
      'Setting up command interpreter... [OK]',
      'Portfolio ready!',
      '',
    ];

    for (String message in bootMessages) {
      await _typeMessage(message, Colors.grey);
      await Future.delayed(Duration(milliseconds: 300));
    }
  }

  Future<void> _showASCIIBanner() async {
    String banner = '''
 _____ _____ _____ _______ _   _ __      __ _____
|  __ \\|  __ \\|_   _|__   __| | | |\\ \\    / /|_   _|
| |__) | |__) | | |    | |  | |_| | \\ \\  / /   | |  
|  ___/|  ___/  | |    | |  |  _  |  \\ \\/ /    | |  
| |    | |     _| |_   | |  | | | |   \\  /    _| |_ 
|_|    |_|    |_____|  |_|  |_| |_|    \\/    |_____|
''';

    await _typeMessage(banner, Color(0xFF00FF00));
    await Future.delayed(Duration(milliseconds: 500));
  }

  Future<void> _typeWelcomeMessage() async {
    List<String> welcomeMessages = [
      '',
      'Welcome to PRITHVI\'s Terminal Portfolio!',
      '',
      'Type "help" to see available commands.',
      'Type "ls" to explore the file system.',
      'Try "cat about_me.txt" to learn more about me.',
      '',
    ];

    for (String message in welcomeMessages) {
      await _typeMessage(message, Color(0xFF00DD00));
      await Future.delayed(Duration(milliseconds: 100));
    }
  }

  Future<void> _typeMessage(String message, Color color) async {
    setState(() {
      _lines.add(TerminalLine(message, color, false));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleCommand(String input) {
    if (input.trim().isEmpty) return;

    setState(() {
      _lines.add(TerminalLine('$_currentDirectory\$ $input', Color(0xFF00FF00), false));
      _commandHistory.insert(0, input);
      _historyIndex = -1;
    });

    _processCommand(input.trim());
    _controller.clear();
    _scrollToBottom();
  }

  void _processCommand(String command) {
    List<String> parts = command.split(' ');
    String cmd = parts[0].toLowerCase();

    switch (cmd) {
      case 'help':
        _showHelp();
        break;
      case 'ls':
        _listFiles(parts.length > 1 ? parts[1] : _currentDirectory);
        break;
      case 'cat':
        if (parts.length > 1) {
          _catFile(parts[1]);
        } else {
          _addLine('cat: missing file operand', Colors.red);
        }
        break;
      case 'cd':
        if (parts.length > 1) {
          _changeDirectory(parts[1]);
        } else {
          _currentDirectory = '~';
          setState(() {});
        }
        break;
      case 'pwd':
        _addLine(_currentDirectory, Color(0xFF00DD00));
        break;
      case 'clear':
        setState(() {
          _lines.clear();
        });
        break;
      case 'whoami':
        _addLine('prithvi', Color(0xFF00DD00));
        break;
      case 'date':
        _addLine(DateTime.now().toString(), Color(0xFF00DD00));
        break;
      case 'tree':
        _showTree();
        break;
      case 'history':
        _showHistory();
        break;
      case 'uname':
        _addLine('Linux prithvi-portfolio 5.4.0 #1 SMP Flutter Web x86_64 GNU/Linux', Color(0xFF00DD00));
        break;
      case 'matrix':
        _startMatrixMode();
        break;
      case 'coffee':
        _showCoffee();
        break;
      case 'exit':
        _addLine('Thanks for visiting! Goodbye! 👋', Color(0xFF00DD00));
        break;
      default:
        _addLine('$cmd: command not found', Colors.red);
        _addLine('Type "help" for available commands', Color(0xFF00DD00));
    }
  }

  void _addLine(String text, Color color) {
    setState(() {
      _lines.add(TerminalLine(text, color, false));
    });
  }

  void _showHelp() {
    List<String> helpText = [
      '',
      'Available Commands:',
      '  ls          - list directory contents',
      '  cat <file>  - display file contents',
      '  cd <dir>    - change directory',
      '  pwd         - show current directory',
      '  clear       - clear terminal screen',
      '  help        - show this help message',
      '  whoami      - display current user',
      '  date        - show current date/time',
      '  tree        - show directory structure',
      '  history     - show command history',
      '  uname       - system information',
      '  matrix      - enter matrix mode',
      '  coffee      - take a coffee break',
      '  exit        - say goodbye',
      '',
      'Navigation Tips:',
      '  Use Tab for auto-completion',
      '  Use ↑/↓ arrows for command history',
      '  Try exploring with "ls" and "cd"',
      '',
    ];

    for (String line in helpText) {
      _addLine(line, Color(0xFF00DD00));
    }
  }

  void _listFiles(String directory) {
    List<FileSystemItem> items = _fileSystem.listDirectory(directory);
    if (items.isEmpty) {
      _addLine('ls: cannot access \'$directory\': No such file or directory', Colors.red);
      return;
    }

    for (FileSystemItem item in items) {
      Color color = item.isDirectory ? Colors.blue : Color(0xFF00DD00);
      String prefix = item.isDirectory ? 'd' : '-';
      String permissions = item.isDirectory ? 'rwxr-xr-x' : 'rw-r--r--';
      String size = item.isDirectory ? '4096' : '${item.content?.length ?? 0}';

      _addLine('$prefix$permissions 1 prithvi prithvi $size Jan 15 12:00 ${item.name}', color);
    }
  }

  void _catFile(String filename) {
    String? content = _fileSystem.readFile(_currentDirectory, filename);
    if (content != null) {
      List<String> lines = content.split('\n');
      for (String line in lines) {
        _addLine(line, Color(0xFF00DD00));
      }
    } else {
      _addLine('cat: $filename: No such file or directory', Colors.red);
    }
  }

  void _changeDirectory(String directory) {
    if (_fileSystem.directoryExists(_currentDirectory, directory)) {
      if (directory == '..') {
        if (_currentDirectory != '~') {
          List<String> parts = _currentDirectory.split('/');
          parts.removeLast();
          _currentDirectory = parts.isEmpty ? '~' : parts.join('/');
        }
      } else if (directory.startsWith('/')) {
        _currentDirectory = directory;
      } else {
        _currentDirectory = _currentDirectory == '~' ? directory : '$_currentDirectory/$directory';
      }
      setState(() {});
    } else {
      _addLine('cd: $directory: No such file or directory', Colors.red);
    }
  }

  void _showTree() {
    List<String> tree = [
      '~/',
      '├── about_me.txt',
      '├── resume.pdf',
      '├── contact_info.txt',
      '├── skills.json',
      '├── about/',
      '│   ├── bio.txt',
      '│   ├── interests.md',
      '│   └── timeline.log',
      '├── projects/',
      '│   ├── flutter_apps/',
      '│   ├── web_projects/',
      '│   └── open_source/',
      '├── blog/',
      '│   ├── tech_posts/',
      '│   └── personal_thoughts/',
      '├── contact/',
      '│   ├── social_links.txt',
      '│   ├── email.txt',
      '│   └── location.txt',
      '└── .hidden/',
      '    ├── easter_eggs.txt',
      '    ├── quotes.txt',
      '    └── fun_facts.json',
    ];

    for (String line in tree) {
      _addLine(line, Color(0xFF00DD00));
    }
  }

  void _showHistory() {
    _addLine('Command History:', Color(0xFF00DD00));
    for (int i = 0; i < _commandHistory.length && i < 10; i++) {
      _addLine('${i + 1}  ${_commandHistory[i]}', Color(0xFF00DD00));
    }
  }

  void _startMatrixMode() {
    _addLine('Entering Matrix Mode...', Colors.green);
    _addLine('Wake up, Neo... 🔴💊', Colors.green);
    // Matrix animation would go here
    Future.delayed(Duration(seconds: 2), () {
      _addLine('Matrix mode activated! Reality is now optional.', Colors.green);
    });
  }

  void _showCoffee() {
    String coffeeArt = '''
    ( (
     ) )
  ........
  |      |]
  \\      /
   `----'
''';
    List<String> lines = coffeeArt.split('\n');
    for (String line in lines) {
      _addLine(line, Colors.brown);
    }
    _addLine('☕ Taking a coffee break... Ahh, that\'s better!', Color(0xFF00DD00));
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (_historyIndex < _commandHistory.length - 1) {
          _historyIndex++;
          _controller.text = _commandHistory[_historyIndex];
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        if (_historyIndex > 0) {
          _historyIndex--;
          _controller.text = _commandHistory[_historyIndex];
        } else if (_historyIndex == 0) {
          _historyIndex = -1;
          _controller.clear();
        }
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Matrix effect overlay
          if (_isBooting)
            MatrixRain(controller: _matrixController),

          // Main terminal interface
          if (!_isBooting)
            Column(
              children: [
                // Terminal content
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _lines.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _lines.length) {
                          // Input line
                          return Row(
                            children: [
                              Text(
                                '$_currentDirectory\$ ',
                                style: TextStyle(
                                  color: Color(0xFF00FF00),
                                  fontFamily: 'Courier',
                                  fontSize: 14,
                                ),
                              ),
                              Expanded(
                                child: RawKeyboardListener(
                                  focusNode: _focusNode,
                                  onKey: _handleKeyEvent,
                                  child: TextField(
                                    controller: _controller,
                                    style: TextStyle(
                                      color: Color(0xFF00FF00),
                                      fontFamily: 'Courier',
                                      fontSize: 14,
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onSubmitted: _handleCommand,
                                  ),
                                ),
                              ),
                              AnimatedBuilder(
                                animation: _cursorController,
                                builder: (context, child) {
                                  return Text(
                                    _cursorController.value > 0.5 ? '_' : ' ',
                                    style: TextStyle(
                                      color: Color(0xFF00FF00),
                                      fontFamily: 'Courier',
                                      fontSize: 14,
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        }

                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 1),
                          child: Text(
                            _lines[index].text,
                            style: TextStyle(
                              color: _lines[index].color,
                              fontFamily: 'Courier',
                              fontSize: 14,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

          // Command panel
          if (_showCommandPanel && !_isBooting)
            Positioned(
              top: 16,
              right: 16,
              child: CommandPanel(
                onToggle: () {
                  setState(() {
                    _showCommandPanel = !_showCommandPanel;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}

class TerminalLine {
  final String text;
  final Color color;
  final bool isCommand;

  TerminalLine(this.text, this.color, this.isCommand);
}

class MatrixRain extends StatefulWidget {
  final AnimationController controller;

  MatrixRain({required this.controller});

  @override
  _MatrixRainState createState() => _MatrixRainState();
}

class _MatrixRainState extends State<MatrixRain> {
  final List<MatrixColumn> columns = [];
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _initializeColumns();
  }

  void _initializeColumns() {
    for (int i = 0; i < 50; i++) {
      columns.add(MatrixColumn(
        x: random.nextDouble(),
        speed: 0.01 + random.nextDouble() * 0.02,
        characters: _generateRandomChars(),
      ));
    }
  }

  String _generateRandomChars() {
    String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(20, (index) => chars[random.nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return CustomPaint(
          painter: MatrixPainter(columns, widget.controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class MatrixColumn {
  double x;
  double speed;
  String characters;

  MatrixColumn({required this.x, required this.speed, required this.characters});
}

class MatrixPainter extends CustomPainter {
  final List<MatrixColumn> columns;
  final double animationValue;

  MatrixPainter(this.columns, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (var column in columns) {
      double y = (animationValue * size.height * 2) % (size.height + 200) - 200;

      for (int i = 0; i < column.characters.length; i++) {
        textPainter.text = TextSpan(
          text: column.characters[i],
          style: TextStyle(
            color: Colors.green.withOpacity(1.0 - (i * 0.05)),
            fontSize: 16,
            fontFamily: 'Courier',
          ),
        );

        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(column.x * size.width, y + (i * 20)),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CommandPanel extends StatelessWidget {
  final VoidCallback onToggle;

  CommandPanel({required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        border: Border.all(color: Color(0xFF00FF00)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '┌─[ COMMANDS ]──────────────┐',
                style: TextStyle(
                  color: Color(0xFF00FF00),
                  fontFamily: 'Courier',
                  fontSize: 12,
                ),
              ),
              GestureDetector(
                onTap: onToggle,
                child: Text(
                  '×',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          ..._buildCommandList(),
          Text(
            '└───────────────────────────┘',
            style: TextStyle(
              color: Color(0xFF00FF00),
              fontFamily: 'Courier',
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCommandList() {
    List<Map<String, String>> commands = [
      {'cmd': 'ls', 'desc': 'list files'},
      {'cmd': 'cat', 'desc': 'read file'},
      {'cmd': 'cd', 'desc': 'change dir'},
      {'cmd': 'pwd', 'desc': 'current path'},
      {'cmd': 'clear', 'desc': 'clear screen'},
      {'cmd': 'help', 'desc': 'show help'},
      {'cmd': 'tree', 'desc': 'show structure'},
      {'cmd': 'whoami', 'desc': 'user info'},
      {'cmd': 'date', 'desc': 'current time'},
      {'cmd': 'exit', 'desc': 'close terminal'},
    ];

    return commands.map((cmd) => Text(
      '│ ${cmd['cmd']!.padRight(6)} - ${cmd['desc']} │',
      style: TextStyle(
        color: Color(0xFF00DD00),
        fontFamily: 'Courier',
        fontSize: 12,
      ),
    )).toList();
  }
}

class FileSystemItem {
  final String name;
  final bool isDirectory;
  final String? content;
  final List<FileSystemItem>? children;

  FileSystemItem({
    required this.name,
    required this.isDirectory,
    this.content,
    this.children,
  });
}

class FileSystem {
  final Map<String, List<FileSystemItem>> _directories = {
    '~': [
      FileSystemItem(name: 'about_me.txt', isDirectory: false, content: '''Hello! I'm PRITHVI 👋

I'm a passionate developer who loves creating digital experiences.
When I'm not coding, you can find me exploring new technologies,
contributing to open source projects, or sharing knowledge with
the developer community.

Tech Stack: Flutter, Dart, JavaScript, Python, React
Interests: Mobile Development, Web Technologies, UI/UX Design
Location: India

Feel free to explore my projects and get in touch!

---
"Code is poetry written in logic"'''),
      FileSystemItem(name: 'resume.pdf', isDirectory: false, content: 'Resume file - Contact me for the latest version!'),
      FileSystemItem(name: 'contact_info.txt', isDirectory: false, content: '''Contact Information:

Email: prithvi@example.com
LinkedIn: linkedin.com/in/prithvi
GitHub: github.com/prithvi
Twitter: @prithvi_dev

Location: India
Timezone: IST (UTC+5:30)

Feel free to reach out for collaboration opportunities!'''),
      FileSystemItem(name: 'skills.json', isDirectory: false, content: '''{
  "programming_languages": [
    "Dart", "JavaScript", "Python", "Java", "C++"
  ],
  "frameworks": [
    "Flutter", "React", "Node.js", "Express"
  ],
  "tools": [
    "Git", "Docker", "VS Code", "Firebase"
  ],
  "databases": [
    "MongoDB", "PostgreSQL", "Firebase"
  ],
  "soft_skills": [
    "Problem Solving", "Team Collaboration", "Communication"
  ]
}'''),
      FileSystemItem(name: 'about', isDirectory: true),
      FileSystemItem(name: 'projects', isDirectory: true),
      FileSystemItem(name: 'blog', isDirectory: true),
      FileSystemItem(name: 'contact', isDirectory: true),
      FileSystemItem(name: '.hidden', isDirectory: true),
    ],
    'about': [
      FileSystemItem(name: 'bio.txt', isDirectory: false, content: '''Full Bio:

I started my journey in software development during college, where I discovered
my passion for creating user-friendly applications. Over the years, I've worked
on various projects ranging from mobile apps to web applications.

My approach to development is user-centric, always thinking about how to make
technology more accessible and enjoyable for everyone.

When I'm not coding, I enjoy reading tech blogs, contributing to open source
projects, and mentoring aspiring developers.'''),
      FileSystemItem(name: 'interests.md', isDirectory: false, content: '''# My Interests

## Technology
- Mobile App Development
- Web Technologies
- UI/UX Design
- Open Source Contributions

## Hobbies
- Photography
- Reading
- Travel
- Gaming

## Learning Goals
- Machine Learning
- Cloud Computing
- DevOps Practices'''),
      FileSystemItem(name: 'timeline.log', isDirectory: false, content: '''Career Timeline:

2024 - Started Terminal Portfolio Project
2023 - Contributed to 5+ Open Source Projects
2022 - Built first Flutter application
2021 - Learned JavaScript and React
2020 - Started programming journey with Python
2019 - Graduated from Computer Science'''),
    ],
  };

  List<FileSystemItem> listDirectory(String path) {
    return _directories[path] ?? [];
  }

  String? readFile(String directory, String filename) {
    List<FileSystemItem>? items = _directories[directory];
    if (items != null) {
      for (FileSystemItem item in items) {
        if (item.name == filename && !item.isDirectory) {
          return item.content;
        }
      }
    }
    return null;
  }

  bool directoryExists(String currentDir, String targetDir) {
    if (targetDir == '..') return true;

    List<FileSystemItem>? items = _directories[currentDir];
    if (items != null) {
      for (FileSystemItem item in items) {
        if (item.name == targetDir && item.isDirectory) {
          return true;
        }
      }
    }
    return _directories.containsKey(targetDir);
  }
}