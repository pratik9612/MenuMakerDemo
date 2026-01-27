import 'package:flutter/material.dart';
import 'package:menu_maker_demo/bottom_sheet/text_sheet.dart';

enum ShapeToolAction {
  change,
  flipH,
  flipV,
  color,
  blur,
  opacity,
  shadow,
  blendMode,
  move,
  copy,
  lockOpration,
}

class ShapeSheet extends StatelessWidget {
  final void Function(ShapeToolAction action) onAction;

  const ShapeSheet({required this.onAction, super.key});

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
                  "Change",
                  onTap: () => onAction(ShapeToolAction.change),
                ),
                SheetIcon(
                  "Flip H",
                  onTap: () => onAction(ShapeToolAction.flipH),
                ),
                SheetIcon(
                  "Flip V",
                  onTap: () => onAction(ShapeToolAction.flipV),
                ),
                SheetIcon(
                  "Colour",
                  onTap: () => onAction(ShapeToolAction.color),
                ),
                SheetIcon("Blur", onTap: () => onAction(ShapeToolAction.blur)),
                SheetIcon(
                  "Opacity",
                  onTap: () => onAction(ShapeToolAction.opacity),
                ),
                SheetIcon(
                  "Shadow",
                  onTap: () => onAction(ShapeToolAction.shadow),
                ),
                SheetIcon(
                  "BlendMode",
                  onTap: () => onAction(ShapeToolAction.blendMode),
                ),
                SheetIcon("Move", onTap: () => onAction(ShapeToolAction.move)),
                SheetIcon("Copy", onTap: () => onAction(ShapeToolAction.copy)),
                SheetIcon(
                  "LockOprations",
                  onTap: () => onAction(ShapeToolAction.lockOpration),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
