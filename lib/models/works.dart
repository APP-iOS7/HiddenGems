class Work {
  final String id;
  final String artistID; //생성자 아이디
  final String nickName; 
  final bool selling;
  final String title;
  final String description;
  final DateTime createDate;
  final String workPhotoURL;
  final double minPrice;
  final List<String> likedUsers;
  final bool doAuction;

  Work({
    required this.id,
    required this.artistID,
    required this.nickName,
    required this.selling,
    required this.title,
    required this.description,
    required this.createDate,
    required this.workPhotoURL,
    required this.minPrice,
    required this.likedUsers,
    required this.doAuction,
  });

  factory Work.fromMap(Map<String, dynamic> map) {
    return Work(
      id: map['id'] ?? '',
      artistID: map['artistID'] ?? '',
      nickName: map['nickName'] ?? '',
      selling: map['selling'] ?? false,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createDate: DateTime.parse(map['createDate']),
      workPhotoURL: map['workPhotoURL'] ?? '',
      minPrice: (map['minPrice'] ?? 0).toDouble(),
      likedUsers: List<String>.from(map['likedUsers'] ?? []),
      doAuction: map['doAuction'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'artistID': artistID,
      'nickName': nickName,
      'selling': selling,
      'title': title,
      'description': description,
      'createDate': createDate.toIso8601String(),
      'workPhotoURL': workPhotoURL,
      'minPrice': minPrice,
      'likedUsers': likedUsers,
      'doAuction': doAuction,
    };
  }
}
