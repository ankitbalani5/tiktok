class ReelModel {
  final String id;
  final String username;
  final String videoUrl;
  final String caption;
  final int likes;
  final bool isLike;

  ReelModel({
    required this.id,
    required this.username,
    required this.videoUrl,
    required this.caption,
    required this.likes,
    required this.isLike,
  });

  factory ReelModel.fromFirestore(
      String id, Map<String, dynamic> map) {
    return ReelModel(
      id: id,
      username: map['username'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      caption: map['caption'] ?? '',
      likes: map['likes'] ?? 0,
      isLike: map['isLike'] ?? false,
    );
  }
}