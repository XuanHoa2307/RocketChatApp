import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rocketchatapp/screens/login_screen.dart';
import 'package:rocketchatapp/screens/search_screen.dart';
import '../services/api_service.dart';
import '../widgets/channel_widget.dart';
import '../widgets/home_widget.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  final String authToken;
  final String userId;
  final String username;

  const HomeScreen({
    super.key,
    required this.authToken,
    required this.userId,
    required this.username,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  List<dynamic> channels = [];
  bool isLoading = false;
  String selectedItem = 'Chat';

  @override
  void initState() {
    super.initState();
    fetchChannelsJoined();
  
  }

  Future<void> fetchChannelsJoined() async {
    setState(() {
      isLoading = true;
    });

    try {
      final fetchedChannelsJoined =
          await apiService.getJoinedChannels(widget.authToken, widget.userId);
      setState(() {
        channels = fetchedChannelsJoined;
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

      final roomId = channelInfo['_id'];
      
      final result = await Navigator.push(
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
      if(result == 'refresh') {
        fetchChannelsJoined();
      }
    } catch (e) {
      print('Error navigating to chat: $e');
    }
  }

  Future<void> createChannel() async {
    final channelNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Channel', style: TextStyle(fontWeight: FontWeight.bold),),
        content: TextField(
          controller: channelNameController,
          decoration: const InputDecoration(hintText: 'Enter channel name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.red, fontSize: 17)),
          ),
          TextButton(
            onPressed: () async {
              final channelName = channelNameController.text.trim();
              if (channelName.isNotEmpty) {
                try {
                  Navigator.pop(context);
                  await apiService.createChannel(
                      widget.authToken, widget.userId, channelName);
                  fetchChannelsJoined();
                } catch (e) {
                  print('Error creating channel: $e');
                }
              }
            },
            child: const Text('Create', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 17)),
          ),
        ],
      ),
    );
  }

  Future<void> logOut() async {
    try {
      await apiService.logOut(widget.authToken, widget.userId);
      
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  void onDrawerItemSelected(String item) {
    setState(() {
      selectedItem = item;
    });

    if (item == 'Chat') {
      Navigator.pop(context);
      
    }

    if(item == 'Logout') {
      logOut();
      Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(), // Điều hướng đến LoginScreen
      ),
      );
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Rocket.Chat',
            style: TextStyle(
              fontFamily: 'Time New Roman',
              fontWeight: FontWeight.bold,
              fontSize: 25,
              color: Colors.blue.shade700,
            ),
          ),
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
        ),
        drawer: AppDrawer(
          username: widget.username,
          selectedItem: selectedItem,
          onItemSelected: onDrawerItemSelected,
        ),
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "😊 Channel Joined",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(221, 23, 21, 163),
                        ),
                      ),
                      //const SizedBox(width: 120),
                      Container(
                        width: 120,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                          IconButton(
                          icon: const Icon(Icons.search_outlined, color: Colors.blue),
                          onPressed: () async {
                            
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchScreen(
                                  authToken: widget.authToken,
                                  userId: widget.userId,
                                  username: widget.username,
                                ),
                              ),
                            );
                            if (result == 'refresh') {
                              fetchChannelsJoined(); 
                            }
                          },
                          
                          ),
                          IconButton(
                          icon: const Icon(Icons.chat_bubble_outline, color: Colors.blue),
                          onPressed: createChannel,
                        ),
                      ],
                      ),
                      ),
                    ],
                    ),
              
                  ),
                  
                
                // Danh sách các kênh
                Expanded(
                  child: ListView.builder(
                    itemCount: channels.length,
                    itemBuilder: (context, index) {
                      final channel = channels[index];
                      return ChannelWidget(
                        channelName: channel['name'],
                        onTap: () => navigateToChat(channel['_id']),
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
      ),
    );
  }


}
