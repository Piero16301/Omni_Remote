part of 'home_cubit.dart';

class HomeState extends Equatable {
  const HomeState({
    this.connected = false,
  });

  final bool connected;

  HomeState copyWith({
    bool? connected,
  }) {
    return HomeState(
      connected: connected ?? this.connected,
    );
  }

  @override
  List<Object> get props => [
    connected,
  ];
}
