class ScreenArguments {
  final String username;
  final String chatRoomId;
  final bool isGroup;
  final String imageUrl;
  final String email;

  ScreenArguments({
    required this.chatRoomId,
    required this.username,
    required this.imageUrl,
    this.isGroup = false,
    this.email = '',
  });
}
