import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auction_works_provider.dart';
import '../../models/auction_work.dart';

import 'package:hidden_gems/models/works.dart';
import 'package:hidden_gems/providers/work_provider.dart';

import 'package:hidden_gems/models/user.dart';
import 'package:hidden_gems/providers/user_provider.dart';

class AuctionWorksScreen extends StatefulWidget {
  const AuctionWorksScreen({super.key});

  @override
  AuctionWorksScreenState createState() => AuctionWorksScreenState();
}

class AuctionWorksScreenState extends State<AuctionWorksScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  List<AuctionWork> _allAuctionWorks = [];
  List<AuctionWork> _filteredWorks = [];
  List<AppUser> _allUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchAuctionWorks();
    _fetchUsers();
  }

  Future<void> _fetchAuctionWorks() async {
    final auctionProvider =
        Provider.of<AuctionWorksProvider>(context, listen: false);
    final workProvider = Provider.of<WorkProvider>(context, listen: false);
    await auctionProvider.fetchAllAuctionWorks();
    await workProvider.loadWorks();
    setState(() {
      _allAuctionWorks = auctionProvider.allAuctionWorks.cast<AuctionWork>();
      _filteredWorks = _allAuctionWorks;
    });
  }
  void _filterAuctionWorks(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredWorks = _allAuctionWorks
          .where((auctionWork) =>
              auctionWork.workTitle.toLowerCase().contains(_searchQuery))
          .toList();
    });
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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
                padding: const EdgeInsets.only(bottom: 25.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterAuctionWorks,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search,
                          color: const Color.fromARGB(255, 105, 105, 105)),
                      hintText: "작품 검색",
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Color.fromRGBO(223, 223, 229, 1),
                      contentPadding: EdgeInsets.symmetric(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
                Expanded(
                  child: _filteredWorks.isEmpty
                    ? const Center(child: Text('진행중인 경매 내역이 없습니다.'))
                    : ListView.builder(
                        itemCount: _filteredWorks.length,
                        itemBuilder: (context, index) {
                          final workProvider = Provider.of<WorkProvider>(context, listen: false);
                          final AuctionWork auctionWork = _filteredWorks[index];
                          final matchingWork = workProvider.works.firstWhere(
                            (work) =>
                                work.id == auctionWork.workId &&
                                work.artistID == auctionWork.artistId,
                            orElse: () => Work(
                              id: '',
                              artistID: '',
                              artistNickName: '',
                              title: '알 수 없는 작품',
                              description: '',
                              createDate: DateTime.now(),
                              workPhotoURL: '',
                              minPrice: 0,
                              likedUsers: [],
                              selling: false,
                              doAuction: false,
                            ),
                          );
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
                                    auctionWork.workTitle,
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
                                      _buildInfoRow('작가 ID', matchingWork.artistNickName),
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
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        const SizedBox(height: 8),
                                        ...auctionWork.auctionUserId.map((bidderId) {
                                          final bidder = _allUsers.firstWhere(
                                            (user) => user.id == bidderId,
                                            orElse: () => AppUser(
                                              id: '',
                                              signupDate: DateTime(2000, 1, 1),
                                              profileURL: '',
                                              nickName: '알 수 없는 사용자',
                                              myLikeScore: 0,
                                              myWorks: [],
                                              likedWorks: [],
                                              biddingWorks: [],
                                              beDeliveryWorks: [],
                                              completeWorks: [],
                                              subscribeUsers: [],
                                            ),

                                          );

                                          return Padding(
                                            padding: const EdgeInsets.only(left: 16, top: 4),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.person_outline, size: 16),
                                                const SizedBox(width: 8),
                                                Text(bidder.nickName),
                                              ],
                                            ),
                                          );
                                        }),
                                      ],

                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ),
              ],
            ),
          );
        }
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

