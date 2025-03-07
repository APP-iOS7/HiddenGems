import 'package:flutter/material.dart';

class AuctionPageScreen extends StatelessWidget {
  const AuctionPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('경매 페이지', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
