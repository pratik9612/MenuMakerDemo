import 'package:flutter/material.dart';
import 'package:menu_maker_demo/bottom_sheet/text_sheet.dart';

enum MoveToolAction {
  leftMove,
  topMove,
  rightMove,
  bottomMove,
  leftLongPress,
  topLongPress,
  rightLongPress,
  bottomLongPress,
}

class MoveToolSheet extends StatelessWidget {
  final void Function(MoveToolAction action) onAction;
  final void Function(MoveToolAction action)? onLongPressStart;
  final VoidCallback? onLongPressEnd;
  const MoveToolSheet({
    super.key,
    required this.onAction,
    this.onLongPressStart,
    this.onLongPressEnd,
  });

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
                  onLongPressStart: () =>
                      onAction(MoveToolAction.leftLongPress),
                  onLongPressEnd: onLongPressEnd,
                ),
                SheetIcon(
                  "TopMove",
                  onTap: () => onAction(MoveToolAction.topMove),
                  onLongPressStart: () => onAction(MoveToolAction.topLongPress),
                  onLongPressEnd: onLongPressEnd,
                ),
                SheetIcon(
                  "RightMove",
                  onTap: () => onAction(MoveToolAction.rightMove),
                  onLongPressStart: () =>
                      onAction(MoveToolAction.rightLongPress),
                  onLongPressEnd: onLongPressEnd,
                ),
                SheetIcon(
                  "BottomMove",
                  onTap: () => onAction(MoveToolAction.bottomMove),
                  onLongPressStart: () =>
                      onAction(MoveToolAction.bottomLongPress),
                  onLongPressEnd: onLongPressEnd,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
