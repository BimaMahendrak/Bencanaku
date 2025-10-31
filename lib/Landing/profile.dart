import 'package:flutter/material.dart';
import '../services/sessionService.dart';
import '../controller/loginController.dart';
import '../controller/profileController.dart';
import 'notificationTest.dart';
import 'editProfile.dart';
import 'widgets/profileHeader.dart';
import 'widgets/profileCard.dart';
import 'widgets/profileButtons.dart';

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

                // Action Buttons
                ProfileButtons(
                  onNotificationTest: _navigateToNotificationTest,
                  onEditProfile: _navigateToEditProfile,
                  onLogout: _handleLogout,
                ),
              ],
            ),
          ),
        ),
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
