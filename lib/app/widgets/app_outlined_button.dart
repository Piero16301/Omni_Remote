import 'package:expressive_kit/expressive_kit.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:material_ui/material_ui.dart';

class AppOutlinedButton extends StatelessWidget {
  const AppOutlinedButton({
    this.onPressed,
    this.icon,
    this.label,
    this.innerPadding,
    super.key,
  });

  final void Function()? onPressed;
  final List<List<dynamic>>? icon;
  final String? label;
  final EdgeInsetsGeometry? innerPadding;

  @override
  Widget build(BuildContext context) {
    return ExpressiveButton.outlined(
      onPressed: onPressed,
      icon: icon != null ? HugeIcon(icon: icon!, strokeWidth: 2) : null,
      label: label ?? '',
      isExpanded: true,
      size: ExpressiveButtonSize.large,
    );
  }
}
