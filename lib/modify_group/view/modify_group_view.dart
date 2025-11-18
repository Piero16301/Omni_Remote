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
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.modifyGroupSaveSuccessSnackbar(state.title)),
            ),
          );
          context.pop();
        } else if (state.saveStatus.isFailure) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                getFailureMessage(state.modifyGroupError, state.title, l10n),
              ),
            ),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            children: [
              AppTextField(
                initialValue: state.title,
                onChanged: context.read<ModifyGroupCubit>().changeTitle,
                labelText: l10n.modifyGroupTitleLabel,
                hintText: l10n.modifyGroupTitleHint,
                prefixIcon: HugeIcons.strokeRoundedBookmark01,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.modifyGroupTitleErrorEmpty;
                  }
                  final alphanumericRegex = RegExp(r'^[a-zA-Z0-9\s]+$');
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
                onChanged: context.read<ModifyGroupCubit>().changeSubtitle,
                labelText: l10n.modifyGroupSubtitleLabel,
                hintText: l10n.modifyGroupSubtitleHint,
                prefixIcon: HugeIcons.strokeRoundedNote,
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
