/* import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:ui';
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
    double pixelRatio = 2.0,
    double scaleX = 1,
    double scaleY = 1,
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
    double scaleX = 1,
    double scaleY = 1,
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
        await drawImageElementCombined(canvas, element, pixelRatio);
        // await drawImageElement22(canvas, element, pixelRatio);
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

    canvas.drawPath(
      clipPath,
      Paint()..color = ColorUtils.fromHex(element.backGroundColor),
    );
    canvas.clipPath(clipPath);

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
        color: element.itemValueTextColor,
      );
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
    String? color,
  }) {
    double strokeWidth = 1.5;
    final context = key.currentContext;
    if (context == null) return false;

    final renderObject = context.findRenderObject();
    if (renderObject == null) return false;

    final size = renderObject.paintBounds.size;
    if (size.isEmpty) return false;

    // Get global transform to ancestor
    final transform = renderObject.getTransformTo(ancestor);

    final Paint paint = Paint()
      ..color = ColorUtils.fromHex(color)
      ..strokeWidth = strokeWidth;

    canvas.save();
    canvas.transform(transform.storage);
    final double centerX = size.width / 2;
    canvas.drawLine(Offset(centerX, 0), Offset(centerX, size.height), paint);
    canvas.restore();
    return true;
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

  Future<void> captureWidget(
    Canvas canvas,
    EditingElementModel element,
    double pixelRatio,
  ) async {
    final RenderObject? renderObject = element.widgetKey?.currentContext
        ?.findRenderObject();

    if (renderObject == null) {
      return;
    }

    debugPrint("renderObject: $renderObject");
    final RenderRepaintBoundary boundary =
        renderObject as RenderRepaintBoundary;

    final ui.Image widgetImage = await boundary.toImage(
      pixelRatio: ui.window.devicePixelRatio,
    );

    // 2️⃣ Element position & size
    final double x = element.x;
    final double y = element.y;
    final double width = element.width;
    final double height = element.height;

    final Rect srcRect = Rect.fromLTWH(
      0,
      0,
      widgetImage.width.toDouble(),
      widgetImage.height.toDouble(),
    );

    final Rect dstRect = Rect.fromLTWH(x, y, width, height);

    // 3️⃣ Draw onto your canvas
    canvas.drawImageRect(widgetImage, srcRect, dstRect, Paint());
  }

  Future<void> drawImageUsingKey(
    Canvas canvas,
    EditingElementModel element,
    double pixelRatio,
  ) async {
    debugPrint("widgetKeys:${element.widgetKey}");
    final boundary =
        element.widgetKey?.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;

    if (boundary == null) return;
    debugPrint("boundary:$boundary");

    // 1️⃣ Capture widget as image
    final ui.Image widgetImage = await boundary.toImage(pixelRatio: pixelRatio);

    // 2️⃣ Element position & size
    final double x = element.x;
    final double y = element.y;
    final double width = element.width;
    final double height = element.height;

    final Rect srcRect = Rect.fromLTWH(
      0,
      0,
      widgetImage.width.toDouble(),
      widgetImage.height.toDouble(),
    );

    final Rect dstRect = Rect.fromLTWH(x, y, width, height);

    // 3️⃣ Draw onto your canvas
    canvas.drawImageRect(widgetImage, srcRect, dstRect, Paint());
  }

  Future<void> drawImageElementCombined(
    Canvas canvas,
    EditingElementModel element,
    double pixelRatio,
  ) async {
    try {
      final double x = element.x;
      final double y = element.y;
      final double width = element.width;
      final double height = element.height;

      final BlendMode blendMode = blendModeFromString(element.blendMode);
      final double opacity = element.alpha.clamp(0.0, 1.0);
      final double blur = element.blurAlpha ?? 0.0;
      final double rotation = element.rotation;

      final double shadowRadius = element.shadowRadius ?? 0;
      final double shadowOpacity = element.shadowOpacity ?? 0;
      final double shadowX = element.shadowX ?? 0;
      final double shadowY = element.shadowY ?? 0;

      final bool flipX = element.flipX ?? false;
      final bool flipY = element.flipY ?? false;

      final String backgroundColor =
          element.backGroundColor ?? AppConstant.transparentColor;

      final bool hasBackground =
          (backgroundColor).toUpperCase().replaceAll(" ", "") !=
          AppConstant.transparentColor;

      final bool isDefaultBlend = blendMode == AppConstant.defaultBlendMode;

      final ui.Image image = await loadUiImage(
        element.url!,
        targetWidth: (width * pixelRatio).toInt(),
        targetHeight: (height * pixelRatio).toInt(),
      );

      final Rect rect = Rect.fromLTWH(0, 0, width, height);

      final Rect srcRect = Rect.fromLTWH(
        0,
        0,
        image.width.toDouble(),
        image.height.toDouble(),
      );

      final FittedSizes fittedSizes = applyBoxFit(
        BoxFit.contain,
        srcRect.size,
        rect.size,
      );

      final Rect fittedSrcRect = Alignment.center.inscribe(
        fittedSizes.source,
        srcRect,
      );

      final Rect fittedDstRect = Alignment.center.inscribe(
        fittedSizes.destination,
        rect,
      );

      canvas.save();
      canvas.translate(x + width / 2, y + height / 2);
      canvas.rotate(rotation);
      canvas.scale(flipX ? -1.0 : 1.0, flipY ? -1.0 : 1.0);
      canvas.translate(-width / 2, -height / 2);

      if (shadowOpacity > 0 && hasBackground) {
        drawShadow(
          canvas: canvas,
          rect: rect,
          blurRadius: (shadowRadius * pixelRatio) / 15,
          spreadRadius: (shadowRadius * pixelRatio) / 15,
          opacity: shadowOpacity * opacity,
          offset: Offset(
            (shadowX * pixelRatio) / 15,
            (shadowY * pixelRatio) / 15,
          ),
        );
      } else if (shadowOpacity > 0 && !hasBackground) {
        drawShadowOnlyImageSurround(
          canvas: canvas,
          image: image,
          srcRect: fittedSrcRect,
          dstRect: fittedDstRect,
          blurRadius: (shadowRadius * pixelRatio) / 15,
          opacity: shadowOpacity * opacity,
          offset: Offset(
            (shadowX * pixelRatio) / 15,
            (shadowY * pixelRatio) / 15,
          ),
        );
      }

      final Paint layerPaint = Paint()..blendMode = blendMode;

      if (opacity < 1.0) {
        layerPaint.colorFilter = ColorFilter.mode(
          Colors.white.withOpacity(opacity),
          BlendMode.modulate,
        );
      }

      canvas.saveLayer(rect, layerPaint);

      if (backgroundColor != AppConstant.transparentColor) {
        canvas.drawRect(
          rect,
          Paint()..color = ColorUtils.fromHex(backgroundColor),
        );
      }

      if (blur > 0) {
        canvas.saveLayer(
          fittedDstRect.inflate(blur * 2),
          Paint()..imageFilter = ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        );
      }

      canvas.drawImageRect(
        image,
        fittedSrcRect,
        fittedDstRect,
        Paint()..filterQuality = FilterQuality.high,
      );

      if (blur > 0) {
        canvas.restore();
      }

      canvas.restore();
      canvas.restore();
    } catch (e) {
      debugPrint("drawImageElementCombined error: $e");
    }
  }

  Future<void> drawImageElement(
    Canvas canvas,
    EditingElementModel element,
    double pixelRatio,
  ) async {
    try {
      double xPosition = element.x;
      double yPosition = element.y;
      String imageUrl = element.url ?? '';
      double imageWidth = element.width;
      double imageHeight = element.height;
      final BlendMode blendMode = blendModeFromString(element.blendMode);
      final double opacity = element.alpha.clamp(0.0, 1.0);
      final double blurValue = element.blurAlpha ?? 0.0;
      final double rotation = element.rotation;
      final String backgroundColor =
          element.backGroundColor ?? AppConstant.transparentColor;
      final double shadowRadius = element.shadowRadius ?? 0;
      final double shadowOpacity = element.shadowOpacity ?? 0;
      final double shadowX = element.shadowX ?? 0;
      final double shadowY = element.shadowY ?? 0;
      final bool flipX = element.flipX ?? false;
      final bool flipY = element.flipY ?? false;

      final bool hasBackground =
          (backgroundColor).toUpperCase().replaceAll(" ", "") !=
          AppConstant.transparentColor;

      final bool isDefaultBlend = blendMode == AppConstant.defaultBlendMode;

      final ui.Image image = await loadUiImage(
        imageUrl,
        targetWidth: imageWidth.toInt(),
        targetHeight: imageHeight.toInt(),
      );

      final Rect srcRect = Rect.fromLTWH(0, 0, imageWidth, imageHeight);

      final FittedSizes fittedSizes = applyBoxFit(
        BoxFit.contain,
        srcRect.size,
        srcRect.size,
      );

      final Rect fittedSrcRect = Alignment.center.inscribe(
        fittedSizes.source,
        srcRect,
      );

      final Rect fittedDstRect = Alignment.center.inscribe(
        fittedSizes.destination,
        srcRect,
      );

      canvas.save();
      canvas.translate(xPosition + imageWidth / 2, yPosition + imageHeight / 2);
      canvas.rotate(rotation);
      canvas.scale(flipX == true ? -1.0 : 1.0, flipY == true ? -1.0 : 1.0);
      canvas.translate(-imageWidth / 2, -imageHeight / 2);

      if (isDefaultBlend && hasBackground) {
        drawShadow(
          canvas: canvas,
          rect: srcRect,
          blurRadius: (shadowRadius * pixelRatio) / 15,
          spreadRadius: (shadowRadius * pixelRatio) / 15,
          opacity: shadowOpacity,
          offset: Offset(
            (shadowX * pixelRatio) / 15,
            (shadowY * pixelRatio) / 15,
          ),
        );
      } else if (isDefaultBlend && !hasBackground) {
        drawShadowOnlyImageSurround(
          canvas: canvas,
          image: image,
          srcRect: fittedSrcRect,
          dstRect: fittedDstRect,
          blurRadius: (shadowRadius * pixelRatio) / 15,
          opacity: shadowOpacity,
          offset: Offset(
            (shadowX * pixelRatio) / 15,
            (shadowY * pixelRatio) / 15,
          ),
        );
      }

      if (hasBackground) {
        canvas.drawRect(
          srcRect,
          Paint()..color = ColorUtils.fromHex(backgroundColor),
        );
      }

      final Paint imagePaint = Paint()
        ..isAntiAlias = true
        ..filterQuality = FilterQuality.high;

      if (!isDefaultBlend) {
        imagePaint.blendMode = blendMode;
      }

      canvas.drawImageRect(image, fittedSrcRect, fittedDstRect, imagePaint);
      canvas.restore();
    } catch (e) {
      debugPrint("drawImageElement error: $e");
    }
  }

  void drawShadow({
    required Canvas canvas,
    required Rect rect,
    required double blurRadius,
    required double spreadRadius,
    required double opacity,
    required Offset offset,
  }) {
    if (opacity <= 0) return;

    final Paint paint = Paint()
      ..color = Colors.black.withValues(alpha: opacity)
      ..maskFilter = blurRadius > 0
          ? MaskFilter.blur(BlurStyle.normal, blurRadius)
          : null;

    // 🔥 Adjust spread to compensate blur expansion
    final double adjustedSpread = spreadRadius;
    final Rect shadowRect = rect.inflate(adjustedSpread).shift(offset);
    canvas.drawRect(shadowRect, paint);
  }

  void drawShadowOnlyImageSurround({
    required Canvas canvas,
    required ui.Image image,
    required Rect srcRect,
    required Rect dstRect,
    required double blurRadius,
    required double opacity,
    required Offset offset,
  }) {
    if (opacity <= 0) return;

    canvas.save();

    canvas.translate(offset.dx, offset.dy);

    canvas.saveLayer(
      dstRect.inflate(blurRadius * 2),
      Paint()
        ..imageFilter = ImageFilter.blur(
          sigmaX: blurRadius,
          sigmaY: blurRadius,
        ),
    );

    canvas.drawImageRect(
      image,
      srcRect,
      dstRect,
      Paint()
        ..colorFilter = ColorFilter.mode(
          Colors.black.withOpacity(opacity),
          BlendMode.srcIn, // IMPORTANT: srcIn not srcATop
        ),
    );

    canvas.restore();
    canvas.restore();
  }

  Future<void> drawImageElement22(
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

      final ui.Image filteredImage = await createFilteredImage(
        original: image,
        width: width,
        height: height,
        opacity: element.alpha,
        blur: element.blurAlpha ?? 0,
        element: element,
        backgroundColor: ColorUtils.fromHex(element.backGroundColor),
      );
      final BlendMode blendMode = blendModeFromString(element.blendMode);

      canvas.drawImage(
        filteredImage,
        Offset(x, y),
        Paint()..blendMode = blendMode,
      );
    } catch (e) {
      debugPrint("drawImageElement error: $e");
    }
  }

  Future<ui.Image> createFilteredImage({
    required ui.Image original,
    required double width,
    required double height,
    required double opacity,
    required double blur,
    required EditingElementModel element,
    Color? backgroundColor,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final Rect rect = Rect.fromLTWH(0, 0, width, height);

    // 1️⃣ First layer → for opacity
    canvas.saveLayer(rect, Paint()..color = Colors.white.withOpacity(opacity));

    // 3️⃣ BACKGROUND
    if (backgroundColor != null) {
      canvas.drawRect(rect, Paint()..color = backgroundColor);
    }

    // 4️⃣ IMAGE BLUR LAYER
    if (blur > 0) {
      // 2️⃣ Second layer → REQUIRED for blur to work properly
      canvas.saveLayer(
        rect,
        Paint()..imageFilter = ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      );
    }

    // Draw image normally
    canvas.drawImageRect(
      original,
      Rect.fromLTWH(
        0,
        0,
        original.width.toDouble(),
        original.height.toDouble(),
      ),
      rect,
      Paint()..filterQuality = FilterQuality.high,
    );

    if (blur > 0) {
      canvas.restore(); // restore blur layer
    }

    canvas.restore(); // restore opacity layer

    final picture = recorder.endRecording();

    return await picture.toImage(width.toInt(), height.toInt());
  }

  BlendMode blendModeFromString(String? modeStr) {
    String? jsonValue = modeStr;

    if (jsonValue != null && jsonValue.endsWith('BlendMode')) {
      jsonValue = jsonValue.replaceAll('BlendMode', '');
    }

    BlendMode blend = BlendMode.values.firstWhere(
      (e) => e.name == jsonValue,
      orElse: () => AppConstant.defaultBlendMode,
    );

    return blend;
  }

  Future<ui.Image> loadUiImage(
    String src, {
    int? targetWidth,
    int? targetHeight,
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
    } else if (src.startsWith('/')) {
      final fileBytes = await File(src).readAsBytes();
      final codec = await ui.instantiateImageCodec(
        fileBytes,
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

      final int svgTargetWidth =
          targetWidth ?? pictureInfo.size.width.round().clamp(1, 1000000);
      final int svgTargetHeight =
          targetHeight ?? pictureInfo.size.height.round().clamp(1, 1000000);

      // Draw Picture to a recorder at target size
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      final double scaleX = svgTargetWidth / pictureInfo.size.width;
      final double scaleY = svgTargetHeight / pictureInfo.size.height;
      canvas.scale(scaleX, scaleY);

      canvas.drawPicture(pictureInfo.picture);

      final ui.Picture picture = recorder.endRecording();
      final ui.Image image = await picture.toImage(
        svgTargetWidth,
        svgTargetHeight,
      );
      return image;
    }
  }

  void drawLabelElement(Canvas canvas, EditingElementModel element) {
    final double x = element.x;
    final double y = element.y;
    final double w = element.width;
    final double h = element.height;
    final double rotation = element.rotation;

    canvas.save();

    // 🔁 Position + rotation
    canvas.translate(x + w / 2, y + h / 2);
    canvas.rotate(rotation);
    canvas.translate(-w / 2, -h / 2);

    // 🎨 Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..isAntiAlias = true
        ..color = ColorUtils.fromHex(element.backGroundColor),
    );
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
 */
