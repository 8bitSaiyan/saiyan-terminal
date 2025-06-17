import 'package:flutter/material.dart';
import '../models/command_output.dart';
import 'typing_text.dart';

class TerminalLine extends StatelessWidget {
  final CommandOutput output;
  final VoidCallback? onAnimatedOutput;

  const TerminalLine({
    super.key,
    required this.output,
    this.onAnimatedOutput,
  });

  @override
  Widget build(BuildContext context) {
    // Render the input prompt line
    if (output.input != null) {
      return RichText(
        text: TextSpan(
          style: const TextStyle(
            fontFamily: 'FiraCode',
            color: Color(0xFF00FF00),
            fontSize: 16,
          ),
          children: [
            const TextSpan(
              text: 'visitor@8itsaiyan:',
              style: TextStyle(
                  color: Colors.lightBlueAccent, fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: '${output.path}\$ ',
              style: const TextStyle(
                  color: Colors.purpleAccent, fontWeight: FontWeight.bold),
            ),
            TextSpan(text: output.input),
          ],
        ),
      );
    }

    // Handle animated typing text specifically
    if (output.type == OutputType.widget && output.widgetContent is TypingText) {
      final typingText = output.widgetContent as TypingText;
      return TypingText(
        text: typingText.text,
        onCharacterTyped: onAnimatedOutput, // Pass the callback here
      );
    }

    // Render other widgets directly
    if (output.type == OutputType.widget) {
      return output.widgetContent!;
    }

    // Render plain text or error messages
    Color textColor;
    switch (output.type) {
      case OutputType.error:
        textColor = Colors.red;
        break;
      default:
        textColor = const Color(0xFF00DD00);
    }
    return Text(
      output.textContent ?? '',
      style: TextStyle(color: textColor),
    );
  }
}