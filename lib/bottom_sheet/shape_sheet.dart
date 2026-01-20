import 'package:flutter/material.dart';
import 'package:menu_maker_demo/bottom_sheet/text_sheet.dart';

enum ShapeToolAction {
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
                SheetIcon("Star", onTap: () => onAction(ShapeToolAction.star)),
                SheetIcon(
                  "CurvedCircle",
                  onTap: () => onAction(ShapeToolAction.curvedCircle),
                ),
                SheetIcon(
                  "CircleFilled",
                  onTap: () => onAction(ShapeToolAction.circleFilled),
                ),
                SheetIcon(
                  "Circle",
                  onTap: () => onAction(ShapeToolAction.circle),
                ),
                SheetIcon(
                  "Capsule",
                  onTap: () => onAction(ShapeToolAction.capsule),
                ),
                SheetIcon(
                  "HeartFilled",
                  onTap: () => onAction(ShapeToolAction.heartFilled),
                ),
                SheetIcon(
                  "Heart",
                  onTap: () => onAction(ShapeToolAction.heart),
                ),
                SheetIcon("Line", onTap: () => onAction(ShapeToolAction.line)),
                SheetIcon(
                  "LineBreaked",
                  onTap: () => onAction(ShapeToolAction.lineBreaked),
                ),
                SheetIcon(
                  "RectangleCircle",
                  onTap: () => onAction(ShapeToolAction.rectangleCircle),
                ),
                SheetIcon(
                  "RectangleFilled",
                  onTap: () => onAction(ShapeToolAction.rectangleFilled),
                ),
                SheetIcon(
                  "Rectangle",
                  onTap: () => onAction(ShapeToolAction.rectangle),
                ),
                SheetIcon(
                  "Square",
                  onTap: () => onAction(ShapeToolAction.square),
                ),
                SheetIcon(
                  "ArrowFilled",
                  onTap: () => onAction(ShapeToolAction.arrowFilled),
                ),
                SheetIcon(
                  "Arrow",
                  onTap: () => onAction(ShapeToolAction.arrow),
                ),
                SheetIcon(
                  "ArrowThinFilled",
                  onTap: () => onAction(ShapeToolAction.arrowThinFilled),
                ),
                SheetIcon(
                  "ArrowThin",
                  onTap: () => onAction(ShapeToolAction.arrowThin),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
