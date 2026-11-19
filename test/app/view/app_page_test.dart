import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omni_remote/app/app.dart';

class MockLocalStorageService extends Mock implements LocalStorageService;

class MockMqttService extends Mock implements MqttService;

class MockPerformanceService extends Mock implements PerformanceService;

class MockTrace extends Mock implements Trace;

void main() {
  group('AppPage', () {
    late LocalStorageService mockLocalStorageService;
    late MqttService mockMqttService;
    late PerformanceService mockPerformanceService;
    late Trace mockTrace;

    setUp(() async {
      mockLocalStorageService = MockLocalStorageService();
      mockMqttService = MockMqttService();
      mockPerformanceService = MockPerformanceService();
      mockTrace = MockTrace();

      await getIt.reset();
      setupServiceLocator(Environment.mock);

      await getIt.unregister<LocalStorageService>();
      getIt.registerSingleton<LocalStorageService>(mockLocalStorageService);
      await getIt.unregister<MqttService>();
      getIt.registerSingleton<MqttService>(mockMqttService);
      await getIt.unregister<PerformanceService>();
      getIt.registerSingleton<PerformanceService>(mockPerformanceService);

      when(() => mockPerformanceService.startTrace(any()))
          .thenReturn(mockTrace);
      when(() => mockPerformanceService.stopTrace(mockTrace)).thenReturn(null);

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
