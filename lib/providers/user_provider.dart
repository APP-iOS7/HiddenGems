import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hidden_gems/models/user.dart';

class UserProvider with ChangeNotifier {
  List<User> _users = [];

  List<User> get users => _users;

  void setUsers(List<User> newUsers) {
    _users = newUsers;
    notifyListeners();
  }
  
  AppUser? _user;
  bool _isLoading = true;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;

  UserProvider() {
    // FirebaseAuth 상태 변화를 구독하여 로그인/로그아웃 시 자동으로 loadUser() 호출
    FirebaseAuth.instance.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser != null) {
        await loadUser();
      } else {
        _user = null;
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  // Firestore에서 사용자 정보 불러오기
  Future<void> loadUser() async {
    _isLoading = true;
    // notifyListeners();

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      if (userDoc.exists) {
      final newUser = AppUser.fromMap(userDoc.data()!);
      if (_user == null || _user!.id != newUser.id) {  //사용자가 변경되지 않으면 실행하지 않음 
        _user = newUser;
        notifyListeners();
      }
    }
  }
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
        updatedUser = AppUser(
          id: data['id'] ?? currentUser.uid,
          signupDate: data['signupDate'] != null
              ? DateTime.parse(data['signupDate'])
              : DateTime.now(),
          profileURL: newProfileURL,
          nickName: newNickName,
          myWorks: List<String>.from(data['myWorks'] ?? []),
          likedWorks: List<String>.from(data['likedWorks'] ?? []),
          biddingWorks: List<String>.from(data['biddingWorks'] ?? []),
          beDeliveryWorks: List<String>.from(data['beDeliveryWorks'] ?? []),
          completeWorks: List<String>.from(data['completeWorks'] ?? []),
        );
      } else {
        updatedUser = AppUser(
          id: currentUser.uid,
          signupDate: DateTime.now(),
          profileURL: newProfileURL,
          nickName: newNickName,
          myWorks: [],
          likedWorks: [],
          biddingWorks: [],
          beDeliveryWorks: [],
          completeWorks: [],
        );
      }
      await userDoc.set(updatedUser.toMap(), SetOptions(merge: true));
      _user = updatedUser;
      notifyListeners();
    }
  }

  void clearUser() {
    _user = null;
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
        myWorks: _user!.myWorks,
        likedWorks: updatedLikedWorks,
        biddingWorks: _user!.myWorks,
        beDeliveryWorks: _user!.myWorks,
        completeWorks: _user!.myWorks,
      );
      notifyListeners();
    }
  }
}
