import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gems/models/works.dart';
import 'package:hidden_gems/providers/user_provider.dart';
import 'package:hidden_gems/providers/work_provider.dart';
import 'package:hidden_gems/screens/Works/workdetail_screen.dart';
import 'package:provider/provider.dart';

class MyWorksScreen extends StatefulWidget {
  const MyWorksScreen({super.key});

  @override
  _MyWorksScreenState createState() => _MyWorksScreenState();
}

class _MyWorksScreenState extends State<MyWorksScreen> {
  late Future<List<String>> _myWorksFuture;

  @override
  void initState() {
    super.initState();
    _fetchMyWorks();
  }

  void _fetchMyWorks() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    setState(() {
      _myWorksFuture = myWorksIds(userProvider.user!.id);
    });
  }

  Future<List<String>> myWorksIds(String userId) async {
    final firestore = FirebaseFirestore.instance;
    DocumentSnapshot userDoc =
        await firestore.collection('users').doc(userId).get();

    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      List<String> myWorksIds = List<String>.from(userData['myWorks'] ?? []);
      return myWorksIds;
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<UserProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final workProvider = Provider.of<WorkProvider>(context);

    final likedWorks = userProvider.user?.likedWorks ?? [];


    return Scaffold(
      appBar: AppBar(
        title: const Text('내가 등록한 작품'),
      ),
      body: FutureBuilder<List<String>>(
        future: _myWorksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('오류가 발생했습니다.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('등록한 작품이 없습니다.', style: TextStyle(fontSize: 18)));
          } else {
            var myWorksIds = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: myWorksIds.length,
                itemBuilder: (context, index) {
                  final workId = myWorksIds[index];

                  // 각 workId에 대해 Firestore에서 작업 상세 정보를 가져옴
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('works')
                        .doc(workId)
                        .get(),
                    builder: (context, workSnapshot) {
                      if (workSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (workSnapshot.hasError ||
                          !workSnapshot.hasData ||
                          !workSnapshot.data!.exists) {
                        return const Center(child: Text('오류가 발생했습니다.'));
                      }

                      // Firestore 문서를 Work 객체로 변환
                      final work = Work.fromFirestore(workSnapshot.data!);
                      bool isLiked = likedWorks.contains(work.id);

                      return GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  WorkdetailScreen(work: work),
                            ),
                          );

                          _fetchMyWorks();
                        },
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        work.workPhotoURL.isNotEmpty
                                            ? work.workPhotoURL
                                            : 'https://picsum.photos/200/300',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),


                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isLiked ? Icons.favorite : Icons.favorite_border,
                                      color: Colors.purple,
                                    ),
                                    onPressed: () {
                                      _toggleLike(workProvider, userProvider,
                                          work.id, work.artistID, isLiked);
                                    },
                                  ),
                                  Expanded(
                                    child: Text(
                                      work.title,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                      );
                    },
                    
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
  void _toggleLike(WorkProvider workProvider, UserProvider userProvider,
      String workId, String artistId, bool isLiked) {
    final currentUser = userProvider.user;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("로그인된 사용자 정보가 없습니다.")),
      );
      return;
    }
    final userId = currentUser.id;
    List<String> updatedLikedWorks = List.from(currentUser.likedWorks);
    if (isLiked) {
      updatedLikedWorks.remove(workId); // 이미 좋아요한 경우 제거
      userProvider.subMyLikeScore(artistId);
    } else {
      updatedLikedWorks.add(workId); // 좋아요 추가
      userProvider.addMyLikeScore(artistId);
    }

    userProvider.updateUserLikedWorks(updatedLikedWorks);

    final work = workProvider.works.firstWhere((w) => w.id == workId);
    List<String> updatedLikedUsers = List.from(work.likedUsers);
    if (isLiked) {
      updatedLikedUsers.remove(userId);
    } else {
      updatedLikedUsers.add(userId);
    }

    workProvider.updateWorkLikedUsers(workId, updatedLikedUsers);
  }
}
