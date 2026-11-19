import 'package:bitaqwa/doa_harian/doa_model.dart';
// Memakai palet lengkap (emas, surface, border, dll.) dari dashboard.
import 'package:bitaqwa/dashboard/color_constant.dart';
import 'package:flutter/material.dart';

// SCREEN DETAIL DOA: Halaman lengkap untuk membaca satu doa (Tulisan Arab, Terjemahan, & Sumber Hadits)
class DetailDoaScreen extends StatelessWidget {
  // Menerima data doa spesifik yang diklik
  final Doa doa;

  const DetailDoaScreen({super.key, required this.doa});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.colorAccent,
      // SingleChildScrollView: Memungkinkan layar digulir (scroll) jika doa panjang
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            // SelectionArea: teks bisa di-select & disalin oleh pengguna
            SelectionArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildArabicCard(),
                    const SizedBox(height: 16),
                    _buildTranslationCard(),
                    const SizedBox(height: 16),
                    _buildReferenceCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(BuildContext context) {
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
          // Judul doa
          Expanded(
            child: Text(
              doa.title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: ColorConstant.colorAccent,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= KARTU BACAAN ARAB =================
  // Kartu hijau dengan garis emas tipis, sama seperti kartu "sholat berikutnya"
  Widget _buildArabicCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      decoration: BoxDecoration(
        color: ColorConstant.colorPrimary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ColorConstant.colorGold.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLabel('BACAAN', dotColor: ColorConstant.colorGold),
          const SizedBox(height: 14),
          // Teks Arab rata kanan (RTL) dengan ukuran huruf besar
          Text(
            doa.arabicText,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: ColorConstant.colorAccent,
              height: 2.0, // Jarak renggang antar baris agar harakat jelas
            ),
          ),
        ],
      ),
    );
  }

  // ================= KARTU TERJEMAHAN =================
  Widget _buildTranslationCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(
            'ARTINYA',
            dotColor: ColorConstant.colorGoldDark,
            textColor: ColorConstant.colorGoldDark,
          ),
          const SizedBox(height: 12),
          Text(
            doa.translation,
            style: const TextStyle(
              fontSize: 15,
              color: ColorConstant.colorText,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ================= KARTU RUJUKAN =================
  Widget _buildReferenceCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: ColorConstant.colorQuoteBg,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.format_quote,
            color: ColorConstant.colorGoldDark,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RUJUKAN / SUMBER',
                  style: TextStyle(
                    color: ColorConstant.colorGoldDark,
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  doa.reference,
                  style: const TextStyle(
                    color: ColorConstant.colorPrimaryDark,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Label kecil huruf kapital berspasi + titik penanda, seperti "SHOLAT BERIKUTNYA"
  Widget _buildLabel(
    String text, {
    required Color dotColor,
    Color textColor = ColorConstant.colorGold,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 11,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
