import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../main.dart';

class AssetsScreen extends StatefulWidget {
  const AssetsScreen({super.key});

  @override
  State<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends State<AssetsScreen> {
  // Local state for assets
  final List<Map<String, dynamic>> _assets = [
    {
      'id': '1',
      'name': 'Emas Fisik Antam',
      'category': 'Emas',
      'value': 12500000.0,
      'change': 8.5, // percent change (+/-)
      'icon': Icons.diamond_rounded,
      'color': const Color(0xFFFFB300),
    },
    {
      'id': '2',
      'name': 'Crypto Portfolio (BTC/ETH)',
      'category': 'Crypto',
      'value': 8700000.0,
      'change': 18.2,
      'icon': Icons.currency_bitcoin_rounded,
      'color': const Color(0xFFAB47BC),
    },
    {
      'id': '3',
      'name': 'Saham BCA (BBCA)',
      'category': 'Saham',
      'value': 18500000.0,
      'change': -2.4,
      'icon': Icons.trending_up_rounded,
      'color': const Color(0xFF42A5F5),
    },
    {
      'id': '4',
      'name': 'Tabungan Reksa Dana',
      'category': 'Reksa Dana',
      'value': 5000000.0,
      'change': 4.1,
      'icon': Icons.account_balance_wallet_rounded,
      'color': const Color(0xFF66BB6A),
    },
  ];

  void _addAsset(String name, String category, double value, double change) {
    setState(() {
      _assets.add({
        'id': DateTime.now().toString(),
        'name': name,
        'category': category,
        'value': value,
        'change': change,
        'icon': category == 'Emas' ? Icons.diamond_rounded : Icons.trending_up_rounded,
        'color': category == 'Emas'
            ? const Color(0xFFFFB300)
            : (category == 'Crypto' ? const Color(0xFFAB47BC) : const Color(0xFF42A5F5)),
      });
    });
  }

  void _updateAsset(String id, double newValue) {
    setState(() {
      final index = _assets.indexWhere((a) => a['id'] == id);
      if (index != -1) {
        _assets[index]['value'] = newValue;
      }
    });
  }

  void _removeAsset(String id) {
    setState(() {
      _assets.removeWhere((a) => a['id'] == id);
    });
  }

  void _showAddSheet() {
    final nameController = TextEditingController();
    final valueController = TextEditingController();
    final changeController = TextEditingController();
    String selectedCategory = 'Saham';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final sheetBg = isDark ? const Color(0xFF0F172A) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
        final subColor = isDark ? Colors.white54 : Colors.black54;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: sheetBg,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.black12,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Tambah Aset Investasi',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kategori Aset',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        DropdownButton<String>(
                          value: selectedCategory,
                          dropdownColor: sheetBg,
                          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                          items: ['Saham', 'Emas', 'Crypto', 'Reksa Dana'].map((String val) {
                            return DropdownMenuItem<String>(
                              value: val,
                              child: Text(val),
                            );
                          }).toList(),
                          onChanged: (newVal) {
                            if (newVal != null) {
                              setSheetState(() {
                                selectedCategory = newVal;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Aset / Saham',
                        labelStyle: TextStyle(color: subColor),
                        filled: true,
                        fillColor: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.015),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(color: textColor),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: valueController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Nilai Pasar Aset (Rupiah)',
                        labelStyle: TextStyle(color: subColor),
                        filled: true,
                        fillColor: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.015),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(color: textColor),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: changeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Perkembangan Keuntungan (%)',
                        labelStyle: TextStyle(color: subColor),
                        filled: true,
                        fillColor: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.015),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(color: textColor),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E293B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          final name = nameController.text;
                          final val = double.tryParse(valueController.text) ?? 0.0;
                          final chg = double.tryParse(changeController.text) ?? 0.0;
                          if (name.isNotEmpty && val > 0) {
                            _addAsset(name, selectedCategory, val, chg);
                            Navigator.pop(context);
                          }
                        },
                        child: const Text(
                          'Simpan Aset',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAdjustValueSheet(String assetId, String name, double currentValue) {
    final valController = TextEditingController(text: currentValue.toStringAsFixed(0));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final sheetBg = isDark ? const Color(0xFF0F172A) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
        final subColor = isDark ? Colors.white54 : Colors.black54;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: sheetBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Sesuaikan Nilai Aset',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Outfit',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Update nilai pasar untuk "$name"',
                  style: TextStyle(
                    color: subColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: valController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Nilai Pasar Baru (Rp)',
                    labelStyle: TextStyle(color: subColor),
                    filled: true,
                    fillColor: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.015),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(color: textColor),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D179),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      final newVal = double.tryParse(valController.text) ?? 0.0;
                      if (newVal > 0) {
                        _updateAsset(assetId, newVal);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      'Perbarui Nilai',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currency = provider.currencySymbol;

    final mainTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.white.withValues(alpha: 0.45) : const Color(0xFF64748B);
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.05);
    final cardBgColor = isDark ? theme.cardColor : Colors.white;

    double totalAssetVal = 0.0;
    double weightedChange = 0.0;
    for (var a in _assets) {
      final val = a['value'] as double;
      totalAssetVal += val;
    }

    for (var a in _assets) {
      final val = a['value'] as double;
      final chg = a['change'] as double;
      if (totalAssetVal > 0) {
        weightedChange += chg * (val / totalAssetVal);
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Manajemen Aset',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            fontFamily: 'Outfit',
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: mainTextColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Summary card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Kekayaan Portofolio Aset',
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocale.formatCurrency(totalAssetVal, '$currency '),
                          style: TextStyle(
                            color: mainTextColor,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (weightedChange >= 0 ? const Color(0xFF00D179) : const Color(0xFFEF5350)).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${weightedChange >= 0 ? "+" : ""}${weightedChange.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: weightedChange >= 0 ? const Color(0xFF00D179) : const Color(0xFFEF5350),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Nilai investasi Anda berfluktuasi secara dinamis.',
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              Text(
                'Alokasi Portofolio',
                style: TextStyle(
                  color: mainTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(height: 16),

              _assets.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Column(
                          children: [
                            Icon(Icons.trending_up_rounded, size: 64, color: subTextColor.withValues(alpha: 0.2)),
                            const SizedBox(height: 12),
                            Text('Belum ada aset terdaftar', style: TextStyle(color: mainTextColor, fontSize: 14)),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: _assets.map((a) {
                        final color = a['color'] as Color;
                        final value = a['value'] as double;
                        final change = a['change'] as double;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  a['icon'] as IconData,
                                  color: color,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      a['name'] as String,
                                      style: TextStyle(
                                        color: mainTextColor,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          a['category'] as String,
                                          style: TextStyle(
                                            color: subTextColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${change >= 0 ? "+" : ""}${change.toStringAsFixed(1)}%',
                                          style: TextStyle(
                                            color: change >= 0 ? const Color(0xFF00D179) : const Color(0xFFEF5350),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    AppLocale.formatCurrency(value, '$currency '),
                                    style: TextStyle(
                                      color: mainTextColor,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      fontFamily: 'Outfit',
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () => _showAdjustValueSheet(a['id'] as String, a['name'] as String, value),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF00D179).withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            'Update',
                                            style: TextStyle(
                                              color: Color(0xFF00D179),
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () => _removeAsset(a['id'] as String),
                                        child: Text(
                                          'Hapus',
                                          style: TextStyle(
                                            color: Colors.redAccent.withValues(alpha: 0.8),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: _showAddSheet,
        backgroundColor: const Color(0xFF1E293B),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}
