import 'package:expressive_kit/expressive_kit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:omni_remote/app/app.dart';

class AppFunctions {
  /// Validates [formKey] and scrolls the first invalid field into view if
  /// it resides inside a [Scrollable].
  static bool validateForm(GlobalKey<FormState> formKey) {
    final invalidFields =
        formKey.currentState?.validateGranularly() ?? const {};
    if (invalidFields.isEmpty) {
      return formKey.currentState != null;
    }
    final firstInvalidContext = invalidFields.first.context;
    if (firstInvalidContext.mounted &&
        Scrollable.maybeOf(firstInvalidContext) != null) {
      Scrollable.ensureVisible(
        firstInvalidContext,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
    return false;
  }

  static void showSnackBar(
    BuildContext context, {
    String? message,
    SnackBarType type = SnackBarType.info,
  }) {
    final expressiveType = switch (type) {
      SnackBarType.success => ExpressiveSnackBarType.success,
      SnackBarType.error => ExpressiveSnackBarType.error,
      SnackBarType.warning => ExpressiveSnackBarType.warning,
      SnackBarType.info => ExpressiveSnackBarType.info,
    };

    showExpressiveSnackBar(
      context: context,
      message: message ?? '',
      type: expressiveType,
    );
  }
}
