import 'package:bencanaku/controller/loginController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../controller/homeController.dart';
import '../utils/timezoneHelper.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final HomeController _homeController = HomeController();
  String? username;

  @override
  void initState() {
    super.initState();
    _homeController.fetchGempaData();
    _homeController.fetchUserLocation();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final loginController = LoginController();
    final user = await loginController.getUsername();

    setState(() {
      username = user;
    });
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
              // Header 
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Greeting berdasarkan waktu
                        ValueListenableBuilder<String>(
                          valueListenable: _homeController.greeting,
                          builder: (context, greetingText, child) {
                            return Text(
                              username != null ? '$greetingText, $username' : greetingText,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        
                        // Real-time clock dengan timezone
                        ValueListenableBuilder<DateTime>(
                          valueListenable: _homeController.currentTime,
                          builder: (context, currentTime, child) {
                            return ValueListenableBuilder<String>(
                              valueListenable: _homeController.currentTimezone,
                              builder: (context, timezone, child) {
                                String timeString = TimezoneHelper.formatTimeWithTimezone(
                                  currentTime, 
                                  timezone,
                                );
                                
                                return Text(
                                  timeString,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF7F8C8D),
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        
                        // Tanggal lengkap
                        ValueListenableBuilder<DateTime>(
                          valueListenable: _homeController.currentTime,
                          builder: (context, currentTime, child) {
                            String dateString = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(currentTime);
                            return Text(
                              dateString,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF7F8C8D),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  // Location widget (existing)
                  ValueListenableBuilder<String>(
                    valueListenable: _homeController.userCity,
                    builder: (context, cityName, child) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  color: Color(0xFF6BB6FF),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  cityName.isEmpty ? 'Mencari lokasi...' : cityName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF2C3E50),
                                  ),
                                ),
                              ],
                            ),
                            // Timezone indicator
                            ValueListenableBuilder<String>(
                              valueListenable: _homeController.currentTimezone,
                              builder: (context, timezone, child) {
                                String tzName = TimezoneHelper.getIndonesianTimezoneName(timezone);
                                return Text(
                                  tzName,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6BB6FF),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Earthquake Weekly Card (versi yang lebih menarik)
              ValueListenableBuilder<int>(
                valueListenable: _homeController.gempaWeeklyCount,
                builder: (context, weeklyCount, child) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF6BB6FF), Color(0xFF5DADE2)],
                        stops: [0.0, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6BB6FF).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Background pattern/decoration
                        Positioned(
                          top: -10,
                          right: -10,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -20,
                          left: -20,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                        ),

                        // Main content
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header dengan icon dan count
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Icon container yang lebih besar
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.waves,
                                            color: Colors.white,
                                            size: 32,
                                          ),
                                          const Text(
                                            'Gempa Bumi',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const Text(
                                            '7 Hari Terakhir',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.white70,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                  ],
                                ),
                                SizedBox(width: 30),
                                // Total Kejadian section
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Total',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$weeklyCount',
                                      style: const TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        height: 1,
                                      ),
                                    ),
                                    const Text(
                                      'kejadian',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // pembatas
                            Container(
                              width: double.infinity,
                              height: 1,
                              color: Colors.white.withOpacity(0.3),
                            ),

                            const SizedBox(height: 16),

                            // Statistik section yang lebih detail
                            ValueListenableBuilder<List<Map<String, dynamic>>>(
                              valueListenable: _homeController.gempaWeeklyData,
                              builder: (context, weeklyData, child) {
                                // Hitung statistik
                                int lowMagnitude = 0; // < 4.0
                                int mediumMagnitude = 0; // 4.0 - 5.9
                                int highMagnitude = 0; // >= 6.0

                                for (var gempa in weeklyData) {
                                  double magnitude =
                                      double.tryParse(
                                        gempa['magnitude'].toString(),
                                      ) ??
                                      0;
                                  if (magnitude < 4.0) {
                                    lowMagnitude++;
                                  } else if (magnitude < 6.0) {
                                    mediumMagnitude++;
                                  } else {
                                    highMagnitude++;
                                  }
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Klasifikasi Berdasarkan Magnitude',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // Progress bars untuk setiap kategori
                                    _buildMagnitudeBar(
                                      label: 'Ringan (< 4.0)',
                                      count: lowMagnitude,
                                      total: weeklyCount,
                                      color: const Color(0xFF27AE60),
                                      icon: Icons.radio_button_unchecked,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildMagnitudeBar(
                                      label: 'Sedang (4.0 - 5.9)',
                                      count: mediumMagnitude,
                                      total: weeklyCount,
                                      color: const Color(0xFFF39C12),
                                      icon: Icons.lens,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildMagnitudeBar(
                                      label: 'Kuat (≥ 6.0)',
                                      count: highMagnitude,
                                      total: weeklyCount,
                                      color: const Color(0xFFE74C3C),
                                      icon: Icons.circle,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    );
                },
              ),

              const SizedBox(height: 24),

              // Section gempa bumi terkini
              const Text(
                'Gempa Bumi Terkini',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),

              const SizedBox(height: 12),

              // Gempa Bumi Card
              ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: _homeController.gempaData,
                builder: (context, gempaData, child) {
                  if (gempaData.isEmpty) {
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
                      child: const Center(
                        child: Text('Mengambil data gempa...'),
                      ),
                    );
                  }

                  final gempa = gempaData.first;

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
                        // Distance and Date Info
                        ValueListenableBuilder<Position?>(
                          valueListenable: _homeController.userLocation,
                          builder: (context, userLocation, child) {
                            double? distance;
                            if (userLocation != null) {
                              distance = _homeController.calculateDistance(
                                userLocation.latitude,
                                userLocation.longitude,
                                gempa['latitude'],
                                gempa['longitude'],
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  distance != null
                                      ? '${distance.toStringAsFixed(0)} Km Dari Lokasi Anda'
                                      : 'Menghitung jarak...',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2C3E50),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${gempa['tanggal']}, ${gempa['jam']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF7F8C8D),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // FlutterMap
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: ValueListenableBuilder<Position?>(
                              valueListenable: _homeController.userLocation,
                              builder: (context, userLocation, child) {
                                return FlutterMap(
                                  options: MapOptions(
                                    initialCenter: LatLng(
                                      gempa['latitude'],
                                      gempa['longitude'],
                                    ),
                                    initialZoom: 6.0,
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate:
                                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    ),
                                    MarkerLayer(
                                      markers: [
                                        // Marker untuk lokasi gempa
                                        Marker(
                                          point: LatLng(
                                            gempa['latitude'],
                                            gempa['longitude'],
                                          ),
                                          width: 40,
                                          height: 40,
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.warning_rounded,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                        // Marker untuk lokasi user (jika tersedia)
                                        if (userLocation != null)
                                          Marker(
                                            point: LatLng(
                                              userLocation.latitude,
                                              userLocation.longitude,
                                            ),
                                            width: 40,
                                            height: 40,
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF6BB6FF),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.person_pin_circle,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Additional Info
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: Color(0xFF6BB6FF),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Magnitude: ${gempa['magnitude']} | Kedalaman: ${gempa['kedalaman']}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF7F8C8D),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  color: Color(0xFF6BB6FF),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    gempa['wilayah'],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF7F8C8D),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              gempa['potensi'],
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    gempa['potensi'].toLowerCase().contains(
                                      'tidak',
                                    )
                                    ? const Color(0xFF27AE60)
                                    : const Color(0xFFE74C3C),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    );
                },
              ),

              const SizedBox(height: 80), // Extra space for bottom navigation
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildMagnitudeBar({
  required String label,
  required int count,
  required int total,
  required Color color,
  required IconData icon,
}) {
  double percentage = total > 0 ? count / total : 0;

  return Row(
    children: [
      Icon(icon, color: color, size: 16),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.white.withOpacity(0.3),
              ),
              child: FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: color,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 8),
      Text(
        '$count',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
