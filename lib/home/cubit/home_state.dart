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
    this.deleteGroupStatus = HomeStatus.initial,
    this.deleteDeviceStatus = HomeStatus.initial,
    this.groupDeleteError = GroupDeleteError.none,
    this.deviceDeleteError = DeviceDeleteError.none,
  });

  final HomeStatus deleteGroupStatus;
  final HomeStatus deleteDeviceStatus;
  final GroupDeleteError groupDeleteError;
  final DeviceDeleteError deviceDeleteError;

  HomeState copyWith({
    HomeStatus? deleteGroupStatus,
    HomeStatus? deleteDeviceStatus,
    GroupDeleteError? groupDeleteError,
    DeviceDeleteError? deviceDeleteError,
  }) {
    return HomeState(
      deleteGroupStatus: deleteGroupStatus ?? this.deleteGroupStatus,
      deleteDeviceStatus: deleteDeviceStatus ?? this.deleteDeviceStatus,
      groupDeleteError: groupDeleteError ?? this.groupDeleteError,
      deviceDeleteError: deviceDeleteError ?? this.deviceDeleteError,
    );
  }

  @override
  List<Object> get props => [
    deleteGroupStatus,
    deleteDeviceStatus,
    groupDeleteError,
    deviceDeleteError,
  ];
}
