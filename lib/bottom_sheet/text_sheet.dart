import 'package:flutter/material.dart';

enum TextToolAction {
  editText,
  move,
  fontStyle,
  fontSize,
  textSpace,
  fontColor,
  bgColor,
  copy,
}

class TextSheet extends StatelessWidget {
  final void Function(TextToolAction action) onAction;

  const TextSheet({required this.onAction, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 24, bottom: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                SheetIcon(
                  "EditText",
                  onTap: () => onAction(TextToolAction.editText),
                ),
                SheetIcon("Move", onTap: () => onAction(TextToolAction.move)),
                SheetIcon(
                  "FontStyle",
                  onTap: () => onAction(TextToolAction.fontStyle),
                ),
                SheetIcon(
                  "FontSize",
                  onTap: () => onAction(TextToolAction.fontSize),
                ),
                SheetIcon(
                  "TextSpace",
                  onTap: () => onAction(TextToolAction.textSpace),
                ),
                SheetIcon(
                  "FontColor",
                  onTap: () => onAction(TextToolAction.fontColor),
                ),
                SheetIcon(
                  "BGColor",
                  onTap: () => onAction(TextToolAction.bgColor),
                ),
                SheetIcon("Copy", onTap: () => onAction(TextToolAction.copy)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SheetIcon extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;

  const SheetIcon(
    this.label, {
    super.key,
    required this.onTap,
    this.onLongPressStart,
    this.onLongPressEnd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPressStart: onLongPressStart == null
          ? null
          : (_) => onLongPressStart!(),
      onLongPressEnd: onLongPressEnd == null ? null : (_) => onLongPressEnd!(),
      onLongPressCancel: onLongPressEnd,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Container(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
