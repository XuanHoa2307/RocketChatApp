import 'package:flutter/material.dart';

class ChannelWidget extends StatelessWidget {
  final String channelName;
  final VoidCallback onTap;

  const ChannelWidget({
    super.key,
    required this.channelName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0), // Khoảng cách giữa các kênh
      padding: const EdgeInsets.all(1.0), // Khoảng cách bên trong mỗi kênh
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: ListTile(
        leading: const Text(
          '#',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        title: Text(
          channelName,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
