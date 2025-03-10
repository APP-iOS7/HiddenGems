import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'address_form_screen.dart';
import '../../models/auctioned_work.dart';

class AuctionedWorksListScreen extends StatelessWidget {
  const AuctionedWorksListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 현재 로그인한 사용자 ID 가져오기
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(
          child: Text('로그인이 필요합니다.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 경매 완료 작품'),
        elevation: 0,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('auctionedWorks')
            .where(Filter.or(
              Filter('artistId', isEqualTo: userId),
              Filter('completeUserId', isEqualTo: userId),
            ))
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('오류가 발생했습니다: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('경매 완료된 작품이 없습니다.'),
            );
          }

          final works = snapshot.data!.docs.map((doc) {
            final data = doc.data();
            return AuctionedWork.fromMap(data);
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: works.length,
            itemBuilder: (context, index) {
              final work = works[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        work.workTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '작가: ${work.artistNickname}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildStatusChip(work.deliverComplete),
                          const SizedBox(width: 8),
                          Text(
                            '낙찰가: ${_formatPrice(work.completePrice)}원',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildRoleText(work, userId),
                    ],
                  ),
                  onTap: () {
                    // 배송지 입력이 필요한 경우 배송지 입력 페이지로 이동
                    if (work.completeUserId == userId &&
                        work.deliverComplete == '배송지입력대기') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddressFormScreen(
                            auctionedWork: work,
                          ),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    String displayStatus;

    switch (status) {
      case '배송지입력대기':
        chipColor = Colors.orange;
        displayStatus = '배송지 입력 대기';
        break;
      case '배송준비중':
        chipColor = Colors.blue;
        displayStatus = '배송 준비중';
        break;
      case '배송중':
        chipColor = Colors.green;
        displayStatus = '배송중';
        break;
      case '배송완료':
        chipColor = Colors.grey;
        displayStatus = '배송 완료';
        break;
      default:
        chipColor = Colors.blue;
        displayStatus = status;
    }

    return Chip(
      label: Text(
        displayStatus,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildRoleText(AuctionedWork work, String userId) {
    if (work.artistId == userId) {
      return const Text(
        '판매 작품',
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.w500,
        ),
      );
    } else {
      return const Text(
        '낙찰 받은 작품',
        style: TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.w500,
        ),
      );
    }
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
