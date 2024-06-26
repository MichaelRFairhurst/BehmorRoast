import 'package:behmor_roast/src/roast/models/roast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const _roastdb = 'roasts';

class RoastService {
  Stream<List<Roast>> get roasts =>
      FirebaseFirestore.instance.collection(_roastdb).snapshots().map((record) {
        return record.docs.map((doc) => Roast.fromJson(doc.data())).toList();
      });

  Future<void> add(Roast roast) {
    return FirebaseFirestore.instance.collection(_roastdb).add(roast.toJson());
  }

  Stream<List<Roast>> roastsForBean(String beanId) => FirebaseFirestore.instance
          .collection(_roastdb)
          .where('beanId', isEqualTo: beanId)
          .snapshots()
          .map((record) {
        return record.docs
            .map((doc) {
              try {
                return Roast.fromJson(doc.data()).copyWith(id: doc.id);
              } catch (e, st) {
                print('Error parsing ${doc.id}: $e\n$st');
                return null;
              }
            })
            .whereType<Roast>()
            .toList()
          ..sort((a, b) => a.roasted.compareTo(b.roasted));
      });

  Stream<Roast> roast(String roastId) => FirebaseFirestore.instance
          .collection(_roastdb)
          .doc(roastId)
          .snapshots()
          .map((doc) {
        return Roast.fromJson(doc.data()!).copyWith(id: doc.id);
      });
}
