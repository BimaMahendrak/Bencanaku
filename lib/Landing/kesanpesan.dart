import 'package:flutter/material.dart';

class KesanPesanPage extends StatefulWidget {
  const KesanPesanPage({super.key});

  @override
  State<KesanPesanPage> createState() => _KesanPesanPageState();
}

class _KesanPesanPageState extends State<KesanPesanPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Kesan & Pesan',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF6BB6FF),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header App
              _buildHeader(),

              const SizedBox(height: 20),

              // Developer Info
              _buildDeveloperInfo(),

              const SizedBox(height: 16),

              // Kesan Section
              _buildSection(
                icon: Icons.sentiment_very_satisfied,
                title: 'Kesan Pengembangan',
                color: const Color(0xFF27AE60),
                content: _buildKesanContent(),
              ),

              const SizedBox(height: 16),

              // Pesan Section
              _buildSection(
                icon: Icons.lightbulb_outline,
                title: 'Pesan & Pembelajaran',
                color: const Color(0xFFF39C12),
                content: _buildPesanContent(),
              ),

              const SizedBox(height: 16),

              // Terima Kasih
              _buildThanksCard(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6BB6FF), Color(0xFF5DADE2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6BB6FF).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.warning_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'BencanaKu',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Aplikasi Monitoring Gempa Bumi',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Proyek Akhir • Semester 5',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6BB6FF), Color(0xFF5DADE2)],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.person,
              size: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bima Mahendra',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Flutter Mobile Developer',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF6BB6FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Mobile Dev',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF6BB6FF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Color color,
    required Widget content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildKesanContent() {
    return Column(
      children: [
        _buildPointItem(
          '🚀',
          'Pengembangan aplikasi BencanaKu memberikan pengalaman yang sangat berharga dalam mobile development.',
        ),
        const SizedBox(height: 8),
        _buildPointItem(
          '💡',
          'Belajar mengintegrasikan API BMKG dan handling real-time data meningkatkan skill programming.',
        ),
        const SizedBox(height: 8),
        _buildPointItem(
          '🎨',
          'Mendesain UI/UX yang user-friendly sambil mempertahankan fungsionalitas yang kompleks.',
        ),
        const SizedBox(height: 8),
        _buildPointItem(
          '📱',
          'Flutter terbukti sangat powerful untuk rapid development dengan hot reload yang membantu.',
        ),
      ],
    );
  }

  Widget _buildPesanContent() {
    return Column(
      children: [
        _buildPointItem(
          '🔥',
          'Flutter Development: Widget system dan state management sangat membantu dalam membangun aplikasi responsive.',
        ),
        const SizedBox(height: 8),
        _buildPointItem(
          '🌐',
          'API Integration: Pengalaman mengintegrasikan REST API membuka wawasan tentang real-time data processing.',
        ),
        const SizedBox(height: 8),
        _buildPointItem(
          '🎯',
          'Problem Solving: Setiap challenge menjadi pembelajaran berharga dalam development process.',
        ),
        const SizedBox(height: 8),
        _buildPointItem(
          '🚀',
          'Future: Aplikasi ini memiliki potensi untuk dikembangkan dengan ML dan IoT integration.',
        ),
      ],
    );
  }

  Widget _buildPointItem(String emoji, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF34495E),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThanksCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // GANTI: Dari hijau ke gradient yang lebih soft
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)], // Purple gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.3), // Update shadow color
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.favorite, color: Colors.white, size: 32),
          const SizedBox(height: 8),
          const Text(
            'Ucapan Terima Kasih',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Aplikasi ini selesai berkat suntikan kopi golda entah nescafe atau apapun itu, nasi telur, kentang goreng, dan tentunya support dari pihak-pihak yang entah kenapa mau direpotin:',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Terima kasih sebesar-besarnya buat Teman-teman (yang selalu ada buat ngetes error di jam 2 pagi), dan yang paling spesial, buat Pak Tua Billy yang sering ngomel tapi ilmunya mantap! Tanpa petuah "ngasal"-nya, mungkin kita masih nyari API Key Google Maps yang gratisan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Semoga aplikasi BencanaKu ini bermanfaat, dan semoga hidup Anda dijauhkan dari bug dan bencana. Amin.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '🇮🇩 Made with ❤️ by Bima Mahendra',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}