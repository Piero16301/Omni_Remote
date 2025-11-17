import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:omni_remote/home/home.dart';
import 'package:omni_remote/l10n/l10n.dart';
import 'package:omni_remote/modify_group/modify_group.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeAppBarTitle),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {},
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedSettings01,
            strokeWidth: 2,
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: context.read<HomeCubit>().getGroupsListenable(),
        builder: (context, box, widget) {
          final groups = box.values.toList();

          return ListView(
            children: [
              ...groups.map(
                (group) => GroupCard(
                  group: group,
                  onEnable: () =>
                      context.read<HomeCubit>().toggleGroupEnabled(group),
                  devices: const [],
                  onEdit: () => context.pushNamed(
                    ModifyGroupPage.pageName,
                    extra: group,
                  ),
                  onDelete: () => context.read<HomeCubit>().deleteGroup(group),
                ),
              ),
              Visibility(
                visible: groups.isEmpty,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Center(
                    child: Text(
                      l10n.homeEmptyGroupsMessage,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
              Card(
                child: InkWell(
                  onTap: () => context.pushNamed(ModifyGroupPage.pageName),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const HugeIcon(
                          icon: HugeIcons.strokeRoundedDashboardSquareAdd,
                          strokeWidth: 2,
                        ),
                        const SizedBox(width: 8),
                        Text(l10n.homeNewGroupButton),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const HugeIcon(
          icon: HugeIcons.strokeRoundedComputerAdd,
          size: 28,
          strokeWidth: 2,
        ),
      ),
    );
  }
}
