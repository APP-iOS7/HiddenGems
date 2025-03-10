import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hidden_gems/models/works.dart';
import 'package:hidden_gems/models/auction_work.dart';

class WorkProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Work> _works = [];

  List<Work> get works => _works;

  //모든 작품 가져오기
  Future<void> loadWorks() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('works')
        .orderBy('createDate', descending: true)
        .get();

    _works = querySnapshot.docs.map((doc) => Work.fromFirestore(doc)).toList();
    notifyListeners();
  }

  //특정 작품 가져오기
  Future<Work?> getWorkById(String workId) async {
    final doc =
        await FirebaseFirestore.instance.collection('works').doc(workId).get();
    if (doc.exists) {
      return Work.fromFirestore(doc);
    }
    return null;
  }

  //작품 추가
  Future<void> addWork(Work work) async {
    final docRef = FirebaseFirestore.instance.collection('works').doc(work.id);
    await docRef.set(work.toMap());
    _works.add(work);
    notifyListeners();
  }

  //작품 수정
  Future<void> updateWork(Work updatedWork) async {
    final docRef =
        FirebaseFirestore.instance.collection('works').doc(updatedWork.id);
    await docRef.set(updatedWork.toMap(), SetOptions(merge: true));

    final index = _works.indexWhere((work) => work.id == updatedWork.id);
    if (index != -1) {
      _works[index] = updatedWork;
      
    }
    final auctionQuery = await _firestore
        .collection('auctionWorks')
        .where('workId', isEqualTo: updatedWork.id)
        .get();

    for (var auctionDoc in auctionQuery.docs) {
      double nowPrice = auctionDoc['nowPrice']?.toDouble() ?? 0.0;
      double minPrice = updatedWork.minPrice;
      bool resetBidder = false;

      if (nowPrice < minPrice) {
        nowPrice = minPrice;
        resetBidder = true;
      }

      await auctionDoc.reference.update({
        'workTitle': updatedWork.title,
        'minPrice': minPrice,
        'nowPrice': nowPrice,
        if (resetBidder) 'lastBidderId': null,
      });
    }
    notifyListeners();
  }

  // //작품 삭제
  // Future<void> deleteWork(String workId) async {
  //   await FirebaseFirestore.instance.collection('works').doc(workId).delete();
  //   _works.removeWhere((work) => work.id == workId);
  //   notifyListeners();
  // }

  /// 작품 삭제 및 관련 사용자 필드 업데이트, 그리고 auctionWorks 컬렉션의 문서 삭제 기능
  Future<void> deleteWork(String workId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    print(workId);
    // 1. Works 컬렉션에서 해당 작품 문서를 가져옵니다.
    final DocumentReference workRef = firestore.collection('works').doc(workId);
    final workSnapshot = await workRef.get();
    if (!workSnapshot.exists) {
      throw Exception("작품을 찾을 수 없습니다.");
    }
    final workData = workSnapshot.data() as Map<String, dynamic>;

    // 작품 생성자 UID와 작품의 좋아요 수를 가져옵니다.
    final String creatorUid = workData['artistID'];
    final int workLikes = workData['likedCount'] ?? 0;

    // WriteBatch를 생성하여 여러 작업을 원자적으로 처리합니다.
    WriteBatch batch = firestore.batch();

    // 2. Works 컬렉션의 해당 작품 문서 삭제
    batch.delete(workRef);

    // 3. auctionWorks 컬렉션의 문서도 함께 삭제 (문서 ID가 workId라고 가정)
    final DocumentReference auctionWorkRef =
        firestore.collection('auctionWorks').doc(workId);
    batch.delete(auctionWorkRef);

    // 4. 생성자(user) 문서 업데이트:
    //    - myWorks 배열에서 workId 제거
    //    - myWorksCount 1 감소 (음수 방지)
    //    - myLikeScore는 작품의 좋아요 수만큼 차감
    final DocumentReference creatorUserRef =
        firestore.collection('users').doc(creatorUid);
    batch.update(creatorUserRef, {
      'myWorks': FieldValue.arrayRemove([workId]),
      'myWorksCount': FieldValue.increment(-1),
      'myLikeScore': FieldValue.increment(-workLikes),
    });

    // 5. 다른 사용자들 중 likedWorks 배열에 workId가 포함된 경우 제거
    final QuerySnapshot likedUsersQuery = await firestore
        .collection('users')
        .where('likedWorks', arrayContains: workId)
        .get();

    for (var doc in likedUsersQuery.docs) {
      batch.update(doc.reference, {
        'likedWorks': FieldValue.arrayRemove([workId]),
      });
    }

    // 6. 모든 업데이트를 커밋합니다.
    await batch.commit();
  }

  //좋아요 누른 유저 수정
  Future<void> updateWorkLikedUsers(
      String workId, List<String> updatedLikedUsers) async {
    final workDoc = FirebaseFirestore.instance.collection('works').doc(workId);
    await workDoc.update({'likedUsers': updatedLikedUsers});

    int index = _works.indexWhere((work) => work.id == workId);
    if (index != -1) {
      _works[index] = Work(
        id: _works[index].id,
        artistID: _works[index].artistID,
        artistNickName: _works[index].artistNickName,
        selling: _works[index].selling,
        title: _works[index].title,
        description: _works[index].description,
        createDate: _works[index].createDate,
        workPhotoURL: _works[index].workPhotoURL,
        minPrice: _works[index].minPrice,
        likedUsers: updatedLikedUsers,
        likedCount: updatedLikedUsers.length,
        doAuction: _works[index].doAuction,
      );
      notifyListeners();
    }
  }

  Future<void> updateWorkAuctionStatus(
      String workId, bool newAuctionStatus) async {
    final workDoc = FirebaseFirestore.instance.collection('works').doc(workId);
    await workDoc.update({'doAuction': newAuctionStatus});
    final index = _works.indexWhere((w) => w.id == workId);
    if (index != -1) {
      _works[index] = Work(
        id: _works[index].id,
        artistID: _works[index].artistID,
        artistNickName: _works[index].artistNickName,
        selling: _works[index].selling,
        title: _works[index].title,
        description: _works[index].description,
        createDate: _works[index].createDate,
        workPhotoURL: _works[index].workPhotoURL,
        minPrice: _works[index].minPrice,
        likedUsers: _works[index].likedUsers,
        likedCount: _works[index].likedCount,
        doAuction: newAuctionStatus,
      );
      notifyListeners();
    }
  }

  Future<List<Work>> loadPopularWorks({int limit = 5}) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('works')
        .orderBy('likedCount', descending: true)
        .limit(limit)
        .get();

    return querySnapshot.docs.map((doc) => Work.fromFirestore(doc)).toList();
  }

  Future<void> updateWorkSellingStatus(
      String workId, bool newAuctionStatus) async {
    final workDoc = FirebaseFirestore.instance.collection('works').doc(workId);
    await workDoc.update({'selling': newAuctionStatus});
    final index = _works.indexWhere((w) => w.id == workId);
    if (index != -1) {
      _works[index] = Work(
        id: _works[index].id,
        artistID: _works[index].artistID,
        artistNickName: _works[index].artistNickName,
        selling: newAuctionStatus,
        title: _works[index].title,
        description: _works[index].description,
        createDate: _works[index].createDate,
        workPhotoURL: _works[index].workPhotoURL,
        minPrice: _works[index].minPrice,
        likedUsers: _works[index].likedUsers,
        likedCount: _works[index].likedCount,
        doAuction: _works[index].doAuction,
      );
      notifyListeners();
    }
  }
}
