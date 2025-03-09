class AppUser {
  final String id;
  final DateTime signupDate;
  final String profileURL;
  final String nickName;
  final int myLikeScore;
  final List<String> myWorks;
  final int myWorksCount;
  final List<String> likedWorks;
  final List<String> biddingWorks;
  final List<String> beDeliveryWorks;
  final List<String> completeWorks;
  final List<String> subscribeUsers;

  AppUser({
    required this.id,
    required this.signupDate,
    required this.profileURL,
    required this.nickName,
    required this.myLikeScore,
    required this.myWorks,
    required this.myWorksCount,
    required this.likedWorks,
    required this.biddingWorks,
    required this.beDeliveryWorks,
    required this.completeWorks,
    required this.subscribeUsers,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] ?? '',
      signupDate: DateTime.parse(map['signupDate']),
      profileURL: map['profileURL'] ?? '',
      nickName: map['nickName'] ?? '',
      myLikeScore:
          (map['myLikeScore'] is num) ? (map['myLikeScore'] as num).toInt() : 0,
      myWorks: List<String>.from(map['myWorks'] ?? []),
      myWorksCount: map['myWorksCount']?.toInt() ?? 0,
      likedWorks: List<String>.from(map['likedWorks'] ?? []),
      biddingWorks: List<String>.from(map['likedWorks'] ?? []),
      beDeliveryWorks: List<String>.from(map['likedWorks'] ?? []),
      completeWorks: List<String>.from(map['likedWorks'] ?? []),
      subscribeUsers: List<String>.from(map['subscribeUsers'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'signupDate': signupDate.toIso8601String(),
      'profileURL': profileURL,
      'nickName': nickName,
      'myLikeScore': myLikeScore,
      'myWorks': myWorks,
      'myWorksCount': myWorksCount,
      'likedWorks': likedWorks,
      'biddingWorks': biddingWorks,
      'beDeliveryWorks': beDeliveryWorks,
      'completeWorks': completeWorks,
      'subscribeUsers': subscribeUsers,
    };
  }
}
