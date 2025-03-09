import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gems/models/auction_work.dart';

class AuctionWorksProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List _allAuctionWorks = [];
  List get allAuctionWorks => _allAuctionWorks;

  List _userAuctionWorks = [];
  List get userAuctionWorks => _userAuctionWorks;

  AuctionWorksProvider() {
    _listenToAuctionUpdates(); // ✅ 실시간 감지
  }

  void _listenToAuctionUpdates() {
    _firestore.collection('auctionWorks').snapshots().listen((snapshot) {
      _allAuctionWorks = snapshot.docs
          .map((doc) => AuctionWork.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      notifyListeners(); // ✅ 변경 감지 즉시 UI 업데이트
    });
  }

  Future<void> fetchAllAuctionWorks() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection('auctionWorks').get();

      _allAuctionWorks = snapshot.docs
          .map((doc) => AuctionWork.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      debugPrint("모든 경매 : ${_allAuctionWorks.length}개");
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching all auction works: $e');
      _allAuctionWorks = [];
      notifyListeners();
    }
  }

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

  Future<void> addAuctionWork(AuctionWork auctionWork) async {
    try {
      await _firestore
          .collection('auctionWorks')
          .doc(auctionWork.workId)
          .set(auctionWork.toMap());

      debugPrint("경매추가 ${auctionWork.workTitle}");

      _userAuctionWorks.add(auctionWork);
      notifyListeners();
    } catch (e) {
      debugPrint("Error: $e");
    }
  }
  Future<void> updateAuctionBidders(String workId, List<String> updatedBidders) async {
    try {
      await _firestore.collection('auctionWorks').doc(workId).update({
        'auctionUserId': updatedBidders,
      });

      // 현재 경매 데이터 업데이트
      int index = _allAuctionWorks.indexWhere((work) => work.workId == workId);
      if (index != -1) {
        _allAuctionWorks[index] = AuctionWork(
          workId: _allAuctionWorks[index].workId,
          workTitle: _allAuctionWorks[index].workTitle,
          artistId: _allAuctionWorks[index].artistId,
          auctionUserId: updatedBidders,
          minPrice: _allAuctionWorks[index].minPrice,
          nowPrice: _allAuctionWorks[index].nowPrice,
          endDate: _allAuctionWorks[index].endDate,
          auctionComplete: _allAuctionWorks[index].auctionComplete,
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint("입찰자 업데이트 오류: $e");
    }
  }
}
