import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/user.dart';
import 'artist_detail_screen.dart';

class ArtistScreen extends StatefulWidget {
  const ArtistScreen({super.key});

  @override
  ArtistScreenState createState() => ArtistScreenState();
}

class ArtistScreenState extends State<ArtistScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  late Future<List<AppUser>> _futureUsers;

  @override
  void initState() {
    super.initState();
    _futureUsers = getActiveUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<AppUser>> getActiveUsers() async {
    List<AppUser> activeUsers = [];

    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();

      activeUsers = snapshot.docs
          .map((doc) => AppUser.fromMap(doc.data() as Map<String, dynamic>))
          .where((user) => user.myWorks.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('Error fetching active users: $e');
    }
    return activeUsers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          '작가',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<List<AppUser>>(
        future: _futureUsers, // Firestore에서 직접 데이터 가져오기
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다.'));
          }
          final activeUsers = snapshot.data ?? [];
          if (activeUsers.isEmpty) {
            return const Center(child: Text('활성화된 작가가 없습니다.'));
          }
          final filteredUsers = activeUsers
              .where((user) => user.nickName
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 25.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search,
                          color: const Color.fromARGB(255, 105, 105, 105)),
                      hintText: "작가 검색",
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Color.fromRGBO(223, 223, 229, 1),
                      contentPadding: EdgeInsets.symmetric(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: filteredUsers.length,
                    itemBuilder: (BuildContext context, int index) {
                      final user = filteredUsers[index];
                      final worksCount = user.myWorks.length;
                      final likesCount = user.likedWorks.length;

                      return GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${user.nickName}의 프로필'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
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
                                backgroundImage: NetworkImage(user.profileURL),
                                backgroundColor: Colors.grey[200],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                user.nickName,
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
                                  _buildStatItem(
                                      Icons.palette, '$worksCount 작품'),
                                  const SizedBox(width: 12),
                                  _buildStatItem(
                                      Icons.favorite, '$likesCount 좋아요'),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${DateFormat('yyyy.MM.dd').format(user.signupDate)} 가입',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
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
