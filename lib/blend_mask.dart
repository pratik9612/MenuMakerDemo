import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class BlendMask extends SingleChildRenderObjectWidget {
  final BlendMode blendMode;
  final double opacity;

  const BlendMask({
    required this.blendMode,
    required this.opacity,
    super.key,
    super.child,
  });

  @override
  RenderObject createRenderObject(context) {
    return RenderBlendMask(blendMode, opacity);
  }

  @override
  void updateRenderObject(BuildContext context, RenderBlendMask renderObject) {
    renderObject.blendMode = blendMode;
    renderObject.opacity = opacity;
  }
}

class RenderBlendMask extends RenderProxyBox {
  BlendMode blendMode;
  double opacity;

  RenderBlendMask(this.blendMode, this.opacity);

  @override
  void paint(PaintingContext context, Offset offset) {
    final Paint paint = Paint()
      ..blendMode = blendMode
      ..color = Color.fromRGBO(255, 255, 255, opacity);

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
