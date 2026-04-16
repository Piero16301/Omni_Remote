import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/modify_device/modify_device.dart';

class ModifyDevicePage extends StatelessWidget {
  const ModifyDevicePage({
    this.device,
    super.key,
  });

  final DeviceModel? device;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ModifyDeviceCubit()..deviceReceived(device),
      child: const ModifyDeviceView(),
    );
  }
}
