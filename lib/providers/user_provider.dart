import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hidden_gems/models/user.dart';

class UserProvider with ChangeNotifier {
  AppUser? _user;
  bool _isLoaded = false;

  AppUser? get user => _user;
  bool get isLoaded => _isLoaded;

  UserProvider() {
    // FirebaseAuth 상태 변화를 구독하여 로그인/로그아웃 시 자동으로 loadUser() 호출
    FirebaseAuth.instance.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser != null) {
        await loadUser();
      } else {
        _user = null;
        notifyListeners();
      }
    });
  }

  // Firestore에서 사용자 정보 불러오기
  Future<void> loadUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      if (userDoc.exists) {
        _user = AppUser.fromMap(userDoc.data()!);
      }
    }
    _isLoaded = true;
    notifyListeners();
  }

  // 사용자 프로필 업데이트
  Future<void> updateUserProfile(
      String newNickName, String newProfileURL) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
      final snapshot = await userDoc.get();

      AppUser updatedUser;
      if (snapshot.exists) {
        final data = snapshot.data()!;
        List<String> myWorksList = List<String>.from(data['myWorks'] ?? []);

        updatedUser = AppUser(
          id: data['id'] ?? currentUser.uid,
          signupDate: data['signupDate'] != null
              ? DateTime.parse(data['signupDate'])
              : DateTime.now(),
          profileURL: newProfileURL,
          nickName: newNickName,
          myLikeScore: data['myLikeScore'] ?? 0,
          myWorks: myWorksList,
          myWorksCount: myWorksList.length,
          likedWorks: List<String>.from(data['likedWorks'] ?? []),
          biddingWorks: List<String>.from(data['biddingWorks'] ?? []),
          beDeliveryWorks: List<String>.from(data['beDeliveryWorks'] ?? []),
          completeWorks: List<String>.from(data['completeWorks'] ?? []),
          subscribeUsers: List<String>.from(data['completeWorks'] ?? []),
        );
      } else {
        updatedUser = AppUser(
          id: currentUser.uid,
          signupDate: DateTime.now(),
          profileURL: newProfileURL,
          nickName: newNickName,
          myLikeScore: 0,
          myWorks: [],
          myWorksCount: 0,
          likedWorks: [],
          biddingWorks: [],
          beDeliveryWorks: [],
          completeWorks: [],
          subscribeUsers: [],
        );
      }
      await userDoc.set(updatedUser.toMap(), SetOptions(merge: true));
      _user = updatedUser;
      notifyListeners();
    }
  }

  void clearUser() {
    _user = null;
    _isLoaded = false;
    notifyListeners();
  }

  // Firestore에 likedWorks 업데이트
  Future<void> updateUserLikedWorks(List<String> updatedLikedWorks) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

    await userDoc.update({'likedWorks': updatedLikedWorks});

    if (_user != null) {
      _user = AppUser(
        id: _user!.id,
        signupDate: _user!.signupDate,
        profileURL: _user!.profileURL,
        nickName: _user!.nickName,
        myLikeScore: _user!.myLikeScore,
        myWorks: _user!.myWorks,
        myWorksCount: _user!.myWorks.length,
        likedWorks: updatedLikedWorks,
        biddingWorks: _user!.biddingWorks,
        beDeliveryWorks: _user!.beDeliveryWorks,
        completeWorks: _user!.completeWorks,
        subscribeUsers: _user!.subscribeUsers,
      );
      notifyListeners();
    }
  }

  Future<void> addMyLikeScore(String artistId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(artistId);

    await userDoc.update({'myLikeScore': FieldValue.increment(1)});

    if (_user != null) {
      _user = AppUser(
        id: _user!.id,
        signupDate: _user!.signupDate,
        profileURL: _user!.profileURL,
        nickName: _user!.nickName,
        myLikeScore: _user!.myLikeScore + 1,
        myWorks: _user!.myWorks,
        myWorksCount: _user!.myWorks.length,
        likedWorks: _user!.likedWorks,
        biddingWorks: _user!.biddingWorks,
        beDeliveryWorks: _user!.beDeliveryWorks,
        completeWorks: _user!.completeWorks,
        subscribeUsers: _user!.subscribeUsers,
      );
      notifyListeners();
    }
  }

  Future<void> subMyLikeScore(String artistId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(artistId);

    await userDoc.update({'myLikeScore': FieldValue.increment(-1)});

    if (_user != null) {
      _user = AppUser(
        id: _user!.id,
        signupDate: _user!.signupDate,
        profileURL: _user!.profileURL,
        nickName: _user!.nickName,
        myLikeScore: _user!.myLikeScore - 1,
        myWorks: _user!.myWorks,
        myWorksCount: _user!.myWorks.length,
        likedWorks: _user!.likedWorks,
        biddingWorks: _user!.biddingWorks,
        beDeliveryWorks: _user!.beDeliveryWorks,
        completeWorks: _user!.completeWorks,
        subscribeUsers: _user!.subscribeUsers,
      );
      notifyListeners();
    }
  }

  Future<void> updateUserMyWorks(List<String> updatedMyWorksId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

    await userDoc.update({'myWorks': updatedMyWorksId});

    if (_user != null) {
      _user = AppUser(
        id: _user!.id,
        signupDate: _user!.signupDate,
        profileURL: _user!.profileURL,
        nickName: _user!.nickName,
        myLikeScore: _user!.myLikeScore,
        myWorks: updatedMyWorksId,
        myWorksCount: updatedMyWorksId.length,
        likedWorks: _user!.likedWorks,
        biddingWorks: _user!.biddingWorks,
        beDeliveryWorks: _user!.beDeliveryWorks,
        completeWorks: _user!.completeWorks,
        subscribeUsers: _user!.subscribeUsers,
      );
      notifyListeners();
    }
  }

  Future<void> updateUserSubscribeUsers(
      List<String> updatedSubscribeUserIds) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

    await userDoc.update({'subscribeUsers': updatedSubscribeUserIds});

    if (_user != null) {
      _user = AppUser(
        id: _user!.id,
        signupDate: _user!.signupDate,
        profileURL: _user!.profileURL,
        nickName: _user!.nickName,
        myLikeScore: _user!.myLikeScore,
        myWorks: _user!.myWorks,
        likedWorks: _user!.likedWorks,
        biddingWorks: _user!.biddingWorks,
        beDeliveryWorks: _user!.beDeliveryWorks,
        completeWorks: _user!.completeWorks,
        subscribeUsers: updatedSubscribeUserIds,
        myWorksCount: _user!.myWorksCount, //
      );
      notifyListeners();
    }
  }
}
