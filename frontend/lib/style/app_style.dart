import 'package:flutter/material.dart';

class DestopAppStyle {
  static const TextStyle normalText = TextStyle(
    fontWeight: FontWeight.normal,
  );
  static const TextStyle fieldTitlesStyle = TextStyle(
    fontWeight: FontWeight.bold,
  );

  static const TextStyle tableHeaderStlye = TextStyle(
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleText = TextStyle(
    fontFamily: "Inter",
    fontWeight: FontWeight.w600,
    fontSize: 16,
  );

  static const TextStyle bigTitleText = TextStyle(
    fontFamily: "Inter",
    fontWeight: FontWeight.w600,
    fontSize: 24,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontFamily: "Inter",
    fontWeight: FontWeight.w600,
    fontSize: 14,
  );

  static const TextStyle normalSemiBoldText = TextStyle(
    fontFamily: "Inter",
    fontWeight: FontWeight.w500,
  );

  static const TextStyle paginationNumberStyle = TextStyle(
    fontFamily: "Inter",
    fontWeight: FontWeight.bold, fontSize: 16
  );

  static const TextStyle simpleBoldText = TextStyle(
    fontFamily: "Inter",
    fontWeight: FontWeight.bold,
  );

  static const TextStyle smallSimpleText = TextStyle(
    fontFamily: "Inter",
    fontWeight: FontWeight.normal,
    fontSize: 10,
  );

  static const double iconSize = 24;
}

BoxDecoration tableDecoration(BuildContext context, {Color? color}) =>
    BoxDecoration(
      border: Border.symmetric(
        horizontal: BorderSide(
          color: Theme.of(context).colorScheme.surfaceBright,
          width: 2,
        ),
      ),
      color: color ?? Theme.of(context).colorScheme.surface,
    );

BoxDecoration marktableDecoration(BuildContext context) => BoxDecoration(
      border: Border.symmetric(
        horizontal: BorderSide(
          color: Theme.of(context).colorScheme.surfaceBright,
          width: 2,
        ),
      ),
      color: Theme.of(context).colorScheme.error.withOpacity(0.2),
    );

BoxDecoration inactiveUsertableDecoration(BuildContext context) =>
    BoxDecoration(
      border: Border.symmetric(
        horizontal: BorderSide(
            color: Theme.of(context).colorScheme.surfaceBright, width: 2),
      ),
      color: Theme.of(context).colorScheme.error.withOpacity(0.2),
    );

BoxDecoration inputTableDecoration(BuildContext context) => BoxDecoration(
      border: Border.symmetric(
        horizontal: BorderSide(
          color: Theme.of(context).colorScheme.surfaceBright,
          width: 2,
        ),
      ),
      color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
    );

BoxDecoration outputTableDecoration(BuildContext context) => BoxDecoration(
      border: Border.symmetric(
        horizontal: BorderSide(
          color: Theme.of(context).colorScheme.surfaceBright,
          width: 2,
        ),
      ),
      color: Theme.of(context).colorScheme.error.withOpacity(0.05),
    );

BoxDecoration checkPermissionTableDecoration(BuildContext context) => BoxDecoration(
      border: Border.symmetric(
        horizontal: BorderSide(
          color: Theme.of(context).colorScheme.surfaceBright,
          width: 2,
        ),
      ),
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
    );

BoxDecoration checkNotPermissionTableDecoration(BuildContext context) => BoxDecoration(
      border: Border.symmetric(
        horizontal: BorderSide(
          color: Theme.of(context).colorScheme.surfaceBright,
          width: 2,
        ),
      ),
      color: Theme.of(context).colorScheme.error.withOpacity(0.1),
    );

BoxDecoration rejectFluxTableDecoration(BuildContext context) => BoxDecoration(
      border: Border.symmetric(
        horizontal: BorderSide(
          color: Theme.of(context).colorScheme.surfaceBright,
          width: 2,
        ),
      ),
      color: Theme.of(context).colorScheme.error.withOpacity(0.1),
    );

BoxDecoration validatedFluxTableDecoration(BuildContext context) =>
    BoxDecoration(
      border: Border.symmetric(
        horizontal: BorderSide(
          color: Theme.of(context).colorScheme.surfaceBright,
          width: 2,
        ),
      ),
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
    );
