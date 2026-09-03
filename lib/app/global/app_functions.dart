import 'package:hugeicons/hugeicons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:omni_remote/app/app.dart';

class AppFunctions {
  static void showSnackBar(
    BuildContext context, {
    String? message,
    SnackBarType type = SnackBarType.info,
  }) {
    List<List<dynamic>> icon;
    switch (type) {
      case SnackBarType.success:
        icon = HugeIcons.strokeRoundedCheckmarkCircle02;
      case SnackBarType.error:
        icon = HugeIcons.strokeRoundedAlertCircle;
      case SnackBarType.warning:
        icon = HugeIcons.strokeRoundedAlert02;
      case SnackBarType.info:
        icon = HugeIcons.strokeRoundedInformationCircle;
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          spacing: 12,
          children: [
            HugeIcon(
              icon: icon,
              strokeWidth: 2,
              color: Colors.white,
            ),
            Expanded(
              child: Text(
                message ?? '',
                style: TextStyle(
                  fontVariations: <FontVariation>[
                    ...(Theme.of(
                              context,
                            ).textTheme.labelMedium?.fontVariations ??
                            const <FontVariation>[])
                        .where((v) => v.axis != 'wght'),
                    const FontVariation('wght', 700),
                  ],
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        closeIconColor: Colors.white,
        backgroundColor: type.isSuccess
            ? Colors.green
            : type.isError
            ? Colors.red
            : type.isWarning
            ? Colors.orange
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
