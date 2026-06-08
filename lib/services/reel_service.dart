import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/reel_model.dart';

class ReelService {

  Future<List<ReelModel>> getReels() async {

    final snapshot = await FirebaseFirestore.instance
        .collection('reels')
        .get();

    return snapshot.docs.map((doc) {
      return ReelModel.fromFirestore(
        doc.id,
        doc.data(),
      );
    }).toList();
  }
}