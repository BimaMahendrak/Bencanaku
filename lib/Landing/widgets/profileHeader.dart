import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final ValueNotifier<bool> isRefreshing;
  final VoidCallback onRefresh;
  final VoidCallback onEditProfile;
  final VoidCallback onNotificationTest;

  const ProfileHeader({
    super.key,
    required this.isRefreshing,
    required this.onRefresh,
    required this.onEditProfile,
    required this.onNotificationTest,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        Row(
          children: [
            // Refresh Button
            ValueListenableBuilder<bool>(
              valueListenable: isRefreshing,
              builder: (context, refreshing, child) {
                return IconButton(
                  onPressed: refreshing ? null : onRefresh,
                  icon: refreshing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(
                          Icons.refresh,
                          color: Color(0xFF6BB6FF),
                          size: 28,
                        ),
                );
              },
            ),
            // Edit Button
            IconButton(
              onPressed: onEditProfile,
              icon: const Icon(
                Icons.edit,
                color: Color(0xFF6BB6FF),
                size: 28,
              ),
            ),
          ],
        ),
      ],
    );
  }
}