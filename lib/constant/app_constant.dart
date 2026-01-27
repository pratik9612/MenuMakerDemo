import 'dart:ui';

class AppConstant {
  static String imageBaseUrl =
      "https://usc1.contabostorage.com/c3563790b10a4b68acfcc6f842daaa3c:mobileapps/menu-maker/";
  static double editorBoxPadding = 8;

  static String defultColor = "#FF000000";

  // static ({String fontFamily, FontWeight fontWeight, FontStyle fontStyle})
  // resolve(String iosFontName) {
  //   // Baseline defaults (safe fallback contract)

  //   String family = iosFontName.split('-').first;

  //   FontWeight weight = FontWeight.w400;

  //   FontStyle style = FontStyle.normal;

  //   final normalized = iosFontName.toLowerCase();

  //   // ---- Italic detection (orthogonal concern) ----

  //   if (normalized.contains('italic') || normalized.contains('oblique')) {
  //     style = FontStyle.italic;
  //   }

  //   // ---- Weight resolution (ordered by specificity) ----

  //   if (normalized.contains('thin')) {
  //     weight = FontWeight.w100;
  //   } else if (normalized.contains('extralight') ||
  //       normalized.contains('ultralight')) {
  //     weight = FontWeight.w200;
  //   } else if (normalized.contains('light')) {
  //     weight = FontWeight.w300;
  //   } else if (normalized.contains('regular') ||
  //       normalized.contains('normal')) {
  //     weight = FontWeight.w400;
  //   } else if (normalized.contains('medium')) {
  //     weight = FontWeight.w500;
  //   } else if (normalized.contains('semibold') ||
  //       normalized.contains('demibold')) {
  //     weight = FontWeight.w600;
  //   } else if (normalized.contains('bold')) {
  //     weight = FontWeight.w700;
  //   } else if (normalized.contains('extrabold') ||
  //       normalized.contains('heavy')) {
  //     weight = FontWeight.w800;
  //   } else if (normalized.contains('black')) {
  //     weight = FontWeight.w900;
  //   }

  //   return (fontFamily: family, fontWeight: weight, fontStyle: style);
  // }
  static ({String fontFamily, FontWeight fontWeight, FontStyle fontStyle})
  resolve(String iosFontName) {
    String family = iosFontName.split('-').first.split('_').first;

    FontWeight weight = FontWeight.w400;
    FontStyle style = FontStyle.normal;

    final normalized = iosFontName.toLowerCase();

    // ---- Italic detection ----
    if (normalized.contains('italic') || normalized.contains('oblique')) {
      style = FontStyle.italic;
    }

    // ---- Weight detection (correct priority) ----
    if (normalized.contains('black')) {
      weight = FontWeight.w900;
    } else if (normalized.contains('extrabold') ||
        normalized.contains('ultrabold')) {
      weight = FontWeight.w800;
    } else if (normalized.contains('bold')) {
      weight = FontWeight.w700;
    } else if (normalized.contains('semibold') ||
        normalized.contains('demibold')) {
      weight = FontWeight.w600;
    } else if (normalized.contains('medium')) {
      weight = FontWeight.w500;
    } else if (normalized.contains('regular') ||
        normalized.contains('normal')) {
      weight = FontWeight.w400;
    } else if (normalized.contains('light')) {
      weight = FontWeight.w300;
    } else if (normalized.contains('extralight') ||
        normalized.contains('ultralight')) {
      weight = FontWeight.w200;
    } else if (normalized.contains('thin')) {
      weight = FontWeight.w100;
    }

    return (fontFamily: family, fontWeight: weight, fontStyle: style);
  }
}
