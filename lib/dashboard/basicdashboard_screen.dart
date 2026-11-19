import 'dart:async';
import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:bitaqwa/dashboard/menu_data.dart';
import 'package:bitaqwa/dashboard/color_constant.dart';
import 'package:bitaqwa/zakat/zakat_screen.dart';
import 'package:bitaqwa/doa_harian/doa_screen.dart';
import 'package:bitaqwa/jadwal_sholat/jadwal_sholat_screen.dart';
import 'package:bitaqwa/jadwal_sholat/lokasi_service.dart';
import 'package:bitaqwa/jadwal_sholat/sholat_service.dart';
import 'package:bitaqwa/kajian_online/video_kajian_screen.dart';

// Satu entri jadwal sholat (jam dan menit dalam waktu setempat).
class _PrayerTime {
  final String name;
  final int hour;
  final int minute;

  const _PrayerTime(this.name, this.hour, this.minute);

  // Format jam sama dengan layar Jadwal Sholat, contoh: 11:38
  String get label =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  int get secondsOfDay => hour * 3600 + minute * 60;
}

class BasicDashboardScreen extends StatefulWidget {
  const BasicDashboardScreen({super.key});

  @override
  State<BasicDashboardScreen> createState() => _BasicDashboardScreenState();
}

class _BasicDashboardScreenState extends State<BasicDashboardScreen> {
  // Slider quotes
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _quoteTimer;

  // Jam real time (waktu perangkat), diperbarui tiap detik
  late DateTime _now;
  Timer? _clockTimer;

  // Jadwal sholat asli dari lokasi pengguna (null = belum dimuat / gagal)
  List<_PrayerTime>? _schedule;
  bool _scheduleLoading = true;
  int?
  _loadedDay; // tanggal saat jadwal dimuat, untuk muat ulang saat ganti hari

  // Nama sholat untuk tampilan sementara saat jadwal belum tersedia
  static const List<String> _placeholderNames = [
    'Subuh',
    'Dzuhur',
    'Ashar',
    'Maghrib',
    'Isya',
  ];

  final List<Map<String, String>> islamicQuotes = [
    {
      "title": "Ingatlah Allah",
      "quote": "Hati akan menjadi tenang dengan mengingat Allah.",
      "ref": "QS. Ar-Ra'd: 28",
    },
    {
      "title": "Sabar & Sholat",
      "quote": "Jadikanlah sabar dan sholat sebagai penolongmu.",
      "ref": "QS. Al-Baqarah: 45",
    },
    {
      "title": "Nikmat Bersyukur",
      "quote":
          "Jika kamu bersyukur, niscaya Aku akan menambah nikmat kepadamu.",
      "ref": "QS. Ibrahim: 7",
    },
    {
      "title": "Berdoa pada-Nya",
      "quote": "Berdoalah kepada-Ku, niscaya akan Kuperkenankan bagimu.",
      "ref": "QS. Ghafir: 60",
    },
  ];

  static const List<String> _dayNames = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
  static const List<String> _monthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  // Waktu perangkat. Jam sholat dari API adalah waktu setempat lokasi
  // pengguna, jadi dibandingkan dengan jam perangkat (bukan WIB tetap).
  DateTime _localNow() => DateTime.now();

  @override
  void initState() {
    super.initState();
    _now = _localNow();

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = _localNow());

