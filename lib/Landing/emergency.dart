import 'package:flutter/material.dart';
import '../controller/emergencyController.dart';

/// Halaman Emergency Alert dengan fitur deteksi kemiringan HP
/// Menggunakan gyroscope untuk mendeteksi gerakan emergency
class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> with TickerProviderStateMixin {
  // Controller untuk menangani logic emergency
  final EmergencyController _emergencyController = EmergencyController();
  
  // Animation controller untuk efek pulse pada tombol emergency
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  // State variables
  double _currentTiltAngle = 0.0; // Sudut kemiringan saat ini
  bool _isMonitoring = false; // Status monitoring aktif/tidak
  List<String> _debugMessages = []; // Pesan debug untuk development

  @override
  void initState() {
    super.initState();
    
    // Inisialisasi animation controller untuk efek pulse
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    // Setup animasi pulse (membesar-mengecil)
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Setup callback functions untuk emergency controller
    _setupEmergencyController();
  }

  /// Setup callback functions untuk berkomunikasi dengan emergency controller
  void _setupEmergencyController() {
    // Callback saat sudut kemiringan berubah
    _emergencyController.onTiltAngleChanged = (angle) {
      setState(() {
        _currentTiltAngle = angle;
      });
    };

    // Callback saat emergency dipicu
    _emergencyController.onEmergencyTriggered = (triggered) {
      if (triggered) {
        _showEmergencyDialog();
        _pulseController.repeat(reverse: true); // Mulai animasi pulse
      }
    };

    // Callback untuk pesan debug
    _emergencyController.onDebugMessage = (message) {
      setState(() {
        // Tambahkan pesan debug dengan timestamp
        String timeStamp = DateTime.now().toString().substring(11, 19);
        _debugMessages.insert(0, '$timeStamp: $message');
        
        // Batasi jumlah pesan debug maksimal 10
        if (_debugMessages.length > 10) {
          _debugMessages.removeLast();
        }
      });
    };
  }

  /// Toggle monitoring emergency (aktif/nonaktif)
  void _toggleMonitoring() async {
    if (_isMonitoring) {
      // Hentikan monitoring
      _emergencyController.stopMonitoring();
      _pulseController.stop();
    } else {
      // Mulai monitoring
      await _emergencyController.startMonitoring();
    }
    
    setState(() {
      _isMonitoring = !_isMonitoring;
    });
  }

  /// Tampilkan dialog emergency saat alert dipicu
  void _showEmergencyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Tidak bisa ditutup dengan tap di luar
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red[700], size: 28),
            const SizedBox(width: 8),
            const Text(
              'DARURAT!',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Alert darurat telah diaktifkan!\nPilih tindakan yang ingin dilakukan:',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          // Tombol untuk berbagi lokasi
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _shareLocation();
            },
            icon: const Icon(Icons.share_location, color: Colors.blue),
            label: const Text('Bagikan Lokasi'),
          ),
          // Tombol untuk panggil 112
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _callEmergency();
            },
            icon: const Icon(Icons.phone, color: Colors.green),
            label: const Text('Panggil 112'),
          ),
          // Tombol batal
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pulseController.stop();
            },
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  /// Bagikan lokasi emergency
  void _shareLocation() async {
    try {
      await _emergencyController.shareEmergencyLocation();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Panggil nomor emergency
  void _callEmergency() async {
    try {
      await _emergencyController.callEmergency();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Bersihkan resources saat widget dihancurkan
    _emergencyController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header halaman
              const Center(
                child: Text(
                  'Alert Darurat',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Tombol emergency utama
              Center(child: _buildEmergencyButton()),

              const SizedBox(height: 30),

              // Indikator kemiringan HP
              _buildTiltIndicator(),

              const SizedBox(height: 20),

              // Instruksi penggunaan
              _buildInstructions(),

              const SizedBox(height: 20),

              // Tombol aksi emergency manual
              _buildManualActions(),

              const SizedBox(height: 20),

              // Info debug (untuk development)
              if (_debugMessages.isNotEmpty) _buildDebugInfo(),

              // Space tambahan untuk bottom navigation
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget tombol emergency utama dengan animasi
  Widget _buildEmergencyButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isMonitoring ? _pulseAnimation.value : 1.0,
          child: GestureDetector(
            onTap: _toggleMonitoring,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _isMonitoring 
                    ? [Colors.red[400]!, Colors.red[600]!] // Merah saat aktif
                    : [Colors.grey[400]!, Colors.grey[600]!], // Abu-abu saat nonaktif
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_isMonitoring ? Colors.red : Colors.grey).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isMonitoring ? Icons.emergency : Icons.emergency_outlined,
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isMonitoring ? 'AKTIF' : 'NONAKTIF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Widget indikator kemiringan HP
  Widget _buildTiltIndicator() {
    double progress = _emergencyController.tiltProgress;
    
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
          // Tampilan sudut kemiringan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sudut Kemiringan:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                '${_currentTiltAngle.toStringAsFixed(1)}°',
                style: TextStyle(
                  color: _currentTiltAngle >= 20 ? Colors.red : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Progress bar timer
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              progress > 0.8 ? Colors.red : Colors.orange,
            ),
          ),
          const SizedBox(height: 8),
          
          // Text status
          Text(
            progress > 0 
              ? 'Tahan ${(2 - (progress * 2)).toStringAsFixed(1)}s lagi...'
              : 'Miringkan HP 70° untuk memicu',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Widget instruksi penggunaan
  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700]),
              const SizedBox(width: 8),
              const Text(
                'Cara Menggunakan:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('1. Tap tombol untuk mengaktifkan monitoring'),
          const Text('2. Miringkan HP hingga 70° selama 5 detik'),
          const Text('3. Alert darurat akan otomatis muncul'),
        ],
      ),
    );
  }

  /// Widget tombol aksi emergency manual
  Widget _buildManualActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aksi Darurat Manual:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Tombol bagikan lokasi
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _shareLocation,
                icon: const Icon(Icons.share_location),
                label: const Text('Bagikan Lokasi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Tombol panggil 112
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _callEmergency,
                icon: const Icon(Icons.phone),
                label: const Text('Panggil 112'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Widget info debug untuk development
  Widget _buildDebugInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Info Debug:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Container(
            height: 100,
            width: double.infinity,
            child: ListView.builder(
              itemCount: _debugMessages.length,
              itemBuilder: (context, index) {
                return Text(
                  _debugMessages[index],
                  style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}