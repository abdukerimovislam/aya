import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class MedicationItem {
  final String id;
  final String name;
  final String dosage;
  final String iconStr;
  final bool isArchived; // 🔥 НОВОЕ: Защита от потери истории

  MedicationItem({
    required this.id,
    required this.name,
    required this.dosage,
    required this.iconStr,
    this.isArchived = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'dosage': dosage,
    'iconStr': iconStr,
    'isArchived': isArchived,
  };

  factory MedicationItem.fromMap(Map<dynamic, dynamic> map) => MedicationItem(
    id: map['id'],
    name: map['name'],
    dosage: map['dosage'],
    iconStr: map['iconStr'] ?? '💊',
    isArchived: map['isArchived'] ?? false,
  );

  MedicationItem copyWithArchive() => MedicationItem(
    id: id, name: name, dosage: dosage, iconStr: iconStr, isArchived: true,
  );
}

class MedicationProvider extends ChangeNotifier {
  final Future<Box> Function(String name)? _boxOpener;
  Box? _registryBox;
  Box? _logsBox;
  late final Future<void> _initialization;

  List<MedicationItem> _medications = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  // 🔥 Выдаем в UI только активные
  List<MedicationItem> get activeMedications =>
      List.unmodifiable(_medications.where((m) => !m.isArchived));

  MedicationProvider({Future<Box> Function(String name)? boxOpener})
      : _boxOpener = boxOpener {
    _initialization = _init();
  }

  Future<void> _init() async {
    _registryBox = await _openBox('medications_registry');
    _logsBox = await _openBox('medications_logs');
    _loadRegistry();
  }

  Future<Box> _openBox(String name) {
    return _boxOpener != null ? _boxOpener!(name) : Hive.openBox(name);
  }

  Future<void> _ensureReady() async {
    await _initialization;
  }

  Future<void> reload() async {
    await _ensureReady();
    if (_registryBox == null || !_registryBox!.isOpen) {
      _registryBox = await _openBox('medications_registry');
    }
    if (_logsBox == null || !_logsBox!.isOpen) {
      _logsBox = await _openBox('medications_logs');
    }
    _loadRegistry();
  }

  void _loadRegistry() {
    if (_registryBox == null) return;

    final List<dynamic> rawList = _registryBox!.get('items', defaultValue: []);
    _medications = rawList.map((e) => MedicationItem.fromMap(Map<dynamic, dynamic>.from(e))).toList();
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> addMedication(String name, String dosage, String iconStr) async {
    await _ensureReady();
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
    await _ensureReady();
    // 🔥 SOFT DELETE: Архивация вместо удаления
    final index = _medications.indexWhere((e) => e.id == id);
    if (index != -1) {
      _medications[index] = _medications[index].copyWithArchive();
      await _saveRegistry();
    }
  }

  Future<void> _saveRegistry() async {
    if (_registryBox != null) {
      await _registryBox!.put('items', _medications.map((e) => e.toMap()).toList());
    }
    notifyListeners();
  }

  String _dateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  List<String> getTakenForDay(DateTime date) {
    if (_logsBox == null) return [];
    final key = _dateKey(date);
    final rawList = _logsBox!.get(key, defaultValue: <String>[]);
    return (rawList as List).cast<String>();
  }

  Future<void> toggleMedication(String medId, DateTime date) async {
    await _ensureReady();
    if (_logsBox == null) return;

    final key = _dateKey(date);
    List<String> taken = getTakenForDay(date).toList();

    if (taken.contains(medId)) {
      taken.remove(medId);
    } else {
      taken.add(medId);
    }

    if (taken.isEmpty) {
      await _logsBox!.delete(key);
    } else {
      await _logsBox!.put(key, taken);
    }

    notifyListeners();
  }

  Future<void> wipeData() async {
    await _ensureReady();

    await _registryBox?.clear();
    await _logsBox?.clear();
    _medications = [];
    _isLoaded = true;
    notifyListeners();
  }

  // 🔥 Ищет по ВСЕМ препаратам (включая архивные), чтобы PDF не был пустым
  List<String> getTakenNamesForDay(DateTime date) {
    final takenIds = getTakenForDay(date);
    return _medications
        .where((med) => takenIds.contains(med.id))
        .map((med) => "${med.name} (${med.dosage})")
        .toList();
  }
}
