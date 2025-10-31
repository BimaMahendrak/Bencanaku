import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final String? username;
  final Map<String, dynamic>? userData;
  final ValueNotifier<bool> isUploading;
  final VoidCallback onUploadPhoto;

  const ProfileCard({
    super.key,
    required this.username,
    required this.userData,
    required this.isUploading,
    required this.onUploadPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Photo
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFF6BB6FF),
                backgroundImage: _buildProfileImage(),
                child: _buildProfileIcon(),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onUploadPhoto,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6BB6FF),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ValueListenableBuilder<bool>(
                      valueListenable: isUploading,
                      builder: (context, uploading, child) {
                        return uploading
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
                              );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // User Info
          Text(
            userData?['nama_lengkap'] ?? username ?? 'Loading...',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '@${username ?? 'loading'}',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
            ),
          ),

          const SizedBox(height: 8),

          // Photo Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _hasProfilePhoto()
                  ? const Color(0xFFE8F5E8)
                  : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _hasProfilePhoto() ? Icons.check_circle : Icons.photo_camera,
                  size: 14,
                  color: _hasProfilePhoto()
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFFF9800),
                ),
                const SizedBox(width: 4),
                Text(
                  _hasProfilePhoto() ? 'Foto Profile Aktif' : 'Belum Ada Foto',
                  style: TextStyle(
                    fontSize: 12,
                    color: _hasProfilePhoto()
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFFF9800),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // User Details
          if (userData != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Username', userData!['username']),
                  _buildInfoRow('Bergabung', _formatDate(userData!['created_at'])),
                  if (userData!['url_foto'] != null)
                    _buildInfoRow('Foto Profile', 'Tersedia'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  ImageProvider? _buildProfileImage() {
    final photoUrl = userData?['url_foto'];
    if (photoUrl != null && photoUrl.toString().isNotEmpty) {
      return NetworkImage(photoUrl.toString());
    }
    return null;
  }

  Widget? _buildProfileIcon() {
    final photoUrl = userData?['url_foto'];
    if (photoUrl == null || photoUrl.toString().isEmpty) {
      return const Icon(Icons.person, size: 60, color: Colors.white);
    }
    return null;
  }

  bool _hasProfilePhoto() {
    final photoUrl = userData?['url_foto'];
    return photoUrl != null && photoUrl.toString().isNotEmpty;
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF7F8C8D),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(color: Color(0xFF7F8C8D))),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2C3E50),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '-';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}