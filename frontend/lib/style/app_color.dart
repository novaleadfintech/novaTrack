import 'package:flutter/material.dart';

class AppColor {
  // ======== LIGHT MODE COLORS ========
  static const Color primaryColor = Color(0xFF277572);
  static const Color backgroundColor = Color.fromARGB(255, 226, 239, 239);
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color grayColor = Color(0xFF8B909A);
  static const Color blackColor = Color(0xFF272827);
  static const Color dirtyWhite = Color(0xFFF5F5F5);
  static const Color greensecondary700 = Color(0xFF6D8B40);
  static const Color greensecondary500 = Color(0xFF99C45A);
  static const Color redColor = Color(0xFFD20000);
  static const Color grayprimary = Color(0xFF565656);
  static const Color greenSecondary = Color(0xFFF5F9EF);
  static const Color popGrey = Colors.grey;
  static const Color modificationColor = Color.fromARGB(255, 12, 3, 134);

  // ======== DARK MODE COLORS ========
  static const Color bprimaryColor =
      Color(0xFF3FA99F); // clair dérivé du primary
  static const Color bbackgroundColor =
      Color.fromARGB(255, 32, 55, 55); // fond sombre doux
  static const Color bwhiteColor = Color(0xFF121212); // fond pour cards/dialog
  static const Color bgrayColor = Color(0xFFB0B3B8); // texte secondaire
  static const Color bblackColor = Color(0xFFE4E6EB); // texte principal
  static const Color bdirtyWhite =
      Color(0xFF292929); // fond composant intermédiaire
  static const Color bgreensecondary700 =
      Color(0xFF81C784); // variation verte douce
  static const Color bgreensecondary500 = Color.fromARGB(255, 62, 79, 63);
  static const Color bredColor = Color(0xFFFF5252); // rouge visible
  static const Color bgrayprimary = Color(0xFF9E9E9E); // gris moyen
  static const Color bgreenSecondary = Color(0xFF2E7D32); // vert foncé (accent)
  static const Color bpopGrey = Colors.grey; // dividers, icônes grises
  static const Color bmodificationColor = Color(0xFF536DFE); // bleu d’action

  // ======== ADAPTATIVE HELPERS ========
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color adaptivePrimaryColor(BuildContext context) =>
      isDark(context) ? bprimaryColor : primaryColor;

  static Color adaptiveBackgroundColor(BuildContext context) =>
      isDark(context) ? bbackgroundColor : backgroundColor;
  static Color adaptativeLoginScreenBachroundColor(BuildContext context) =>
      isDark(context) ? bbackgroundColor : primaryColor;

  static Color adaptiveWhiteColor(BuildContext context) =>
      isDark(context) ? bwhiteColor : whiteColor;

  static Color adaptiveGrayColor(BuildContext context) =>
      isDark(context) ? bgrayColor : grayColor;

  static Color adaptiveBlackColor(BuildContext context) =>
      isDark(context) ? bblackColor : blackColor;

  static Color adaptiveDirtyWhite(BuildContext context) =>
      isDark(context) ? bdirtyWhite : dirtyWhite;

  static Color adaptiveGreenSecondary700(BuildContext context) =>
      isDark(context) ? bgreensecondary700 : greensecondary700;

  static Color adaptiveGreenSecondary500(BuildContext context) =>
      isDark(context) ? bgreensecondary500 : greensecondary500;

  static Color adaptiveRedColor(BuildContext context) =>
      isDark(context) ? bredColor : redColor;

  static Color adaptiveGrayPrimary(BuildContext context) =>
      isDark(context) ? bgrayprimary : grayprimary;

  static Color adaptiveGreenSecondary(BuildContext context) =>
      isDark(context) ? bgreenSecondary : greenSecondary;
  static Color adaptiveamber(BuildContext context) =>
      isDark(context) ? Color.fromARGB(255, 62, 53, 35) : Colors.amber.shade50;

  static Color adaptivePopGrey(BuildContext context) =>
      isDark(context) ? grayprimary : popGrey;

  static Color adaptiveModificationColor(BuildContext context) =>
      isDark(context) ? bmodificationColor : modificationColor;
}
