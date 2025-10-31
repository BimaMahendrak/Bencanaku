import 'package:flutter/material.dart';
import '../controller/profileController.dart';

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
      Navigator.pop(context);
    }
  }

  Future<void> _handleUploadPhoto() async {
    final success = await _profileController.uploadPhoto(context, _isUploading);

    if (success) {
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
              children: [
                // Profile Photo Section
                _buildPhotoSection(),

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

                // Password Info
                _buildPasswordInfo(),

                const SizedBox(height: 30),

                // Action Buttons
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: const Color(0xFF6BB6FF),
            backgroundImage: widget.userData?['url_foto'] != null
                ? NetworkImage(widget.userData!['url_foto'])
                : null,
            child: widget.userData?['url_foto'] == null
                ? const Icon(Icons.person, size: 70, color: Colors.white)
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
                              valueColor: AlwaysStoppedAnimation<Color>(
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

  Widget _buildPasswordInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF6BB6FF).withOpacity(0.3),
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: Color(0xFF6BB6FF)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Kosongkan jika tidak ingin mengubah password',
              style: TextStyle(fontSize: 12, color: Color(0xFF6BB6FF)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
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
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
    );
  }

  @override
  void dispose() {
    _profileController.dispose();
    _isLoading.dispose();
    _isUploading.dispose();
    super.dispose();
  }
}