      // Ganti hari: ambil jadwal sholat yang baru
      if (!_scheduleLoading && _loadedDay != null && _now.day != _loadedDay) {
        _loadSchedule();
      }
    });

    _quoteTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % islamicQuotes.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });

    _loadSchedule();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _quoteTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // Mengubah teks jam dari API (contoh "04:03") jadi _PrayerTime
  _PrayerTime _toPrayerTime(String name, Object? raw) {
    final text = raw?.toString();
    final m = text == null
        ? null
        : RegExp(r'(\d{1,2})[:.](\d{2})').firstMatch(text);
    if (m == null) {
      throw FormatException('Format jam tidak dikenali: $raw');
    }
    return _PrayerTime(name, int.parse(m.group(1)!), int.parse(m.group(2)!));
  }

  // Mengambil jadwal sholat asli: lokasi GPS -> API jadwal sholat
  // (sumber data yang sama dengan layar Jadwal Sholat)
  Future<void> _loadSchedule() async {
    if (!_scheduleLoading) {
      setState(() => _scheduleLoading = true);
    }

    try {
      final location = await LocationService().getCurrentLocation();
      final dynamic prayer = await PrayerService().getPrayerTimes(
        latitude: location.latitude,
        longitude: location.longitude,
      );

      final list = <_PrayerTime>[
        _toPrayerTime('Subuh', prayer.fajr),
        _toPrayerTime('Dzuhur', prayer.dhuhr),
        _toPrayerTime('Ashar', prayer.asr),
        _toPrayerTime('Maghrib', prayer.maghrib),
        _toPrayerTime('Isya', prayer.isha),
      ];

      if (!mounted) return;
      setState(() {
        _schedule = list;
        _loadedDay = DateTime.now().day;
      });
    } catch (e, st) {
      debugPrint('Dashboard: gagal memuat jadwal sholat: $e\n$st');
      if (!mounted) return;
      setState(() => _schedule = null);
    } finally {
      if (mounted) setState(() => _scheduleLoading = false);
    }
  }

  // Membuka halaman sesuai menu yang ditekan.
  // Nilai route harus sama dengan field route di menu_data.dart.
  void _openMenu(String route, String title) {
    final Widget? page = switch (route) {
      'doa' => const DoaScreen(),
      'sholat' => const JadwalSholatScreen(),
      'kajian' => const VideoKajianScreen(),
      'zakat' => const ZakatScreen(),
      _ => null,
    };

    // Menu yang belum punya halaman: tampilkan info singkat
    if (page == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('$title segera hadir')));
      return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  String get _clockLabel =>
      '${_two(_now.hour)}:${_two(_now.minute)}:${_two(_now.second)}';

  String get _dateLabel =>
      '${_dayNames[_now.weekday - 1]}, ${_now.day} ${_monthNames[_now.month - 1]} ${_now.year}';

  // Mencari sholat berikutnya dan sisa waktunya (detik)
  _PrayerTime _nextPrayer(
    List<_PrayerTime> schedule,
    int nowSec,
    void Function(int) onRemaining,
  ) {
    _PrayerTime next = schedule.first;
    int best = 1 << 30;
    for (final p in schedule) {
      int diff = p.secondsOfDay - nowSec;
      if (diff <= 0) diff += 86400;
      if (diff < best) {
        best = diff;
        next = p;
      }
    }
    onRemaining(best);
    return next;
  }

  @override
  Widget build(BuildContext context) {
    final nowSec = _now.hour * 3600 + _now.minute * 60 + _now.second;
    int remaining = 0;
    _PrayerTime? next;

    final schedule = _schedule;
    if (schedule != null && schedule.isNotEmpty) {
      next = _nextPrayer(schedule, nowSec, (r) => remaining = r);
    }

    return Scaffold(
      backgroundColor: ColorConstant.colorAccent,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                _buildHeader(context, next, remaining),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: -34,
                  child: _buildPrayerStrip(next),
                ),
              ],
            ),
            const SizedBox(height: 54),
            _buildQuoteSlider(),
            const SizedBox(height: 26),
            _buildMenuSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(BuildContext context, _PrayerTime? next, int remaining) {
    final h = remaining ~/ 3600;
    final m = (remaining % 3600) ~/ 60;
    final s = remaining % 60;
    final loaded = next != null;

    // Teks kartu "sholat berikutnya" (ada versi sementara saat memuat / gagal)
    final countdown = loaded ? '${_two(h)}:${_two(m)}:${_two(s)}' : '--:--:--';
    final title =
        next?.name ?? (_scheduleLoading ? 'Memuat...' : 'Gagal memuat');
    final subtitle =
        next?.label ??
        (_scheduleLoading
            ? 'Mengambil jadwal sesuai lokasi'
            : 'Ketuk untuk coba lagi');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 24,
        20,
        56,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Assalamu'alaikum,",
                      style: TextStyle(
                        color: ColorConstant.colorOnDarkMuted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "Muhammad Hafidz",
                      style: TextStyle(
                        color: ColorConstant.colorAccent,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _dateLabel,
                      style: const TextStyle(
                        color: ColorConstant.colorGold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _circleButton(Icons.search, 'Cari', () {}),
              const SizedBox(width: 10),
              _circleButton(Icons.explore_outlined, 'Arah kiblat', () {}),
            ],
          ),
          const SizedBox(height: 22),

          // Kartu sholat berikutnya (diketuk untuk mencoba lagi kalau gagal)
          GestureDetector(
            onTap: (!loaded && !_scheduleLoading) ? _loadSchedule : null,
            child: Container(
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
                      Expanded(
                        child: Column(
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
                              title,
                              style: const TextStyle(
                                color: ColorConstant.colorAccent,
                                fontSize: 34,
                                fontWeight: FontWeight.w700,
                                height: 1.05,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                color: Color(0xFFD6E4DB),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'tersisa',
                            style: TextStyle(
                              color: ColorConstant.colorOnDarkMuted,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            countdown,
                            style: const TextStyle(
                              color: ColorConstant.colorAccent,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
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
                      const Text(
                        'Waktu real time',
                        style: TextStyle(
                          color: Color(0xFFD6E4DB),
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _clockLabel,
                        style: const TextStyle(
                          color: ColorConstant.colorGold,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, String tooltip, VoidCallback onTap) {
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
        icon: Icon(icon, color: ColorConstant.colorAccent, size: 20),
        onPressed: onTap,
      ),
    );
  }

  // ================= BARIS JADWAL SHOLAT =================
  Widget _buildPrayerStrip(_PrayerTime? next) {
    // Kalau jadwal belum ada, tampilkan nama sholat dengan jam "--:--"
    final schedule = _schedule;
    final entries = schedule != null
        ? schedule
              .map(
                (p) =>
                    (name: p.name, label: p.label, isNext: identical(p, next)),
              )
              .toList()
        : _placeholderNames
              .map((n) => (name: n, label: '--:--', isNext: false))
              .toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: BoxDecoration(
        color: ColorConstant.colorSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ColorConstant.colorBorder),
        boxShadow: [
          BoxShadow(
            color: ColorConstant.colorPrimaryDark.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: entries.map((e) {
          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: e.isNext ? ColorConstant.colorPrimaryDark : null,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    e.name,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: e.isNext
                          ? const Color(0xFFD6E4DB)
                          : ColorConstant.colorMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    e.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: e.isNext
                          ? ColorConstant.colorGold
                          : ColorConstant.colorText,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ================= KUTIPAN (AUTO SLIDE) =================
  Widget _buildQuoteSlider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: BoxDecoration(
        color: ColorConstant.colorQuoteBg,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 112,
            child: PageView.builder(
              controller: _pageController,
              itemCount: islamicQuotes.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, i) {
                final q = islamicQuotes[i];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.format_quote,
                          color: ColorConstant.colorGoldDark,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            q["title"]!,
                            style: const TextStyle(
                              color: ColorConstant.colorPrimaryDark,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      q["quote"]!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: ColorConstant.colorText,
                        fontSize: 16,
                        height: 1.3,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      q["ref"]!,
                      style: const TextStyle(
                        color: Color(0xFF5E5230),
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: List.generate(
              islamicQuotes.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(left: 5),
                width: _currentPage == i ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentPage == i
                      ? ColorConstant.colorPrimaryDark
                      : const Color(0xFFB9AC86),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= MENU UTAMA (GRID 2x2) =================
  Widget _buildMenuSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Menu Utama",
                style: TextStyle(
                  color: ColorConstant.colorText,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                "Lengkap & praktis",
                style: TextStyle(
                  color: ColorConstant.colorGoldDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: menus.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              mainAxisExtent: 158,
            ),
            itemBuilder: (context, index) => _buildMenuTile(menus[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(dynamic menu) {
    // Ikon bawaan Flutter menggantikan PNG, jadi tidak ada lagi error 404.
    IconData icon;
    String subtitle;
    switch (menu.route) {
      case 'doa':
        icon = Icons.menu_book_outlined;
        subtitle = 'Doa harian dan dzikir pilihan';
        break;
      case 'zakat':
        icon = Icons.calculate_outlined;
        subtitle = 'Hitung zakat dengan mudah';
        break;
      case 'sholat':
        icon = Icons.mosque_outlined;
        subtitle = 'Waktu sholat dan pengingat adzan';
        break;
      case 'kajian':
        icon = Icons.video_library_outlined;
        subtitle = 'Kajian Islam pilihan';
        break;
      default:
        icon = Icons.apps_outlined;
        subtitle = 'Akses menu ${menu.title}';
    }

    return Container(
      decoration: BoxDecoration(
        color: ColorConstant.colorSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ColorConstant.colorBorder),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _openMenu(menu.route, menu.title),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: ColorConstant.colorPrimaryDark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: ColorConstant.colorGold, size: 24),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menu.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: ColorConstant.colorText,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: ColorConstant.colorMuted,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
