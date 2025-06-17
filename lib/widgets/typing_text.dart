import 'dart:async';
import 'package:flutter/material.dart';

class TypingText extends StatefulWidget {
  final String text;
  final VoidCallback? onCharacterTyped;

  const TypingText({
    super.key,
    required this.text,
    this.onCharacterTyped,
  });

  @override
  State<TypingText> createState() => _TypingTextState();
}

class _TypingTextState extends State<TypingText> {
  final StringBuffer _displayedText = StringBuffer();
  Timer? _timer;
  int _charIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    // A slightly slower speed can make the auto-scroll feel more natural
    const typingSpeed = Duration(milliseconds: 20);
    _timer = Timer.periodic(typingSpeed, (timer) {
      if (_charIndex < widget.text.length) {
        if (mounted) {
          setState(() {
            _displayedText.write(widget.text[_charIndex]);
            _charIndex++;
            // Notify the parent to scroll down
            widget.onCharacterTyped?.call();
          });
        }
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText.toString(),
      style: const TextStyle(color: Color(0xFF00DD00)),
    );
  }
}