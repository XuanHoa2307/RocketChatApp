import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final String username;
  final String selectedItem;
  final Function(String) onItemSelected;

  const AppDrawer({
    Key? key,
    required this.username,
    required this.selectedItem,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.6, // Thu hẹp Drawer
      child: Column(
        
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header của Drawer
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
            color: Color.fromARGB(255, 163, 160, 239)), // Màu nền cho header
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.account_circle, size: 40),
              
            ),
            
            accountName: Text(
              username,
              style: const TextStyle(
                color: Color.fromARGB(255, 27, 8, 136),
                fontSize: 18, // Tăng kích thước font
                fontWeight: FontWeight.bold, // In đậm
              ),
            ),
            accountEmail: const Text(""),
          ),
          // Các mục trong Drawer
          _buildDrawerItem(
            context: context,
            title: 'Chat',
            icon: Icons.chat,
            isSelected: selectedItem == 'Chat',
            onTap: () => onItemSelected('Chat'),
          ),
          _buildDrawerItem(
            context: context,
            title: 'Profile',
            icon: Icons.person,
            isSelected: selectedItem == 'Profile',
            onTap: () => onItemSelected('Profile'),
          ),
          _buildDrawerItem(
            context: context,
            title: 'Settings',
            icon: Icons.settings,
            isSelected: selectedItem == 'Settings',
            onTap: () => onItemSelected('Settings'),
          ),
          _buildDrawerItem(
            context: context,
            title: 'Log out',
            icon: Icons.logout,
            isSelected: selectedItem == 'Log out',
            onTap: () => onItemSelected('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      color: isSelected ? Colors.grey.shade300 : Colors.transparent,
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.black : Colors.grey,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, 
            fontSize: 16,
            color: isSelected ? Colors.black : Colors.grey,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
