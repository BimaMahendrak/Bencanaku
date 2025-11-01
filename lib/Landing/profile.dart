import 'package:flutter/material.dart';
import '../services/sessionService.dart';
import '../controller/loginController.dart';
import '../controller/profileController.dart';
import 'notificationTest.dart';
import 'editProfile.dart';
import 'kesanpesan.dart'; // Import halaman kesan pesan
import 'widgets/profileHeader.dart';
import 'widgets/profileCard.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? username;
  Map<String, dynamic>? userData;

  final ProfileController _profileController = ProfileController();
  final ValueNotifier<bool> _isUploading = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isRefreshing = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _isRefreshing.value = true;

    try {
      final user = await SessionService.getUsername();
      final freshUserData = await _profileController.getUserData();

      setState(() {
        username = user;
        userData = freshUserData;
      });
    } catch (e) {
      print('Error loading user data: $e');
      final sessionData = await SessionService.getUserData();
      setState(() {
        userData = sessionData;
      });
    } finally {
      _isRefreshing.value = false;
    }
  }

  Future<void> _handleUploadPhoto() async {
    final success = await _profileController.uploadPhoto(context, _isUploading);

    if (success) {
      await _loadUserData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto profile berhasil diupload!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _handleLogout() async {
    final loginController = LoginController();
    await loginController.handleLogout(context);
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(userData: userData),
      ),
    ).then((_) {
      _loadUserData();
    });
  }

  void _navigateToNotificationTest() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationTestPage(),
      ),
    );
  }

  void _navigateToKesanPesan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const KesanPesanPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadUserData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header
                ProfileHeader(
                  isRefreshing: _isRefreshing,
                  onRefresh: _loadUserData,
                  onEditProfile: _navigateToEditProfile,
                  onNotificationTest: _navigateToNotificationTest,
                ),

                const SizedBox(height: 30),

                // Profile Card
                ProfileCard(
                  username: username,
                  userData: userData,
                  isUploading: _isUploading,
                  onUploadPhoto: _handleUploadPhoto,
                ),

                const SizedBox(height: 30),

                // Menu Options - GANTI BUTTON JADI MENU
                _buildMenuSection(),

                const SizedBox(height: 30),

                // Logout Button - TETAP TERPISAH
                _buildLogoutButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Menu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),

          // Edit Profile
          _buildMenuItem(
            icon: Icons.edit,
            title: 'Edit Profile',
            subtitle: 'Ubah informasi profile Anda',
            color: const Color(0xFF6BB6FF),
            onTap: _navigateToEditProfile,
          ),

          const SizedBox(height: 12),

          // Test Notifikasi
          _buildMenuItem(
            icon: Icons.notifications_active,
            title: 'Test Notifikasi',
            subtitle: 'Uji coba sistem peringatan darurat',
            color: const Color(0xFFFF9800),
            onTap: _navigateToNotificationTest,
          ),

          const SizedBox(height: 12),

          // Kesan & Pesan
          _buildMenuItem(
            icon: Icons.favorite,
            title: 'Kesan & Pesan',
            subtitle: 'Refleksi pengembangan aplikasi',
            color: const Color(0xFFE91E63),
            onTap: _navigateToKesanPesan,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(),
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleLogout();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _profileController.dispose();
    _isUploading.dispose();
    _isRefreshing.dispose();
    super.dispose();
  }
}
