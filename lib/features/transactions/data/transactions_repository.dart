import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_paths.dart';
import '../models/transaction.dart' as models;

class TransactionsRepository {
  TransactionsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _transactions(String uid) {
    return _firestore
        .collection(FirestorePaths.users)
        .doc(uid)
        .collection(FirestorePaths.transactions);
  }

  Stream<List<models.Transaction>> watchTransactions(String uid) {
    return _transactions(uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => models.Transaction.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> addTransaction(String uid, models.Transaction transaction) {
    return _transactions(uid).doc(transaction.id).set(transaction.toMap());
  }

  Future<void> deleteTransaction(String uid, String transactionId) {
    return _transactions(uid).doc(transactionId).delete();
  }

  Future<void> deleteAllTransactions(String uid, Iterable<String> ids) async {
    if (ids.isEmpty) {
      return;
    }
    final batch = _firestore.batch();
    for (final id in ids) {
      batch.delete(_transactions(uid).doc(id));
    }
    await batch.commit();
  }
}
