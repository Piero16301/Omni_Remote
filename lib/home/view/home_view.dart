import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/connection/connection.dart';
import 'package:omni_remote/home/home.dart';
import 'package:omni_remote/l10n/l10n.dart';
import 'package:omni_remote/modify_device/modify_device.dart';
import 'package:omni_remote/modify_group/modify_group.dart';
import 'package:omni_remote/settings/settings.dart';

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
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.homeDeleteGroupSuccessSnackbar,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        } else if (state.deleteGroupStatus.isFailure) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                getGroupDeleteFailureMessage(
                  state.groupDeleteError,
                  l10n,
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
          context.read<HomeCubit>().resetDeleteGroupStatus();
        }

        // Handle delete device status changes
        if (state.deleteDeviceStatus.isSuccess) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.homeDeleteDeviceSuccessSnackbar,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        } else if (state.deleteDeviceStatus.isFailure) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                getDeviceDeleteFailureMessage(
                  state.deviceDeleteError,
                  l10n,
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
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
                      l10n.homeAppBarTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
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
                  onPressed: () => context.pushNamed(ConnectionPage.pageName),
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedInternetAntenna04,
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () => context.pushNamed(SettingsPage.pageName),
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedSettings01,
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              body: ListView(
                children: [
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
                  ...groups.map(
                    (group) => GroupCard(
                      group: group,
                      onEdit: () => context.pushNamed(
                        ModifyGroupPage.pageName,
                        extra: group,
                      ),
                      onDelete: () =>
                          context.read<HomeCubit>().deleteGroup(group),
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
                          context.pushNamed(ModifyDevicePage.pageName),
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
