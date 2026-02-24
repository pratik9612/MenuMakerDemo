import 'dart:ffi';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:menu_maker_demo/constant/app_constant.dart';
import 'package:menu_maker_demo/constant/color_utils.dart';
import 'package:menu_maker_demo/model/editing_element_model.dart';
import 'package:menu_maker_demo/editing_screen/editing_screen_controller.dart';

extension SaveMenuCanvas on EditingScreenController {
  Future<List<ui.Image>> generateWhitePagesFromModel({
    required EditorDataModel editorData,
    required BuildContext canvasContext,
    double pixelRatio = 3.0,
  }) async {
    final List<ui.Image> pages = [];
    double width = editorData.superViewWidth;
    double height = editorData.superViewHeight;

    for (final pageKey in editorData.elements.keys) {
      final pageElements = editorData.elements[pageKey] ?? [];
      if (pageElements.isEmpty) continue;

      final image = await drawPage(
        width: width,
        height: height,
        elements: pageElements,
        pixelRatio: pixelRatio,
        canvasContext: canvasContext,
      );

      pages.add(image);
    }
    return pages;
  }

  Future<ui.Image> drawPage({
    required double width,
    required double height,
    required List<EditingElementModel> elements,
    required BuildContext canvasContext,
    required double pixelRatio,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.scale(pixelRatio, pixelRatio);

    if (elements.isNotEmpty) {
      final bgElement = elements.first;
      final bgRect = Rect.fromLTWH(0, 0, width, height);

      canvas.drawRect(
        bgRect,
        Paint()
          ..colorFilter = ColorFilter.mode(
            ColorUtils.fromHex(bgElement.backGroundColor),
            blendModeFromString(bgElement.blendMode),
          ),
      );

      if (bgElement.url != null && bgElement.url!.isNotEmpty) {
        try {
          final ui.Image bgImage = await loadUiImage(
            bgElement.url!,
            targetWidth: (width * pixelRatio).toInt(),
            targetHeight: (height * pixelRatio).toInt(),
          );

          canvas.drawImageRect(
            bgImage,
            Rect.fromLTWH(
              0,
              0,
              bgImage.width.toDouble(),
              bgImage.height.toDouble(),
            ),
            bgRect,
            Paint(),
          );
        } catch (e) {
          debugPrint("Background image error: $e");
        }
      }
    }

    for (int i = 1; i < elements.length; i++) {
      final element = elements[i];
      if (element.type == EditingWidgetType.image.name ||
          element.type == EditingWidgetType.shape.name) {
        await drawImageElement(canvas, element, pixelRatio);
      } else if (element.type == EditingWidgetType.label.name) {
        drawLabelElement(canvas, element);
      } else {
        paintMenuBox(canvas, element, canvasContext);
      }
    }

    final picture = recorder.endRecording();

    return picture.toImage(
      (width * pixelRatio).toInt(),
      (height * pixelRatio).toInt(),
    );
  }

  void paintMenuBox(
    Canvas canvas,
    EditingElementModel element,
    BuildContext menuBoxContext,
  ) {
    final items = element.menuData ?? const <MenuItemModel>[];
    if (items.isEmpty) return;

    final renderObject = menuBoxContext.findRenderObject();
    if (renderObject is! RenderObject) return;

    final double boxWidth = element.width;
    final double boxHeight = element.height;
    final double x = element.x;
    final double y = element.y;
    final int? menuType = element.menuStyle;
    if (menuType == 7 || menuType == 8 || menuType == 10 || menuType == 11) {
    } else if (menuType == 9 || menuType == 13) {}
    canvas.save();

    if (element.rotation != 0) {
      final double rotation = element.rotation;

      final cx = x + boxWidth / 2;
      final cy = y + boxHeight / 2;

      final cosA = math.cos(rotation);
      final sinA = math.sin(rotation);

      Offset rotate(double px, double py) {
        final dx = px - cx;
        final dy = py - cy;
        return Offset(dx * cosA - dy * sinA + cx, dx * sinA + dy * cosA + cy);
      }

      final p1 = rotate(x, y);
      final p2 = rotate(x + boxWidth, y);
      final p3 = rotate(x + boxWidth, y + boxHeight);
      final p4 = rotate(x, y + boxHeight);

      final clipPath = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p3.dx, p3.dy)
        ..lineTo(p4.dx, p4.dy)
        ..close();

      canvas.clipPath(clipPath);
      canvas.drawRect(
        Rect.fromLTWH(x, y, boxWidth, boxHeight),
        Paint()..color = Colors.transparent,
      );
    } else {
      canvas.clipRect(Rect.fromLTWH(x, y, boxWidth, boxHeight));
    }

    // 🔤 Draw all text (global transform safe)
    for (final item in items) {
      if (item.itemName.isNotEmpty) {
        _paintTextFromGlobalKey(
          canvas: canvas,
          key: item.itemNameKey,
          ancestor: renderObject,
        );
      }

      if (item.description.isNotEmpty) {
        _paintTextFromGlobalKey(
          canvas: canvas,
          key: item.descriptionKey,
          ancestor: renderObject,
        );
      }

      for (final entry in item.values.entries) {
        final valueKey = item.valuesKey[entry.key];
        if (valueKey == null) continue;

        _paintValuesTextFromGlobalKey(
          canvas: canvas,
          key: valueKey,
          ancestor: renderObject,
        );
      }

      _paintSeparatorFromContainer(
        canvas: canvas,
        key: item.separatorKey,
        ancestor: renderObject,
      );

      // if (menuType == 7 || menuType == 8 || menuType == 10 || menuType == 11) {
      //   final keys = <GlobalKey>[];

      //   for (final entry in item.values.entries) {
      //     final valueKey = item.valuesKey[entry.key];
      //     if (valueKey != null) keys.add(valueKey);
      //   }

      //   // Draw bars AFTER values are painted
      //   for (int i = 0; i < keys.length - 1; i++) {
      //     if (element.rotation == 0) {
      //       _drawResponsiveBar(
      //         canvas: canvas,
      //         firstKey: keys[i],
      //         secondKey: keys[i + 1],
      //         ancestor: renderObject,
      //         element: element,
      //       );
      //     } else {
      //       _drawResponsiveBarWithAngle(
      //         canvas: canvas,
      //         firstKey: keys[i],
      //         secondKey: keys[i + 1],
      //         ancestor: renderObject,
      //         element: element,
      //       );
      //     }
      //   }
      // } else if (menuType == 9 || menuType == 13) {
      // } else {}
    }

    canvas.restore();
  }

