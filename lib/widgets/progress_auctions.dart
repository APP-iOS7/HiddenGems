import 'package:flutter/material.dart';
import 'package:hidden_gems/models/auction_work.dart';
import 'package:hidden_gems/models/works.dart';
import 'package:hidden_gems/providers/auction_works_provider.dart';
import 'package:hidden_gems/providers/work_provider.dart';
import 'package:provider/provider.dart';
class ProgressAuctions extends StatefulWidget {
  const ProgressAuctions({super.key});

  @override
  ProgressAuctionsState createState() => ProgressAuctionsState();
}

class ProgressAuctionsState extends State<ProgressAuctions> {

  Future<List<AuctionWork>> _fetchAuctionWorks() async {
    final auctionProvider = Provider.of<AuctionWorksProvider>(context, listen: false);
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
                  height: 160,
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
                              future: Provider.of<WorkProvider>(context, listen: false)
                                              .getWorkById(auction.workId),
                              builder: (context, workSnapshot) {
                                if (workSnapshot.connectionState == ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                }
                                if (workSnapshot.hasError || !workSnapshot.hasData) {
                                  return Text(
                                    '작품 없음',
                                    style: TextStyle(fontSize: 9),
                                  );
                                }
                                final work = workSnapshot.data!;
                                return Padding(
                                  padding: EdgeInsets.only(
                                    right: 12.0,
                                    left: index == 0 ? 0.0 : 0.0,
                                  ),
                                  child: SizedBox(

                                    width: 150,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          height: 90,
                                          child: Card(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Center(child: 
                                                    Text(
                                                      auction.workTitle,
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    )
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(

                                          padding:
                                              const EdgeInsets.symmetric(horizontal: 4.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 70, // 명확한 너비 설정
                                                child: Text(
                                                  work.title,
                                                  style: TextStyle(fontSize: 14),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      work.artistNickName,
                                                      style: TextStyle(fontSize: 9),
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                  Flexible(
                                                    child: Text(
                                                      '₩${auction.nowPrice}',
                                                      style: TextStyle(fontSize: 9),
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ],
                                              )

                                            ],
                                          ),
                                        ),
                                      ],
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
      }
    );
  }
}
