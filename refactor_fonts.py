import os
import re

lib_dir = r"d:\AGRI_PULSE\lib"

# We will create lib/utils/app_fonts.dart
fonts_dart = """import 'package:flutter/material.dart';
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
"""

with open(os.path.join(lib_dir, "utils", "app_fonts.dart"), "w") as f:
    f.write(fonts_dart)

# We need to replace GoogleFonts.dmSans(...) with AppFonts.dmSans(context, ...)
for root, dirs, files in os.walk(lib_dir):
    for file in files:
        if file.endswith(".dart") and file != "app_fonts.dart":
            path = os.path.join(root, file)
            with open(path, "r", encoding="utf-8") as f:
                content = f.read()

            if "GoogleFonts.dmSans" in content or "GoogleFonts.playfairDisplay" in content:
                # Add import if needed
                import_stmt = "import 'package:agri_pulse/utils/app_fonts.dart';"
                
                # We can't just blindly use 'package:agri_pulse...' if the app name is different. Let's use relative imports.
                rel_path = os.path.relpath(os.path.join(lib_dir, "utils", "app_fonts.dart"), os.path.dirname(path)).replace("\\", "/")
                import_stmt = f"import '{rel_path}';"
                
                if import_stmt not in content:
                    # Find first import and insert after
                    import_idx = content.find("import ")
                    if import_idx != -1:
                        content = content[:import_idx] + import_stmt + "\n" + content[import_idx:]

                # Replace
                content = re.sub(r'GoogleFonts\.dmSans\(', r'AppFonts.dmSans(context, ', content)
                content = re.sub(r'GoogleFonts\.playfairDisplay\(', r'AppFonts.playfairDisplay(context, ', content)

                with open(path, "w", encoding="utf-8") as f:
                    f.write(content)
                print(f"Updated {path}")
