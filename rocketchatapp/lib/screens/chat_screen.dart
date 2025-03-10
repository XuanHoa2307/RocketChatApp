import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rocketchatapp/services/api_get_channel.dart';
import 'package:rocketchatapp/services/api_message.dart';
import 'package:rocketchatapp/services/api_post_channel.dart';
import 'package:rocketchatapp/widgets/message_widget.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../services/api_service.dart';


class ChatScreen extends StatefulWidget {
  final String authToken;
  final String userId;
  final String username;
  //final String email;
  //final String avatarUrl;
  final String roomId;
  final String channelName;

  const ChatScreen({
    super.key,
    required this.authToken,
    required this.userId,
    required this.username,
    //required this.email,
    //required this.avatarUrl,
    required this.roomId,
    required this.channelName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiService apiService = ApiService();
  final ApiServiceGetChannel apiServiceGetChannel = ApiServiceGetChannel();
  final ApiServicePostChannel apiServicePostChannel = ApiServicePostChannel();
  final ApiServiceMessage apiServiceMessage = ApiServiceMessage();
  final TextEditingController messageController = TextEditingController();
  
  late WebSocketChannel channel;

  bool isSending = false;
  //late Timer _messageFetchTimer;
  DateTime? lastMessageTimestamp;
  
  List<dynamic> messages = [];
  bool isLoading = false;
  bool isJoined = false; // Trạng thái đã join hay chưa

  @override
  void initState() {
    super.initState();
    _connectToWebSocket(); // Kết nối tới WebSocket
    fetchMessages(); // Lấy tin nhắn
    checkIfJoined(); // Kiểm tra đã join hay chưa
    

    // Bắt đầu Long Polling
    //startLongPolling();

    // Tạo timer để fetch messages mỗi 3 giây
    /*_messageFetchTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      fetchNewMessages(); // Fetch chỉ các tin nhắn mới
    });*/

  }

  @override
  void dispose() {
    channel.sink.close(1000); // Normal Closure

    //_messageFetchTimer.cancel(); // Hủy Timer
    messageController.dispose(); // Dọn dẹp TextEditingController
    super.dispose();
  }

late Timer _pingTimer;

void _connectToWebSocket() {
  const wsUrl = 'ws://10.10.10.20:3000/websocket';
  channel = WebSocketChannel.connect(Uri.parse(wsUrl));

  // Gửi yêu cầu kết nối
  channel.sink.add(jsonEncode({
    "msg": "connect",
    "version": "1",
    "support": ["1"],
  }));

  // Bắt đầu gửi ping định kỳ mỗi 30 giây
  _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
    print('Sending ping...');
    channel.sink.add(jsonEncode({"msg": "ping"}));
  });

  // Lắng nghe các sự kiện từ WebSocket
  channel.stream.listen((data) {
    final decoded = jsonDecode(data);
    print('Received: $decoded');

    // Nếu server gửi ping
    if (decoded['msg'] == 'ping') {
      print('Received ping, sending pong...');
      channel.sink.add(jsonEncode({"msg": "pong"}));
    }

    // Nếu kết nối thành công
    if (decoded['msg'] == 'connected') {
      _authenticateAndSubscribe();
    }

    // Kiểm tra phản hồi "ready"
    if (decoded['msg'] == 'ready' && decoded['subs'].contains(widget.roomId)) {
      print('Successfully subscribed to stream-room-messages!');
    }

    // Nhận tin nhắn mới
    if (decoded['collection'] == 'stream-room-messages') {
      final newMessage = decoded['fields']['args'][0];
      print('New message received: $newMessage');
      setState(() {
        messages.insert(0, newMessage); // Thêm tin nhắn mới vào danh sách
      });
    }
  }, onError: (error) {
    print('WebSocket error: $error');
  }, onDone: () {
    print('WebSocket connection closed');
    _pingTimer.cancel(); // Dừng ping khi kết nối bị đóng
  });
}


void _authenticateAndSubscribe() {
  // Xác thực WebSocket
  channel.sink.add(jsonEncode({
    "msg": "method",
    "method": "login",
    "id": "login-id",
    "params": [
      {
        "resume": widget.authToken, // Dùng authToken để xác thực
      }
    ],
  }));

  // Đăng ký sự kiện stream-room-messages
  channel.sink.add(jsonEncode({
    "msg": "sub",
    "id": widget.roomId, // Sử dụng roomId làm unique-id
    "name": "stream-room-messages",
    "params": [
      widget.roomId,
      false,
    ],
  }));
}

  void _subscribeToMessages() {
  channel.sink.add(jsonEncode({
    "msg": "sub",
    "id": widget.roomId, // Sử dụng roomId làm unique-id
    "name": "stream-room-messages",
    "params": [
      widget.roomId,
      false,
    ],
  }));
}



  /*void startLongPolling() async {
  while (mounted) { // Đảm bảo widget vẫn còn hoạt động
    try {
      // Gửi yêu cầu Long Polling để lấy tin nhắn mới
      await fetchNewMessages();
    } catch (e) {
      print('Lỗi trong quá trình long polling: $e');
    }

    // Không cần thêm thời gian chờ vì server sẽ timeout sau 30 giây
  }
}*/


