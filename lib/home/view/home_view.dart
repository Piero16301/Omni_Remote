import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/home/home.dart';
import 'package:omni_remote/l10n/l10n.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final connectionStatus = context.select<AppCubit, BrokerConnectionStatus>(
      (cubit) => cubit.state.brokerConnectionStatus,
    );

    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) {
        // Handle delete group status changes
        if (state.deleteGroupStatus.isSuccess) {
          AppFunctions.showSnackBar(
            context,
            message: l10n.homeDeleteGroupSuccessSnackbar,
            type: SnackBarType.success,
          );
        } else if (state.deleteGroupStatus.isFailure) {
          AppFunctions.showSnackBar(
            context,
            message: getGroupDeleteFailureMessage(
              state.groupDeleteError,
              l10n,
            ),
            type: SnackBarType.error,
          );
          context.read<HomeCubit>().resetDeleteGroupStatus();
        }

        // Handle delete device status changes
        if (state.deleteDeviceStatus.isSuccess) {
          AppFunctions.showSnackBar(
            context,
            message: l10n.homeDeleteDeviceSuccessSnackbar,
            type: SnackBarType.success,
          );
        } else if (state.deleteDeviceStatus.isFailure) {
          AppFunctions.showSnackBar(
            context,
            message: getDeviceDeleteFailureMessage(
              state.deviceDeleteError,
              l10n,
            ),
            type: SnackBarType.error,
          );
          context.read<HomeCubit>().resetDeleteDeviceStatus();
        }
      },
      builder: (context, state) {
        String statusText;
        Color statusColor;

        switch (connectionStatus) {
          case BrokerConnectionStatus.connected:
            statusText = l10n.connectionStatusConnected;
            statusColor = Colors.green;
          case BrokerConnectionStatus.disconnected:
            statusText = l10n.connectionStatusDisconnected;
            statusColor = Colors.red;
          case BrokerConnectionStatus.connecting:
            statusText = l10n.connectionStatusConnecting;
            statusColor = Colors.orange;
          case BrokerConnectionStatus.disconnecting:
            statusText = l10n.connectionStatusDisconnecting;
            statusColor = Colors.grey;
        }

        return ValueListenableBuilder(
          valueListenable: context.read<HomeCubit>().getGroupsListenable(),
          builder: (context, groups, widget) {
            return Scaffold(
              appBar: AppBar(
                title: Column(
                  children: [
                    Text(
                      AppVariables.appName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          statusText,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: statusColor,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
                centerTitle: true,
                leading: IconButton(
                  onPressed: () => context.pushNamed(AppRoute.connection.name),
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedInternetAntenna04,
                    strokeWidth: 2,
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () => context.pushNamed(AppRoute.settings.name),
                    icon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedSettings01,
                      strokeWidth: 2,
                    ),
                  ),
                ],
              ),
              body: ListView(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 8,
                  bottom: 120,
                ),
                children: [
                  Visibility(
                    visible: groups.isEmpty,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
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
                  ...groups.map(
                    (group) => GroupCard(
                      group: group,
                      onEdit: () => context.pushNamed(
                        AppRoute.modifyGroup.name,
                        extra: group,
                      ),
                      onDelete: () =>
                          context.read<HomeCubit>().deleteGroup(group),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: InkWell(
                      onTap: () => context.pushNamed(AppRoute.modifyGroup.name),
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
                            Text(
                              l10n.homeNewGroupButton,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              floatingActionButton: groups.isNotEmpty
                  ? FloatingActionButton(
                      onPressed: () =>
                          context.pushNamed(AppRoute.modifyDevice.name),
                      child: const HugeIcon(
                        icon: HugeIcons.strokeRoundedComputerAdd,
                        size: 28,
                        strokeWidth: 2,
                      ),
                    )
                  : null,
            );
          },
        );
      },
    );
  }

  String getGroupDeleteFailureMessage(
    GroupDeleteError error,
    AppLocalizations l10n,
  ) {
    switch (error) {
      case GroupDeleteError.groupNotEmpty:
        return l10n.homeDeleteGroupErrorNotEmpty;
      case GroupDeleteError.groupNotFound:
        return l10n.homeDeleteGroupErrorNotFound;
      case GroupDeleteError.unknown:
        return l10n.homeDeleteGroupErrorUnknown;
      case GroupDeleteError.none:
        return '';
    }
  }

  String getDeviceDeleteFailureMessage(
    DeviceDeleteError error,
    AppLocalizations l10n,
  ) {
    switch (error) {
      case DeviceDeleteError.deviceNotFound:
        return l10n.homeDeleteDeviceErrorNotFound;
      case DeviceDeleteError.unknown:
        return l10n.homeDeleteDeviceErrorUnknown;
      case DeviceDeleteError.none:
        return '';
    }
  }
}
