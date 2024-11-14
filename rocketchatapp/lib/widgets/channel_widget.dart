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
    return ListTile(
      title: Text(channelName),
      trailing: const Icon(Icons.arrow_forward),
      onTap: onTap,
    );
  }
}
