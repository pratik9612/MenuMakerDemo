import 'package:flutter/material.dart';
import 'package:menu_maker_demo/bottom_sheet/text_sheet.dart';

enum ImageToolAction {
  change,
  move,
  flipH,
  flipV,
  crop,
  adjustments,
  bgColor,
  blur,
  opacity,
  shadow,
  blendModes,
  copy,
}

class ImageSheet extends StatelessWidget {
  final void Function(ImageToolAction action) onAction;
  const ImageSheet({required this.onAction, super.key});

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
                  onTap: () => onAction(ImageToolAction.change),
                ),
                SheetIcon("Move", onTap: () => onAction(ImageToolAction.move)),
                SheetIcon(
                  "Flip H",
                  onTap: () => onAction(ImageToolAction.flipH),
                ),
                SheetIcon(
                  "Flip V",
                  onTap: () => onAction(ImageToolAction.flipV),
                ),
                SheetIcon("Crop", onTap: () => onAction(ImageToolAction.crop)),
                SheetIcon(
                  "Adjustments",
                  onTap: () => onAction(ImageToolAction.adjustments),
                ),
                SheetIcon(
                  "Bg Color",
                  onTap: () => onAction(ImageToolAction.bgColor),
                ),
                SheetIcon("Blur", onTap: () => onAction(ImageToolAction.blur)),
                SheetIcon(
                  "Opacity",
                  onTap: () => onAction(ImageToolAction.opacity),
                ),
                SheetIcon(
                  "Shadow",
                  onTap: () => onAction(ImageToolAction.shadow),
                ),
                SheetIcon(
                  "Blend Modes",
                  onTap: () => onAction(ImageToolAction.blendModes),
                ),
                SheetIcon("Copy", onTap: () => onAction(ImageToolAction.copy)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
