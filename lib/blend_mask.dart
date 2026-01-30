import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';

class BlendMask extends SingleChildRenderObjectWidget {
  final BlendMode blendMode;
  final double opacity;
  final double blur;

  const BlendMask({
    required this.blendMode,
    required this.opacity,
    this.blur = 0,
    super.key,
    super.child,
  });

  @override
  RenderObject createRenderObject(context) {
    return RenderBlendMask(blendMode, opacity, blur);
  }

  @override
  void updateRenderObject(BuildContext context, RenderBlendMask renderObject) {
    renderObject
      ..blendMode = blendMode
      ..opacity = opacity
      ..blur = blur;
  }
}

class RenderBlendMask extends RenderProxyBox {
  BlendMode blendMode;
  double opacity;
  double blur;

  RenderBlendMask(this.blendMode, this.opacity, this.blur);

  @override
  void paint(PaintingContext context, Offset offset) {
    final Paint paint = Paint()
      ..blendMode = blendMode
      ..color = Color.fromRGBO(255, 255, 255, opacity);

    // 👇 APPLY BLUR HERE
    if (blur > 0) {
      paint.imageFilter = ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur);
    }

    context.canvas.saveLayer(offset & size, paint);
    super.paint(context, offset);
    context.canvas.restore();
  }
}

/* 
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class BlendMask extends SingleChildRenderObjectWidget {
  final BlendMode blendMode;

  const BlendMask({required this.blendMode, super.key, super.child});

  @override
  RenderObject createRenderObject(context) {
    return RenderBlendMask(blendMode);
  }

  @override
  void updateRenderObject(BuildContext context, RenderBlendMask renderObject) {
    renderObject.blendMode = blendMode;
  }
}

class RenderBlendMask extends RenderProxyBox {
  BlendMode blendMode;

  RenderBlendMask(this.blendMode);

  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.saveLayer(offset & size, Paint()..blendMode = blendMode);

    super.paint(context, offset);

    context.canvas.restore();
  }
}

 */
