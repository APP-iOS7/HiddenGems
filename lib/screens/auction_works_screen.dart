import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/auction_works_provider.dart';
import '../models/auction_work.dart';

class AuctionWorksScreen extends StatelessWidget {
  const AuctionWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuctionWorksProvider provider =
        Provider.of<AuctionWorksProvider>(context, listen: false);

    return FutureBuilder(
        future: provider.fetchUserAuctionWorks(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final auctionWorks =
              context.watch<AuctionWorksProvider>().userAuctionWorks;

          return Scaffold(
            body: auctionWorks.isEmpty
                ? const Center(child: Text('입찰 내역이 없습니다.'))
                : ListView.builder(
                    itemCount: auctionWorks.length,
                    itemBuilder: (context, index) {
                      final AuctionWork auctionWork = auctionWorks[index];
                      debugPrint("입찰 내역: ${auctionWork.workId}");
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ExpansionTile(
                          title: Row(
                            children: [
                              Icon(
                                auctionWork.auctionComplete
                                    ? Icons.check_circle
                                    : Icons.access_time,
                                color: auctionWork.auctionComplete
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '작품 ID: ${auctionWork.workId}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                '현재가: ${NumberFormat('#,###').format(auctionWork.nowPrice)}원',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow('작가 ID', auctionWork.artistId),
                                  _buildInfoRow('시작가',
                                      '${NumberFormat('#,###').format(auctionWork.minPrice)}원'),
                                  _buildInfoRow(
                                      '마감일',
                                      DateFormat('yyyy-MM-dd HH:mm')
                                          .format(auctionWork.endDate)),
                                  _buildInfoRow('입찰자 수',
                                      '${auctionWork.auctionUserId.length}명'),
                                  _buildInfoRow(
                                      '상태',
                                      auctionWork.auctionComplete
                                          ? '경매 종료'
                                          : '진행중'),
                                  if (auctionWork.auctionUserId.isNotEmpty) ...[
                                    const Divider(height: 20),
                                    const Text(
                                      '입찰자 목록',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    const SizedBox(height: 8),
                                    ...auctionWork.auctionUserId
                                        .map((bidder) => Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 16, top: 4),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                      Icons.person_outline,
                                                      size: 16),
                                                  const SizedBox(width: 8),
                                                  Text(bidder),
                                                ],
                                              ),
                                            )),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          );
        });
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style:
                TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[700]),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
