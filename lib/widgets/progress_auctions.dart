import 'package:flutter/material.dart';
import 'package:hidden_gems/models/auction_work.dart';
import 'package:hidden_gems/models/works.dart';
import 'package:hidden_gems/providers/auction_works_provider.dart';
import 'package:hidden_gems/providers/work_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:hidden_gems/screens/Auctions/auction_screen.dart'; // AuctionScreen 임포트

class ProgressAuctions extends StatefulWidget {
  const ProgressAuctions({super.key});

  @override
  ProgressAuctionsState createState() => ProgressAuctionsState();
}

class ProgressAuctionsState extends State<ProgressAuctions> {
  Future<List<AuctionWork>> _fetchAuctionWorks() async {
    final auctionProvider =
        Provider.of<AuctionWorksProvider>(context, listen: false);
    await auctionProvider.fetchAllAuctionWorks();
    return auctionProvider.allAuctionWorks.cast<AuctionWork>();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AuctionWork>>(
        future: _fetchAuctionWorks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('데이터를 불러오는 중 오류 발생'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('진행중인 경매가 없습니다.'));
          }
          final auctionWorks = snapshot.data!;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 200,
                child: CustomScrollView(
                  scrollDirection: Axis.horizontal,
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          if (index >= auctionWorks.length) {
                            return SizedBox.shrink();
                          }
                          final auction = auctionWorks[index];
                          return FutureBuilder<Work?>(
                            future: Provider.of<WorkProvider>(context,
                                    listen: false)
                                .getWorkById(auction.workId),
                            builder: (context, workSnapshot) {
                              if (workSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              }
                              if (workSnapshot.hasError ||
                                  !workSnapshot.hasData) {
                                return Text(
                                  '작품 없음',
                                  style: TextStyle(fontSize: 9),
                                );
                              }
                              final work = workSnapshot.data!;
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AuctionScreen(auctionWork: auction),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(25, 0, 0, 10),
                                  child: Container(
                                    width: 150,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color.fromARGB(
                                              255, 225, 225, 225),
                                          spreadRadius: 2,
                                          blurRadius: 10,
                                          offset: Offset(0, 2),
                                        )
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          height: 110,
                                          width: double.infinity,
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: Container(
                                              child: Image.network(
                                                work.workPhotoURL,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 15),
                                        Column(
                                          children: [
                                            SizedBox(
                                              // width: 100,
                                              height: 30,
                                              child: Text(
                                                '₩ ${NumberFormat('###,###,###,###').format(auction.nowPrice)}',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w700),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            SizedBox(
                                              // width: 100,
                                              child: Text(
                                                work.title,
                                                style: TextStyle(fontSize: 12),
                                                // overflow:
                                                // TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        childCount: auctionWorks.length,
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
