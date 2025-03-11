class AuctionedWork {
  final String id;
  final String workId;
  final String workTitle;
  final String artistId;
  final String artistNickname;
  final String completeUserId;
  final int completePrice;
  final String? address;
  final String? name;
  final String? phone;
  final String deliverComplete;
  final String deliverRequest;

  AuctionedWork({
    required this.id,
    required this.workId,
    required this.workTitle,
    required this.artistId,
    required this.artistNickname,
    required this.completeUserId,
    required this.completePrice,
    this.address,
    this.name,
    this.phone,
    required this.deliverComplete,
    required this.deliverRequest,
  });

  factory AuctionedWork.fromMap(Map<String, dynamic> map) {
    return AuctionedWork(
        id: map['id'] ?? '',
        workId: map['workId'] ?? '',
        workTitle: map['workTitle'] ?? '',
        artistId: map['artistId'] ?? '',
        artistNickname: map['artistNickname'] ?? '',
        completeUserId: map['completeUserId'] ?? '',
        completePrice: (map['completePrice'] ?? 0).toInt(),
        address: map['address'] ?? '',
        name: map['name'] ?? '',
        phone: map['phone'] ?? '',
        deliverComplete: map['deliverComplete'] ?? '',
        deliverRequest: map['deliverRequest'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workId': workId,
      'workTitle': workTitle,
      'artistId': artistId,
      'artistNickname': artistNickname,
      'completeUserId': completeUserId,
      'completePrice': completePrice,
      'address': address,
      'name': name,
      'phone': phone,
      'deliverComplete': deliverComplete,
      'deliverRequest': deliverRequest,
    };
  }

  AuctionedWork copyWith({
    String? id,
    String? workId,
    String? artistId,
    String? artistNickname,
    String? workTitle,
    String? completeUserId,
    int? completePrice,
    String? address,
    String? name,
    String? phone,
    String? deliverComplete,
    String? deliverRequest,
  }) {
    return AuctionedWork(
      id: id ?? this.id,
      workId: workId ?? this.workId,
      artistId: artistId ?? this.artistId,
      artistNickname: artistNickname ?? this.artistNickname,
      workTitle: workTitle ?? this.workTitle,
      completeUserId: completeUserId ?? this.completeUserId,
      completePrice: completePrice ?? this.completePrice,
      address: address ?? this.address,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      deliverComplete: deliverComplete ?? this.deliverComplete,
      deliverRequest: deliverRequest ?? this.deliverRequest,
    );
  }
}
