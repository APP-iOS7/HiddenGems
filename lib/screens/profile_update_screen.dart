import 'package:flutter/material.dart';
import 'package:hidden_gems/providers/user_provider.dart';
import 'package:provider/provider.dart';

class ProfileUpdateScreen extends StatefulWidget {
  const ProfileUpdateScreen({super.key});

  @override
  State<ProfileUpdateScreen> createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _profileURLController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('프로필 업데이트')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(labelText: '닉네임'),
            ),
            TextField(
              controller: _profileURLController,
              decoration: const InputDecoration(labelText: '프로필 사진 URL'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await userProvider.updateUserProfile(
                  _nicknameController.text,
                  _profileURLController.text,
                );
                // 업데이트 후 다른 화면으로 이동하거나 메시지 출력 등 처리
              },
              child: const Text('프로필 업데이트'),
            ),
          ],
        ),
      ),
    );
  }
}
