import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:omni_remote/app/app.dart';
import 'package:user_api/user_api.dart';

class GroupCard extends StatelessWidget {
  const GroupCard({
    required this.group,
    required this.onEnable,
    required this.devices,
    super.key,
  });

  final GroupModel group;
  final void Function() onEnable;
  final List<Widget> devices;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: group.enabled
                    ? Radius.zero
                    : const Radius.circular(16),
                bottomRight: group.enabled
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
                  HugeIcon(
                    icon: IconHelper.getIconByName(group.icon),
                    size: 32,
                    strokeWidth: 2,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Text(
                          group.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          group.subtitle,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: group.enabled,
                    onChanged: (_) => onEnable(),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: group.enabled
                ? Padding(
                    padding: const EdgeInsets.all(12),
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
