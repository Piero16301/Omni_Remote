import 'package:expressive_kit/expressive_kit.dart';
import 'package:material_ui/material_ui.dart';

class AppFilledButton extends StatelessWidget {
  const AppFilledButton({
    this.onPressed,
    this.icon,
    this.label,
    this.innerPadding,
    this.color,
    this.isOnlyIcon = false,
    this.isLoading = false,
    super.key,
  });

  final void Function()? onPressed;
  final Widget? icon;
  final String? label;
  final EdgeInsetsGeometry? innerPadding;
  final Color? color;
  final bool isOnlyIcon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isOnlyIcon && icon != null) {
      return ExpressiveIconButton.circle(
        icon: icon!,
        variant: ExpressiveIconButtonVariant.filled,
        backgroundColor: color,
        onPressed: onPressed,
      );
    }
    return ExpressiveButton.filled(
      onPressed: onPressed,
      backgroundColor: color,
      icon: icon,
      label: label ?? '',
      isLoading: isLoading,
      isExpanded: true,
      size: ExpressiveButtonSize.large,
    );
  }
}
