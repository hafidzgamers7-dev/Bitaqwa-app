import 'package:bitaqwa/kajian_online/video_data.dart';
import 'package:flutter/material.dart';
// Memakai palet lengkap (emas, surface, border, dll.) dari dashboard.
// Kalau mau, nanti semua palet bisa digabung jadi satu file bersama.
import 'package:bitaqwa/dashboard/color_constant.dart';
import 'package:bitaqwa/kajian_online/detail_video_kajian_screen.dart';

// SCREEN VIDEO KAJIAN: Menampilkan daftar video ceramah islami yang siap diputar
class VideoKajianScreen extends StatelessWidget {
  const VideoKajianScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.colorAccent,
      // ListView.builder: item pertama = header, sisanya = kartu video kajian
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: videos.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return _buildHeader(context);
          return _buildVideoCard(context, videos[index - 1]);
        },
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Video Kajian',
                  style: TextStyle(
                    color: ColorConstant.colorAccent,
                    fontSize: 26,
                    height: 1.15,
                    fontFamily: 'PoppinsSemiBold',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${videos.length} kajian pilihan',
                  style: const TextStyle(
                    color: ColorConstant.colorGold,
                    fontSize: 12,
                    fontFamily: 'PoppinsRegular',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= KARTU VIDEO =================
  Widget _buildVideoCard(BuildContext context, dynamic video) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
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
          // Saat kartu disentuh, buka pemutar video DetailVideoKajianScreen
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailVideoKajianScreen(
                  // videoId disusun jadi URL lengkap supaya valid di layar detail
                  url: 'https://www.youtube.com/watch?v=${video.videoId}',
                  account: video.account,
                  ustadz: video.ustadz,
                  title: video.title,
                  description: video.description,
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail + lapisan gelap + tombol play bulat di tengah
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      video.thumbnail,
                      fit: BoxFit.cover,
                      // Kalau file thumbnail belum ada, tampil blok hijau gelap
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: ColorConstant.colorPrimaryDark,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: ColorConstant.colorOnDarkMuted,
                          size: 36,
                        ),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            ColorConstant.colorPrimaryDark.withValues(
                              alpha: 0.55,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorConstant.colorPrimaryDark.withValues(
                            alpha: 0.85,
                          ),
                          border: Border.all(
                            color: ColorConstant.colorGold.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: ColorConstant.colorGold,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul Video Kajian
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        height: 1.3,
                        color: ColorConstant.colorText,
                        fontFamily: 'PoppinsSemiBold',
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Nama Ustadz / Penceramah
                    Row(
                      children: [
                        const Icon(
                          Icons.person_rounded,
                          size: 16,
                          color: ColorConstant.colorPrimary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            video.ustadz,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: ColorConstant.colorPrimary,
                              fontFamily: 'PoppinsMedium',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Nama Akun Pengunggah Video
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: const BoxDecoration(
                            color: ColorConstant.colorGold,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            video.account,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: ColorConstant.colorMuted,
                              fontFamily: 'PoppinsRegular',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
