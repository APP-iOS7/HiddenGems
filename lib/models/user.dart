class User {
  final String id;
  final String signupService;
  final DateTime signupDate;
  final String profileURL;
  final String nickName;
  final List<String> myWorks;
  final List<String> likedWorks;

  User({
    required this.id,
    required this.signupService,
    required this.signupDate,
    required this.profileURL,
    required this.nickName,
    required this.myWorks,
    required this.likedWorks,
  });
}
