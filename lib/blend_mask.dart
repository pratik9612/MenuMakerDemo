import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class BlendMask extends SingleChildRenderObjectWidget {
  final BlendMode blendMode;
  final double opacity;
  final double blur;
  final double shadowOpacity;
  final double shadowBlur;
  final Offset shadowOffset;
  const BlendMask({
    required this.blendMode,
    required this.opacity,
    this.blur = 0,
    this.shadowOpacity = 0,
    this.shadowBlur = 0,
    this.shadowOffset = Offset.zero,
    super.key,
    super.child,
  });

  @override
  RenderObject createRenderObject(context) {
    return RenderBlendMask(
      blendMode,
      opacity,
      blur,
      shadowOpacity,
      shadowBlur,
      shadowOffset,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderBlendMask renderObject) {
    renderObject
      ..blendMode = blendMode
      ..opacity = opacity
      ..blur = blur
      ..shadowOpacity = shadowOpacity
      ..shadowBlur = shadowBlur
      ..shadowOffset = shadowOffset;
  }
}

class RenderBlendMask extends RenderProxyBox {
  BlendMode blendMode;
  double opacity;
  double blur;

  double shadowOpacity;
  double shadowBlur;
  Offset shadowOffset;

  RenderBlendMask(
    this.blendMode,
    this.opacity,
    this.blur,
    this.shadowOpacity,
    this.shadowBlur,
    this.shadowOffset,
  );

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final rect = offset & size;

    if (shadowOpacity > 0 && shadowBlur > 0) {
      final shadowPaint = Paint()
        ..color = Color(0xFF000000).withValues(alpha: shadowOpacity)
        ..imageFilter = ui.ImageFilter.blur(
          sigmaX: shadowBlur,
          sigmaY: shadowBlur,
        );

      // draw blurred silhouette behind
      canvas.saveLayer(rect.shift(shadowOffset), shadowPaint);
      super.paint(context, offset);
      canvas.restore();
    }

    // ===== MAIN IMAGE =====
    final paint = Paint()
      ..blendMode = blendMode
      ..color = Color.fromRGBO(255, 255, 255, opacity);

    if (blur > 0) {
      paint.imageFilter = ui.ImageFilter.blur(
        sigmaX: blur * 15,
        sigmaY: blur * 15,
      );
    }

    canvas.saveLayer(rect, paint);
    super.paint(context, offset);
    canvas.restore();
  }
}
