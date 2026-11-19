import 'dart:convert';
import 'package:bitaqwa/jadwal_sholat/lokasi_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

// SERVICE LOKASI: Bertugas mendeteksi koordinat GPS HP dan mencari nama kota pengguna secara otomatis
class LocationService {
  // Batas waktu supaya layar tidak loading selamanya kalau GPS/internet lambat
  static const Duration _timeout = Duration(seconds: 15);

  // FUNGSI UTAMA: Mengambil koordinat dan mengubahnya menjadi objek data LocationModel
  Future<LocationModel> getCurrentLocation() async {
    // 1. CEK STATUS GPS: Apakah sakelar GPS / Lokasi di HP pengguna dalam keadaan menyala?
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("GPS belum aktif. Silakan nyalakan GPS di HP Anda.");
    }

    // 2. CEK IZIN (PERMISSION): Apakah aplikasi sudah diberi izin mengakses lokasi?
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception("Izin lokasi ditolak oleh pengguna.");
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        "Izin lokasi ditolak permanen. Silakan aktifkan melalui Pengaturan HP.",
      );
    }

    // 3. MENGAMBIL KOORDINAT GPS dari sensor HP (dengan batas waktu)
    final position = await Geolocator.getCurrentPosition().timeout(
      _timeout,
      onTimeout: () =>
          throw Exception("Gagal mendapatkan lokasi (waktu habis). Coba lagi."),
    );

    // 4. MENCARI NAMA KOTA: kalau gagal, tetap lanjut dengan nama cadangan
    //    (koordinat sudah cukup untuk menghitung waktu sholat)
    final location = await _getLocationName(
      position.latitude,
      position.longitude,
    );

    // 5. Kembalikan paket data lokasi yang sudah lengkap
    return LocationModel(
      latitude: position.latitude,
      longitude: position.longitude,
      city: location["city"]!,
      district: location["district"]!,
    );
  }

  // FUNGSI PRIVAT: Mengubah angka koordinat menjadi nama Kota & Kecamatan (Reverse Geocoding)
  Future<Map<String, String>> _getLocationName(
    double latitude,
    double longitude,
  ) async {
    const fallback = {"city": "Lokasi Tidak Diketahui", "district": ""};

    try {
      final url = Uri.parse(
        "https://nominatim.openstreetmap.org/reverse"
        "?format=jsonv2"
        "&addressdetails=1"
        "&accept-language=id"
        "&lat=$latitude"
        "&lon=$longitude",
      );

      final response = await http
          .get(url, headers: {"User-Agent": "Bitaqwa/1.0"})
          .timeout(_timeout);

      if (response.statusCode != 200) return fallback;

      final json = jsonDecode(response.body);
      final address = (json["address"] as Map<String, dynamic>?) ?? {};

      // Nama kota / kabupaten
      final city = _pick(address, [
        "city",
        "municipality",
        "town",
        "county",
        "state_district",
        "state",
      ], fallback["city"]!);

      // Nama kecamatan / kelurahan. Isi field Nominatim bisa beda tiap daerah,
      // kalau hasilnya kurang pas, tukar urutan daftar di bawah.
      final district = _pick(address, [
        "city_district",
        "suburb",
        "village",
        "hamlet",
        "neighbourhood",
      ], "");

      return {"city": city, "district": district};
    } catch (_) {
      // Internet putus / respon aneh: jangan bikin seluruh proses gagal
      return fallback;
    }
  }

  // Ambil nilai pertama yang tidak kosong dari daftar kunci
  String _pick(Map<String, dynamic> data, List<String> keys, String fallback) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) return value;
    }
    return fallback;
  }
}
