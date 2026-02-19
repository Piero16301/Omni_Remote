import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class AppFilledButton extends StatelessWidget {
  const AppFilledButton({
    this.onPressed,
    this.icon,
    this.label,
    this.innerPadding,
    this.color,
    super.key,
  });

  final void Function()? onPressed;
  final List<List<dynamic>>? icon;
  final String? label;
  final EdgeInsetsGeometry? innerPadding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        padding: innerPadding ??
            const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: icon != null ? HugeIcon(icon: icon!, strokeWidth: 2) : null,
      label: Text(
        label ?? '',
        style: TextStyle(
          fontSize: Theme.of(context).textTheme.titleSmall?.fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
