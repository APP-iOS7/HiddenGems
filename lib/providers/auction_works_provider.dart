import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gems/models/auction_work.dart';

class AuctionWorksProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List _userAuctionWorks = [];

  List get userAuctionWorks => _userAuctionWorks;

  Future fetchUserAuctionWorks(String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('auctionWorks')
          .where('auctionUserId', arrayContains: userId)
          .get();

      _userAuctionWorks = snapshot.docs
          .map((doc) => AuctionWork.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching auction works; $e');
      _userAuctionWorks = [];
      notifyListeners();
    }
  }
}
