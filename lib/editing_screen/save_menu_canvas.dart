import 'dart:io';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:menu_maker_demo/constant/app_constant.dart';
import 'package:menu_maker_demo/constant/color_utils.dart';
import 'package:menu_maker_demo/model/editing_element_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:menu_maker_demo/editing_screen/editing_screen_controller.dart';

extension SaveMenuCanvas on EditingScreenController {
  /// Generate canvas pages using EditorDataModel
  Future<List<ui.Image>> generateWhitePagesFromModel({
    required EditorDataModel editorData,
  }) async {
    final List<ui.Image> pages = [];

    final elements =
        editorData.elements; // Map<String, List<EditingElementModel>>
    final width = editorData.superViewWidth;
    final height = editorData.superViewHeight;

    for (final pageKey in elements.keys) {
      final pageElements = elements[pageKey] ?? [];
      if (pageElements.isEmpty) continue;

      final page = await drawPage(
        width: width,
        height: height,
        elements: pageElements,
      );
      pages.add(page);
    }

    return pages;
  }

  /// Draw single page with white background and supported elements
  Future<ui.Image> drawPage({
    required double width,
    required double height,
    required List<EditingElementModel> elements,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // 1️⃣ Draw white background
    final paint = Paint()
      ..color = const ui.Color(0xFFFFFFFF)
      ..filterQuality = FilterQuality.high
      ..isAntiAlias = true;
    ;
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);

    // 2️⃣ Draw each element (only image, label, shape)
    for (final element in elements) {
      if (element.type == EditingWidgetType.image.name) {
        await drawImageElement(canvas, element);
      } else if (element.type == EditingWidgetType.label.name) {
        drawLabelElement(canvas, element);
      } else if (element.type == EditingWidgetType.shape.name) {
        drawShapeElement(canvas, element);
      } else if (element.type == EditingWidgetType.menuBox.name) {
        drawMenuBox(canvas, element);
      }
    }

    final picture = recorder.endRecording();
    return picture.toImage(width.toInt(), height.toInt());
  }

  /// Draw image element
  Future<void> drawImageElement(
    Canvas canvas,
    EditingElementModel element,
  ) async {
    try {
      final ui.Image image = await loadUiImage(element.url!);

      final double x = element.x;
      final double y = element.y;
      final double w = element.width;
      final double h = element.height;
      final double alpha = element.alpha.clamp(0, 1);
      final double rotationRad = element.rotation;

      final paint = Paint()
        ..color = ui.Color.fromRGBO(255, 255, 255, alpha)
        ..filterQuality = FilterQuality.high
        ..isAntiAlias = true;

      canvas.save();
      canvas.translate(x + w / 2, y + h / 2);
      canvas.rotate(rotationRad);

      final srcRect = Rect.fromLTWH(
        0,
        0,
        image.width.toDouble(),
        image.height.toDouble(),
      );
      final dstRect = Rect.fromLTWH(-w / 2, -h / 2, w, h);
      canvas.drawImageRect(image, srcRect, dstRect, paint);

      canvas.restore();
    } catch (e) {
      print('Failed to draw image element: ${element.url}, error: $e');
    }
  }

  void drawLabelElement(Canvas canvas, EditingElementModel element) {
    final double w = element.width;
    final double h = element.height;
    final double alpha = element.alpha.clamp(0, 1);
    final double rotationRad = element.rotation;

    // Background
    if (element.backGroundColor != null) {
      final bgPaint = Paint()
        ..color = ColorUtils.fromHex(element.backGroundColor)
        ..filterQuality = FilterQuality.high
        ..isAntiAlias = true;
      final centerX = element.x + w / 2;
      final centerY = element.y + h / 2;
      canvas.save();
      canvas.translate(centerX, centerY);
      canvas.rotate(rotationRad);
      canvas.translate(-w / 2, -h / 2);
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);
      canvas.restore();
    }

    // Text style
    final textStyle = ui.TextStyle(
      color: element.textColor != null
          ? ColorUtils.fromHex(element.textColor)
          : const ui.Color(0xFF000000),
      fontSize: element.textSize ?? 24,
      fontFamily: element.fontURL,
    );

    // Paragraph
    final paragraphStyle = ui.ParagraphStyle(
      textAlign: getTextAlign(element.alignment), // horizontal alignment
      maxLines: 10,
    );

    final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(textStyle)
      ..addText(element.text ?? '');
    final paragraph = paragraphBuilder.build();
    paragraph.layout(ui.ParagraphConstraints(width: w));

    // Vertical alignment
    double dy;
    switch (element.alignment) {
      case 0: // top
        dy = 0;
        break;
      case 1: // center
        dy = (h - paragraph.height) / 2;
        break;
      case 2: // bottom
        dy = h - paragraph.height;
        break;
      default:
        dy = 0;
    }

