import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'language_provider.dart';

class AppFonts {
  static TextStyle dmSans(BuildContext context, {Color? color, double? fontSize, FontWeight? fontWeight, double? height, double? letterSpacing}) {
    final isUrdu = LanguageScope.of(context).isUrdu;
    if (isUrdu) {
      return GoogleFonts.notoNastaliqUrdu(color: color, fontSize: fontSize, fontWeight: fontWeight, height: height, letterSpacing: letterSpacing);
    }
    return GoogleFonts.dmSans(color: color, fontSize: fontSize, fontWeight: fontWeight, height: height, letterSpacing: letterSpacing);
  }

  static TextStyle playfairDisplay(BuildContext context, {Color? color, double? fontSize, FontWeight? fontWeight, double? height, double? letterSpacing}) {
    final isUrdu = LanguageScope.of(context).isUrdu;
    if (isUrdu) {
      return GoogleFonts.notoNastaliqUrdu(color: color, fontSize: fontSize, fontWeight: fontWeight, height: height, letterSpacing: letterSpacing);
    }
    return GoogleFonts.playfairDisplay(color: color, fontSize: fontSize, fontWeight: fontWeight, height: height, letterSpacing: letterSpacing);
  }
}
