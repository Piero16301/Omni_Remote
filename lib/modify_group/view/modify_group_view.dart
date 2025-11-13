import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:omni_remote/app/helpers/icon_helper.dart';
import 'package:omni_remote/modify_group/cubit/modify_group_cubit.dart';

class ModifyGroupView extends StatelessWidget {
  const ModifyGroupView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo grupo'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            strokeWidth: 2,
          ),
        ),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            BlocBuilder<ModifyGroupCubit, ModifyGroupState>(
              buildWhen: (previous, current) => previous.title != current.title,
              builder: (context, state) {
                return TextFormField(
                  initialValue: state.title,
                  onChanged: (value) {
                    context.read<ModifyGroupCubit>().changeTitle(value);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    hintText: 'Ej: Sala de estar',
                    border: OutlineInputBorder(),
                    prefixIcon: HugeIcon(
                      icon: HugeIcons.strokeRoundedEdit02,
                      strokeWidth: 2,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa un título';
                    }
                    return null;
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            BlocBuilder<ModifyGroupCubit, ModifyGroupState>(
              buildWhen: (previous, current) =>
                  previous.subtitle != current.subtitle,
              builder: (context, state) {
                return TextFormField(
                  initialValue: state.subtitle,
                  onChanged: (value) {
                    context.read<ModifyGroupCubit>().changeSubtitle(value);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Subtítulo',
                    hintText: 'Ej: 3 dispositivos',
                    border: OutlineInputBorder(),
                    prefixIcon: HugeIcon(
                      icon: HugeIcons.strokeRoundedTextFont,
                      strokeWidth: 2,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa un subtítulo';
                    }
                    return null;
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Selecciona un ícono',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            BlocBuilder<ModifyGroupCubit, ModifyGroupState>(
              buildWhen: (previous, current) => previous.icon != current.icon,
              builder: (context, state) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: IconHelper.groupIcons.length,
                      itemBuilder: (context, index) {
                        final entry = IconHelper.groupIcons.entries.elementAt(
                          index,
                        );
                        final iconName = entry.key;
                        final iconData = entry.value;
                        final isSelected = state.icon == iconName;

                        return InkWell(
                          onTap: () {
                            context.read<ModifyGroupCubit>().changeIcon(
                              iconName,
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.primary.withValues(alpha: 0.2)
                                  : Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest
                                        .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: HugeIcon(
                                icon: iconData,
                                size: 28,
                                strokeWidth: 2,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            BlocBuilder<ModifyGroupCubit, ModifyGroupState>(
              builder: (context, state) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'Vista previa',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              HugeIcon(
                                icon: IconHelper.getIconByName(state.icon),
                                size: 32,
                                strokeWidth: 2,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      state.title.isEmpty
                                          ? 'Título del grupo'
                                          : state.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      state.subtitle.isEmpty
                                          ? 'Subtítulo del grupo'
                                          : state.subtitle,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
