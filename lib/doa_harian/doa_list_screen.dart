import 'package:bitaqwa/doa_harian/doa_data.dart';
import 'package:bitaqwa/doa_harian/kategori_doa_enum.dart';
import 'package:bitaqwa/doa_harian/kategori_doa_ext.dart';
import 'package:bitaqwa/doa_harian/detail_doa_screen.dart';
// Memakai palet lengkap (emas, surface, border, dll.) dari dashboard.
import 'package:bitaqwa/dashboard/color_constant.dart';
import 'package:flutter/material.dart';

// SCREEN DOA LIST: Halaman yang menampilkan daftar bacaan doa dalam kategori yang dipilih
class DoaListScreen extends StatelessWidget {
  // Menerima kategori doa yang dipilih
  final DoaCategory category;

  const DoaListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    // Mengambil daftar doa dari Map doaData sesuai kategori yang dipilih
    final doas = doaData[category] ?? [];

    return Scaffold(
      backgroundColor: ColorConstant.colorAccent,
      // ListView.builder: item pertama = header, sisanya = kartu doa
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        // Kalau kosong: header + satu item pesan kosong
        itemCount: doas.isEmpty ? 2 : doas.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return _buildHeader(context, doas.length);

          // Tampilan kalau kategori belum punya doa
          if (doas.isEmpty) {
            return const Padding(
              padding: EdgeInsets.only(top: 60),
              child: Center(
                child: Text(
                  'Belum ada doa di kategori ini',
                  style: TextStyle(
                    color: ColorConstant.colorMuted,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }

          final doa = doas[index - 1];
          return _buildDoaCard(context, doa, index);
        },
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(BuildContext context, int total) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        28,
      ),
      decoration: const BoxDecoration(
        color: ColorConstant.colorPrimaryDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Row(
        children: [
          // Tombol kembali bulat dengan garis emas tipis
          Container(
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
              tooltip: 'Kembali',
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: ColorConstant.colorAccent,
                size: 18,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama kategori doa
                Text(
                  category.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ColorConstant.colorAccent,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$total doa',
                  style: const TextStyle(
                    color: ColorConstant.colorGold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= KARTU DOA =================
  // [number] = nomor urut yang ditampilkan (mulai dari 1)
  Widget _buildDoaCard(BuildContext context, dynamic doa, int number) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          // Saat diklik, buka layar DetailDoaScreen
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailDoaScreen(doa: doa),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Nomor urut dalam kotak hijau gelap berangka emas
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ColorConstant.colorPrimaryDark,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      color: ColorConstant.colorGold,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Judul Doa
                Expanded(
                  child: Text(
                    doa.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ColorConstant.colorText,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Ikon panah penunjuk
                const Icon(
                  Icons.chevron_right_rounded,
                  color: ColorConstant.colorGoldDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
