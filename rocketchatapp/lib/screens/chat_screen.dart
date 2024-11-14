import 'package:flutter/material.dart';
import 'package:rocketchatapp/widgets/message_widget.dart';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final String authToken;
  final String userId;
  final String username;
  final String email;
  final String avatarUrl;
  final String roomId;

  const ChatScreen({
    super.key,
    required this.authToken,
    required this.userId,
    required this.username,
    required this.email,
    required this.avatarUrl,
    required this.roomId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiService apiService = ApiService();
  final TextEditingController messageController = TextEditingController();
  List<dynamic> messages = [];
  bool isLoading = false;
  bool isJoined = false; // Trạng thái đã join hay chưa

  @override
  void initState() {
    super.initState();
    fetchMessages(); // Lấy tin nhắn
    checkIfJoined(); // Kiểm tra đã join hay chưa
  }

  /// Kiểm tra user đã join channel hay chưa
  Future<void> checkIfJoined() async {
    try {
      final joinedChannels =
          await apiService.getJoinedChannels(widget.authToken, widget.userId);
      setState(() {
        isJoined = joinedChannels.any((channel) => channel['_id'] == widget.roomId);
      });
    } catch (e) {
      print('Error checking if joined: $e');
    }
  }

  /// Lấy tin nhắn
  Future<void> fetchMessages() async {
    setState(() {
      isLoading = true;
    });

    try {
      final fetchedMessages = await apiService.getMessagesWithAuth(
        widget.authToken,
        widget.userId,
        widget.roomId,
      );

      final filteredMessages = fetchedMessages.where((msg) {
        if (msg.containsKey('t') && msg['t'] != null) {
          return false; // Loại bỏ tin nhắn hệ thống
        }
        return true;
      }).toList();

      setState(() {
        messages = filteredMessages;
      });
    } catch (e) {
      print('Error fetching messages: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Gửi tin nhắn
  Future<void> sendMessage() async {
    if (messageController.text.isNotEmpty) {
      try {
        await apiService.sendMessageWithAuth(
          widget.authToken,
          widget.userId,
          widget.roomId,
          messageController.text,
        );

        setState(() {
          messages.insert(0, {
            'u': {'username': widget.username},
            'msg': messageController.text,
          });
        });

        messageController.clear();
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }

  /// Join channel
  Future<void> joinChannel() async {
    try {
      await apiService.joinChannel(widget.authToken, widget.userId, widget.roomId);
      setState(() {
        isJoined = true; // Cập nhật trạng thái
      });
      print('Joined channel successfully!');
    } catch (e) {
      print('Error joining channel: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.avatarUrl),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.username, style: const TextStyle(fontSize: 16)),
                Text(
                  widget.email,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return MessageWidget(
                      sender: message['u']['username'],
                      message: message['msg'],
                      isCurrentUser: message['u']['username'] == widget.username,
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      enabled: isJoined, // Bật/tắt TextField nếu đã join
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(isJoined ? Icons.send : Icons.login),
                    onPressed: () async {
                      if (isJoined) {
                        await sendMessage();
                        await fetchMessages();
                      } else {
                        await joinChannel();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
