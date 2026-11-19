import 'package:material_ui/material_ui.dart';
import 'package:omni_remote/app/app.dart';

class AppMaxWidthContainer extends StatelessWidget {
  const new({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppVariables.maxContentWidth,
        ),
        child: child,
      ),
    );
  }
}
