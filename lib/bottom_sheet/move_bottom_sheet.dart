import 'package:flutter/material.dart';
import 'package:menu_maker_demo/bottom_sheet/text_sheet.dart';

enum MoveToolAction { leftMove, topMove, rightMove, bottomMove }

class MoveToolSheet extends StatelessWidget {
  final void Function(MoveToolAction action) onAction;

  const MoveToolSheet({required this.onAction, super.key});

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
                  "LeftMove",
                  onTap: () => onAction(MoveToolAction.leftMove),
                ),
                SheetIcon(
                  "TopMove",
                  onTap: () => onAction(MoveToolAction.topMove),
                ),
                SheetIcon(
                  "RightMove",
                  onTap: () => onAction(MoveToolAction.rightMove),
                ),
                SheetIcon(
                  "BottomMove",
                  onTap: () => onAction(MoveToolAction.bottomMove),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
