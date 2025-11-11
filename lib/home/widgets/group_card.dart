import 'package:flutter/material.dart';

class GroupCard extends StatelessWidget {
  const GroupCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isEnabled,
    required this.onEnable,
    required this.devices,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isEnabled;
  final void Function() onEnable;
  final List<Widget> devices;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isEnabled ? Radius.zero : const Radius.circular(16),
                bottomRight: isEnabled
                    ? Radius.zero
                    : const Radius.circular(16),
              ),
              color: Theme.of(context).colorScheme.primary.withValues(
                alpha: 0.1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                spacing: 16,
                children: [
                  Icon(
                    icon,
                    size: 32,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isEnabled,
                    onChanged: (_) => onEnable(),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: isEnabled
                ? Padding(
                    padding: const EdgeInsets.only(
                      left: 28,
                      right: 12,
                      top: 12,
                      bottom: 12,
                    ),
                    child: Column(
                      spacing: 18,
                      children: devices,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
