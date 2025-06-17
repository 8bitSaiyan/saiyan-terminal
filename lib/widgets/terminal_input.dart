import 'package:flutter/material.dart';

class TerminalInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String path;
  final Function(String) onSubmit;

  const TerminalInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.path,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontFamily: 'FiraCode',
              color: Color(0xFF00FF00),
              fontSize: 16,
            ),
            children: [
              TextSpan(
                text: 'visitor@8itsaiyan:',
                style: const TextStyle(
                    color: Colors.lightBlueAccent,
                    fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: '$path\$ ',
                style: const TextStyle(
                    color: Colors.purpleAccent, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: true,
            onSubmitted: onSubmit,
            cursorColor: const Color(0xFF00FF00),
            style: const TextStyle(
              color: Color(0xFF00FF00),
              fontSize: 16,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}