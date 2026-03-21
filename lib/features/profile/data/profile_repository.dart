import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../../../core/constants/firestore_paths.dart';
import '../models/user_profile.dart';

class ProfileRepository {
  ProfileRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return _firestore.collection(FirestorePaths.users).doc(uid);
  }

  Stream<UserProfile?> watchProfile(String uid) {
    return _userDoc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      final data = snapshot.data() ?? <String, dynamic>{};
      return UserProfile(
        id: snapshot.id,
        name: data['name'] as String? ?? '',
        email: data['email'] as String? ?? '',
        photoUrl: data['photoUrl'] as String?,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      );
    });
  }

  Future<void> ensureProfile(auth.User firebaseUser, {String? name}) async {
    final doc = _userDoc(firebaseUser.uid);
    final snapshot = await doc.get();
    final fallbackName = name?.trim().isNotEmpty == true
        ? name!.trim()
        : (firebaseUser.displayName?.trim().isNotEmpty == true
              ? firebaseUser.displayName!.trim()
              : firebaseUser.email!.split('@').first);
    final payload = <String, dynamic>{
      'email': firebaseUser.email,
      'name': fallbackName,
      'photoUrl': firebaseUser.photoURL,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (!snapshot.exists) {
      payload['createdAt'] = FieldValue.serverTimestamp();
    }
    await doc.set(payload, SetOptions(merge: true));
  }

  Future<void> updateName({required String uid, required String name}) {
    return _userDoc(uid).set({
      'name': name.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
