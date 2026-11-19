import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:bitaqwa/dashboard/color_constant.dart';
import 'package:bitaqwa/zakat/zakat_logic.dart';
import 'package:bitaqwa/zakat/zakat_result_card.dart';

// SCREEN UTAMA KALKULATOR ZAKAT MAL
class ZakatScreen extends StatefulWidget {
  const ZakatScreen({super.key});

  @override
  State<ZakatScreen> createState() => _ZakatScreenState();
}

class _ZakatScreenState extends State<ZakatScreen> {
  final ScrollController _scroll = ScrollController();

  // Controller dengan format mata uang otomatis (Rp)
  final MoneyMaskedTextController _totalHartaController =
      MoneyMaskedTextController(
        thousandSeparator: '.',
        precision: 0,
        decimalSeparator: '',
      );

  final MoneyMaskedTextController _hargaEmasController =
      MoneyMaskedTextController(
        thousandSeparator: '.',
        precision: 0,
        decimalSeparator: '',
        initialValue:
            1400000, // Nilai default estimasi, ubah sesuai harga hari ini
      );

  // Hasil perhitungan
  bool _sudahDihitung = false;
  bool _wajib = false;
  double _nisab = 0;
  double _totalHarta = 0;
  double _nominal = 0;

  String? _errorTotal;
  String? _errorHarga;

  @override
  void dispose() {
    _scroll.dispose();
    _totalHartaController.dispose();
    _hargaEmasController.dispose();
    super.dispose();
  }

  void _hitung() {
    FocusScope.of(context).unfocus();

    final total = _totalHartaController.numberValue;
    final harga = _hargaEmasController.numberValue;

    // Validasi input
    final errTotal = total <= 0 ? 'Isi total harta Anda terlebih dahulu' : null;
    final errHarga = harga <= 0
        ? 'Isi harga emas per gram terlebih dahulu'
        : null;
    if (errTotal != null || errHarga != null) {
      setState(() {
        _errorTotal = errTotal;
        _errorHarga = errHarga;
        _sudahDihitung = false;
      });
      return;
    }

    final nisab = ZakatLogic.hitungNisabRupiah(harga);
    final wajib = ZakatLogic.apakahWajibZakat(
      totalHarta: total,
      hargaEmasPerGram: harga,
    );

    setState(() {
      _errorTotal = null;
      _errorHarga = null;
      _sudahDihitung = true;
      _nisab = nisab;
      _totalHarta = total;
      _wajib = wajib;
      _nominal = wajib ? ZakatLogic.hitungZakat(total) : 0;
    });

    // Gulir otomatis ke kartu hasil
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _reset() {
    _totalHartaController.updateValue(0);
    _hargaEmasController.updateValue(1400000);
    setState(() {
      _sudahDihitung = false;
      _wajib = false;
      _nisab = 0;
      _totalHarta = 0;
      _nominal = 0;
      _errorTotal = null;
      _errorHarga = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.colorAccent,
      body: SingleChildScrollView(
        controller: _scroll,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormCard(),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _hitung,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConstant.colorPrimaryDark,
                        foregroundColor: ColorConstant.colorAccent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Hitung Zakat',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: _reset,
                      child: const Text(
                        'Atur ulang',
                        style: TextStyle(color: ColorConstant.colorGoldDark),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ZakatResultCard(
                    sudahDihitung: _sudahDihitung,
                    wajibZakat: _wajib,
                    batasNisab: _nisab,
                    nominalZakat: _nominal,
                    hartaBersih: _totalHarta,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Hasil ini adalah perkiraan. Untuk kondisi khusus, '
                    'tanyakan kepada ulama atau lembaga amil zakat.',
                    style: TextStyle(
                      color: ColorConstant.colorMuted,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
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
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        26,
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
                Icons.arrow_back,
                color: ColorConstant.colorAccent,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Kalkulator Zakat',
            style: TextStyle(
              color: ColorConstant.colorAccent,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Zakat mal (harta)',
            style: TextStyle(
              color: ColorConstant.colorOnDarkMuted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: ColorConstant.colorPrimary,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: ColorConstant.colorGold.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                _info('NISAB', '85 gram emas'),
                Container(
                  width: 1,
                  height: 30,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  color: ColorConstant.colorAccent.withValues(alpha: 0.18),
                ),
                _info('KADAR', '2,5%'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: ColorConstant.colorGold,
            fontSize: 10,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: ColorConstant.colorAccent,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ================= FORM =================
  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorConstant.colorSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ColorConstant.colorBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Harta Anda'),
          _field(
            label: 'Total harta',
            controller: _totalHartaController,
            helper: 'Tabungan, emas, investasi, dan harta lain yang dimiliki',
            error: _errorTotal,
            onChanged: (_) {
              if (_errorTotal != null) setState(() => _errorTotal = null);
            },
          ),
          const SizedBox(height: 22),
          _sectionTitle('Harga emas'),
          _field(
            label: 'Harga emas per gram',
            controller: _hargaEmasController,
            helper:
                'Perbarui sesuai harga emas hari ini (misal Antam atau Pegadaian)',
            error: _errorHarga,
            onChanged: (_) {
              if (_errorHarga != null) setState(() => _errorHarga = null);
            },
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: ColorConstant.colorGoldDark,
          fontSize: 11,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    String? helper,
    String? error,
    ValueChanged<String>? onChanged,
  }) {
    final borderRadius = BorderRadius.circular(14);
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.number,
      style: const TextStyle(
        color: ColorConstant.colorText,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: ColorConstant.colorMuted,
          fontSize: 14,
        ),
        prefixText: 'Rp ',
        helperText: helper,
        helperMaxLines: 2,
        errorText: error,
        filled: true,
        fillColor: ColorConstant.colorAccent,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(
            color: ColorConstant.colorPrimary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: Color(0xFFB3261E)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: Color(0xFFB3261E), width: 1.5),
        ),
      ),
    );
  }
}
