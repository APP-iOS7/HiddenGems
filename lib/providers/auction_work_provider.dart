import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hidden_gems/models/auction_work.dart';

class AuctionWorkProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<AuctionWork> _actionWorks = [];
  bool _isLoading = false;

  List get auctionHistories => _actionWorks;
  bool get isLoading => _isLoading;

  // 입찰 내역 로드
  Future loadAuctionHistories() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('auctionWorks')
          .orderBy('endDate', descending: true)
          .get();

      _actionWorks = snapshot.docs
          .map((doc) {
            final work = AuctionWork.fromMap({...doc.data(), 'workId': doc.id});
            return {
              'workId': work.workId,
              'artistId': work.artistId,
              'minPrice': work.minPrice,
              'nowPrice': work.nowPrice,
              'endDate': work.endDate,
              'bidderCount': work.auctionUserId.length,
              'bidders': work.auctionUserId,
              'isComplete': work.auctionComplete,
            };
          })
          .cast<AuctionWork>()
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      debugPrint('입찰 내역 로드 중 오류 발생: $e');
      notifyListeners();
    }
  }

  // 입찰가 업데이트
  Future updatePrice(String workId, int newPrice) async {
    try {
      final docSnap =
          await _firestore.collection('auctionWorks').doc(workId).get();

      if (!docSnap.exists) return false;

      final currentWork =
          AuctionWork.fromMap({...docSnap.data()!, 'workId': docSnap.id});

      if (newPrice <= currentWork.nowPrice) {
        return false;
      }

      await _firestore.collection('auctionWorks').doc(workId).update({
        'nowPrice': newPrice,
      });

      // 데이터 새로고침
      await loadAuctionHistories();
      return true;
    } catch (e) {
      debugPrint('입찰가 업데이트 중 오류 발생: $e');
      return false;
    }
  }
}
