import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

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
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
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
          fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
