import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_paths.dart';
import '../models/savings_goal.dart';

class GoalsRepository {
  GoalsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _goals(String uid) {
    return _firestore
        .collection(FirestorePaths.users)
        .doc(uid)
        .collection(FirestorePaths.goals);
  }

  Stream<List<SavingsGoal>> watchGoals(String uid) {
    return _goals(uid)
        .orderBy('deadline')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SavingsGoal.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> addGoal(String uid, SavingsGoal goal) {
    return _goals(uid).doc(goal.id).set(goal.toMap());
  }

  Future<void> deleteGoal(String uid, String goalId) {
    return _goals(uid).doc(goalId).delete();
  }

  Future<void> updateGoalAmount({
    required String uid,
    required String goalId,
    required double currentAmount,
  }) {
    return _goals(uid).doc(goalId).set({
      'currentAmount': currentAmount,
    }, SetOptions(merge: true));
  }

  Future<void> deleteAllGoals(String uid, Iterable<String> ids) async {
    if (ids.isEmpty) {
      return;
    }
    final batch = _firestore.batch();
    for (final id in ids) {
      batch.delete(_goals(uid).doc(id));
    }
    await batch.commit();
  }
}
