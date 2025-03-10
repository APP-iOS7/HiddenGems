import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gems/models/auction_work.dart';
import 'package:hidden_gems/models/works.dart';
import 'package:hidden_gems/models/user.dart';
import 'package:hidden_gems/providers/work_provider.dart';
import 'package:hidden_gems/providers/user_provider.dart';
import 'package:hidden_gems/providers/auction_works_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/auctioned_work.dart';

class AuctionScreen extends StatefulWidget {
  final AuctionWork auctionWork;

  const AuctionScreen({super.key, required this.auctionWork});

  @override
  AuctionScreenState createState() => AuctionScreenState();
}

class AuctionScreenState extends State<AuctionScreen> {
  Future<Work?> _fetchWork() async {
    final workProvider = Provider.of<WorkProvider>(context, listen: false);
    return await workProvider.getWorkById(widget.auctionWork.workId);
  }

  Future<String> _fetchArtistNickname(String artistId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(artistId)
          .get();
      if (userDoc.exists) {
        return userDoc['nickName'] ?? '알 수 없는 작가';
      }
    } catch (e) {
      debugPrint('작가 닉네임을 가져오는 중 오류 발생: $e');
    }
    return '알 수 없는 작가';
  }

  List<AppUser> _allUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();

      setState(() {
        _allUsers = snapshot.docs
            .map((doc) => AppUser.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      debugPrint('Error fetching users: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final auctionProvider = Provider.of<AuctionWorksProvider>(context);
    final updatedAuction = auctionProvider.allAuctionWorks.firstWhere(
      (w) => w.workId == widget.auctionWork.workId,
      orElse: () => widget.auctionWork,
    );
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(updatedAuction.workTitle)),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<Work?>(
            future: _fetchWork(),
            builder: (context, workSnapshot) {
              if (workSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final work = workSnapshot.data;

              return FutureBuilder<String>(
                future: _fetchArtistNickname(updatedAuction.artistId),
                builder: (context, artistSnapshot) {
                  if (artistSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final artistNickname = artistSnapshot.data ?? '알 수 없는 작가';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                          image: work?.workPhotoURL != null &&
                                  work!.workPhotoURL.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(work.workPhotoURL),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        alignment: Alignment.center,
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              artistNickname,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            if (!updatedAuction.auctionComplete)
                              Text(
                                "경매진행중",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),

                      //작품 설명
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          work?.description ?? "설명 없음",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Text(
                              "최저가",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black54),
                            ),
                            SizedBox(width: 10),
                            Text(
                              '${NumberFormat('#,###').format(updatedAuction.minPrice)}원',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Text(
                              "현재가",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black54),
                            ),
                            SizedBox(width: 10),
                            Text(
                              '${NumberFormat('#,###').format(updatedAuction.nowPrice)}원',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Text(
                              "마감일",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black54),
                            ),
                            SizedBox(width: 10),
                            Text(
                              DateFormat('yyyy-MM-dd HH:mm')
                                  .format(updatedAuction.endDate),
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                          ],
                        ),
                      ),
                      if (updatedAuction.auctionUserId.isNotEmpty) ...[
                        const Divider(height: 30),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '입찰자 목록',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 8),
                              ...updatedAuction.auctionUserId.map((bidderId) {
                                final bidder = _allUsers.firstWhere(
                                  (user) => user.id == bidderId,
                                  orElse: () => AppUser(
                                    id: '',
                                    signupDate: DateTime(2000, 1, 1),
                                    profileURL: '',
                                    nickName: '알 수 없는 사용자',
                                    myLikeScore: 0,
                                    myWorks: [],
                                    myWorksCount: 0,
                                    likedWorks: [],
                                    biddingWorks: [],
                                    beDeliveryWorks: [],
                                    completeWorks: [],
                                    subscribeUsers: [],
                                  ),
                                );
                                bool isLastBidder =
                                    bidder.id == updatedAuction.lastBidderId;

                                return SingleChildScrollView(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(left: 16, top: 4),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.person_outline,
                                          size: 16,
                                          color: isLastBidder
                                              ? Colors.blue
                                              : Colors.black,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(bidder.nickName,
                                            style: TextStyle(
                                              color: isLastBidder
                                                  ? Colors.blue
                                                  : Colors.black,
                                            )),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        )
                      ]
                    ],
                  );
                },
              );
            },
          ),
        ),
        bottomNavigationBar: GestureDetector(
          onTap: () {
            if (updatedAuction.artistId == userProvider.user?.id) {
              if (!updatedAuction.auctionComplete) {
                _endAuctionModal(
                    context, updatedAuction, userProvider.user!.id); //경매 종료하기
              }
            } else {
              bool isBidder =
                  updatedAuction.auctionUserId.contains(userProvider.user?.id);
              if (!isBidder) {
                _joinAuction(context); // 경매 참여하기
              } else {
                _showAuctionModal(context); // 가격 제시하기
              }
            }
          },
          child: Container(
            width: double.infinity,
            height: 50,
            padding: EdgeInsets.symmetric(vertical: 12),
            margin: EdgeInsets.only(bottom: 50, left: 16, right: 16),
            decoration: BoxDecoration(
              color: updatedAuction.artistId == userProvider.user?.id
                  ? updatedAuction.auctionComplete
                      ? Colors.grey[300]
                      : Colors.purple
                  : Colors.purple,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              updatedAuction.artistId == userProvider.user?.id
                  ? updatedAuction.auctionComplete
                      ? "해당 경매는 종료되었습니다."
                      : "경매 종료하기"
                  : updatedAuction.auctionUserId.contains(userProvider.user?.id)
                      ? "가격 제시하기"
                      : "경매 참여하기",
              style: TextStyle(
                  color: updatedAuction.artistId == userProvider.user?.id
                      ? updatedAuction.auctionComplete
                          ? Colors.black
                          : Colors.white
                      : Colors.white),
            ),
          ),
        ));
  }

  void _endAuctionModal(
      BuildContext context, AuctionWork updatedAuction, String userId) {
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
                "경매 종료",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                "해당 경매를 종료하시겠습니까?",
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
                        try {
                          // 입찰자가 없는 경우 경매 종료 불가
                          if (updatedAuction.lastBidderId == null ||
                              updatedAuction.lastBidderId!.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text("입찰자가 없어 경매를 종료할 수 없습니다.")),
                            );
                            return;
                          }
                          // Firestore에 저장할 새로운 ID 생성
                          String newId = FirebaseFirestore.instance
                              .collection('auctionedWorks')
                              .doc()
                              .id;

                          debugPrint('종료되는 경매 정보: $updatedAuction');
                          AuctionedWork auctionedWork = AuctionedWork(
                            id: newId,
                            workId: updatedAuction.workId,
                            workTitle: updatedAuction.workTitle,
                            artistId: updatedAuction.artistId,
                            artistNickname: updatedAuction.artistNickname,
                            completeUserId:
                                updatedAuction.lastBidderId!, // null 검사 통과 확인됨
                            completePrice: updatedAuction.nowPrice, // int 변환 확인
                            address: '', // null 허용 필드는 빈 값으로 초기화
                            name: '',
                            phone: '',
                            deliverComplete: '배송지 입력',
                            deliverRequest: '직접 입력',
                          );
                          // Firestore에 저장
                          await FirebaseFirestore.instance
                              .collection('auctionedWorks')
                              .doc(newId)
                              .set(auctionedWork.toMap(),
                                  SetOptions(merge: true));

                          await FirebaseFirestore.instance
                              .collection('works')
                              .doc(updatedAuction.workId)
                              .update({
                            'auctionComplete': true,
                            'completedAt': DateTime.now(), // Firestore에서 자동 변환됨
                          });
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("경매가 성공적으로 종료되었습니다.")),
                          );
                        } catch (e) {
                          debugPrint("경매 종료 오류: $e");
                        }
                      },
                      child: Text("확인"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _joinAuction(BuildContext context) {
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
                "경매 참여",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                "이 경매에 참여하시겠습니까?",
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
                        final userProvider =
                            Provider.of<UserProvider>(context, listen: false);
                        final auctionProvider =
                            Provider.of<AuctionWorksProvider>(context,
                                listen: false);

                        // 입찰자 목록에 추가
                        List<String> updatedBidders =
                            List.from(widget.auctionWork.auctionUserId);
                        updatedBidders.add(userProvider.user!.id);

                        await auctionProvider.updateAuctionBidders(
                            widget.auctionWork.workId, updatedBidders);

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("경매에 참여하였습니다!")),
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
                      child: Text("참여하기"),
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

  void _showAuctionModal(BuildContext context) {
    TextEditingController _priceController = TextEditingController();
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
                '현재가: ${NumberFormat('#,###').format(widget.auctionWork.nowPrice)}원',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "가격을 제시해주세요",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
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
                        String enteredPrice = _priceController.text;
                        if (enteredPrice.isNotEmpty) {
                          int newPrice = int.tryParse(enteredPrice) ?? 0;
                          if (newPrice > widget.auctionWork.nowPrice) {
                            final userProvider = Provider.of<UserProvider>(
                                context,
                                listen: false);
                            String currentUserId = userProvider.user!.id;
                            final auctionProvider =
                                Provider.of<AuctionWorksProvider>(context,
                                    listen: false);
                            await auctionProvider.updateNowprice(
                                widget.auctionWork.workId, newPrice);
                            await auctionProvider.updateLastBidder(
                                widget.auctionWork.workId, currentUserId);

                            setState(() {
                              widget.auctionWork.nowPrice = newPrice;
                              widget.auctionWork.lastBidderId = currentUserId;
                            });
                            Navigator.pop(context);
                          }
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
                      child: Text("제시"),
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
