import 'package:flutter/widgets.dart';

enum OutputType { text, widget, error }

class CommandOutput {
  final String? input;
  final String? path;
  final String? textContent;
  final Widget? widgetContent;
  final OutputType type;

  CommandOutput({
    this.input,
    this.path,
    this.textContent,
    this.widgetContent,
    this.type = OutputType.text,
  }) : assert(
  (type == OutputType.text && textContent != null) ||
      (type == OutputType.widget && widgetContent != null) ||
      (type == OutputType.error && textContent != null) ||
      (input != null && path != null),
  );
}