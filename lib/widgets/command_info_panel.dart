import 'package:flutter/material.dart';

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
│ ls      - list files      │
│ cat     - read file       │
│ cd      - change dir      │
│ pwd     - current path    │
│ tree    - show structure  │
│ clear   - clear screen    │
│ help    - show help       │
│ github  - open profile    │
└───────────────────────────┘''',
          style: TextStyle(
            color: Color(0xFF00DD00),
            fontSize: 14,
            fontFamily: 'FiraCode',
          ),
        ),
      ),
    );
  }
}