import 'package:flutter/material.dart';
import 'package:bitaqwa/dashboard/color_constant.dart';
import 'package:bitaqwa/zakat/zakat_logic.dart';

// WIDGET KARTU HASIL PERHITUNGAN ZAKAT
// Dipisah ke komponen sendiri agar kode screen utama tetap bersih dan mudah dibaca siswa
//
// Empat parameter pertama sama seperti sebelumnya, jadi zakat_screen.dart lama
// tetap bisa memakainya. hartaBersih dan sudahHaul bersifat opsional.
class ZakatResultCard extends StatelessWidget {
  final bool sudahDihitung;
  final bool wajibZakat;
  final double batasNisab;
  final double nominalZakat;
  final double? hartaBersih; // opsional: tampil sebagai baris tambahan
  final bool sudahHaul; // opsional: untuk alasan "belum wajib"

  const ZakatResultCard({
    super.key,
    required this.sudahDihitung,
    required this.wajibZakat,
    required this.batasNisab,
    required this.nominalZakat,
    this.hartaBersih,
    this.sudahHaul = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!sudahDihitung) return _buildPlaceholder();
    return wajibZakat ? _buildWajib() : _buildBelumWajib();
  }

  // Sebelum tombol "Hitung Zakat" ditekan
  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorConstant.colorSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ColorConstant.colorBorder),
      ),
      child: const Row(
        children: [
          Icon(Icons.calculate_outlined, color: ColorConstant.colorGoldDark),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Masukkan total harta dan harga emas saat ini, lalu tekan tombol "Hitung Zakat".',
              style: TextStyle(
                color: ColorConstant.colorMuted,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hasil: wajib zakat (kartu hijau gelap, sama gayanya dengan header beranda)
  Widget _buildWajib() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: ColorConstant.colorPrimaryDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ColorConstant.colorGold.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ZAKAT YANG HARUS DIBAYAR',
            style: TextStyle(
              color: ColorConstant.colorGold,
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ZakatLogic.formatRupiah(nominalZakat),
            style: const TextStyle(
              color: ColorConstant.colorAccent,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Anda wajib mengeluarkan zakat mal',
            style: TextStyle(
              color: ColorConstant.colorOnDarkMuted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: ColorConstant.colorAccent.withValues(alpha: 0.14),
          ),
          const SizedBox(height: 14),
          if (hartaBersih != null) ...[
            _row('Harta bersih', ZakatLogic.formatRupiah(hartaBersih!)),
            const SizedBox(height: 8),
          ],
          _row(
            'Batas nisab (85 gram emas)',
            ZakatLogic.formatRupiah(batasNisab),
          ),
          const SizedBox(height: 8),
          _row('Kadar zakat', '2,5%'),
          const SizedBox(height: 14),
          const Text(
            'Salurkan melalui lembaga amil zakat yang terpercaya.',
            style: TextStyle(
              color: ColorConstant.colorOnDarkMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Hasil: belum wajib zakat (kartu krem)
  Widget _buildBelumWajib() {
    final alasan = !sudahHaul
        ? 'Harta belum dimiliki selama satu tahun (haul).'
        : 'Harta Anda belum mencapai nisab (85 gram emas) sebesar ${ZakatLogic.formatRupiah(batasNisab)}, sehingga belum diwajibkan zakat mal.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: ColorConstant.colorSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ColorConstant.colorBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: ColorConstant.colorGoldDark),
              SizedBox(width: 10),
              Text(
                'Belum wajib zakat',
                style: TextStyle(
                  color: ColorConstant.colorText,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            alasan,
            style: const TextStyle(
              color: ColorConstant.colorMuted,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Anda tetap dianjurkan bersedekah kapan pun.',
            style: TextStyle(color: ColorConstant.colorMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: ColorConstant.colorOnDarkMuted,
              fontSize: 13,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: ColorConstant.colorAccent,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