  // Lấy tin nhắn mới
  Future<void> fetchNewMessages() async {
  try {
    if (lastMessageTimestamp == null) {
      await fetchMessages(); // Lấy tất cả tin nhắn nếu timestamp null
      return;
    }

    final newMessages = await apiServiceMessage.syncMessages(
      authToken: widget.authToken,
      userId: widget.userId,
      roomId: widget.roomId,
      lastUpdate: lastMessageTimestamp!.toIso8601String(), // Định dạng ISO
    );

    // Loại bỏ các tin nhắn đã tồn tại trong danh sách `messages`
    final uniqueMessages = newMessages.where((msg) {
      return !messages.any((existingMsg) => existingMsg['_id'] == msg['_id']);
    }).toList();

    if (uniqueMessages.isNotEmpty) {
      setState(() {
        messages.insertAll(0, uniqueMessages); // Chèn tin nhắn mới
        lastMessageTimestamp =
            DateTime.parse(uniqueMessages.first['ts']); // Cập nhật timestamp
      });
    }
  } catch (e) {
    print('Error fetching new messages: $e');
  }
  }


  /// Kiểm tra user đã join channel hay chưa
  Future<void> checkIfJoined() async {
    try {
      final joinedChannels =
          await apiServiceGetChannel.getJoinedChannels(widget.authToken, widget.userId);
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
    List<dynamic> allMessages = [];
    int offset = 0;
    bool hasMore = true;

    while (hasMore) {
      final fetchedMessages = await apiServiceMessage.getMessagesWithAuth(
        widget.authToken,
        widget.userId,
        widget.roomId,
        offset,
      );

      if (fetchedMessages.isEmpty) {
        hasMore = false;
      } else {
        // Loại bỏ tin nhắn trùng lặp
        final uniqueMessages = fetchedMessages.where((msg) {
          return !allMessages.any((existingMsg) => existingMsg['_id'] == msg['_id']);
        }).toList();

        allMessages.addAll(uniqueMessages);
        offset += fetchedMessages.length;
      }
    }

    final filteredMessages = allMessages.where((msg) {
      if (msg.containsKey('t') && msg['t'] != null) {
        return false; // Loại bỏ tin nhắn hệ thống
      }
      return true;
    }).toList();

    setState(() {
      messages = filteredMessages;
      if (messages.isNotEmpty) {
        lastMessageTimestamp =
            DateTime.parse(messages.first['ts']); // Cập nhật timestamp
      }
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
    setState(() {
      isSending = true; 
    });

    try {
      await apiServiceMessage.sendMessageWithAuth(
        widget.authToken,
        widget.userId,
        widget.roomId,
        messageController.text,
      );

      messageController.clear();

      // Fetch tin nhắn mới ngay sau khi gửi
      await fetchNewMessages();
    } catch (e) {
      print('Error sending message: $e');
    } finally {
      setState(() {
        isSending = false; // Ẩn trạng thái gửi
      });
    }
  }
}

  /// Join channel
  Future<void> joinChannel() async {
    try {
      await apiServicePostChannel.joinChannel(widget.authToken, widget.userId, widget.roomId);
      setState(() {
        isJoined = true;

      });
      print('Joined channel successfully!');
    } catch (e) {
      print('Error joining channel: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
        '# ${widget.channelName}', 
        style: const TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 255, 255)),
      ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), 
          onPressed: () {
            Navigator.pop(context,'refresh');
          },
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
                  final isCurrentUser = message['u']['username'] == widget.username;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      
                      if (!isCurrentUser)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.blue[300], 
                            child: const Icon(Icons.person, size: 16, color: Colors.white),
                          ),
                        ),
                      Expanded(
                        child: MessageWidget(
                          sender: message['u']['username'],
                          message: message['msg'],
                          isCurrentUser: isCurrentUser,
                        ),
                      ),
                      
                    ],
                  );
                },
              ),
            ),

              Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 10, bottom: 10, top: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3), 
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3), 
                        ),
                      ],
                      border: Border.all(
                        color: Colors.grey.shade100,
                        width: 1.5, 
                      ),
                    ),
                    child: TextField(
                      controller: messageController,
                      enabled: isJoined,
                      decoration: InputDecoration(
                        hintText: isSending ? 'Sending...' : 'Type your message here...',
                        hintStyle: TextStyle(color: isJoined ? Colors.grey : Colors.grey.shade400, fontFamily: 'Time New Roman'),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  margin: const EdgeInsets.only(right: 10, bottom: 10, top: 10),
                  child: InkWell(
                    onTap: () async {
                      if (isJoined) {
                        await sendMessage();
                      } else {
                        await joinChannel();
                      }
                    },
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.blue,
                      child: Icon(
                        isJoined ? Icons.send : Icons.login,
                        color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          /*if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),*/
        ],
      ),
    );
  }
}
