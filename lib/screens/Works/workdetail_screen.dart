import 'package:flutter/material.dart';
import 'package:hidden_gems/modal.dart';
import 'package:hidden_gems/models/works.dart';
import 'package:hidden_gems/models/auction_work.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hidden_gems/providers/work_provider.dart';
import 'package:hidden_gems/providers/user_provider.dart';
import 'package:hidden_gems/providers/auction_works_provider.dart';
import 'package:hidden_gems/screens/Auctions/auction_screen.dart';
import 'package:hidden_gems/screens/Works/editwork_screen.dart';
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
    Provider.of<AuctionWorksProvider>(context, listen: false)
        .fetchAllAuctionWorks();
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
    final auctionProvider =
        Provider.of<AuctionWorksProvider>(context, listen: false);
    final auctionWork = auctionProvider.allAuctionWorks.firstWhere(
      (auction) => auction.workId == widget.work.id,
      orElse: () => AuctionWork(
          workId: '',
          workTitle: '알 수 없는 경매',
          artistId: '',
          auctionUserId: [],
          minPrice: 0,
          nowPrice: 0,
          endDate: DateTime.now(),
          auctionComplete: true,
          artistNickname: 'unknown'),
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
            actions: [
              if (updatedWork.artistID == userProvider.user?.id)
                Theme(
                  data: Theme.of(context).copyWith(
                    cardColor: Colors.white,
                  ),
                  child: PopupMenuButton<String>(
                    onSelected: (String result) async {
                      if (result == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditWorkScreen(work: updatedWork),
                          ),
                        );
                      } else if (result == 'delete') {
                        await AddModal(
                          context: context,
                          title: '작품 삭제',
                          description: '해당 작품의 경매 내역까지 삭제됩니다.\n삭제하시겠습니까?',
                          whiteButtonText: '취소',
                          purpleButtonText: '삭제',
                          function: () async {
                            await userProvider.deleteMyWorks(updatedWork.id);
                            await workProvider.deleteWork(updatedWork.id);
                            await auctionProvider
                                .deleteAuctionWork(updatedWork.id);
                            await workProvider.loadWorks();
                            Navigator.pop(context);
                          },
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.black),
                            SizedBox(width: 8),
                            Text('수정'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('삭제'),
                          ],
                        ),
                      ),
                    ],
                    icon: Icon(Icons.more_vert), // 드롭다운 버튼 아이콘
                  ),
                )
            ]),
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
                            updatedWork.artistID, isLiked);
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
                        "${NumberFormat('###,###,###,###').format(updatedWork.minPrice)} 원",
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
                if (auctionWork.auctionUserId.contains(userProvider.user?.id)) {
                  _showAuctionModal(context);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AuctionScreen(auctionWork: auctionWork),
                    ),
                  );
                }
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
                      ? auctionWork.auctionUserId
                              .contains(userProvider.user?.id)
                          ? "해당 경매 참여하기"
                          : "경매 페이지로 이동하기"
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

  void _showDeleteConfirmationDialog(
      BuildContext context2,
      UserProvider userProvider,
      WorkProvider workProvider,
      AuctionWorksProvider auctionProvider,
      String workId) {
    showDialog(
      context: context2,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("작품 삭제"),
          content: Text("해당 작품의 경매 내역까지 삭제됩니다. 삭제하시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("취소", style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                await userProvider.deleteMyWorks(workId);
                await workProvider.deleteWork(workId);
                await auctionProvider.deleteAuctionWork(workId);
                await workProvider.loadWorks();

                Navigator.pop(context2);
              },
              child: Text("삭제", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _startAuctionModal(BuildContext context) {
    DateTime selectedDate = DateTime.now().add(Duration(days: 7));
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                      Text(
                        "마감일: ${DateFormat('yyyy-MM-dd HH:mm').format(selectedDate)}",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(width: 10),
                      IconButton(
                        icon: Icon(Icons.calendar_today, color: Colors.purple),
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now()
                                .add(Duration(days: 30)), // 최대 30일 후까지 선택 가능
                          );
                          if (pickedDate != null) {
                            setModalState(() {
                              selectedDate = pickedDate; // 선택한 날짜 반영
                            });
                          }
                        },
                      ),
                    ],
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
                          child: Text("취소",
                              style: TextStyle(color: Colors.purple)),
                        ),
                      ),
                      SizedBox(width: 16),
                      SizedBox(
                        width: 120,
                        child: ElevatedButton(
                          onPressed: () async {
                            final auctionProvider =
                                Provider.of<AuctionWorksProvider>(context,
                                    listen: false);

                            final auctionWork = AuctionWork(
                              workId: widget.work.id,
                              workTitle: widget.work.title,
                              artistId: widget.work.artistID,
                              artistNickname: widget.work.artistNickName,
                              auctionUserId: [],
                              minPrice: widget.work.minPrice.toInt(),
                              endDate: DateTime.now().add(Duration(days: 7)),
                              nowPrice: widget.work.minPrice.toInt(),
                              auctionComplete: false,
                              lastBidderId: null,
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
      },
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
    } else {
      updatedLikedWorks.add(workId); // 좋아요 추가
    }

    userProvider.updateUserLikedWorks(updatedLikedWorks);

    final work = workProvider.works.firstWhere((w) => w.id == workId);
    List<String> updatedLikedUsers = List.from(work.likedUsers);
    if (isLiked) {
      updatedLikedUsers.remove(userId);
      userProvider.subMyLikeScore(artistId);
    } else {
      updatedLikedUsers.add(userId);
      userProvider.addMyLikeScore(artistId);
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
                        final auctionProvider =
                            Provider.of<AuctionWorksProvider>(context,
                                listen: false);

                        // 해당 작품 ID를 경매의 workId로 가지고 있는 auctionWork 찾기
                        final auctionWork =
                            auctionProvider.allAuctionWorks.firstWhere(
                          (auction) => auction.workId == widget.work.id,
                          orElse: () => AuctionWork(
                            workId: '',
                            workTitle: '알 수 없는 경매',
                            artistId: '',
                            auctionUserId: [],
                            minPrice: 0,
                            nowPrice: 0,
                            endDate: DateTime.now(),
                            auctionComplete: true,
                            artistNickname: 'unknown',
                          ),
                        );

                        Navigator.pop(context);

                        // AuctionWork가 유효한 경우에만 이동
                        if (auctionWork.workId.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AuctionScreen(
                                auctionWork: auctionWork,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("해당 작품의 경매 정보를 찾을 수 없습니다.")),
                          );
                        }
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
