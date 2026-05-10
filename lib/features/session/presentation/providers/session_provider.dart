import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/session_model.dart';
import '../../data/models/person_model.dart';
import '../../data/models/item_model.dart';
import '../../domain/split_calculator.dart';
import '../../../../services/storage/local_storage_service.dart';

class SessionProvider with ChangeNotifier {
  final LocalStorageService _storageService = LocalStorageService();
  
  List<SessionModel> _recentSessions = [];
  List<SessionModel> get recentSessions => _recentSessions;

  SessionModel? _currentSession;
  SessionModel? get currentSession => _currentSession;

  Map<String, double> _calculationResult = {};
  Map<String, double> get calculationResult => _calculationResult;

  double _tipPercent = 0.0;
  double get tipPercent => _tipPercent;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Undo tracking
  PersonModel? _lastDeletedPerson;
  Map<String, double>? _lastDeletedPersonShares; // itemId -> share
  ItemModel? _lastDeletedItem;
  SessionModel? _lastDeletedSession;
  int? _lastDeletedSessionIndex;

  SessionProvider() {
    loadRecentSessions();
  }

  Future<void> loadRecentSessions() async {
    _isLoading = true;
    notifyListeners();
    
    _recentSessions = await _storageService.getSessions();
    _recentSessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    _isLoading = false;
    notifyListeners();
  }

  void startNewSession() {
    _currentSession = SessionModel(
      id: const Uuid().v4(),
      name: '',
      currency: 'PKR',
      people: [],
      items: [],
      taxPercent: 0.0,
      serviceChargePercent: 0.0,
      createdAt: DateTime.now(),
    );
    _calculationResult = {};
    _tipPercent = 0.0;
    notifyListeners();
  }

