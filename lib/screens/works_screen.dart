import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hidden_gems/providers/work_provider.dart';
import 'package:hidden_gems/providers/user_provider.dart';
import 'package:hidden_gems/models/works.dart';

class WorkScreen extends StatefulWidget {
  const WorkScreen({super.key});

  @override
  _WorkScreenState createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> {
  @override
void initState() {
  super.initState();
  Future.microtask(() {
    Provider.of<WorkProvider>(context, listen: false).loadWorks();
    Provider.of<UserProvider>(context, listen: false).loadUser();
  });
}


  @override
  Widget build(BuildContext context) {
    final workProvider = Provider.of<WorkProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final works = workProvider.works;

    return Scaffold(
      appBar: AppBar(
        title: Text('작품 목록'),
      ),
      body: works.isEmpty
          ? Center(child: Text('작품이 없습니다.', style: TextStyle(fontSize: 18)))
          : ListView.builder(
              itemCount: works.length,
              itemBuilder: (context, index) {
                final work = works[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: work.workPhotoURL.isNotEmpty
                        ? Image.network(work.workPhotoURL, width: 50, height: 50, fit: BoxFit.cover)
                        : Icon(Icons.image_not_supported, size: 50),
                    title: Text(work.title, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('최소 금액: \$${work.minPrice.toStringAsFixed(2)}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => workProvider.deleteWork(work.id),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addDummyWork(workProvider, userProvider),
        backgroundColor: Colors.purple,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _addDummyWork(WorkProvider workProvider, UserProvider userProvider) {
    if (userProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("로그인된 사용자 정보가 없습니다.")),
      );
      return;
    }
    final dummyWork = Work(
      artistID: userProvider.user!.id,
      selling: true,
      title: '랜덤 작품 #${DateTime.now().millisecondsSinceEpoch % 1000}',
      description: '이것은 자동 생성된 더미 데이터입니다.',
      createDate: DateTime.now(),
      workPhotoURL: 'https://via.placeholder.com/150',
      minPrice: (10 + (DateTime.now().millisecondsSinceEpoch % 100) * 5)
          .toDouble(),
      likedUsers: [],
      doAuction: false,
    );

    workProvider.addWork(dummyWork);
  }
}
