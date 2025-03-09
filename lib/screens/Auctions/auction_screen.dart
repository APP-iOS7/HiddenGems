import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gems/models/auction_work.dart';
import 'package:hidden_gems/models/works.dart';
import 'package:hidden_gems/models/user.dart';
import 'package:hidden_gems/providers/work_provider.dart';
import 'package:hidden_gems/providers/user_provider.dart';
import 'package:provider/provider.dart';

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
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(artistId).get();
      if (userDoc.exists) {
        return userDoc['nickName'] ?? '알 수 없는 작가';
      }
    } catch (e) {
      debugPrint('작가 닉네임을 가져오는 중 오류 발생: $e');
    }
    return '알 수 없는 작가';
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.auctionWork.workTitle)
        ),
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
              future: _fetchArtistNickname(widget.auctionWork.artistId),
              builder: (context, artistSnapshot) {
                if (artistSnapshot.connectionState == ConnectionState.waiting) {
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
                        image: work?.workPhotoURL != null && work!.workPhotoURL!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(work.workPhotoURL),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: work?.workPhotoURL != null && work!.workPhotoURL!.isNotEmpty
                          ? Text("작품 사진", style: TextStyle(color: Colors.black54))
                          : null,
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        artistNickname,
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      )),
                    SizedBox(height: 5),

                    //작품 설명
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        work?.description ?? "설명 없음",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ),
                    SizedBox(height: 15),
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
                            "₩${widget.auctionWork.minPrice.toString()}",
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
                            "현재가",
                            style: TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                          SizedBox(width: 10),
                          Text(
                            "₩${widget.auctionWork.nowPrice.toString()}",
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
                            style: TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                          SizedBox(width: 10),
                          Text(
                            "${widget.auctionWork.endDate}",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: GestureDetector(
          onTap: () {
            if (widget.auctionWork.artistId == userProvider.user?.id) {
              if (!widget.auctionWork.auctionComplete) {
                _endAuctionModal(context);
              }
            } else {
              if (widget.auctionWork.auctionComplete) {
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
              color: widget.auctionWork.artistId == userProvider.user?.id
                  ? widget.auctionWork.auctionComplete
                      ? Colors.grey[300]
                      : Colors.purple
                  : Colors.purple,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              widget.auctionWork.artistId == userProvider.user?.id
                  ? widget.auctionWork.auctionComplete
                      ? "해당 경매는 종료되었습니다."
                      : "경매 종료하기"
                  : "가격 제시하기",
              style: TextStyle(
                color: widget.auctionWork.artistId == userProvider.user?.id
                    ? widget.auctionWork.auctionComplete
                        ? Colors.black
                        : Colors.white
                    : Colors.white,
              ),
            ),
          ),
        )
    );
  }
  void _endAuctionModal(BuildContext context) {
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
                      child: Text("종료하기"),
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
                "현재가 ₩12345678",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                "가격을 제시해주세요",
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
                          Text("취소", style: TextStyle(color: Colors.purple)),
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
