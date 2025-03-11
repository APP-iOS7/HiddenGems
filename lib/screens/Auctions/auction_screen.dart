import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gems/models/auction_work.dart';
import 'package:hidden_gems/models/works.dart';
import 'package:hidden_gems/models/user.dart';
import 'package:hidden_gems/providers/work_provider.dart';
import 'package:hidden_gems/providers/user_provider.dart';
import 'package:hidden_gems/providers/auction_works_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';

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
  Timer? _auctionTimer;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _startAuctionTimer();
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
  void dispose() {
    _auctionTimer?.cancel();
    super.dispose();
  }

  void _startAuctionTimer() {
    _auctionTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      final auctionProvider =
          Provider.of<AuctionWorksProvider>(context, listen: false);
      final now = DateTime.now();

      if (widget.auctionWork.endDate.isBefore(now) &&
          !widget.auctionWork.auctionComplete) {
        _endAuction();
      }
      auctionProvider.checkAndEndExpiredAuctions();
    });
  }

  Future<void> _endAuction() async {
    final auctionProvider =
        Provider.of<AuctionWorksProvider>(context, listen: false);

    await auctionProvider.endAuction(widget.auctionWork.workId);
    Provider.of<WorkProvider>(context, listen: false)
        .updateWorkAuctionStatus(widget.auctionWork.workId, false);
    Provider.of<WorkProvider>(context, listen: false)
        .updateWorkSellingStatus(widget.auctionWork.workId, true);

    setState(() {
      widget.auctionWork.auctionComplete = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("경매가 자동 종료되었습니다.")),
    );
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
                                "경매 진행중",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            if (updatedAuction.auctionComplete)
                              Text(
                                "경매 종료됨",
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
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700),
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
                              FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(updatedAuction.lastBidderId)
                                    .get(),
                                builder: (context, snapshot) {
                                  if (!updatedAuction.auctionComplete) {
                                    return const SizedBox();
                                  }
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  }
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  }
                                  if (!snapshot.hasData ||
                                      snapshot.data!.data() == null) {
                                    return const Text('No data found');
                                  }

                                  final userData = snapshot.data!.data()
                                      as Map<String, dynamic>;
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 20),
                                        Text('낙찰자',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700)),
                                        SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Icon(Icons.person_outline,
                                                size: 16, color: Colors.blue),
                                            const SizedBox(width: 8),
                                            Text(
                                              userData['nickName'],
                                              style:
                                                  TextStyle(color: Colors.blue),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: () async {
                        try {
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
                            completeUserId: updatedAuction.lastBidderId!,
                            completePrice: updatedAuction.nowPrice,
                            address: '',
                            name: '',
                            phone: '',
                            deliverComplete: '배송지입력대기',
                            deliverRequest: '직접 입력',
                          );
                          await FirebaseFirestore.instance
                              .collection('auctionedWorks')
                              .doc(newId)
                              .set(auctionedWork.toMap(),
                                  SetOptions(merge: true));

                          await FirebaseFirestore.instance
                              .collection('auctionedWorks')
                              .doc(newId)
                              .set(auctionedWork.toMap(),
                                  SetOptions(merge: true));

                          DocumentReference auctionDocRef = FirebaseFirestore
                              .instance
                              .collection('auctionWorks')
                              .doc(updatedAuction.workId);

                          DocumentSnapshot auctionDoc =
                              await auctionDocRef.get();
                          if (auctionDoc.exists) {
                            await auctionDocRef.update({
                              'auctionComplete': true,
                              'completedAt': DateTime.now(),
                            });

                            await sendNotification(
                                auctionedWork.completeUserId,
                                '축하합니다! 경매에 낙찰되었습니다. 배송지를 입력해주세요',
                                '${updatedAuction.artistNickname}님의 ${updatedAuction.workTitle}');

                            Provider.of<AuctionWorksProvider>(context,
                                    listen: false)
                                .updateAuctionStatus(updatedAuction.workId);

                            await Provider.of<WorkProvider>(context,
                                    listen: false)
                                .updateWorkSellingStatus(
                                    updatedAuction.workId, false);

                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("경매가 성공적으로 종료되었습니다.")),
                            );
                          } else {
                            debugPrint(
                                "경매 종료 오류: 해당 workId (${updatedAuction.workId})를 찾을 수 없음");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("해당 경매를 찾을 수 없습니다.")),
                            );
                          }
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

  Future sendNotification(String bidder, String title, String message) async {
    final url = Uri.parse('https://api.onesignal.com/notifications?c=push');

    final payload = {
      'app_id': '8f8cdaab-a211-4b80-ae3d-d196988e6a78',
      'contents': {'en': title},
      'headings': {'en': message},
      'include_aliases': {
        'external_id': [bidder]
      },
      'target_channel': 'push',
    };

    var headers = {
      'accept': "application/json",
      'Authorization':
          'Key os_v2_app_r6gnvk5ccffyblr52gljrdtkpdacftqxzvxu3v4g4s2zbvag5ffqoq3i2lcqn2nyhujwcsqd64bfqwthmi6oiefdhtjbrw2ezrl4jra',
      'content-type': 'application/json',
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        debugPrint('Notification sent successfully');
        debugPrint(response.body);
      } else {
        debugPrint('Failed to send notification');
        debugPrint('Status code: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }
}
