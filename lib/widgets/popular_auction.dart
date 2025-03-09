import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gems/models/user.dart';

class PopularAuction extends StatefulWidget {
  const PopularAuction({super.key});

  @override
  State<PopularAuction> createState() => _PopularAuctionState();
}

class _PopularAuctionState extends State<PopularAuction> {
  Future<List<AppUser>> getFamousSortedUser() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('myWorksCount', isGreaterThan: 0)
          .orderBy('myWorksCount', descending: true) // where 절과 일치하는 orderBy 추가
          .orderBy('myLikeScore', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AppUser.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching famous users: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AppUser>>(
        future: getFamousSortedUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading users'));
          }
          final users = snapshot.data ?? [];

          return Column(
            children: [
              SizedBox(
                height: 100,
                child: CustomScrollView(
                  scrollDirection: Axis.horizontal,
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          if (index >= users.length) return SizedBox.shrink();
                          final user = users[index];

                          return Padding(
                            padding: EdgeInsets.only(
                              right: 16.0,
                              left: index == 0 ? 0.0 : 0.0,
                            ),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.grey[300],
                                  backgroundImage: user.profileURL.isNotEmpty
                                      ? NetworkImage(user.profileURL)
                                      : null,
                                  child: user.profileURL.isEmpty
                                      ? Text(
                                          '${index + 1}',
                                          style: TextStyle(color: Colors.black),
                                        )
                                      : null,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  user.nickName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        childCount: 20,
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
        });
  }
}
