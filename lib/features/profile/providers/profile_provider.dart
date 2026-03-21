import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';

import '../data/profile_repository.dart';
import '../models/user_profile.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._repository);

  final ProfileRepository _repository;

  StreamSubscription<UserProfile?>? _profileSubscription;
  String? _uid;
  UserProfile? _profile;
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _errorMessage;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get errorMessage => _errorMessage;

  Future<void> bindUser(auth.User? user) async {
    final nextUid = user?.uid;
    if (_uid == nextUid) {
      return;
    }
    await _profileSubscription?.cancel();
    _uid = nextUid;
    _profile = null;
    _errorMessage = null;
    if (user == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();
    unawaited(_repository.ensureProfile(user));
    _profileSubscription = _repository
        .watchProfile(user.uid)
        .listen(
          (profile) {
            _profile = profile;
            _isLoading = false;
            notifyListeners();
          },
          onError: (_) {
            _errorMessage = 'Unable to load your profile right now.';
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  Future<bool> updateName(String name) async {
    if (_uid == null) {
      return false;
    }
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.updateName(uid: _uid!, name: name);
      _profile = _profile?.copyWith(name: name.trim());
      return true;
    } catch (_) {
      _errorMessage = 'Unable to update your profile.';
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }
}
