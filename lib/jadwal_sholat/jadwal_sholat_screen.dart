import 'package:bitaqwa/jadwal_sholat/waktu_sholat_model.dart';
import 'package:bitaqwa/jadwal_sholat/sholat_helper.dart';
import 'package:bitaqwa/jadwal_sholat/lokasi_service.dart';
import 'package:bitaqwa/jadwal_sholat/sholat_service.dart';
// Memakai palet lengkap (emas, surface, border, dll.) dari dashboard.
import 'package:bitaqwa/dashboard/color_constant.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// SCREEN JADWAL SHOLAT: Menampilkan jadwal sholat harian akurat sesuai lokasi pengguna
class JadwalSholatScreen extends StatefulWidget {
  const JadwalSholatScreen({super.key});

  @override
  State<JadwalSholatScreen> createState() => _JadwalSholatScreenState();
}

class _JadwalSholatScreenState extends State<JadwalSholatScreen> {
  // Variabel penampung state data lokasi dan waktu sholat
  String _location = "Mengambil lokasi...";
  bool _isLoading = true;
  PrayerTimeModel? prayerTime;

  @override
  void initState() {
    super.initState();
    // Saat layar pertama dibuka, langsung panggil loadData
    loadData();
  }

  // FUNGSI LOAD DATA: Mengambil koordinat GPS lalu meminta waktu sholat ke server Aladhan
  Future<void> loadData() async {
    setState(() {
      _isLoading = true;
      _location = "Mengambil lokasi...";
    });

    try {
      final location = await LocationService().getCurrentLocation();

      final prayer = await PrayerService().getPrayerTimes(
        latitude: location.latitude,
        longitude: location.longitude,
      );

      if (!mounted) return;
      setState(() {
        // Tampilkan "Kecamatan, Kota" kalau kecamatan tersedia
        _location = location.district.isNotEmpty
            ? "${location.district}, ${location.city}"
            : location.city;
        prayerTime = prayer;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        prayerTime = null;
        _location = "Lokasi tidak tersedia";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sholat berikutnya hanya dihitung kalau data jadwal sudah ada
    final dynamic next = (!_isLoading && prayerTime != null)
        ? PrayerHelper.getNextPrayer(prayerTime!)
        : null;

    return Scaffold(
      backgroundColor: ColorConstant.colorAccent,
      // Header selalu tampil (supaya tombol kembali tetap ada saat loading/error)
      body: Column(
        children: [
          _buildHeader(context, next),
          Expanded(child: _buildBody(next)),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(BuildContext context, dynamic next) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        24,
      ),
      decoration: const BoxDecoration(
        color: ColorConstant.colorPrimaryDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _circleButton(
                Icons.arrow_back_ios_new_rounded,
                'Kembali',
                () => Navigator.pop(context),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Jadwal Sholat',
                      style: TextStyle(
                        color: ColorConstant.colorAccent,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: ColorConstant.colorGold,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: ColorConstant.colorGold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Tombol muat ulang lokasi & jadwal
              _circleButton(
                Icons.refresh_rounded,
                'Muat ulang',
                _isLoading ? null : loadData,
              ),
            ],
          ),

          // Kartu sholat berikutnya (hanya kalau data sudah ada)
          if (next != null) ...[
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: ColorConstant.colorPrimary,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: ColorConstant.colorGold.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SHOLAT BERIKUTNYA',
                            style: TextStyle(
                              color: ColorConstant.colorGold,
                              fontSize: 11,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            next['name'],
                            style: const TextStyle(
                              color: ColorConstant.colorAccent,
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              height: 1.05,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        next['time'],
                        style: const TextStyle(
                          color: ColorConstant.colorAccent,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    height: 1,
                    color: ColorConstant.colorAccent.withValues(alpha: 0.14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: ColorConstant.colorGold,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat(
                          'EEEE, d MMMM yyyy',
                          'id_ID',
                        ).format(DateTime.now()),
                        style: const TextStyle(
                          color: Color(0xFFD6E4DB),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Tombol bulat dengan garis emas tipis; onTap null = tombol nonaktif
  Widget _circleButton(IconData icon, String tooltip, VoidCallback? onTap) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ColorConstant.colorWhite.withValues(alpha: 0.06),
        border: Border.all(
          color: ColorConstant.colorGold.withValues(alpha: 0.4),
        ),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        tooltip: tooltip,
        icon: Icon(
          icon,
          color: onTap == null
              ? ColorConstant.colorOnDarkMuted
              : ColorConstant.colorAccent,
          size: 20,
        ),
        onPressed: onTap,
      ),
    );
  }

  // ================= ISI HALAMAN (loading / error / daftar) =================
  Widget _buildBody(dynamic next) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: ColorConstant.colorPrimary),
      );
    }

    if (prayerTime == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 60,
                color: ColorConstant.colorPrimary.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              const Text(
                'Gagal mengambil jadwal sholat',
                style: TextStyle(
                  color: ColorConstant.colorText,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Periksa GPS, izin lokasi, dan koneksi internet.',
                textAlign: TextAlign.center,
                style: TextStyle(color: ColorConstant.colorMuted, fontSize: 12),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: loadData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstant.colorPrimaryDark,
                  foregroundColor: ColorConstant.colorAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: _buildPrayerCard(next),
    );
  }

  // ================= DAFTAR WAKTU SHOLAT =================
  Widget _buildPrayerCard(dynamic next) {
    final prayers = <({String name, String time, IconData icon})>[
      (name: "Subuh", time: prayerTime!.fajr, icon: Icons.wb_twilight),
      (name: "Dzuhur", time: prayerTime!.dhuhr, icon: Icons.wb_sunny_outlined),
      (name: "Ashar", time: prayerTime!.asr, icon: Icons.wb_cloudy_outlined),
      (name: "Maghrib", time: prayerTime!.maghrib, icon: Icons.wb_twilight),
      (name: "Isya", time: prayerTime!.isha, icon: Icons.nightlight_outlined),
    ];
    final nextName = next?['name'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: BoxDecoration(
        color: ColorConstant.colorSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ColorConstant.colorBorder),
        boxShadow: [
          BoxShadow(
            color: ColorConstant.colorPrimaryDark.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: prayers.map((p) {
          // Baris sholat berikutnya diberi latar hijau gelap
          final isNext = p.name == nextName;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isNext ? ColorConstant.colorPrimaryDark : null,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isNext
                        ? ColorConstant.colorPrimary
                        : ColorConstant.colorPrimaryDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(p.icon, color: ColorConstant.colorGold, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    p.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isNext
                          ? ColorConstant.colorAccent
                          : ColorConstant.colorText,
                    ),
                  ),
                ),
                Text(
                  p.time,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isNext
                        ? ColorConstant.colorGold
                        : ColorConstant.colorPrimary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
