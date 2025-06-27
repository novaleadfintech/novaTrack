import 'package:flutter/material.dart';
import 'app_color.dart';

class AppTheme {
  static ThemeData getLightTheme() {
    return ThemeData(
      fontFamily: "Inter",
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColor.primaryColor,
        onPrimary: AppColor.whiteColor,
        secondary: AppColor.grayprimary,
        onSecondary: AppColor.grayColor,
        onError: AppColor.whiteColor,
        error: AppColor.redColor,
        surfaceBright: AppColor.dirtyWhite,
        onSurfaceVariant: AppColor.popGrey,
        surface: AppColor.whiteColor,
        onSurface: AppColor.blackColor,
      ),
      scaffoldBackgroundColor: AppColor.backgroundColor,
      scrollbarTheme: const ScrollbarThemeData(
        //thumbVisibility: MaterialStatePropertyAll(false),
        thumbColor: WidgetStatePropertyAll(Colors.transparent),
        minThumbLength: 0.0,
      ),
      elevatedButtonTheme: const ElevatedButtonThemeData(
        style: ButtonStyle(
          //textStyle: MaterialStatePropertyAll(DestopAppStyle.simpleSemiBoldText),
          //elevation: MaterialStatePropertyAll(1),
          padding: WidgetStatePropertyAll(EdgeInsets.all(8)),

          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
          ),
        ),
      ),
    );
  }

  static ThemeData getDarkTheme() {
    return ThemeData(
      fontFamily: "Inter",
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColor.bprimaryColor,
        onPrimary: AppColor.bwhiteColor,
        secondary: AppColor.bgrayprimary,
        onSecondary: AppColor.bgrayColor,
        onError: AppColor.bwhiteColor,
        error: AppColor.bredColor,
        surfaceBright: AppColor.bdirtyWhite,
        onSurfaceVariant: AppColor.bpopGrey,
        surface: AppColor.bwhiteColor,
        onSurface: AppColor.bblackColor,
      ),
      scaffoldBackgroundColor: AppColor.bbackgroundColor,
      scrollbarTheme: const ScrollbarThemeData(
        //thumbVisibility: MaterialStatePropertyAll(false),
        thumbColor: WidgetStatePropertyAll(Colors.transparent),
        minThumbLength: 0.0,
      ),
      elevatedButtonTheme: const ElevatedButtonThemeData(
        style: ButtonStyle(
          //textStyle: MaterialStatePropertyAll(DestopAppStyle.simpleSemiBoldText),
          //elevation: MaterialStatePropertyAll(1),
          padding: WidgetStatePropertyAll(EdgeInsets.all(8)),

          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
          ),
        ),
      ),
    );
  }
}
