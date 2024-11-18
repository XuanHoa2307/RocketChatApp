import 'package:flutter/material.dart';
import 'package:rocketchatapp/screens/chat_screen.dart';
import '../services/api_service.dart';
import '../widgets/channel_widget.dart';

class SearchScreen extends StatefulWidget {
  final String authToken;
  final String userId;
  final String username;

  const SearchScreen({
    super.key,
    required this.authToken,
    required this.userId,
    required this.username, 
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService apiService = ApiService();
  List<dynamic> allChannels = []; // Danh sách tất cả kênh từ API
  List<dynamic> filteredChannels = []; // Danh sách sau khi lọc
  bool isLoading = false;
  final TextEditingController searchController = TextEditingController(); // Controller cho thanh tìm kiếm

  @override
  void initState() {
    super.initState();
    fetchAllChannels();
  }

  // Lấy danh sách tất cả các kênh từ API
  Future<void> fetchAllChannels() async {
  setState(() {
    isLoading = true;
  });

  try {
    final response = await apiService.getListChannels(widget.authToken, widget.userId);
    final fetchedChannels = response['channels'] ?? []; // Lấy danh sách kênh từ API
    print('Fetched Channels: $fetchedChannels'); // Log danh sách trả về
    setState(() {
      allChannels = fetchedChannels;
      filteredChannels = fetchedChannels; // Hiển thị toàn bộ kênh ban đầu
    });
  } catch (e) {
    print('Error fetching all channels: $e');
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

      final roomId = channelInfo['_id'];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            roomId: roomId,
            authToken: widget.authToken,
            userId: widget.userId,
            username: widget.username,
            channelName: channelInfo['name'],
            
          ),
        ),
      );
    } catch (e) {
      print('Error navigating to chat: $e');
    }
  }

  // Lọc danh sách kênh dựa trên từ khóa
  void filterChannels(String query) {
  setState(() {
    if (query.isEmpty) {
      filteredChannels = allChannels; // Hiển thị tất cả nếu không nhập gì
    } else {
      filteredChannels = allChannels.where((channel) {
        final fname = channel['fname']?.toLowerCase() ?? ''; // Tên chính thức
        final name = channel['name']?.toLowerCase() ?? '';  // Tên phụ
        return fname.contains(query.toLowerCase()) || name.contains(query.toLowerCase());
      }).toList();
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Search Channels",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), 
          onPressed: () {
            
            Navigator.pop(context, 'refresh');

          },
        ),
      ),

      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: searchController,
                  onChanged: filterChannels, 
                  decoration: InputDecoration(
                    hintText: "Search Channels...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
              ),

              // Danh sách kênh đã lọc
              Expanded(
              child: filteredChannels.isEmpty
                  ? const Center(
                      child: Text(
                        "No Channels Found",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredChannels.length,
                      itemBuilder: (context, index) {
                        final channel = filteredChannels[index];
                        return ChannelWidget(
                          channelName: channel['fname'] ?? channel['name'] ?? 'Unknown Channel',

                          onTap: () {
                            print("Selected channel: ${channel['name']}");
                          
                            navigateToChat(channel['_id']);
                          },
                        );
                      },
                    ),
              ),

            ],
          ),
          
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
