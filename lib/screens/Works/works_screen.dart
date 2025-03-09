import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hidden_gems/providers/work_provider.dart';
import 'package:hidden_gems/providers/user_provider.dart';

import 'workdetail_screen.dart';

class WorkScreen extends StatefulWidget {
  const WorkScreen({super.key});

  @override
  WorkScreenState createState() => WorkScreenState();
}

class WorkScreenState extends State<WorkScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  bool _showSelling = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Provider.of<WorkProvider>(context, listen: false).loadWorks();
    Provider.of<UserProvider>(context, listen: false).loadUser();
  }

  @override
  Widget build(BuildContext context) {
    final workProvider = Provider.of<WorkProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final works = workProvider.works;

    final likedWorks = userProvider.user?.likedWorks ?? [];

    final filteredWorks = works
      .where((work) =>
          work.title.toLowerCase().contains(_searchQuery.toLowerCase()) && (!_showSelling || work.selling == false))
      .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
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
                  hintText: "작품 검색",
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("판매 중인 작품만 보기", style: TextStyle(fontSize: 16)),
                Switch(
                  value: _showSelling,
                  onChanged: (value) {
                    setState(() {
                      _showSelling = value;
                    });
                  },
                ),
              ],
            ),
          ),
          
          Expanded(
            child: filteredWorks.isEmpty
                ? Center(
                    child: Text('작품이 없습니다.', style: TextStyle(fontSize: 18)),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: filteredWorks.length,
                      itemBuilder: (context, index) {
                        final work = filteredWorks[index];
                        bool isLiked = likedWorks.contains(work.id);

                        return GestureDetector(
                          onTap: () {
                            //debugPrint("Navigating to WorkdetailScreen with work: ${work.title}");
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      WorkdetailScreen(work: work),
                                ));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: NetworkImage(
                                  work.workPhotoURL.isNotEmpty
                                      ? work.workPhotoURL
                                      : 'https://picsum.photos/200/300', // 기본 이미지 대체
                                ),
                                fit: BoxFit.cover, // 이미지를 꽉 차게 표시
                              ),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Text(
                                    work.title,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  left: 8,
                                  child: IconButton(
                                    icon: Icon(
                                      isLiked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: Colors.purple,
                                    ),
                                    onPressed: () {
                                      _toggleLike(workProvider, userProvider,
                                          work.id, work.artistID, isLiked);
                                    },
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
