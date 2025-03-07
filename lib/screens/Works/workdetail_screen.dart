import 'package:flutter/material.dart';
import 'package:hidden_gems/models/works.dart';
import 'package:provider/provider.dart';
import 'package:hidden_gems/providers/work_provider.dart';
import 'package:hidden_gems/providers/user_provider.dart';
//import 'package:flutter/widgets.dart';

class WorkdetailScreen extends StatefulWidget {
  final Work work;

  const WorkdetailScreen({super.key, required this.work});

  @override
  _WorkdetailScreenState createState() => _WorkdetailScreenState();
}

class _WorkdetailScreenState extends State<WorkdetailScreen> {
  
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
    final likedWorks = userProvider.user?.likedWorks ?? [];
    bool isLiked = likedWorks.contains(widget.work.id);
    // final artist = Provider.of<UserProvider>(context, listen: false)
    //   .users
    //   .firstWhere((user) => user.id == widget.work.artistID, orElse: () => null);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.work.title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 작품 이미지
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                  image: widget.work.workPhotoURL.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(widget.work.workPhotoURL),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: widget.work.workPhotoURL.isEmpty
                    ? Text("작품 사진", style: TextStyle(color: Colors.black54))
                    : null,
              ),
              SizedBox(height: 10),

              // 좋아요 아이콘 및 개수
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: Colors.purple,
                    ),
                    onPressed: () {
                      _toggleLike(workProvider, userProvider, widget.work.id, isLiked);
                    },
                  ),
                  SizedBox(width: 5),
                  Text(
                    widget.work.likedUsers.length.toString(),
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  /*artist != null ? artist.nickName : */"알 수 없는 작가",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )
              ),
              SizedBox(height: 5),

              //작품 설명
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  widget.work.description,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
              SizedBox(height: 15),

              //최저가 
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      "최저가",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "₩${widget.work.minPrice.toString()}",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              
            ],
          ),
          
        ),
        
      ),
      bottomNavigationBar: Container(
          width: double.infinity,
          height: 50,
          padding: EdgeInsets.symmetric(vertical: 12),
          margin: EdgeInsets.only(bottom: 50, left: 16, right: 16),
          decoration: BoxDecoration(
            color: widget.work.doAuction ? Colors.purple : Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.work.doAuction ? "해당 경매 참여하기" : "경매가 아직 시작되지 않았습니다",
            style: TextStyle(color: widget.work.doAuction ? Colors.white : Colors.black,),
          ),
        ),
    );
  }
  void _toggleLike(WorkProvider workProvider, UserProvider userProvider, String workId, bool isLiked) {
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
    } else {
      updatedLikedWorks.add(workId); // 좋아요 추가
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
