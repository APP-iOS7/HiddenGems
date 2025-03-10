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

  Future<void> updateAuctionBidders(
      String workId, List<String> updatedBidders) async {
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
          artistNickname: _allAuctionWorks[index].artistNickname,
          auctionUserId: updatedBidders,
          minPrice: _allAuctionWorks[index].minPrice,
          nowPrice: _allAuctionWorks[index].nowPrice,
          endDate: _allAuctionWorks[index].endDate,
          auctionComplete: _allAuctionWorks[index].auctionComplete,
          lastBidderId: _allAuctionWorks[index].lastBidderId,
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint("입찰자 업데이트 오류: $e");
    }
  }

  Future<void> endAuction(String workId) async {
    try {
      await _firestore.collection('auctionWorks').doc(workId).update({
        'auctionComplete': true,
      });

      int index = _allAuctionWorks.indexWhere((work) => work.workId == workId);
      if (index != -1) {
        _allAuctionWorks[index] = AuctionWork(
          workId: _allAuctionWorks[index].workId,
          workTitle: _allAuctionWorks[index].workTitle,
          artistId: _allAuctionWorks[index].artistId,
          artistNickname: _allAuctionWorks[index].artistNickname,
          auctionUserId: _allAuctionWorks[index].auctionUserId,
          minPrice: _allAuctionWorks[index].minPrice,
          nowPrice: _allAuctionWorks[index].nowPrice,
          endDate: _allAuctionWorks[index].endDate,
          auctionComplete: true,
          lastBidderId: _allAuctionWorks[index].lastBidderId,
        );
      }

      notifyListeners();
      debugPrint("경매 종료 완료: $workId");
    } catch (e) {
      debugPrint("경매 종료 오류: $e");
    }
  }

  Future<void> checkAndEndExpiredAuctions() async {
    final now = DateTime.now();
    final expiredAuctions = allAuctionWorks.where((auction) => auction.endDate.isBefore(now) && !auction.auctionComplete).toList();

    for (final auction in expiredAuctions) {
      await endAuction(auction.workId);
    }

    notifyListeners();
  }
  
  Future<void> updateNowprice(String workId, int newPrice) async {
    try {
      await _firestore.collection('auctionWorks').doc(workId).update({
        'nowPrice': newPrice,
      });

      int index = _allAuctionWorks.indexWhere((work) => work.workId == workId);
      if (index != -1) {
        _allAuctionWorks[index] = AuctionWork(
          workId: _allAuctionWorks[index].workId,
          workTitle: _allAuctionWorks[index].workTitle,
          artistId: _allAuctionWorks[index].artistId,
          artistNickname: _allAuctionWorks[index].artistNickname,
          auctionUserId: _allAuctionWorks[index].auctionUserId,
          minPrice: _allAuctionWorks[index].minPrice,
          nowPrice: newPrice,
          endDate: _allAuctionWorks[index].endDate,
          auctionComplete: _allAuctionWorks[index].auctionComplete,
          lastBidderId: _allAuctionWorks[index].lastBidderId,
        );
      }

      notifyListeners();
      debugPrint("현재가 업로드 완료: $workId");
    } catch (e) {
      debugPrint("현재가 업로드 오류: $e");
    }
  }

  Future<void> updateLastBidder(String workId, String newBidder) async {
    try {
      await _firestore.collection('auctionWorks').doc(workId).update({
        'lastBidderId': newBidder,
      });

      int index = _allAuctionWorks.indexWhere((work) => work.workId == workId);
      if (index != -1) {
        _allAuctionWorks[index] = AuctionWork(
          workId: _allAuctionWorks[index].workId,
          workTitle: _allAuctionWorks[index].workTitle,
          artistId: _allAuctionWorks[index].artistId,
          artistNickname: _allAuctionWorks[index].artistNickname,
          auctionUserId: _allAuctionWorks[index].auctionUserId,
          minPrice: _allAuctionWorks[index].minPrice,
          nowPrice: _allAuctionWorks[index].nowPrice,
          endDate: _allAuctionWorks[index].endDate,
          auctionComplete: _allAuctionWorks[index].auctionComplete,
          lastBidderId: newBidder,
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint("오류: $e");
    }
  }
  Future<void> deleteAuctionWork(String workId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('auctions')
        .where('workId', isEqualTo: workId)
        .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }

    _allAuctionWorks.removeWhere((auction) => auction.workId == workId);
    notifyListeners();
  }
}
