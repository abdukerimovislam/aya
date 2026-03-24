import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

// Модель нашего препарата
class MedicationItem {
  final String id;
  final String name;
  final String dosage;
  final String iconStr; // Например: 💊, 💧, 🌿, ☀️

  MedicationItem({
    required this.id,
    required this.name,
    required this.dosage,
    required this.iconStr,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'dosage': dosage,
    'iconStr': iconStr,
  };

  factory MedicationItem.fromMap(Map<dynamic, dynamic> map) => MedicationItem(
    id: map['id'],
    name: map['name'],
    dosage: map['dosage'],
    iconStr: map['iconStr'] ?? '💊',
  );
}

class MedicationProvider extends ChangeNotifier {
  Box? _registryBox;
  Box? _logsBox;

  List<MedicationItem> _medications = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  List<MedicationItem> get activeMedications => List.unmodifiable(_medications);

  MedicationProvider() {
    _init();
  }

  Future<void> _init() async {
    _registryBox = await Hive.openBox('medications_registry');
    _logsBox = await Hive.openBox('medications_logs');
    _loadRegistry();
  }

  void _loadRegistry() {
    if (_registryBox == null) return;

    final List<dynamic> rawList = _registryBox!.get('items', defaultValue: []);
    _medications = rawList.map((e) => MedicationItem.fromMap(Map<dynamic, dynamic>.from(e))).toList();
    _isLoaded = true;
    notifyListeners();
  }

  // --- УПРАВЛЕНИЕ СПИСКОМ ПРЕПАРАТОВ ---

  Future<void> addMedication(String name, String dosage, String iconStr) async {
    final newItem = MedicationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      dosage: dosage,
      iconStr: iconStr,
    );
    _medications.add(newItem);
    await _saveRegistry();
  }

  Future<void> removeMedication(String id) async {
    _medications.removeWhere((e) => e.id == id);
    await _saveRegistry();
  }

  Future<void> _saveRegistry() async {
    if (_registryBox != null) {
      await _registryBox!.put('items', _medications.map((e) => e.toMap()).toList());
    }
    notifyListeners();
  }

  // --- ЛОГИРОВАНИЕ ПРИЕМА (КАЖДЫЙ ДЕНЬ) ---

  String _dateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  List<String> getTakenForDay(DateTime date) {
    if (_logsBox == null) return [];
    final key = _dateKey(date);
    final rawList = _logsBox!.get(key, defaultValue: <String>[]);
    return (rawList as List).cast<String>();
  }

  Future<void> toggleMedication(String medId, DateTime date) async {
    if (_logsBox == null) return;

    final key = _dateKey(date);
    List<String> taken = getTakenForDay(date).toList();

    if (taken.contains(medId)) {
      taken.remove(medId); // Убираем галочку
    } else {
      taken.add(medId); // Ставим галочку
    }

    if (taken.isEmpty) {
      await _logsBox!.delete(key);
    } else {
      await _logsBox!.put(key, taken);
    }

    notifyListeners();
  }

  // Метод для AI и PDF: получить красивый список выпитого за день
  List<String> getTakenNamesForDay(DateTime date) {
    final takenIds = getTakenForDay(date);
    return _medications
        .where((med) => takenIds.contains(med.id))
        .map((med) => "${med.name} (${med.dosage})")
        .toList();
  }
}