class AuctionWork {
  final String workId;
  final String workTitle;
  final String artistId;
  final String artistNickname;
  final List<String> auctionUserId;
  final int minPrice;
  final DateTime endDate;
  late int nowPrice;
  bool auctionComplete;
  String? lastBidderId;

  AuctionWork({
    required this.workId,
    required this.workTitle,
    required this.artistId,
    required this.artistNickname,
    required this.auctionUserId,
    required this.minPrice,
    required this.endDate,
    required this.nowPrice,
    required this.auctionComplete,
    this.lastBidderId,
  });

  factory AuctionWork.fromMap(Map<String, dynamic> map) {
    return AuctionWork(
      workId: map['workId'] ?? '',
      workTitle: map['workTitle'] ?? '',
      artistId: map['artistId'] ?? '',
      artistNickname: map['artistNickname'] ?? '',
      auctionUserId: List<String>.from(map['auctionUserId'] ?? []),
      minPrice: map['minPrice']?.toInt() ?? 0,
      endDate: map['endDate'] != null
          ? DateTime.parse(map['endDate'])
          : DateTime.now(),
      nowPrice: map['nowPrice']?.toInt() ?? 0,
      auctionComplete: map['auctionComplete'] ?? false,
      lastBidderId: map['lastBidderId'],
    )..nowPrice = map['nowPrice']?.toInt() ?? 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'workId': workId,
      'workTitle': workTitle,
      'artistId': artistId,
      'artistNickname': artistNickname,
      'auctionUserId': auctionUserId,
      'minPrice': minPrice,
      'endDate': endDate.toIso8601String(),
      'nowPrice': nowPrice,
      'auctionComplete': auctionComplete,
      'lastBidderId': lastBidderId,
    };
  }
}