  bool _paintTextFromGlobalKey({
    required Canvas canvas,
    required GlobalKey key,
    required RenderObject ancestor,
  }) {
    final context = key.currentContext;
    if (context == null) return false;

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderParagraph) return false;

    final size = renderObject.size;
    if (size.isEmpty) return false;

    final transform = renderObject.getTransformTo(ancestor);
    final TextSpan span = renderObject.text as TextSpan;
    final double width = renderObject.size.width;
    final double height = renderObject.size.height;

    final maxLines = _calculateMaxLinesFromHeight(
      span: span,
      width: width,
      height: height,
      textAlign: renderObject.textAlign,
      textDirection: renderObject.textDirection,
    );

    final painter = TextPainter(
      text: renderObject.text,
      textAlign: renderObject.textAlign,
      textDirection: renderObject.textDirection,
      maxLines: maxLines,
      ellipsis: "...",
    );

    painter.layout(maxWidth: size.width);

    canvas.save();
    canvas.transform(transform.storage);

    // clip to original bounds
    canvas.clipRect(Offset.zero & size);

    painter.paint(canvas, Offset.zero);

    canvas.restore();

    return true;
  }

  bool _paintSeparatorFromContainer({
    required Canvas canvas,
    required GlobalKey key,
    required RenderObject ancestor,
    Color color = Colors.white,
    double strokeWidth = 1.0,
  }) {
    final context = key.currentContext;
    if (context == null) return false;

    final renderObject = context.findRenderObject();
    if (renderObject == null) return false;

    final size = renderObject.paintBounds.size;
    if (size.isEmpty) return false;

    // Get global transform to ancestor
    final transform = renderObject.getTransformTo(ancestor);

    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;

    canvas.save();
    canvas.transform(transform.storage);

    // Draw vertical line in center of container
    final double centerX = size.width / 2;
    canvas.drawLine(Offset(centerX, 0), Offset(centerX, size.height), paint);

    canvas.restore();

    return true;
  }

  void _drawResponsiveBar({
    required Canvas canvas,
    required GlobalKey firstKey,
    required GlobalKey secondKey,
    required RenderObject ancestor,
    required EditingElementModel element,
    double spacing = 6.0,
  }) {
    final context1 = firstKey.currentContext;
    final context2 = secondKey.currentContext;
    if (context1 == null || context2 == null) return;

    final render1 = context1.findRenderObject();
    final render2 = context2.findRenderObject();
    if (render1 is! RenderParagraph || render2 is! RenderParagraph) return;

    if (render1.size.isEmpty || render2.size.isEmpty) return;

    // Get positions relative to same ancestor
    final Offset pos1 = MatrixUtils.transformPoint(
      render1.getTransformTo(ancestor),
      Offset.zero,
    );

    final Offset pos2 = MatrixUtils.transformPoint(
      render2.getTransformTo(ancestor),
      Offset.zero,
    );

    final paint = Paint()
      ..color = ColorUtils.fromHex(element.itemValueTextColor)
      ..strokeWidth = 1;

    final double lineHeight = render1.size.height;
    final double barHeight = element.itemValueFontSize ?? lineHeight;

    final double dyDiff = (pos1.dy - pos2.dy).abs();

    const double tolerance = 2.0;

    // ===============================
    // CASE 3 → SAME ROW
    // value1   |   value2
    // ===============================
    if (dyDiff < tolerance) {
      final double barX = pos1.dx + render1.size.width + spacing;

      final double top = pos1.dy + (lineHeight - barHeight) / 2;

      canvas.drawLine(Offset(barX, top), Offset(barX, top + barHeight), paint);
      return;
    }

    // ===============================
    // CASE 2 → NEXT LINE (wrapped)
    // value1   |
    // value2
    // ===============================
    if (pos2.dy > pos1.dy && pos2.dy <= pos1.dy + lineHeight + tolerance) {
      final double barX = pos1.dx + render1.size.width + spacing;

      final double top = pos1.dy + (lineHeight - barHeight) / 2;

      canvas.drawLine(Offset(barX, top), Offset(barX, top + barHeight), paint);
      return;
    }

    // ===============================
    // CASE 1 → BAR ON ITS OWN LINE
    // value1
    //   |
    // value2
    // ===============================

    // Horizontal position (6px from text start)
    final double barX = pos1.dx + spacing;

    // Bottom of value1
    final double value1Bottom = pos1.dy + render1.size.height;

    // Top of value2
    final double value2Top = pos2.dy;

    // Total vertical gap between texts
    final double gap = value2Top - value1Bottom;

    // Center the bar inside the gap
    final double top = value1Bottom + (gap - barHeight) / 2;

    canvas.drawLine(Offset(barX, top), Offset(barX, top + barHeight), paint);
  }

  void _drawResponsiveBarWithAngle({
    required Canvas canvas,
    required GlobalKey firstKey,
    required GlobalKey secondKey,
    required RenderObject ancestor,
    required EditingElementModel element,
    double spacing = 6.0,
  }) {
    debugPrint("angle: ${element.rotation}");
    final context1 = firstKey.currentContext;
    final context2 = secondKey.currentContext;
    if (context1 == null || context2 == null) return;

    final render1 = context1.findRenderObject();
    final render2 = context2.findRenderObject();
    if (render1 is! RenderParagraph || render2 is! RenderParagraph) return;
    if (render1.size.isEmpty || render2.size.isEmpty) return;

    // Positions relative to ancestor
    final Offset pos1 = MatrixUtils.transformPoint(
      render1.getTransformTo(ancestor),
      Offset.zero,
    );
    final Offset pos2 = MatrixUtils.transformPoint(
      render2.getTransformTo(ancestor),
      Offset.zero,
    );

    final paint = Paint()
      ..color = ColorUtils.fromHex(element.itemValueTextColor)
      ..strokeWidth = 1;

    final double barHeight = element.itemValueFontSize ?? render1.size.height;
    const double tolerance = 2.0;

    double centerX;
    double centerY;

    final double dyDiff = (pos1.dy - pos2.dy).abs();

    // CASE 3 → SAME ROW (value1 | value2)
    if (dyDiff < tolerance) {
      debugPrint("if");
      centerX = pos1.dx;
      centerY = pos1.dy;
    }
    // CASE 2 → WRAPPED (value1 |
    else if (pos2.dy > pos1.dy &&
        pos2.dy <= pos1.dy + render1.size.height + tolerance) {
      debugPrint("else if");
      centerX = pos1.dx + (render1.size.width) + spacing;
      centerY = pos1.dy + render1.size.height;
    }
    // CASE 1 → STACKED (value1 above value2)
    else {
      debugPrint("else");
      // Horizontal: small spacing from left of first value

      // Vertical: center of gap between bottom of first and top of second

      final double value2Top = pos2.dy;
      if (element.rotation > 0) {
        centerX = pos1.dx + render1.size.width;
        final double value1Bottom = pos1.dy + render1.size.height;
        centerY = value1Bottom + (value2Top - value1Bottom);
      } else {
        centerX = pos1.dx + render1.size.width + spacing;
        centerY = pos2.dy + render1.size.height;
      }
    }

    // ROTATE BAR
    canvas.save();
    canvas.translate(centerX, centerY);
    canvas.rotate(element.rotation); // rotation in radians

    final double half = barHeight / 2;
    canvas.drawLine(Offset(0, -half), Offset(0, half), paint);

    canvas.restore();
  }

  bool _paintValuesTextFromGlobalKey({
    required Canvas canvas,
    required GlobalKey key,
    required RenderObject ancestor,
  }) {
    final context = key.currentContext;
    if (context == null) return false;

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderParagraph) return false;

    final size = renderObject.size;
    if (size.isEmpty) return false;

    final transform = renderObject.getTransformTo(ancestor);
    final TextSpan span = renderObject.text as TextSpan;
    final double width = renderObject.size.width;
    final double height = renderObject.size.height;

    final maxLines = _calculateMaxLinesFromHeight(
      span: span,
      width: width,
      height: height,
      textAlign: renderObject.textAlign,
      textDirection: renderObject.textDirection,
    );

    final painter = TextPainter(
      text: renderObject.text,
      textAlign: renderObject.textAlign,
      textDirection: renderObject.textDirection,
      maxLines: maxLines,
      ellipsis: "...",
    );

    painter.layout(maxWidth: size.width);

    canvas.save();
    canvas.transform(transform.storage);

    // clip to original bounds
    canvas.clipRect(Offset.zero & size);

    painter.paint(canvas, Offset.zero);

    canvas.restore();

    return true;
  }

  int _calculateMaxLinesFromHeight({
    required TextSpan span,
    required double width,
    required double height,
    required TextAlign textAlign,
    required TextDirection textDirection,
  }) {
    int lines = 1;

    while (true) {
      final painter = TextPainter(
        text: span,
        textAlign: textAlign,
        textDirection: textDirection,
        maxLines: lines,
      );

      painter.layout(maxWidth: width);

      if (painter.height > height) {
        return lines - 1 <= 0 ? 1 : lines - 1;
      }

      if (!painter.didExceedMaxLines) {
        return lines;
      }

      lines++;
    }
  }

  Future<void> drawImageElement(
    Canvas canvas,
    EditingElementModel element,
    double pixelRatio,
  ) async {
    try {
      final double x = element.x;
      final double y = element.y;
      final double width = element.width;
      final double height = element.height;
      final ui.Image image = await loadUiImage(
        element.url!,
        targetWidth: (width * pixelRatio).toInt(),
        targetHeight: (height * pixelRatio).toInt(),
      );

      final paint = Paint()
        ..isAntiAlias = true
        ..filterQuality = FilterQuality.high
        ..colorFilter = ColorFilter.mode(
          ColorUtils.fromHex(element.backGroundColor),
          blendModeFromString(element.blendMode),
        );

      canvas.save();
      canvas.translate(x + width / 2, y + height / 2);
      canvas.rotate(element.rotation);

      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromLTWH(-width / 2, -height / 2, width, height),
        paint,
      );

      canvas.restore();
    } catch (_) {}
  }

  BlendMode blendModeFromString(String? modeStr) {
    switch (modeStr) {
      case 'Normal':
        return BlendMode.srcIn;
      case 'Multiply':
        return BlendMode.multiply;
      case 'Screen':
        return BlendMode.screen;
      case 'Overlay':
        return BlendMode.overlay;
      case 'Darken':
        return BlendMode.darken;
      case 'Lighten':
        return BlendMode.lighten;
      case 'Color Dodge':
        return BlendMode.colorDodge;
      case 'Color Burn':
        return BlendMode.colorBurn;
      case 'Soft Light':
        return BlendMode.softLight;
      case 'Hard Light':
        return BlendMode.hardLight;
      default:
        return BlendMode.srcOver;
    }
  }

  Future<ui.Image> loadUiImage(
    String src, {
    required int targetWidth,
    required int targetHeight,
  }) async {
    final Uint8List bytes;

    if (src.startsWith('http') || src.startsWith('Templates')) {
      final res = await http.get(
        Uri.parse(
          src.startsWith('http') ? src : "${AppConstant.imageBaseUrl}$src",
        ),
      );
      bytes = res.bodyBytes;

      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: targetWidth,
        targetHeight: targetHeight,
      );

      return (await codec.getNextFrame()).image;
    } else {
      // 🔹 Local SVG asset
      final String svgPath = "assets/shapes/$src.svg";
      final String rawSvg = await rootBundle.loadString(svgPath);

      // Load SVG as PictureInfo
      final PictureInfo pictureInfo = await vg.loadPicture(
        SvgStringLoader(rawSvg),
        null,
      );

      // Draw Picture to a recorder at target size
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      final double scaleX = targetWidth / pictureInfo.size.width;
      final double scaleY = targetHeight / pictureInfo.size.height;
      canvas.scale(scaleX, scaleY);

      canvas.drawPicture(pictureInfo.picture);

      final ui.Picture picture = recorder.endRecording();
      final ui.Image image = await picture.toImage(targetWidth, targetHeight);
      return image;
    }
  }

  void drawLabelElement(Canvas canvas, EditingElementModel element) {
    final double x = element.x;
    final double y = element.y;
    final double w = element.width;
    final double h = element.height;
    final double rotation = element.rotation;
    String? backgroundColor = element.backGroundColor;

    canvas.save();

    // 🔁 Position + rotation
    canvas.translate(x + w / 2, y + h / 2);
    canvas.rotate(rotation);
    canvas.translate(-w / 2, -h / 2);

    // 🎨 Background
    if (backgroundColor != null) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, w, h),
        Paint()
          ..isAntiAlias = true
          ..color = ColorUtils.fromHex(backgroundColor),
      );
    }

    // ✂ Strict clip
    canvas.clipRect(Rect.fromLTWH(0, 0, w, h));

    final paragraph = _buildParagraph(
      text: element.text ?? "",
      width: w,
      color: element.textColor,
      fontSize: element.textSize ?? 16,
      fontFamily: element.fontURL,
      lineHeight: element.lineSpace ?? 0.0,
      letterSpacing: element.letterSpace ?? 0.0,
      alignment: element.alignment,
    );

    final double dy = _verticalOffset(h, paragraph.height, element.alignment);

    canvas.drawParagraph(paragraph, Offset(0, dy));

    canvas.restore();
  }

  ui.Paragraph _buildParagraph({
    required String text,
    required double width,
    required String? color,
    required double fontSize,
    required String? fontFamily,
    required double lineHeight,
    required double letterSpacing,
    int? alignment,
  }) {
    final builder =
        ui.ParagraphBuilder(ui.ParagraphStyle(textAlign: _align(alignment)))
          ..pushStyle(
            ui.TextStyle(
              color: color != null
                  ? ColorUtils.fromHex(color)
                  : const Color(0xFF000000),
              fontSize: fontSize,
              fontFamily: fontFamily,
              height: lineHeight,
              letterSpacing: letterSpacing,
            ),
          )
          ..addText(text);

    final paragraph = builder.build();
    paragraph.layout(ui.ParagraphConstraints(width: width));
    return paragraph;
  }

  double _verticalOffset(double boxHeight, double paragraphHeight, int? align) {
    // If paragraph taller than box, do NOT shift
    if (paragraphHeight >= boxHeight) {
      return 0;
    }

    // Only align if paragraph fully fits
    if (align == 1) {
      return (boxHeight - paragraphHeight) / 2;
    }

    if (align == 2) {
      return boxHeight - paragraphHeight;
    }

    return 0;
  }

  TextAlign _align(int? a) {
    if (a == 0) return TextAlign.left;
    if (a == 2) return TextAlign.right;
    return TextAlign.center;
  }

  Future<Uint8List> exportImage(ui.Image image) async {
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  Future<File> savePngToCache(Uint8List bytes, String name) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}
