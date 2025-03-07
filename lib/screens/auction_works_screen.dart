import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AuctionWorksScreen extends StatelessWidget {
  AuctionWorksScreen({super.key});

  // 더미 데이터
  final List dummyHistories = [
    {
      'workId': 'work_001',
      'workTitle': 'work_title',
      'artistId': 'artist_123',
      'minPrice': 100000,
      'nowPrice': 150000,
      'endDate': DateTime.now().add(Duration(days: 5)),
      'bidderCount': 3,
      'bidders': ['user1', 'user2', 'user3'],
      'isComplete': false,
    },
    {
      'workId': 'work_002',
      'workTitle': 'work_title2',
      'artistId': 'artist_456',
      'minPrice': 200000,
      'nowPrice': 250000,
      'endDate': DateTime.now().add(Duration(days: 3)),
      'bidderCount': 2,
      'bidders': ['user2', 'user4'],
      'isComplete': false,
    },
    {
      'workId': 'work_003',
      'workTitle': 'work_title3',
      'artistId': 'artist_789',
      'minPrice': 300000,
      'nowPrice': 400000,
      'endDate': DateTime.now().subtract(Duration(days: 1)),
      'bidderCount': 5,
      'bidders': ['user1', 'user3', 'user5', 'user6', 'user7'],
      'isComplete': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('경매 내역'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              // 새로고침 기능 구현 예정
            },
          ),
        ],
      ),
      body: dummyHistories.isEmpty
          ? Center(child: Text('입찰 내역이 없습니다.'))
          : ListView.builder(
              itemCount: dummyHistories.length,
              itemBuilder: (context, index) {
                final history = dummyHistories[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ExpansionTile(
                    title: Row(
                      children: [
                        Icon(
                          history['isComplete']
                              ? Icons.check_circle
                              : Icons.access_time,
                          color: history['isComplete']
                              ? Colors.green
                              : Colors.orange,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '작품 ID: ${history['workId']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text(
                          '현재가: ${NumberFormat('#,###').format(history['nowPrice'])}원',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow('작가 ID', history['artistId']),
                            _buildInfoRow('시작가',
                                '${NumberFormat('#,###').format(history['minPrice'])}원'),
                            _buildInfoRow(
                                '마감일',
                                DateFormat('yyyy-MM-dd HH:mm')
                                    .format(history['endDate'])),
                            _buildInfoRow(
                                '입찰자 수', '${history['bidderCount']}명'),
                            _buildInfoRow(
                                '상태', history['isComplete'] ? '경매 종료' : '진행중'),
                            if (history['bidders'].isNotEmpty) ...[
                              Divider(height: 20),
                              Text(
                                '입찰자 목록',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              ...history['bidders']
                                  .map((bidder) => Padding(
                                        padding:
                                            EdgeInsets.only(left: 16, top: 4),
                                        child: Row(
                                          children: [
                                            Icon(Icons.person_outline,
                                                size: 16),
                                            SizedBox(width: 8),
                                            Text(bidder),
                                          ],
                                        ),
                                      ))
                                  .toList(),
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
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
