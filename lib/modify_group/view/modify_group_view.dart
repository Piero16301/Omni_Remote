import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/l10n/l10n.dart';
import 'package:omni_remote/modify_group/cubit/modify_group_cubit.dart';
import 'package:omni_remote/modify_group/widgets/widgets.dart';

class ModifyGroupView extends StatelessWidget {
  const ModifyGroupView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<ModifyGroupCubit, ModifyGroupState>(
      listener: (context, state) {
        if (state.saveStatus.isSuccess) {
          AppFunctions.showSnackBar(
            context,
            message: l10n.modifyGroupSaveSuccessSnackbar(state.title),
            type: SnackBarType.success,
          );
          context.pop();
        } else if (state.saveStatus.isFailure) {
          AppFunctions.showSnackBar(
            context,
            message: getFailureMessage(
              state.modifyGroupError,
              state.title,
              l10n,
            ),
            type: SnackBarType.error,
          );
          context.read<ModifyGroupCubit>().resetSaveStatus();
        }
      },
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text(
            state.groupModel == null
                ? l10n.modifyGroupPageTitleCreate
                : l10n.modifyGroupPageTitleEdit,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              strokeWidth: 2,
            ),
          ),
        ),
        body: Form(
          key: state.formKey,
          child: ListView(
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 12,
              bottom: 120,
            ),
            children: [
              AppTextField(
                initialValue: state.title,
                onChanged: context.read<ModifyGroupCubit>().changeTitle,
                label: l10n.modifyGroupTitleLabel,
                hintText: l10n.modifyGroupTitleHint,
                prefix: const HugeIcon(
                  icon: HugeIcons.strokeRoundedBookmark01,
                  strokeWidth: 2,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.modifyGroupTitleErrorEmpty;
                  }
                  final alphanumericRegex = RegExp(
                    r'^[a-zA-Z0-9áéíóúÁÉÍÓÚüÜñÑ\s]+$',
                  );
                  if (!alphanumericRegex.hasMatch(value)) {
                    return l10n.modifyGroupTitleErrorInvalidFormat;
                  }
                  if (value.contains(RegExp(r'\s{2,}'))) {
                    return l10n.modifyGroupTitleErrorMultipleSpaces;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                initialValue: state.subtitle,
                isRequired: false,
                onChanged: context.read<ModifyGroupCubit>().changeSubtitle,
                label: l10n.modifyGroupSubtitleLabel,
                hintText: l10n.modifyGroupSubtitleHint,
                prefix: const HugeIcon(
                  icon: HugeIcons.strokeRoundedNote,
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(height: 24),
              AppIconSelector(
                label: l10n.modifyGroupSelectIcon,
                iconOptions: IconHelper.groupIcons,
                selectedIcon: state.icon,
                onIconSelected: context.read<ModifyGroupCubit>().changeIcon,
              ),
              const SizedBox(height: 48),
              GroupPreview(
                title: state.title,
                subtitle: state.subtitle,
                iconName: state.icon,
              ),
              if (state.title.isNotEmpty) const SizedBox(height: 48),
              if (state.title.isNotEmpty)
                MqttTopicsInfo(
                  topicInfoType: TopicInfoType.group,
                  groupTitle: state.title,
                ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: context.read<ModifyGroupCubit>().saveGroupModel,
          child: const HugeIcon(
            icon: HugeIcons.strokeRoundedFloppyDisk,
            size: 28,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  String getFailureMessage(
    ModifyGroupError error,
    String title,
    AppLocalizations l10n,
  ) {
    switch (error) {
      case ModifyGroupError.duplicateGroupName:
        return l10n.modifyGroupSaveDuplicateError(title);
      case ModifyGroupError.unknown:
        return l10n.modifyGroupSaveDefaultError(title);
      case ModifyGroupError.none:
        return '';
    }
  }
}
