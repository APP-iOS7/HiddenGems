import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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
      final XFile? pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );

      if (pickedImage == null) {
        return;
      }

      // 파일 업로드
      final File file = File(pickedImage.path);
      final ref = FirebaseStorage.instance.ref(
        'profile_images/${FirebaseAuth.instance.currentUser!.uid}',
      );
      await ref.putFile(file);

      // 다운로드 URL 업데이트
      final String downloadUrl = await ref.getDownloadURL();

      // 사용자 프로필 업데이트
      await FirebaseAuth.instance.currentUser?.updatePhotoURL(downloadUrl);

      setState(() {
        _profileImageUrl = downloadUrl;
      });
    } catch (e) {
      debugPrint('프로필 사진 변경 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('프로필 업데이트')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Spacer(),
            CircleAvatar(
              radius: 50,
              backgroundImage: _profileImageUrl != null
                  ? NetworkImage(_profileImageUrl!)
                  : AssetImage("lib/assets/person.png"),
            ),
            SizedBox(height: 20),
            MaterialButton(
              color: Theme.of(context).colorScheme.primary,
              textColor: Colors.white,
              minWidth: 160,
              onPressed: _updateProfileImage,
              child: const Text('프로필 사진 변경'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(labelText: '닉네임'),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () async {
                await userProvider.updateUserProfile(
                  _nicknameController.text,
                  _profileImageUrl!,
                );
                // 업데이트 후 다른 화면으로 이동하거나 메시지 출력 등 처리
              },
              child: const Text('프로필 업데이트'),
            ),
            Spacer()
          ],
        ),
      ),
    );
  }
}
