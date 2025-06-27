import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../helper/assets/asset_icon.dart';
import '../../main.dart';
import 'popop_status.dart';

class MutationRequestContextualBehavior {
  static void showPopup({
    required PopupStatus status,
    String? customMessage,
  }) {
    switch (status) {
      case PopupStatus.success:
        _showSuccessPopUp(
          message: customMessage ?? 'Opération réussie',
        );
        break;
      case PopupStatus.serverError:
        _showServerErrorPopUp(
          message: customMessage ??
              'Une erreur inattendue est survenue du côté serveur.',
        );
        break;
      case PopupStatus.customError:
        _showCustomErrorPopUp(
          message: customMessage ?? 'Une erreur inattendue est survenue.',
        );
      case PopupStatus.information:
        showCustomInformationPopUp(
          message: customMessage ?? 'Une erreur inattendue est survenue.',
        );
        break;
    }
  }

  // Pop-up de succès
  static void _showSuccessPopUp({
    required String message,
  }) {
    final context = navigatorKey.currentContext;

    if (context == null) {
      return;
    }
    // print(context);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          elevation: 2,
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: IntrinsicWidth(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.green,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    AssetsIcons.success,
                    height: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Pop-up d'erreur serveur
  static void _showServerErrorPopUp({
    required String message,
  }) {
    final context = navigatorKey.currentContext;

    if (context == null) {
      return; // Ne rien faire si le contexte n'est pas disponible
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          elevation: 2,
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: IntrinsicWidth(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
                top: 16,
                bottom: 8,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.orange,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    AssetsIcons.serverError,
                    height: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Ferme le pop-up
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Pop-up d'erreur personnalisée
  static void _showCustomErrorPopUp({
    required String message,
  }) {
    final context = navigatorKey.currentContext;

    if (context == null) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          elevation: 2,
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: IntrinsicWidth(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
                top: 16,
                bottom: 8,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.red,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    AssetsIcons.err,
                    height: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Ferme le pop-up
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static void showCustomInformationPopUp({
    required String message,
  }) {
    final context = navigatorKey.currentContext;

    if (context == null) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          elevation: 2,
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: IntrinsicWidth(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
                top: 16,
                bottom: 8,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blue,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    AssetsIcons.information,
                    height: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Ferme le pop-up
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static void showSuccessLoginPopUp({required Widget content}) {
    final context = navigatorKey.currentContext;

    if (context == null) {
      return;
    }
    // print(context);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          elevation: 2,
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: IntrinsicWidth(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.green,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    AssetsIcons.success,
                    height: 40,
                  ),
                  const SizedBox(height: 8),
                  content,
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static void closePopup() {
    if (Navigator.canPop(navigatorKey.currentContext!)) {
      Navigator.of(navigatorKey.currentContext!).pop(); // Ferme le Dialog
    }
  }
static T closePopupWithSomething<T>({required T theThing}) {
    if (Navigator.canPop(navigatorKey.currentContext!)) {
      Navigator.of(navigatorKey.currentContext!).pop(theThing);
    }
    return theThing;
  }

  static Future<T?> openPage<T>(Widget page) async {
    final context = navigatorKey.currentContext;
    if (context == null) return null;

    return await Navigator.push<T>(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }
}
