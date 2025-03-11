import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gems/modal.dart';
import 'package:hidden_gems/providers/user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileUpdateScreen extends StatefulWidget {
  const ProfileUpdateScreen({super.key});

  @override
  State<ProfileUpdateScreen> createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  String? _profileImageUrl;
  bool _isUploading = false; // 업로드 상태 변수 추가

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user != null) {
      _profileImageUrl = userProvider.user!.profileURL;
    }
  }

  Future<void> _updateProfileImage() async {
    try {
      setState(() {
        _isUploading = true; // 업로드 시작
      });
      final XFile? pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );

      if (pickedImage == null) {
        setState(() {
          _isUploading = false;
        });
        return;
      }

      final File file = File(pickedImage.path);
      final ref = FirebaseStorage.instance.ref(
        'profile_images/${FirebaseAuth.instance.currentUser!.uid}',
      );
      await ref.putFile(file);

      final String downloadUrl = await ref.getDownloadURL();

      await FirebaseAuth.instance.currentUser?.updatePhotoURL(downloadUrl);

      setState(() {
        _profileImageUrl = downloadUrl;
        _isUploading = false; // 업로드 완료
      });
    } catch (e) {
      setState(() {
        _isUploading = false; // 에러 발생 시에도 false 로 변경
      });
      debugPrint('프로필 사진 변경 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('프로필 업데이트')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Spacer(),
              // CircleAvatar 내부에서만 로딩 인디케이터 표시
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!)
                        : AssetImage("lib/assets/person.png") as ImageProvider,
                  ),
                  if (_isUploading)
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                    ),
                ],
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: _updateProfileImage,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 160,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9800CB).withOpacity(0.65),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      "프로필 사진 변경",
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              Spacer(),
              TextField(
                controller: _nicknameController,
                decoration: const InputDecoration(labelText: '닉네임'),
              ),
              Spacer(),
              Spacer(),
              InkWell(
                onTap: () async {
                  AddModal(
                    context: context,
                    title: '프로필 설정',
                    description: '해당 정보로 프로필을 설정합니다.',
                    whiteButtonText: '취소',
                    purpleButtonText: '확인',
                    function: () async {
                      await userProvider.updateUserProfile(
                        _nicknameController.text,
                        _profileImageUrl ??
                            'https://firebasestorage.googleapis.com/v0/b/hiddengems-8371c.firebasestorage.app/o/profile_images%2Fdefaultprofile.png?alt=media&token=0452972f-e06b-46e3-9f92-1c1d05a5caf6',
                      );
                    },
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 330,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9800CB).withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      "프로필 설정",
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
