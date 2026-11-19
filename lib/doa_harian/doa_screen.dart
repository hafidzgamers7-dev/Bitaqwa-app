import 'package:bitaqwa/doa_harian/kategori_doa_data.dart';
import 'package:bitaqwa/doa_harian/card_doa.dart';
import 'package:bitaqwa/doa_harian/color_constant.dart';
import 'package:flutter/material.dart';

// SCREEN DOA: Halaman kumpulan kategori doa dalam tampilan Grid (Kisi-kisi 2 kolom)
class DoaScreen extends StatelessWidget {
  const DoaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Latar halaman krem hangat
      backgroundColor: ColorConstant.colorAccent,
      // AppBar: Bilah judul bagian atas layar
      appBar: AppBar(
        title: Text(
          'Kumpulan Doa',
          style: TextStyle(
            color: ColorConstant.colorWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: ColorConstant.colorPrimary,
        elevation: 0,
        iconTheme: IconThemeData(color: ColorConstant.colorWhite),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Teks pengantar di atas grid
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Text(
              'Pilih kategori doa',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ColorConstant.colorText,
              ),
            ),
          ),
          // GridView 2 Kolom menampilkan kartu-kartu kategori doa
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Membagi layar menjadi 2 kolom
                crossAxisSpacing: 14, // Jarak spasi horizontal
                mainAxisSpacing: 14, // Jarak spasi vertikal
                childAspectRatio: 1.1, // Proporsi kartu
              ),
              itemCount: doaCategoryData.length,
              itemBuilder: (context, index) {
                // Membuat satu per satu kartu kategori doa
                return CardDoa(doa: doaCategoryData[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
