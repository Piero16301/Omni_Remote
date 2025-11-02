import 'package:flutter/material.dart';

/// Widget reutilizable para las tarjetas de habitaciones
class RoomCard extends StatelessWidget {
  const RoomCard({
    required this.icon,
    required this.title,
    required this.isExpanded,
    required this.onToggle,
    required this.devices,
    super.key,
  });

  final IconData icon;
  final String title;
  final bool isExpanded;
  final VoidCallback onToggle;
  final List<Widget> devices;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isExpanded
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).disabledColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      alignment: isExpanded
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        width: 26,
                        height: 26,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...devices,
        ],
      ),
    );
  }
}