    // Draw text
    final centerX = element.x + w / 2;
    final centerY = element.y + h / 2;
    canvas.save();
    canvas.translate(centerX, centerY);
    canvas.rotate(rotationRad);
    canvas.translate(-w / 2, -h / 2);
    canvas.drawParagraph(paragraph, Offset(0, dy));
    canvas.restore();
  }

  TextAlign getTextAlign(int? align) {
    switch (align) {
      case 0:
        return TextAlign.left;
      case 2:
        return TextAlign.right;
      default:
        return TextAlign.center;
    }
  }

  /// Draw shape element (simple rectangle example)
  void drawShapeElement(Canvas canvas, EditingElementModel element) {
    final paint = Paint()
      ..color = ColorUtils.fromHex(element.backGroundColor)
      ..style = PaintingStyle.fill
      ..filterQuality = FilterQuality.high
      ..isAntiAlias = true;

    canvas.save();
    canvas.translate(element.x, element.y);
    canvas.rotate(element.rotation);
    canvas.drawRect(Rect.fromLTWH(0, 0, element.width, element.height), paint);
    canvas.restore();
  }

  /// Load image from HTTP or local asset
  Future<ui.Image> loadUiImage(String src) async {
    Uint8List bytes;

    try {
      if (src.startsWith('http') || src.startsWith('Templates')) {
        final response = await http.get(
          Uri.parse(
            src.startsWith('http') ? src : "${AppConstant.imageBaseUrl}$src",
          ),
        );
        bytes = response.bodyBytes;
      } else {
        final data = await rootBundle.load(src);
        bytes = data.buffer.asUint8List();
      }

      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (e) {
      print('Failed to load image: $src, error: $e');
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawRect(
        Rect.fromLTWH(0, 0, 1, 1),
        Paint()
          ..color = const ui.Color(0x00000000)
          ..filterQuality = FilterQuality.high
          ..isAntiAlias = true,
      );
      return recorder.endRecording().toImage(1, 1);
    }
  }

  void drawMenuBox(Canvas canvas, EditingElementModel element) {
    final double x = element.x;
    final double y = element.y;
    final double w = element.width;
    final double h = element.height;
    final double alpha = element.alpha.clamp(0, 1);
    final double rotationRad = element.rotation * 3.1415926535 / 180;

    // 1️⃣ Draw menu background
    if (element.backGroundColor != null) {
      final bgPaint = Paint()
        ..color = ColorUtils.fromHex(element.backGroundColor)
        ..style = PaintingStyle.fill
        ..isAntiAlias = true
        ..filterQuality = FilterQuality.high;

      canvas.save();
      canvas.translate(x + w / 2, y + h / 2);
      canvas.rotate(rotationRad);
      canvas.translate(-w / 2, -h / 2);
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);
      canvas.restore();
    }

    final items = element.menuData ?? [];
    if (items.isEmpty) return;

    // 2️⃣ Calculate per-item row height
    final rowHeight = h / items.length;

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final double itemY = y + i * rowHeight;

      // Draw title
      drawMenuText(
        canvas,
        text: item.itemName,
        x: x,
        y: itemY,
        width: w * 0.5, // left half for name
        height: rowHeight * 0.4, // top portion for title
        rotationRad: rotationRad,
        color: element.itemNameTextColor,
        fontSize: element.itemNameFontSize,
        fontFamily: element.itemNameFontStyle,
        alignment: 0, // left
        alpha: alpha,
      );

      // Draw description below title
      drawMenuText(
        canvas,
        text: item.description,
        x: x,
        y: itemY + rowHeight * 0.4,
        width: w * 0.5, // left half for description
        height: rowHeight * 0.6,
        rotationRad: rotationRad,
        color: element.itemDescriptionTextColor,
        fontSize: element.itemDescriptionFontSize,
        fontFamily: element.itemDescriptionFontStyle,
        alignment: 0, // left
        alpha: alpha,
      );

      // Draw values/prices on right side
      final values = item.values as Map<String, dynamic>? ?? {};
      final columnWidth = element.columnWidth ?? (w * 0.5 / 3);

      int colIndex = 0;
      for (var key in ["1", "2", "3"]) {
        if (!values.containsKey(key)) continue;

        drawMenuText(
          canvas,
          text: values[key].toString(),
          x: x + w * 0.5 + colIndex * columnWidth,
          y: itemY,
          width: columnWidth,
          height: rowHeight,
          rotationRad: rotationRad,
          color: element.itemValueTextColor,
          fontSize: element.itemValueFontSize,
          fontFamily: element.itemValueFontStyle,
          alignment: 1, // center
          alpha: alpha,
        );
        colIndex++;
      }
    }
  }

  /// Draw text helper (same as before)
  void drawMenuText(
    Canvas canvas, {
    required String text,
    required double x,
    required double y,
    required double width,
    required double height,
    required double rotationRad,
    required String? color,
    required double? fontSize,
    required String? fontFamily,
    int? alignment, // 0 = left, 1 = center, 2 = right
    required double alpha,
  }) {
    if (text.isEmpty) return;

    final textStyle = ui.TextStyle(
      color: color != null
          ? ColorUtils.fromHex(color).withOpacity(alpha)
          : const ui.Color(0xFF000000).withOpacity(alpha),
      fontSize: fontSize ?? 14,
      fontFamily: fontFamily,
    );

    final paragraphStyle = ui.ParagraphStyle(
      textAlign: getTextAlign(alignment),
      maxLines: 10,
    );

    final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(textStyle)
      ..addText(text);

    final paragraph = paragraphBuilder.build();
    paragraph.layout(ui.ParagraphConstraints(width: width));

    final dy = (height - paragraph.height) / 2; // vertical center

    canvas.save();
    canvas.translate(x + width / 2, y + height / 2);
    canvas.rotate(rotationRad);
    canvas.translate(-width / 2, -height / 2);
    canvas.drawParagraph(paragraph, Offset(0, dy));
    canvas.restore();
  }

  /// Export ui.Image to PNG bytes
  Future<Uint8List> exportImage(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /// Save PNG bytes to cache directory
  Future<File> savePngToCache(Uint8List pngBytes, String fileName) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(pngBytes, flush: true);
    return file;
  }
}
