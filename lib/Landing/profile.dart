import 'package:flutter/material.dart';
import '../services/sessionService.dart';
import '../controller/loginController.dart';
import '../controller/profileController.dart';

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

  // Update fungsi _loadUserData untuk mengambil data terbaru dari server
  Future<void> _loadUserData() async {
    _isRefreshing.value = true;

    try {
      // Ambil username dari session
      final user = await SessionService.getUsername();

      // Ambil data terbaru dari server melalui ProfileController
      final freshUserData = await _profileController.getUserData();

      setState(() {
        username = user;
        userData = freshUserData;
      });

      print('Loaded user data: $userData');
      print('Photo URL: ${userData?['url_foto']}');
    } catch (e) {
      print('Error loading user data: $e');

      // Fallback ke session data jika error
      final sessionData = await SessionService.getUserData();
      setState(() {
        userData = sessionData;
      });
    } finally {
      _isRefreshing.value = false;
    }
  }

  // Update fungsi _handleUploadPhoto untuk refresh setelah upload
  Future<void> _handleUploadPhoto() async {
    final success = await _profileController.uploadPhoto(context, _isUploading);

    if (success) {
      // Refresh data setelah upload berhasil
      await _loadUserData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto profile berhasil diupload!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadUserData, // Tambahkan pull to refresh
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header dengan refresh indicator
                Row(
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
                        // Refresh button
                        ValueListenableBuilder<bool>(
                          valueListenable: _isRefreshing,
                          builder: (context, isRefreshing, child) {
                            return IconButton(
                              onPressed: isRefreshing ? null : _loadUserData,
                              icon: isRefreshing
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.refresh,
                                      color: Color(0xFF6BB6FF),
                                      size: 28,
                                    ),
                            );
                          },
                        ),
                        IconButton(
                          onPressed: _navigateToEditProfile,
                          icon: const Icon(
                            Icons.edit,
                            color: Color(0xFF6BB6FF),
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Profile Card dengan foto yang diperbarui
                Container(
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
                      Stack(
                        children: [
                          // CircleAvatar dengan error handling untuk foto
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: const Color(0xFF6BB6FF),
                            backgroundImage: _buildProfileImage(),
                            child: _buildProfileIcon(),
                          ),

                          // Tombol kamera untuk upload foto
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _handleUploadPhoto,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6BB6FF),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ValueListenableBuilder<bool>(
                                  valueListenable: _isUploading,
                                  builder: (context, isUploading, child) {
                                    return isUploading
                                        ? const SizedBox(
                                            height: 16,
                                            width: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
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

                      // Tambahkan status foto
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
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
                              _hasProfilePhoto()
                                  ? Icons.check_circle
                                  : Icons.photo_camera,
                              size: 14,
                              color: _hasProfilePhoto()
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFFFF9800),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _hasProfilePhoto()
                                  ? 'Foto Profile Aktif'
                                  : 'Belum Ada Foto',
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
                              // _buildInfoRow(
                              //   'User ID',
                              //   userData!['id'].toString(),
                              // ),
                              _buildInfoRow('Username', userData!['username']),
                              _buildInfoRow(
                                'Bergabung',
                                _formatDate(userData!['created_at']),
                              ),
                              if (userData!['url_foto'] != null) ...[
                                _buildInfoRow('Foto Profile', 'Tersedia'),
                                // _buildInfoRow(
                                //   'URL Foto',
                                //   userData!['url_foto'],
                                // ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Edit Profile Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _navigateToEditProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6BB6FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _showLogoutDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // function untuk build profile image dengan error handling
  ImageProvider? _buildProfileImage() {
    final photoUrl = userData?['url_foto'];
    if (photoUrl != null && photoUrl.toString().isNotEmpty) {
      return NetworkImage(photoUrl.toString());
    }
    return null;
  }

  // function untuk build profile icon
  Widget? _buildProfileIcon() {
    final photoUrl = userData?['url_foto'];
    if (photoUrl == null || photoUrl.toString().isEmpty) {
      return const Icon(Icons.person, size: 60, color: Colors.white);
    }
    return null;
  }

  // function untuk cek apakah ada foto profile
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
            onPressed: () async {
              Navigator.pop(context);
              await _handleLogout();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
      // Refresh data setelah kembali dari edit
      _loadUserData();
    });
  }

  @override
  void dispose() {
    _profileController.dispose();
    _isUploading.dispose();
    _isRefreshing.dispose();
    super.dispose();
  }
}

// Edit Profile Page dengan foto upload juga
class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const EditProfilePage({super.key, this.userData});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ProfileController _profileController = ProfileController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isUploading = ValueNotifier<bool>(false);
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.userData != null) {
      _profileController.namaLengkapController.text =
          widget.userData!['nama_lengkap'] ?? '';
      _profileController.usernameController.text =
          widget.userData!['username'] ?? '';
    }
  }

  Future<void> _handleUpdateProfile() async {
    final success = await _profileController.updateProfile(
      context,
      _formKey,
      _isLoading,
    );

    if (success) {
      Navigator.pop(context); // Kembali ke profile page
    }
  }

  // Tambahkan fungsi upload foto di edit page juga
  Future<void> _handleUploadPhoto() async {
    final success = await _profileController.uploadPhoto(context, _isUploading);

    if (success) {
      // Refresh widget userData jika perlu
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Foto berhasil diupload! Kembali ke profile untuk melihat perubahan.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _profileController.dispose();
    _isLoading.dispose();
    _isUploading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF6BB6FF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Section dengan upload foto
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: const Color(0xFF6BB6FF),
                        backgroundImage: widget.userData?['url_foto'] != null
                            ? NetworkImage(widget.userData!['url_foto'])
                            : null,
                        child: widget.userData?['url_foto'] == null
                            ? const Icon(
                                Icons.person,
                                size: 70,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _handleUploadPhoto,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: ValueListenableBuilder<bool>(
                              valueListenable: _isUploading,
                              builder: (context, isUploading, child) {
                                return isUploading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Color(0xFF6BB6FF),
                                              ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.camera_alt,
                                        size: 20,
                                        color: Color(0xFF6BB6FF),
                                      );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Form Fields
                _buildTextField(
                  controller: _profileController.namaLengkapController,
                  label: 'Nama Lengkap',
                  icon: Icons.person_outline,
                  validator: _profileController.validateNamaLengkap,
                ),

                const SizedBox(height: 16),

                _buildTextField(
                  controller: _profileController.usernameController,
                  label: 'Username',
                  icon: Icons.alternate_email,
                  validator: _profileController.validateUsername,
                ),

                const SizedBox(height: 16),

                _buildTextField(
                  controller: _profileController.passwordController,
                  label: 'Password Baru (Opsional)',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  validator: _profileController.validatePassword,
                ),

                const SizedBox(height: 8),

                // Info text untuk password
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF6BB6FF).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: const Color(0xFF6BB6FF),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Kosongkan jika tidak ingin mengubah password',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6BB6FF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Update Button
                ValueListenableBuilder<bool>(
                  valueListenable: _isLoading,
                  builder: (context, isLoading, child) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleUpdateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6BB6FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: Colors.grey[300],
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Update Profile',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Cancel Button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFF6BB6FF)),
                      ),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6BB6FF),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !_showPassword,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF6BB6FF)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF6BB6FF),
                  ),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6BB6FF), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
