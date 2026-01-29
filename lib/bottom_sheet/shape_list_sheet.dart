import 'package:flutter/material.dart';
import 'package:menu_maker_demo/bottom_sheet/text_sheet.dart';

enum ShapeTypeToolAction {
  star,
  curvedCircle,
  circleFilled,
  circle,
  capsule,
  heartFilled,
  heart,
  line,
  lineBreaked,
  rectangleCircle,
  rectangleFilled,
  rectangle,
  square,
  arrowFilled,
  arrow,
  arrowThinFilled,
  arrowThin,
}

class ShapeTypeSheet extends StatelessWidget {
  final void Function(ShapeTypeToolAction action) onAction;
  const ShapeTypeSheet({required this.onAction, super.key});

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
                  "star",
                  onTap: () => onAction(ShapeTypeToolAction.star),
                ),
                SheetIcon(
                  "curvedCircle",
                  onTap: () => onAction(ShapeTypeToolAction.curvedCircle),
                ),
                SheetIcon(
                  "circleFilled",
                  onTap: () => onAction(ShapeTypeToolAction.circleFilled),
                ),
                SheetIcon(
                  "circle",
                  onTap: () => onAction(ShapeTypeToolAction.circle),
                ),
                SheetIcon(
                  "capsule",
                  onTap: () => onAction(ShapeTypeToolAction.capsule),
                ),
                SheetIcon(
                  "heartFilled",
                  onTap: () => onAction(ShapeTypeToolAction.heartFilled),
                ),
                SheetIcon(
                  "heart",
                  onTap: () => onAction(ShapeTypeToolAction.heart),
                ),
                SheetIcon(
                  "line",
                  onTap: () => onAction(ShapeTypeToolAction.line),
                ),
                SheetIcon(
                  "lineBreaked",
                  onTap: () => onAction(ShapeTypeToolAction.lineBreaked),
                ),
                SheetIcon(
                  "rectangleCircle",
                  onTap: () => onAction(ShapeTypeToolAction.rectangleCircle),
                ),
                SheetIcon(
                  "rectangleFilled",
                  onTap: () => onAction(ShapeTypeToolAction.rectangleFilled),
                ),
                SheetIcon(
                  "rectangle",
                  onTap: () => onAction(ShapeTypeToolAction.rectangle),
                ),
                SheetIcon(
                  "square",
                  onTap: () => onAction(ShapeTypeToolAction.square),
                ),
                SheetIcon(
                  "arrowFilled",
                  onTap: () => onAction(ShapeTypeToolAction.arrowFilled),
                ),
                SheetIcon(
                  "arrow",
                  onTap: () => onAction(ShapeTypeToolAction.arrow),
                ),
                SheetIcon(
                  "arrowThingFilled",
                  onTap: () => onAction(ShapeTypeToolAction.arrowThinFilled),
                ),
                SheetIcon(
                  "arrowThin",
                  onTap: () => onAction(ShapeTypeToolAction.arrowThin),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
