import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:bitaqwa/dashboard/color_constant.dart';
import 'package:bitaqwa/dashboard/basicdashboard_screen.dart';

// "async" ditambahkan supaya bisa memakai await di dalam main()
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Mengaktifkan data format tanggal Bahasa Indonesia ('id_ID').
  // Tanpa ini, DateFormat(..., 'id_ID') menyebabkan layar merah (LocaleDataException).
  await initializeDateFormatting('id_ID');

  // Ikon status bar terang karena header berwarna hijau gelap
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // Android
      statusBarBrightness: Brightness.dark, // iOS
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bitaqwa',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: ColorConstant.colorPrimary,
        scaffoldBackgroundColor: ColorConstant.colorAccent,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ColorConstant.colorPrimaryDark,
          primary: ColorConstant.colorPrimary,
          secondary: ColorConstant.colorGold,
        ),
      ),
      home: const BasicDashboardScreen(),
    );
  }
}
