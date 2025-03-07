class AppUser {
  final String id;
  final DateTime signupDate;
  final String profileURL;
  final String nickName;
  final List<String> myWorks;
  final List<String> likedWorks;

  AppUser({
    required this.id,
    required this.signupDate,
    required this.profileURL,
    required this.nickName,
    required this.myWorks,
    required this.likedWorks,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] ?? '',
      signupDate: DateTime.parse(map['signupDate']),
      profileURL: map['profileURL'] ?? '',
      nickName: map['nickName'] ?? '',
      myWorks: List<String>.from(map['myWorks'] ?? []),
      likedWorks: List<String>.from(map['likedWorks'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'signupDate': signupDate.toIso8601String(),
      'profileURL': profileURL,
      'nickName': nickName,
      'myWorks': myWorks,
      'likedWorks': likedWorks,
    };
  }
}
