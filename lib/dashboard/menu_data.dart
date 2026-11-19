import 'package:bitaqwa/dashboard/menu_model.dart';

// DATA MENU DASHBOARD: Daftar menu utama di beranda Bitaqwa
final List<MenuModel> menus = [
  MenuModel(
    title: "Doa-doa",
    image: "assets/images/ic_menu_doa.png",
    route: "doa",
  ),
  MenuModel(
    title: "Zakat",
    image: "assets/images/ic_menu_zakat.png",
    route: "zakat",
  ),
  MenuModel(
    title: "Jadwal Sholat",
    image: "assets/images/ic_menu_sholat.png",
    route: "sholat",
  ),
  MenuModel(
    title: "Video Kajian",
    image: "assets/images/ic_menu_kajian.png",
    route: "kajian",
  ),
];
