import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthIntegrationService {
  static bool _isConfigured = false;

  static void _configure() {
    if (!_isConfigured) {
      Health().configure();
      _isConfigured = true;
    }
  }

  // Типы данных, с которыми мы работаем
  static final List<HealthDataType> _dataTypes = [
    HealthDataType.MENSTRUATION_FLOW,
    HealthDataType.BODY_TEMPERATURE,
    HealthDataType.STEPS,
  ];

  // Права доступа
  static final List<HealthDataAccess> _permissions = [
    HealthDataAccess.READ_WRITE,
    HealthDataAccess.READ_WRITE,
    HealthDataAccess.READ,
  ];

  /// Запрос разрешений у системы
  static Future<bool> requestPermissions() async {
    _configure();
    try {
      if (Platform.isAndroid) {
        await Permission.activityRecognition.request();
      }

      bool? hasPermissions = await Health().hasPermissions(
        _dataTypes,
        permissions: _permissions,
      );

      if (hasPermissions != true) {
        hasPermissions = await Health().requestAuthorization(
          _dataTypes,
          permissions: _permissions,
        );
      }

      return hasPermissions ?? false;
    } catch (e) {
      if (kDebugMode) debugPrint("🍏 HealthKit/Connect Permission Error: $e");
      return false;
    }
  }

  /// 🔥 КИЛЛЕР-ФИЧА: Чтение Температуры (Apple Watch, Oura, Garmin)
  static Future<double?> fetchTodayBBT() async {
    _configure();
    try {
      bool hasAuth = await requestPermissions();
      if (!hasAuth) return null;

      final now = DateTime.now();
      // Ищем измерения с полуночи до текущего момента
      final startOfDay = DateTime(now.year, now.month, now.day);

      // Запрашиваем данные по температуре
      List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
        types: [HealthDataType.BODY_TEMPERATURE],
        startTime: startOfDay,
        endTime: now,
      );

      if (healthData.isEmpty) return null;

      // Берем самое свежее утреннее измерение
      healthData.sort((a, b) => b.dateTo.compareTo(a.dateTo));

      final dataPoint = healthData.first;
      final value = dataPoint.value;

      // Пакет health может возвращать разные типы (NumericHealthValue и т.д.)
      if (value is NumericHealthValue) {
        return value.numericValue.toDouble();
      }

      return double.tryParse(value.toString());
    } catch (e) {
      if (kDebugMode) debugPrint("🍏 BBT Fetch Error: $e");
      return null;
    }
  }

  /// Запись Температуры (BBT) в систему
  static Future<bool> syncBBT(double temperature, DateTime date) async {
    _configure();
    try {
      bool hasAuth = await requestPermissions();
      if (!hasAuth) return false;

      final time = DateTime(date.year, date.month, date.day, 7, 0);

      return await Health().writeHealthData(
        value: temperature,
        type: HealthDataType.BODY_TEMPERATURE,
        startTime: time,
        endTime: time,
      );
    } catch (e) {
      if (kDebugMode) debugPrint("🍏 BBT Sync Error: $e");
      return false;
    }
  }

  /// Запись дня менструации в систему
  static Future<bool> syncPeriodDay(DateTime date, {bool isHeavy = false}) async {
    _configure();
    try {
      bool hasAuth = await requestPermissions();
      if (!hasAuth) return false;

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      // В Apple Health: 1.0 = Light, 2.0 = Medium, 3.0 = Heavy
      double flowValue = isHeavy ? 3.0 : 2.0;

      return await Health().writeHealthData(
        value: flowValue,
        type: HealthDataType.MENSTRUATION_FLOW,
        startTime: startOfDay,
        endTime: endOfDay,
      );
    } catch (e) {
      if (kDebugMode) debugPrint("🍏 Period Sync Error: $e");
      return false;
    }
  }
}