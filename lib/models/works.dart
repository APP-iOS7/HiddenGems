import 'package:cloud_firestore/cloud_firestore.dart';

class Work {
  final String id;
  final String artistID; //생성자 아이디
  final String artistNickName;
  final bool selling;
  final String title;
  final String description;
  final DateTime createDate;
  final String workPhotoURL;
  final double minPrice;
  final List<String> likedUsers;
  final int likedCount;
  final bool doAuction;

  Work({
    String? id,
    required this.artistID,
    required this.artistNickName,
    required this.selling,
    required this.title,
    required this.description,
    DateTime? createDate,
    required this.workPhotoURL,
    required this.minPrice,
    required this.likedUsers,
    required this.likedCount,
    required this.doAuction,
  })  : id = id ?? FirebaseFirestore.instance.collection('works').doc().id,
        createDate = createDate ?? DateTime.now();

  factory Work.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return Work(
      id: doc['id'] ?? FirebaseFirestore.instance.collection('works').doc().id,
      artistID: map['artistID'] ?? '',
      artistNickName: map['artistNickName'] ?? '',
      selling: map['selling'] ?? false,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createDate: map['createDate'] != null
          ? (map['createDate'] as Timestamp).toDate()
          : DateTime.now(),
      workPhotoURL: map['workPhotoURL'] ?? '',
      minPrice: (map['minPrice'] ?? 0).toDouble(),
      likedUsers: List<String>.from(map['likedUsers'] ?? []),
      likedCount: map['likedCount']?.toInt() ?? 0,
      doAuction: map['doAuction'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'artistID': artistID,
      'artistNickName': artistNickName,
      'selling': selling,
      'title': title,
      'description': description,
      'createDate': Timestamp.fromDate(createDate),
      'workPhotoURL': workPhotoURL,
      'minPrice': minPrice,
      'likedUsers': likedUsers,
      'likedCount': likedCount,
      'doAuction': doAuction,
    };
  }
}
