import 'dart:ui';

import 'package:flutter/material.dart';

class MessageWidget extends StatelessWidget {
  final String sender;
  final String message;
  final bool isCurrentUser;

  const MessageWidget({
    super.key,
    required this.sender,
    required this.message,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Hiển thị username (chỉ cho người khác)
          if (!isCurrentUser)
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Text(
                sender,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
          // Hiển thị nội dung tin nhắn với minWidth
          LayoutBuilder(
            builder: (context, constraints) {
              final textPainter = TextPainter(
                text: TextSpan(
                  text: sender,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                textDirection: TextDirection.ltr,
              )..layout();

              final minWidth = textPainter.width + 7; // Thêm padding (8 * 2)

              return Container(
                constraints: BoxConstraints(
                  minWidth: minWidth, // Đặt chiều rộng tối thiểu
                ),
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isCurrentUser
                      ? Colors.lightGreenAccent.shade100 // Màu xanh lá sáng
                      : Colors.blue[100],// Màu xanh lá cho người khác
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(10),
                    topRight: const Radius.circular(10),
                    bottomLeft: isCurrentUser
                        ? const Radius.circular(10)
                        : const Radius.circular(0),
                    bottomRight: isCurrentUser
                        ? const Radius.circular(0)
                        : const Radius.circular(10),
                  ),
                ),
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Roboto', // Font hỗ trợ Unicode
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
