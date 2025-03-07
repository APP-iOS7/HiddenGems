import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gems/models/auction_work.dart';
import 'package:provider/provider.dart';

class AuctionWorksProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List _userAuctionWorks = [];
  List get userAuctionWorks => _userAuctionWorks;

  Future<void> fetchUserAuctionWorks(BuildContext context) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        debugPrint("Error: 로그인한 사용자 없음");
        return;
      }

      final QuerySnapshot snapshot = await _firestore
          .collection('auctionWorks')
          .where('auctionUserId', arrayContains: user.uid)
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
