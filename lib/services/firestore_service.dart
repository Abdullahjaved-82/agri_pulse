import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<Map<String, dynamic>>> watchCrops({int limit = 0}) {
    return _watchCollection(
      collectionPath: 'crops',
      limit: limit,
      orderByField: 'name',
    );
  }

  Stream<List<Map<String, dynamic>>> watchMandis({int limit = 0}) {
    return _watchCollection(
      collectionPath: 'mandis',
      limit: limit,
      orderByField: 'name',
    );
  }

  Stream<List<Map<String, dynamic>>> watchNews({int limit = 0}) {
    return _watchCollection(
      collectionPath: 'news',
      limit: limit,
      orderByField: 'date',
      descending: true,
    );
  }

  Stream<List<Map<String, dynamic>>> _watchCollection({
    required String collectionPath,
    int limit = 0,
    String? orderByField,
    bool descending = false,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection(collectionPath);

    if (orderByField != null) {
      query = query.orderBy(orderByField, descending: descending);
    }

    if (limit > 0) {
      query = query.limit(limit);
    }

    return query.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => _normalizeDoc(doc.id, doc.data()))
              .toList(),
        );
  }

  Map<String, dynamic> _normalizeDoc(
    String docId,
    Map<String, dynamic> data,
  ) {
    final Map<String, dynamic> copy = Map<String, dynamic>.from(data);

    if (!copy.containsKey('id')) {
      final int? parsedId = int.tryParse(docId);
      copy['id'] = parsedId ?? 0;
    }

    copy['docId'] = docId;
    return copy;
  }
}

