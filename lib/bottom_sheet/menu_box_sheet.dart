import 'package:flutter/material.dart';
import 'package:menu_maker_demo/bottom_sheet/text_sheet.dart';

enum MenuToolAction {
  editContent,
  changeSize,
  move,
  bgColor,
  copy,
  lockOpration,
}

class MenuBoxSheet extends StatelessWidget {
  final void Function(MenuToolAction action) onAction;

  const MenuBoxSheet({required this.onAction, super.key});

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
                  "Edit Content",
                  onTap: () => onAction(MenuToolAction.editContent),
                ),
                SheetIcon(
                  "Change Size",
                  onTap: () => onAction(MenuToolAction.changeSize),
                ),
                SheetIcon("Move", onTap: () => onAction(MenuToolAction.move)),
                SheetIcon(
                  "BG Color",
                  onTap: () => onAction(MenuToolAction.bgColor),
                ),
                SheetIcon("Copy", onTap: () => onAction(MenuToolAction.copy)),
                SheetIcon(
                  "Lock Oprations",
                  onTap: () => onAction(MenuToolAction.lockOpration),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
