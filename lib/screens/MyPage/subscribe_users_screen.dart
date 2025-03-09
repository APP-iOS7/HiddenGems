import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gems/models/user.dart';
import 'package:hidden_gems/providers/user_provider.dart';
import 'package:hidden_gems/screens/Artist/artist_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SubscribeUsersScreen extends StatelessWidget {
  const SubscribeUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('구독한 작가'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: userProvider.user!.subscribeUsers.length,
                itemBuilder: (BuildContext context, int index) {
                  final user = userProvider.user!.subscribeUsers[index];
                  return FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(user)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return Text("오류 발생");
                        }
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return Text("문서가 존재하지 않습니다.");
                        }
                        Map<String, dynamic> data =
                            snapshot.data!.data() as Map<String, dynamic>;
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ArtistDetailScreen(
                                        user: AppUser.fromMap(data))));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                width: 1,
                                color: const Color(0xB2B2B2B2),
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage:
                                      NetworkImage(data['profileURL']),
                                  backgroundColor: Colors.grey[200],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  data['nickName'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildStatItem(Icons.palette,
                                        '${data['myWokrsCount']} 작품'),
                                    const SizedBox(width: 12),
                                    _buildStatItem(Icons.favorite,
                                        '${data['myLikeScore'].toInt()} 좋아요'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${DateFormat('yyyy-MM-dd').format(DateTime.parse(data['signupDate']))} 가입',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
