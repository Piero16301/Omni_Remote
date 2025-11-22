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

        return Scaffold(
          appBar: AppBar(
            title: Column(
              children: [
                Text(l10n.connectionAppBarTitle),
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
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ],
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
                  onPressed: () async => context
                      .read<ConnectionCubit>()
                      .saveAndConnect(context: context),
                  child: Text(l10n.connectionSaveAndConnectButton),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
