import 'package:flutter/material.dart';

class SettingsCardBlock<T> extends StatelessWidget {
  const SettingsCardBlock({
    required this.title,
    required this.value,
    required this.items,
    this.onChanged,
    this.isExpanded = false,
    super.key,
  });

  final String title;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    return isExpanded
        ? Expanded(child: _buildCard(context))
        : _buildCard(context);
  }

  Widget _buildCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                underline: const SizedBox(),
                borderRadius: BorderRadius.circular(8),
                onChanged: onChanged,
                items: items,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
