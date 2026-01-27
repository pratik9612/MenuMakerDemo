// import 'dart:async';
// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';
// import 'package:menu_maker_demo/constant/app_constant.dart';
// import 'model/editing_element_model.dart';

// class EditorImageRenderer {
//   static Future<Uint8List> renderFromJson(EditorDataModel data) async {
//     final recorder = ui.PictureRecorder();
//     final canvas = Canvas(recorder);

//     final width = data.superViewWidth;
//     final height = data.superViewHeight;

//     /// 🔹 Draw white background
//     canvas.drawRect(
//       Rect.fromLTWH(0, 0, width, height),
//       Paint()..color = Colors.white,
//     );

//     /// ⚠️ Only render first page
//     final firstPage = data.elements.values.first;

//     /// 🔹 Draw background layer
//     final bg = firstPage.first;
//     _drawBackground(canvas, bg, width, height);

//     /// 🔹 Draw other elements
//     for (int i = 1; i < firstPage.length; i++) {
//       final el = firstPage[i];

//       if (el.type == EditingWidgetType.label.name) {
//         _drawText(canvas, el);
//       } else if (el.type == EditingWidgetType.image.name) {
//         await _drawImage(canvas, el);
//       }
//     }

//     final picture = recorder.endRecording();
//     final image = await picture.toImage(width.toInt(), height.toInt());

//     final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

//     return byteData!.buffer.asUint8List();
//   }

//   /// 🔹 Background Renderer
//   static void _drawBackground(
//     Canvas canvas,
//     EditingElementModel bg,
//     double width,
//     double height,
//   ) {
//     if (bg.backGroundColor != null) {
//       canvas.drawRect(
//         Rect.fromLTWH(0, 0, width, height),
//         Paint()..color = _hexToColor(bg.backGroundColor!),
//       );
//     }
//   }

//   /// 🔹 Text Renderer
//   static void _drawText(Canvas canvas, EditingElementModel el) {
//     final textPainter = TextPainter(
//       text: TextSpan(
//         text: el.text ?? '',
//         style: TextStyle(
//           fontSize: el.textSize ?? 24,
//           color: _hexToColor(el.textColor ?? "#FF000000"),
//           backgroundColor: _hexToColor(el.backGroundColor ?? "#00000000"),
//         ),
//       ),
//       textDirection: TextDirection.ltr,
//     );

//     textPainter.layout();

//     canvas.save();
//     canvas.translate(el.x, el.y);
//     canvas.rotate(el.rotation);

//     textPainter.paint(canvas, Offset.zero);
//     canvas.restore();
//   }

//   /// 🔹 Image Renderer
//   static Future<void> _drawImage(Canvas canvas, EditingElementModel el) async {
//     if (el.url == null) return;

//     late ImageProvider imageProvider;

//     final url = el.url!;

//     if (url.startsWith("http")) {
//       imageProvider = NetworkImage(url);
//     } else if (url.startsWith("Templates")) {
//       imageProvider = NetworkImage("${AppConstant.imageBaseUrl}$url");
//     } else {
//       // Fallback to asset for true local assets
//       imageProvider = AssetImage(url);
//     }

//     final imageStream = imageProvider.resolve(const ImageConfiguration());
//     final completer = Completer<ui.Image>();

//     imageStream.addListener(
//       ImageStreamListener((info, _) {
//         completer.complete(info.image);
//       }),
//     );

//     final img = await completer.future;

//     final src = Rect.fromLTWH(
//       0,
//       0,
//       img.width.toDouble(),
//       img.height.toDouble(),
//     );

//     final dst = Rect.fromLTWH(el.x, el.y, el.width, el.height);

//     canvas.drawImageRect(img, src, dst, Paint());
//   }

//   static Color _hexToColor(String hex) {
//     hex = hex.replaceAll("#", "");
//     if (hex.length == 6) hex = "FF$hex";
//     return Color(int.parse(hex, radix: 16));
//   }
// }
