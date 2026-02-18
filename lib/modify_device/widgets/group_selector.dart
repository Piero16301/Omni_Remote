import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/l10n/l10n.dart';

class GroupSelector extends StatefulWidget {
  const GroupSelector({
    required this.groups,
    required this.selectedGroupId,
    required this.onGroupSelected,
    super.key,
  });

  final List<GroupModel> groups;
  final String? selectedGroupId;
  final void Function(String? value) onGroupSelected;

  @override
  State<GroupSelector> createState() => _GroupSelectorState();
}

class _GroupSelectorState extends State<GroupSelector> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateControllerText();
  }

  @override
  void didUpdateWidget(GroupSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedGroupId != widget.selectedGroupId) {
      _updateControllerText();
    }
  }

  void _updateControllerText() {
    if (widget.selectedGroupId == null) {
      _controller.text = '';
    } else {
      final selectedGroup = widget.groups.firstWhere(
        (group) => group.id == widget.selectedGroupId,
        orElse: () => widget.groups.first,
      );
      _controller.text = selectedGroup.title;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Find the selected group to get its icon
    GroupModel? selectedGroup;
    if (widget.selectedGroupId != null) {
      try {
        selectedGroup = widget.groups.firstWhere(
          (group) => group.id == widget.selectedGroupId,
        );
      } on Exception {
        selectedGroup = null;
      }
    }

    return DropdownMenu<String>(
      controller: _controller,
      enableSearch: false,
      requestFocusOnTap: false,
      expandedInsets: EdgeInsets.zero,
      label: Text(l10n.modifyDeviceGroupLabel),
      hintText: l10n.modifyDeviceGroupHint,
      leadingIcon: selectedGroup != null
          ? SizedBox(
              width: 24,
              height: 24,
              child: Center(
                child: HugeIcon(
                  icon: IconHelper.getIconByName(selectedGroup.icon),
                ),
              ),
            )
          : null,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      menuStyle: MenuStyle(
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        padding: WidgetStateProperty.all(EdgeInsets.zero),
      ),
      dropdownMenuEntries: widget.groups.map((group) {
        return DropdownMenuEntry<String>(
          value: group.id,
          leadingIcon: SizedBox(
            width: 24,
            height: 24,
            child: Center(
              child: HugeIcon(
                icon: IconHelper.getIconByName(group.icon),
              ),
            ),
          ),
          label: group.title,
          labelWidget: Text(
            group.title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        );
      }).toList(),
      onSelected: (value) {
        if (value == '') {
          widget.onGroupSelected(null);
        } else {
          widget.onGroupSelected(value);
        }
      },
    );
  }
}
