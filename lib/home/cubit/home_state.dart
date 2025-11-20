part of 'home_cubit.dart';

enum HomeStatus {
  initial,
  loading,
  success,
  failure;

  bool get isInitial => this == HomeStatus.initial;
  bool get isLoading => this == HomeStatus.loading;
  bool get isSuccess => this == HomeStatus.success;
  bool get isFailure => this == HomeStatus.failure;
}

enum GroupDeleteError { none, groupNotEmpty, groupNotFound, unknown }

enum DeviceDeleteError { none, deviceNotFound, unknown }

class HomeState extends Equatable {
  const HomeState({
    this.deleteStatus = HomeStatus.initial,
    this.groupDeleteError = GroupDeleteError.none,
    this.deviceDeleteError = DeviceDeleteError.none,
  });

  final HomeStatus deleteStatus;
  final GroupDeleteError groupDeleteError;
  final DeviceDeleteError deviceDeleteError;

  HomeState copyWith({
    HomeStatus? deleteStatus,
    GroupDeleteError? groupDeleteError,
    DeviceDeleteError? deviceDeleteError,
  }) {
    return HomeState(
      deleteStatus: deleteStatus ?? this.deleteStatus,
      groupDeleteError: groupDeleteError ?? this.groupDeleteError,
      deviceDeleteError: deviceDeleteError ?? this.deviceDeleteError,
    );
  }

  @override
  List<Object> get props => [
    deleteStatus,
    groupDeleteError,
    deviceDeleteError,
  ];
}