  void updateSessionInfo(String name, String currency) {
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(
        name: name,
        currency: currency,
      );
      notifyListeners();
    }
  }

  void updateReceiptImage(String? path) {
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(receiptImagePath: path);
      notifyListeners();
    }
  }

  void editPersonName(String personId, String newName) {
    if (_currentSession != null) {
      final updatedPeople = _currentSession!.people.map((p) {
        if (p.id == personId) return PersonModel(id: p.id, name: newName);
        return p;
      }).toList();
      _currentSession = _currentSession!.copyWith(people: updatedPeople);
      notifyListeners();
    }
  }

  void addPerson(String name) {
    if (_currentSession != null) {
      final person = PersonModel(id: const Uuid().v4(), name: name);
      final updatedPeople = [..._currentSession!.people, person];
      _currentSession = _currentSession!.copyWith(people: updatedPeople);
      notifyListeners();
    }
  }

  void removePerson(String id) {
    if (_currentSession != null) {
      final personIndex = _currentSession!.people.indexWhere((p) => p.id == id);
      if (personIndex == -1) return;

      _lastDeletedPerson = _currentSession!.people[personIndex];
      _lastDeletedPersonShares = {};
      
      final updatedPeople = _currentSession!.people.where((p) => p.id != id).toList();
      final updatedItems = _currentSession!.items.map((item) {
        final updatedShares = Map<String, double>.from(item.assignedShares);
        if (updatedShares.containsKey(id)) {
          _lastDeletedPersonShares![item.id] = updatedShares[id]!;
          updatedShares.remove(id);
        }
        return item.copyWith(assignedShares: updatedShares);
      }).toList();

      _currentSession = _currentSession!.copyWith(
        people: updatedPeople,
        items: updatedItems,
      );
      notifyListeners();
    }
  }

  void undoDeletePerson() {
    if (_currentSession != null && _lastDeletedPerson != null) {
      final updatedPeople = [..._currentSession!.people, _lastDeletedPerson!];
      final updatedItems = _currentSession!.items.map((item) {
        if (_lastDeletedPersonShares?.containsKey(item.id) ?? false) {
          final updatedShares = Map<String, double>.from(item.assignedShares);
          updatedShares[_lastDeletedPerson!.id] = _lastDeletedPersonShares![item.id]!;
          return item.copyWith(assignedShares: updatedShares);
        }
        return item;
      }).toList();

      _currentSession = _currentSession!.copyWith(
        people: updatedPeople,
        items: updatedItems,
      );
      _lastDeletedPerson = null;
      _lastDeletedPersonShares = null;
      notifyListeners();
    }
  }

  void addItem(String name, double price) {
    if (_currentSession != null) {
      final item = ItemModel(
        id: const Uuid().v4(),
        name: name,
        price: price,
        assignedShares: {},
      );
      final updatedItems = [..._currentSession!.items, item];
      _currentSession = _currentSession!.copyWith(items: updatedItems);
      notifyListeners();
    }
  }

  void editItemName(String itemId, String newName) {
    if (_currentSession != null) {
      final updatedItems = _currentSession!.items.map((i) {
        if (i.id == itemId) return i.copyWith(name: newName);
        return i;
      }).toList();
      _currentSession = _currentSession!.copyWith(items: updatedItems);
      notifyListeners();
    }
  }

  void editItemPrice(String itemId, double newPrice) {
    if (_currentSession != null) {
      final updatedItems = _currentSession!.items.map((i) {
        if (i.id == itemId) return i.copyWith(price: newPrice);
        return i;
      }).toList();
      _currentSession = _currentSession!.copyWith(items: updatedItems);
      notifyListeners();
    }
  }

  void removeItem(String id) {
    if (_currentSession != null) {
      final itemIndex = _currentSession!.items.indexWhere((i) => i.id == id);
      if (itemIndex == -1) return;

      _lastDeletedItem = _currentSession!.items[itemIndex];
      final updatedItems = _currentSession!.items.where((i) => i.id != id).toList();
      _currentSession = _currentSession!.copyWith(items: updatedItems);
      notifyListeners();
    }
  }

  void undoDeleteItem() {
    if (_currentSession != null && _lastDeletedItem != null) {
      final updatedItems = [..._currentSession!.items, _lastDeletedItem!];
      _currentSession = _currentSession!.copyWith(items: updatedItems);
      _lastDeletedItem = null;
      notifyListeners();
    }
  }

  void updateTaxAndService(double tax, double service) {
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(
        taxPercent: tax,
        serviceChargePercent: service,
      );
      notifyListeners();
    }
  }

  void updateTipPercent(double tip) {
    _tipPercent = tip;
    calculateResult();
  }

  void togglePersonInItem(String itemId, String personId) {
    if (_currentSession != null) {
      final updatedItems = _currentSession!.items.map((item) {
        if (item.id == itemId) {
          final updatedShares = Map<String, double>.from(item.assignedShares);
          if (updatedShares.containsKey(personId)) {
            updatedShares.remove(personId);
          } else {
            updatedShares[personId] = 1.0;
          }
          return item.copyWith(assignedShares: updatedShares);
        }
        return item;
      }).toList();
      _currentSession = _currentSession!.copyWith(items: updatedItems);
      notifyListeners();
    }
  }

  void updatePersonShare(String itemId, String personId, double share) {
    if (_currentSession != null) {
      final updatedItems = _currentSession!.items.map((item) {
        if (item.id == itemId) {
          final updatedShares = Map<String, double>.from(item.assignedShares);
          if (share <= 0) {
            updatedShares.remove(personId);
          } else {
            updatedShares[personId] = share;
          }
          return item.copyWith(assignedShares: updatedShares);
        }
        return item;
      }).toList();
      _currentSession = _currentSession!.copyWith(items: updatedItems);
      notifyListeners();
    }
  }

  void reassignShares(String itemId, Map<String, double> newShares) {
    if (_currentSession != null) {
      final updatedItems = _currentSession!.items.map((item) {
        if (item.id == itemId) return item.copyWith(assignedShares: newShares);
        return item;
      }).toList();
      _currentSession = _currentSession!.copyWith(items: updatedItems);
      notifyListeners();
    }
  }

  void assignItemToEveryone(String itemId) {
    if (_currentSession != null) {
      final updatedItems = _currentSession!.items.map((item) {
        if (item.id == itemId) {
          final updatedShares = <String, double>{};
          for (var person in _currentSession!.people) {
            updatedShares[person.id] = 1.0;
          }
          return item.copyWith(assignedShares: updatedShares);
        }
        return item;
      }).toList();
      _currentSession = _currentSession!.copyWith(items: updatedItems);
      notifyListeners();
    }
  }

  void calculateResult() {
    if (_currentSession != null) {
      _calculationResult = SplitCalculator.calculate(
        items: _currentSession!.items,
        taxPercent: _currentSession!.taxPercent,
        serviceChargePercent: _currentSession!.serviceChargePercent + _tipPercent,
      );
      notifyListeners();
    }
  }

  Future<void> saveCurrentSession() async {
    if (_currentSession != null) {
      await _storageService.saveSession(_currentSession!);
      await loadRecentSessions();
    }
  }

  Future<void> deleteRecentSession(String sessionId) async {
    final index = _recentSessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      _lastDeletedSession = _recentSessions[index];
      _lastDeletedSessionIndex = index;
      await _storageService.deleteSession(sessionId);
      await loadRecentSessions();
    }
  }

  Future<void> undoDeleteSession() async {
    if (_lastDeletedSession != null) {
      await _storageService.saveSession(_lastDeletedSession!);
      _lastDeletedSession = null;
      _lastDeletedSessionIndex = null;
      await loadRecentSessions();
    }
  }

  void loadSession(SessionModel session) {
    _currentSession = session;
    _tipPercent = 0.0;
    calculateResult();
    notifyListeners();
  }
}
