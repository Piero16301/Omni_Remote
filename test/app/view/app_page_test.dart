import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omni_remote/app/app.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}

class MockMqttService extends Mock implements MqttService {}

void main() {
  group('AppPage', () {
    late LocalStorageService mockLocalStorageService;
    late MqttService mockMqttService;

    setUp(() async {
      mockLocalStorageService = MockLocalStorageService();
      mockMqttService = MockMqttService();

      await getIt.reset();
      getIt
        ..registerSingleton<LocalStorageService>(mockLocalStorageService)
        ..registerSingleton<MqttService>(mockMqttService);

      when(() => mockLocalStorageService.getLanguage()).thenReturn(null);
      when(() => mockLocalStorageService.getTheme()).thenReturn(null);
      when(() => mockLocalStorageService.getBaseColor()).thenReturn(null);
      when(() => mockLocalStorageService.getFontFamily()).thenReturn(null);
      when(() => mockLocalStorageService.getGroupsListenable())
          .thenReturn(ValueNotifier<List<GroupModel>>([]));
      when(() => mockLocalStorageService.getDevicesListenable())
          .thenReturn(ValueNotifier<List<DeviceModel>>([]));
      when(() => mockMqttService.connectionStatusStream)
          .thenAnswer((_) => const Stream.empty());
      when(() => mockMqttService.initializeMqttClient())
          .thenAnswer((_) async {});
    });

    testWidgets('renders AppView', (tester) async {
      await tester.pumpWidget(const AppPage());
      expect(find.byType(AppView), findsOneWidget);
    });
  });
}
