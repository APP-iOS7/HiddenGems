import 'package:flutter/material.dart';
import 'package:hidden_gems/models/works.dart';
import 'package:hidden_gems/models/auction_work.dart';
import 'package:provider/provider.dart';
import 'package:hidden_gems/providers/work_provider.dart';
import 'package:hidden_gems/providers/user_provider.dart';
import 'package:hidden_gems/providers/auction_works_provider.dart';
//import 'package:flutter/widgets.dart';

class WorkdetailScreen extends StatefulWidget {
  final Work work;

  const WorkdetailScreen({super.key, required this.work});

  @override
  WorkdetailScreenState createState() => WorkdetailScreenState();
}

class WorkdetailScreenState extends State<WorkdetailScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<WorkProvider>(context, listen: false).loadWorks();
    Provider.of<UserProvider>(context, listen: false).loadUser();
    Provider.of<AuctionWorksProvider>(context, listen: false).fetchAllAuctionWorks();
  }

  @override
  Widget build(BuildContext context) {
    final workProvider = Provider.of<WorkProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final likedWorks = userProvider.user?.likedWorks ?? [];
    bool isLiked = likedWorks.contains(widget.work.id);
    final updatedWork = workProvider.works.firstWhere(
      (w) => w.id == widget.work.id,
      orElse: () => widget.work,
    );

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            updatedWork.title,
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
                    image: updatedWork.workPhotoURL.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(updatedWork.workPhotoURL),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: updatedWork.workPhotoURL.isEmpty
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
                        _toggleLike(workProvider, userProvider, updatedWork.id,
                            isLiked);
                      },
                    ),
                    SizedBox(width: 5),
                    Text(
                      updatedWork.likedUsers.length.toString(),
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      updatedWork.artistNickName,
                      // /*artist != null ? artist.nickName : */ "알 수 없는 작가",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    )),
                SizedBox(height: 5),

                //작품 설명
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    updatedWork.description,
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
                        "₩${updatedWork.minPrice.toString()}",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
        bottomNavigationBar: GestureDetector(
          onTap: () {
            if (updatedWork.artistID == userProvider.user?.id) {
              if (!updatedWork.doAuction) {
                _startAuctionModal(context);
              }
            } else {
              if (updatedWork.doAuction) {
                _showAuctionModal(context);
              }
            }
          },
          child: Container(
            width: double.infinity,
            height: 50,
            padding: EdgeInsets.symmetric(vertical: 12),
            margin: EdgeInsets.only(bottom: 50, left: 16, right: 16),
            decoration: BoxDecoration(
              color: updatedWork.artistID == userProvider.user?.id
                  ? updatedWork.doAuction
                      ? Colors.grey[300]
                      : Colors.purple
                  : updatedWork.doAuction
                      ? Colors.purple
                      : Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              updatedWork.artistID == userProvider.user?.id
                  ? updatedWork.doAuction
                      ? "경매가 이미 시작되었습니다"
                      : "경매 시작하기"
                  : updatedWork.doAuction
                      ? "해당 경매 참여하기"
                      : "경매가 아직 시작되지 않았습니다",
              style: TextStyle(
                color: updatedWork.artistID == userProvider.user?.id
                    ? updatedWork.doAuction
                        ? Colors.black
                        : Colors.white
                    : updatedWork.doAuction
                        ? Colors.white
                        : Colors.black,
              ),
            ),
          ),
        ));
  }

  void _startAuctionModal(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              Text(
                "경매 시작",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                "이 작품의 경매를 시작하시겠습니까?",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.purple),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Text("취소", style: TextStyle(color: Colors.purple)),
                    ),
                  ),
                  SizedBox(width: 16),
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      onPressed: () async {
                        final auctionProvider =
                            Provider.of<AuctionWorksProvider>(context, listen: false);

                        final auctionWork = AuctionWork(
                          workId: widget.work.id,
                          workTitle: widget.work.title,
                          artistId: widget.work.artistID,
                          auctionUserId: [],
                          minPrice: widget.work.minPrice.toInt(),
                          endDate: DateTime.now().add(Duration(days: 7)),
                          nowPrice: widget.work.minPrice.toInt(),
                          auctionComplete: false,
                        );

                        await auctionProvider.addAuctionWork(auctionWork);

                        Provider.of<WorkProvider>(context, listen: false)
                            .updateWorkAuctionStatus(widget.work.id, true);

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("경매가 시작되었습니다!")),
                        );

                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Text("시작하기"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }


  void _toggleLike(WorkProvider workProvider, UserProvider userProvider,
      String workId, bool isLiked) {
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

  void _showAuctionModal(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              Text(
                "경매 참여 권한을 얻으셨습니다.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                "해당 경매 페이지로 이동하시겠습니까?",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.purple),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child:
                          Text("돌아가기", style: TextStyle(color: Colors.purple)),
                    ),
                  ),
                  SizedBox(width: 16),
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // 여기에 경매 페이지 이동 로직 추가
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Text("확인"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
