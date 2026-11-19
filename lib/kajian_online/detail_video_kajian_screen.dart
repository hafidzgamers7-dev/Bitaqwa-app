import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:bitaqwa/kajian_online/color_constant.dart';

// SCREEN DETAIL VIDEO KAJIAN: Memutar video YouTube langsung di dalam aplikasi
class DetailVideoKajianScreen extends StatefulWidget {
  final String url;
  final String account;
  final String ustadz;
  final String title;
  final String description;

  const DetailVideoKajianScreen({
    super.key,
    required this.url,
    required this.account,
    required this.ustadz,
    required this.title,
    required this.description,
  });

  @override
  State<DetailVideoKajianScreen> createState() =>
      _DetailVideoKajianScreenState();
}

class _DetailVideoKajianScreenState extends State<DetailVideoKajianScreen> {
  // Kontroler pemutar YouTube (null kalau URL video tidak valid)
  YoutubePlayerController? _controller;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();

    // 1. Mengubah URL YouTube menjadi Video ID (misal: "kOnZ_Jv_C6k")
    final videoId = YoutubePlayerController.convertUrlToId(widget.url);

    // URL tidak valid: jangan crash, layar akan menampilkan pesan error
    if (videoId == null) return;

    // 2. Konfigurasi kontroler YouTube player
    final controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        enableJavaScript: true,
        strictRelatedVideos: true,
      ),
    );

    // 3. Listener saat video siap dimainkan
    controller.listen((value) {
      if (mounted &&
          !_isPlayerReady &&
          value.playerState != PlayerState.unknown) {
        setState(() {
          _isPlayerReady = true;
        });
      }
    });

    // 4. Memuat video berdasarkan videoId
    controller.loadVideoById(videoId: videoId);

    _controller = controller;
  }

  @override
  void dispose() {
    // Menutup pemutar saat keluar dari layar agar memori HP bersih
    _controller?.close();
    super.dispose();
  }

  // AppBar dipakai bersama oleh tampilan normal dan tampilan error
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: ColorConstant.colorPrimary,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: ColorConstant.colorWhite),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        widget.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: ColorConstant.colorWhite,
          fontFamily: "PoppinsMedium",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    // Tampilan kalau URL YouTube tidak valid
    if (controller == null) {
      return Scaffold(
        backgroundColor: ColorConstant.colorAccent,
        appBar: _buildAppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.videocam_off_rounded,
                  size: 60,
                  color: ColorConstant.colorPrimary.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  "Video tidak dapat diputar.\nLink YouTube tidak valid.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ColorConstant.colorText,
                    fontFamily: "PoppinsMedium",
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return YoutubePlayerControllerProvider(
      controller: controller,
      child: Scaffold(
        // Latar halaman krem hangat
        backgroundColor: ColorConstant.colorAccent,
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              YoutubePlayer(controller: controller),
              if (!_isPlayerReady)
                LinearProgressIndicator(
                  color: ColorConstant.colorPrimary,
                  backgroundColor: ColorConstant.colorPrimary.withValues(
                    alpha: 0.15,
                  ),
                ),
              // Kartu informasi video
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: ColorConstant.colorWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: ColorConstant.colorPrimary.withValues(alpha: 0.12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ColorConstant.colorPrimaryDark.withValues(
                          alpha: 0.08,
                        ),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  // SelectionArea: teks bisa di-select & disalin
                  child: SelectionArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Judul kajian
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 20,
                            height: 1.3,
                            color: ColorConstant.colorText,
                            fontFamily: "PoppinsSemiBold",
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Nama ustadz
                        Row(
                          children: [
                            Icon(
                              Icons.person_rounded,
                              size: 18,
                              color: ColorConstant.colorPrimary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.ustadz,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: ColorConstant.colorPrimaryDark,
                                  fontFamily: "PoppinsMedium",
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Nama akun / channel
                        Row(
                          children: [
                            Icon(
                              Icons.play_circle_outline_rounded,
                              size: 18,
                              color: ColorConstant.colorPrimary.withValues(
                                alpha: 0.7,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.account,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: ColorConstant.colorText.withValues(
                                    alpha: 0.6,
                                  ),
                                  fontFamily: "PoppinsRegular",
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Divider(
                            height: 1,
                            thickness: 1.5,
                            color: ColorConstant.colorPrimary.withValues(
                              alpha: 0.15,
                            ),
                          ),
                        ),
                        // Deskripsi kajian
                        Text(
                          widget.description,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: ColorConstant.colorText,
                            fontFamily: "PoppinsRegular",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
