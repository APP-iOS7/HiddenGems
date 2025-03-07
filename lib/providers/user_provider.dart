import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hidden_gems/models/user.dart';

class UserProvider with ChangeNotifier {
  AppUser? _user;

  AppUser? get user => _user;

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
      notifyListeners();
    }
  }

  // 사용자 프로필 업데이트: 닉네임과 프로필 사진을 포함한 전체 정보를 Firestore에 저장
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
        );
      } else {
        updatedUser = AppUser(
          id: currentUser.uid,
          signupDate: DateTime.now(),
          profileURL: newProfileURL,
          nickName: newNickName,
          myWorks: [],
          likedWorks: [],
        );
      }
      // 기존 데이터 보존을 위해 merge 옵션 사용
      await userDoc.set(updatedUser.toMap(), SetOptions(merge: true));
      _user = updatedUser;
      notifyListeners();
    }
  }
}
