import 'package:flutter/material.dart';
import 'package:menu_maker_demo/bottom_sheet/text_sheet.dart';

enum LabelSpaceToolAction { lineSpacing, textSpacing }

class LabelSpaceToolSheet extends StatelessWidget {
  final void Function(LabelSpaceToolAction action) onAction;

  const LabelSpaceToolSheet({required this.onAction, super.key});

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
                  "LineSpacing",
                  onTap: () => onAction(LabelSpaceToolAction.lineSpacing),
                ),
                SheetIcon(
                  "TextSpacing",
                  onTap: () => onAction(LabelSpaceToolAction.textSpacing),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
