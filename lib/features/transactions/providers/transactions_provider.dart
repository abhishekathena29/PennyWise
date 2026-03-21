import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../data/category_catalog.dart';
import '../data/transactions_repository.dart';
import '../models/category.dart' as models;
import '../models/transaction.dart';

class TransactionsProvider extends ChangeNotifier {
  TransactionsProvider(this._repository);

  final TransactionsRepository _repository;

  StreamSubscription<List<Transaction>>? _subscription;
  String? _uid;
  List<Transaction> _transactions = const [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<Transaction> get transactions => _transactions;
  List<models.Category> get categories => CategoryCatalog.categories;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  Future<void> bindUser(auth.User? user) async {
    final nextUid = user?.uid;
    if (_uid == nextUid) {
      return;
    }
    await _subscription?.cancel();
    _uid = nextUid;
    _transactions = const [];
    _errorMessage = null;
    if (user == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();
    _subscription = _repository
        .watchTransactions(user.uid)
        .listen(
          (items) {
            _transactions = items;
            _isLoading = false;
            notifyListeners();
          },
          onError: (_) {
            _errorMessage = 'Unable to load activity right now.';
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  Future<bool> addTransaction(Transaction transaction) async {
    if (_uid == null) {
      return false;
    }
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.addTransaction(_uid!, transaction);
      return true;
    } catch (_) {
      _errorMessage = 'Unable to save the transaction.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String id) async {
    if (_uid == null) {
      return;
    }
    try {
      await _repository.deleteTransaction(_uid!, id);
    } catch (_) {
      _errorMessage = 'Unable to delete the transaction.';
      notifyListeners();
    }
  }

  List<Transaction> get thisMonthTransactions {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return _transactions
        .where((transaction) => !transaction.date.isBefore(startOfMonth))
        .toList();
  }

  double get monthlyIncome {
    return thisMonthTransactions
        .where((transaction) => !transaction.isExpense)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  double get monthlyExpenses {
    return thisMonthTransactions
        .where((transaction) => transaction.isExpense)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  double get todayExpenses {
    final now = DateTime.now();
    return thisMonthTransactions
        .where((transaction) {
          return transaction.isExpense &&
              transaction.date.year == now.year &&
              transaction.date.month == now.month &&
              transaction.date.day == now.day;
        })
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  Map<String, double> get categorySpending {
    final map = <String, double>{};
    for (final transaction in thisMonthTransactions.where(
      (item) => item.isExpense,
    )) {
      map[transaction.categoryId] =
          (map[transaction.categoryId] ?? 0) + transaction.amount;
    }
    return map;
  }

  int get daysLeftInMonth {
    final now = DateTime.now();
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    return max(1, endOfMonth.day - now.day + 1);
  }

  double get currentMonthBalance => monthlyIncome - monthlyExpenses;

  double goalReserveForRemainingMonth(double dailySavingsRequired) {
    return max(0, dailySavingsRequired * daysLeftInMonth);
  }

  double availableAfterGoalReserve(double dailySavingsRequired) {
    return max(
      0,
      currentMonthBalance - goalReserveForRemainingMonth(dailySavingsRequired),
    );
  }

  double safeToSpendToday(double dailySavingsRequired) {
    final safe =
        (currentMonthBalance / daysLeftInMonth) -
        dailySavingsRequired -
        todayExpenses;
    return max(0, safe);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
