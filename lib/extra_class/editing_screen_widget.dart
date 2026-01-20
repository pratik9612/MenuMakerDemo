// import 'package:flutter/material.dart';
// import 'package:menu_maker_demo/constant/app_constant.dart';
// import 'package:menu_maker_demo/constant/color_utils.dart';
// import 'package:menu_maker_demo/editing_screen/editing_screen_controller.dart';

// class BackgroundWidget extends StatelessWidget {
//   final BackgroundModel backgroundModel;
//   const BackgroundWidget({super.key, required this.backgroundModel});

//   @override
//   Widget build(BuildContext context) {
//     final aspectRatio = backgroundModel.width / backgroundModel.height;
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         double width = constraints.maxWidth;
//         double height = width / aspectRatio;

//         if (height > constraints.maxHeight) {
//           height = constraints.maxHeight;
//           width = height * aspectRatio;
//         }

//         return SizedBox(
//           width: width,
//           height: height,
//           child: DecoratedBox(
//             decoration: BoxDecoration(
//               color: ColorUtils.fromHex(backgroundModel.backGroundColor),
//             ),
//             child: _buildImage(backgroundModel),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildImage(BackgroundModel bg) {
//     if (bg.url.isEmpty) return SizedBox.shrink();
//     return bg.url.startsWith('images')
//         ? Image.network(
//             "${AppConstant.imageBaseUrl}${bg.url}",
//             fit: BoxFit.fill,
//           )
//         : Image.asset(bg.url, fit: BoxFit.fill);
//   }
// }
