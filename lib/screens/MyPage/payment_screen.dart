import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gems/models/auctioned_work.dart';
import 'package:hidden_gems/screens/MyPage/checkout_screen.dart';
import 'package:hidden_gems/services/payment_service.dart';
import 'package:intl/intl.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    required this.auctionedWork,
    required this.fullAddress,
    required this.name,
    required this.phone,
    required this.requestText,
  });
  final AuctionedWork auctionedWork;
  final String fullAddress;
  final String name;
  final String phone;
  final String requestText;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _paymentService = PaymentService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('결제하기'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Spacer(),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${NumberFormat('###,###,###,###').format(widget.auctionedWork.completePrice)}원',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '을',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    '결제합니다.',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  )
                ],
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      _saveAddress();
                      _processPayment(widget.auctionedWork.completePrice);
                    },
                    child: Text(
                      '결제하기',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveAddress() async {
    try {
      await FirebaseFirestore.instance
          .collection('auctionedWorks')
          .doc(widget.auctionedWork.id)
          .update({
        'name': widget.name,
        'phone': widget.phone,
        'address': widget.fullAddress,
        'deliverRequest': widget.requestText,
        'deliverComplete': '배송준비중',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("배송지가 저장되었습니다.")),
      );
    } catch (e) {
      debugPrint("배송지 저장 오류: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("배송지 저장에 실패했습니다: $e")),
      );
    }
  }

  void _processPayment(int totalAmount) async {
    // 폼 검증
    // 폼 데이터 저장

    // 결제 API 호출
    final result = await _paymentService.processPayment(
      amount: totalAmount,
      shippingAddress: {
        'address1': '서울시 강남구',
        'city': '서울',
        'postal_code': '12345',
        'country': 'KR',
      },
    );

    print('결제 결과: $result');
    if (result['success']) {
      // 결제 완료 화면으로 이동
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CheckoutScreen(),
        ),
      );
    } else {
      // 결제 실패
      final error = result['error'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('결제 실패: $error'), backgroundColor: Colors.red),
      );
    }
  }
}
