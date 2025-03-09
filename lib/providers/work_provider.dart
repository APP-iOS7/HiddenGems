import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hidden_gems/models/works.dart';

class WorkProvider with ChangeNotifier {
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
      notifyListeners();
    }
  }

  //작품 삭제
  Future<void> deleteWork(String workId) async {
    await FirebaseFirestore.instance.collection('works').doc(workId).delete();
    _works.removeWhere((work) => work.id == workId);
    notifyListeners();
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

  Future<List<Work>> loadPopularWorks({int limit = 10}) async {
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
