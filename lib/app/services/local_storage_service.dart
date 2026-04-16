import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:omni_remote/app/app.dart';

class LocalStorageService {
  LocalStorageService({required LocalStorageRepository localStorageRepository})
      : _localStorageRepository = localStorageRepository;

  final LocalStorageRepository _localStorageRepository;

  Future<void> initialize() async {
    await _localStorageRepository.initialize();
  }

  void saveLanguage({required Locale language}) {
    _localStorageRepository.saveLanguage(language: language);
  }

  Locale? getLanguage() {
    return _localStorageRepository.getLanguage();
  }

  void saveTheme({required ThemeMode theme}) {
    _localStorageRepository.saveTheme(theme: theme);
  }

  ThemeMode? getTheme() {
    return _localStorageRepository.getTheme();
  }

  void saveBaseColor({required Color baseColor}) {
    _localStorageRepository.saveBaseColor(baseColor: baseColor);
  }

  Color? getBaseColor() {
    return _localStorageRepository.getBaseColor();
  }

  void saveFontFamily({required String fontFamily}) {
    _localStorageRepository.saveFontFamily(fontFamily: fontFamily);
  }

  String? getFontFamily() {
    return _localStorageRepository.getFontFamily();
  }

  void saveBrokerUrl({required String brokerUrl}) {
    _localStorageRepository.saveBrokerUrl(brokerUrl: brokerUrl);
  }

  String? getBrokerUrl() {
    return _localStorageRepository.getBrokerUrl();
  }

  void saveBrokerPort({required String brokerPort}) {
    _localStorageRepository.saveBrokerPort(brokerPort: brokerPort);
  }

  String? getBrokerPort() {
    return _localStorageRepository.getBrokerPort();
  }

  void saveBrokerUsername({required String brokerUsername}) {
    _localStorageRepository.saveBrokerUsername(brokerUsername: brokerUsername);
  }

  String? getBrokerUsername() {
    return _localStorageRepository.getBrokerUsername();
  }

  void saveBrokerPassword({required String brokerPassword}) {
    _localStorageRepository.saveBrokerPassword(brokerPassword: brokerPassword);
  }

  String? getBrokerPassword() {
    return _localStorageRepository.getBrokerPassword();
  }

  ValueListenable<List<GroupModel>> getGroupsListenable() {
    return _localStorageRepository.getGroupsListenable();
  }

  void createGroup({required GroupModel group}) {
    _localStorageRepository.createGroup(group: group);
  }

  List<GroupModel> getGroups() {
    return _localStorageRepository.getGroups();
  }

  void updateGroup({required GroupModel group}) {
    _localStorageRepository.updateGroup(group: group);
  }

  void deleteGroup({required String groupId}) {
    _localStorageRepository.deleteGroup(groupId: groupId);
  }

  ValueListenable<List<DeviceModel>> getDevicesListenable() {
    return _localStorageRepository.getDevicesListenable();
  }

  void createDevice({required DeviceModel device}) {
    _localStorageRepository.createDevice(device: device);
  }

  List<DeviceModel> getDevices() {
    return _localStorageRepository.getDevices();
  }

  void updateDevice({required DeviceModel device}) {
    _localStorageRepository.updateDevice(device: device);
  }

  void deleteDevice({required String deviceId}) {
    _localStorageRepository.deleteDevice(deviceId: deviceId);
  }
}
