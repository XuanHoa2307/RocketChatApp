import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/channel_widget.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  final String authToken;
  final String userId;
  final String username;
  final String email;
  final String avatarUrl;

  const HomeScreen({
    super.key,
    required this.authToken,
    required this.userId,
    required this.username,
    required this.email,
    required this.avatarUrl,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  List<dynamic> channels = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchChannels();
  }

  Future<void> fetchChannels() async {
    setState(() {
      isLoading = true;
    });

    try {
      final fetchedChannels =
          await apiService.fetchChannels(widget.authToken, widget.userId);
      setState(() {
        channels = fetchedChannels;
      });
    } catch (e) {
      print('Error fetching channels: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> navigateToChat(String channelId) async {
    try {
      final channelInfo = await apiService.getChannelInformation(
        widget.authToken,
        widget.userId,
        channelId,
      );

      final roomId = channelInfo['_id']; // Lấy RoomID từ channel info
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            roomId: roomId,
            authToken: widget.authToken,
            userId: widget.userId,
            username: widget.username,
            email: widget.email,
            avatarUrl: widget.avatarUrl,
          ),
        ),
      );
    } catch (e) {
      print('Error navigating to chat: $e');
    }
  }

  Future<void> createChannel() async {
    final channelNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Channel'),
        content: TextField(
          controller: channelNameController,
          decoration: const InputDecoration(hintText: 'Enter channel name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final channelName = channelNameController.text.trim();
              if (channelName.isNotEmpty) {
                try {
                  Navigator.pop(context); // Đóng dialog
                  await apiService.createChannel(
                      widget.authToken, widget.userId, channelName);
                  fetchChannels(); // Cập nhật danh sách channels
                } catch (e) {
                  print('Error creating channel: $e');
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.avatarUrl),
              radius: 18,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.username,
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  widget.email,
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: createChannel, // Gọi hàm tạo channel
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: channels.length,
            itemBuilder: (context, index) {
              final channel = channels[index];
              return ChannelWidget(
                channelName: channel['name'],
                onTap: () => navigateToChat(channel['_id']), // Truyền channelId
              );
            },
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
