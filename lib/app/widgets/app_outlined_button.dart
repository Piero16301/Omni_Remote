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
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: innerPadding ?? const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: icon != null ? HugeIcon(icon: icon!, strokeWidth: 2) : null,
      label: Text(
        label ?? '',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontVariations: [
            ...(Theme.of(context).textTheme.titleMedium?.fontVariations ??
                    const <FontVariation>[])
                .where((v) => v.axis != 'wght'),
            const FontVariation('wght', 700),
          ],
        ),
      ),
    );
  }
}
