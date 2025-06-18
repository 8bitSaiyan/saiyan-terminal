import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/command_output.dart';
import 'services/command_runner.dart';
import 'widgets/command_info_panel.dart';
import 'widgets/terminal_input.dart';
import 'widgets/terminal_line.dart';
import 'utils/commands.dart';

void main() {
  runApp(const TerminalApp());
}

class TerminalApp extends StatelessWidget {
  const TerminalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '8bitSaiyan',
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
  final CommandRunner _commandRunner = CommandRunner();
  final List<CommandOutput> _terminalOutput = [];
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final List<String> _commandHistory = [];
  int _historyIndex = 0;

  @override
  void initState() {
    super.initState();
    _terminalOutput.add(CommandOutput(
      type: OutputType.widget,
      widgetContent: WelcomeMessage.widget,
    ));
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    }
  }

  void _onCommandSubmitted(String command) {
    final trimmedCommand = command.trim();
    if (trimmedCommand.isEmpty) {
      setState(() {
        _terminalOutput.add(CommandOutput(input: '', path: _commandRunner.currentPath));
      });
    } else {
      if (trimmedCommand.toLowerCase() == 'clear') {
        setState(() {
          _terminalOutput.clear();
          _commandHistory.add(trimmedCommand);
          _historyIndex = _commandHistory.length;
        });
      } else {
        setState(() {
          _terminalOutput.add(CommandOutput(
            input: trimmedCommand,
            path: _commandRunner.currentPath,
          ));
          final output = _commandRunner.run(trimmedCommand);
          _terminalOutput.add(output);
          _commandHistory.add(trimmedCommand);
          _historyIndex = _commandHistory.length;
        });
      }
    }

    _commandRunner.controller.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _moveCursorToEnd() {
    _commandRunner.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _commandRunner.controller.text.length),
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (_historyIndex > 0) {
        setState(() {
          _historyIndex--;
          final previousCommand = _commandHistory[_historyIndex];
          _commandRunner.controller.text = previousCommand;
          // FIX: Schedule cursor move to after the build
          WidgetsBinding.instance.addPostFrameCallback((_) => _moveCursorToEnd());
        });
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (_historyIndex < _commandHistory.length - 1) {
        setState(() {
          _historyIndex++;
          final nextCommand = _commandHistory[_historyIndex];
          _commandRunner.controller.text = nextCommand;
          // FIX: Schedule cursor move to after the build
          WidgetsBinding.instance.addPostFrameCallback((_) => _moveCursorToEnd());
        });
      } else {
        setState(() {
          _historyIndex = _commandHistory.length;
          _commandRunner.controller.clear();
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
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _terminalOutput.length + 1,
                itemBuilder: (context, index) {
                  if (index == _terminalOutput.length) {
                    return KeyboardListener(
                      focusNode: FocusNode(),
                      onKeyEvent: _handleKeyEvent,
                      child: TerminalInput(
                        controller: _commandRunner.controller,
                        focusNode: _focusNode,
                        path: _commandRunner.currentPath,
                        onSubmit: _onCommandSubmitted,
                      ),
                    );
                  }
                  return TerminalLine(
                    output: _terminalOutput[index],
                    onAnimatedOutput: _scrollToBottom,
                  );
                },
              ),
            ),
          ),
          const CommandInfoPanel(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commandRunner.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}