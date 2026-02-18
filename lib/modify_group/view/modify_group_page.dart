import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/modify_group/modify_group.dart';

class ModifyGroupPage extends StatelessWidget {
  const ModifyGroupPage({
    this.group,
    super.key,
  });

  static const String pageName = 'modify-group';
  static const String pagePath = '/modify-group';

  final GroupModel? group;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ModifyGroupCubit()..groupReceived(group),
      child: const ModifyGroupView(),
    );
  }
}
