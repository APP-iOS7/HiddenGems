import 'package:flutter/material.dart';
import 'package:hidden_gems/models/user.dart';

class ArtistDetailScreen extends StatelessWidget {
  const ArtistDetailScreen({super.key, required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${user.nickName} 님의 작품'),
      ),
      body: Column(
        children: [],
      ),
    );
  }
}
