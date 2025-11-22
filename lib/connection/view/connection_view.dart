import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/connection/connection.dart';
import 'package:omni_remote/l10n/l10n.dart';

class ConnectionView extends StatelessWidget {
  const ConnectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final connectionStatus = context.select<AppCubit, BrokerConnectionStatus>(
      (cubit) => cubit.state.brokerConnectionStatus,
    );

    return BlocBuilder<ConnectionCubit, ConnectionState>(
      builder: (context, state) {
        String statusText;
        Color statusColor;
        List<List<dynamic>> icon;

        switch (connectionStatus) {
          case BrokerConnectionStatus.connected:
            statusText = l10n.connectionStatusConnected;
            statusColor = Colors.green;
            icon = HugeIcons.strokeRoundedCheckmarkCircle02;
          case BrokerConnectionStatus.disconnected:
            statusText = l10n.connectionStatusDisconnected;
            statusColor = Colors.red;
            icon = HugeIcons.strokeRoundedCancelCircle;
          case BrokerConnectionStatus.connecting:
            statusText = l10n.connectionStatusConnecting;
            statusColor = Colors.orange;
            icon = HugeIcons.strokeRoundedLink01;
          case BrokerConnectionStatus.disconnecting:
            statusText = l10n.connectionStatusDisconnecting;
            statusColor = Colors.grey;
            icon = HugeIcons.strokeRoundedLink01;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.connectionAppBarTitle),
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
                  initialValue: state.brokerUrl,
                  onChanged: context.read<ConnectionCubit>().changeBrokerUrl,
                  labelText: l10n.connectionUrlLabel,
                  hintText: l10n.connectionUrlHint,
                  prefixIcon: HugeIcons.strokeRoundedLink01,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.connectionFieldErrorEmpty;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  initialValue: state.brokerPort,
                  onChanged: context.read<ConnectionCubit>().changeBrokerPort,
                  labelText: l10n.connectionPortLabel,
                  hintText: l10n.connectionPortHint,
                  prefixIcon: HugeIcons.strokeRoundedGps01,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.connectionFieldErrorEmpty;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  initialValue: state.brokerUsername,
                  onChanged: context
                      .read<ConnectionCubit>()
                      .changeBrokerUsername,
                  labelText: l10n.connectionUsernameLabel,
                  hintText: l10n.connectionUsernameHint,
                  prefixIcon: HugeIcons.strokeRoundedUser,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.connectionFieldErrorEmpty;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  initialValue: state.brokerPassword,
                  onChanged: context
                      .read<ConnectionCubit>()
                      .changeBrokerPassword,
                  labelText: l10n.connectionPasswordLabel,
                  hintText: l10n.connectionPasswordHint,
                  prefixIcon: HugeIcons.strokeRoundedLockPassword,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.connectionFieldErrorEmpty;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed:
                      (connectionStatus.isConnecting ||
                          connectionStatus.isDisconnecting)
                      ? null
                      : () async => context
                            .read<ConnectionCubit>()
                            .saveAndConnect(context: context),
                  child: Text(l10n.connectionSaveAndConnectButton),
                ),
                if (state.brokerUrl.isNotEmpty && state.brokerPort.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest.withValues(
                              alpha: 0.5,
                            ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        spacing: 12,
                        children: [
                          HugeIcon(
                            icon: icon,
                            color: statusColor,
                            size: 48,
                          ),
                          Text(
                            statusText,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: statusColor),
                          ),
                          Row(
                            spacing: 8,
                            children: [
                              const HugeIcon(
                                icon: HugeIcons.strokeRoundedLink01,
                                size: 20,
                              ),
                              Expanded(
                                child: Text(
                                  state.brokerUrl,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            spacing: 8,
                            children: [
                              const HugeIcon(
                                icon: HugeIcons.strokeRoundedGps01,
                                size: 20,
                              ),
                              Text(
                                state.brokerPort,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
