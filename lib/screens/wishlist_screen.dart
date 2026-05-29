import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../main.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  // Local state for wishlist items
  final List<Map<String, dynamic>> _wishes = [
    {
      'id': '1',
      'title': 'Mechanical Keyboard Keychron K2',
      'price': 1450000.0,
      'priority': 5, // 1 to 5 stars
      'isBought': false,
      'color': const Color(0xFFAB47BC),
      'icon': Icons.keyboard_rounded,
    },
    {
      'id': '2',
      'title': 'Headphone Sony WH-1000XM5',
      'price': 4800000.0,
      'priority': 4,
      'isBought': false,
      'color': const Color(0xFF42A5F5),
      'icon': Icons.headphones_rounded,
    },
    {
      'id': '3',
      'title': 'Sepatu Nike Air Jordan 1 Low',
      'price': 2200000.0,
      'priority': 3,
      'isBought': true,
      'color': const Color(0xFFEF5350),
      'icon': Icons.roller_skating_rounded,
    },
  ];

  void _addWish(String title, double price, int priority) {
    setState(() {
      _wishes.add({
        'id': DateTime.now().toString(),
        'title': title,
        'price': price,
        'priority': priority.clamp(1, 5),
        'isBought': false,
        'color': const Color(0xFFFFB300),
        'icon': Icons.favorite_rounded,
      });
    });
  }

  void _buyWish(String id) {
    setState(() {
      final index = _wishes.indexWhere((w) => w['id'] == id);
      if (index != -1) {
        _wishes[index]['isBought'] = true;
      }
    });
  }

  void _removeWish(String id) {
    setState(() {
      _wishes.removeWhere((w) => w['id'] == id);
    });
  }

  void _showAddSheet() {
    final titleController = TextEditingController();
    final priceController = TextEditingController();
    int priority = 5;

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
                      'Tambah Daftar Keinginan',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Nama Barang',
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
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Harga Barang',
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
                    const SizedBox(height: 20),
                    // Priority selector (Stars)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Prioritas Kebutuhan',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Row(
                          children: List.generate(5, (index) {
                            final starVal = index + 1;
                            return GestureDetector(
                              onTap: () {
                                setSheetState(() {
                                  priority = starVal;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                child: Icon(
                                  Icons.star_rounded,
                                  color: starVal <= priority ? const Color(0xFFFFB300) : (isDark ? Colors.white24 : Colors.black12),
                                  size: 28,
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
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
                          final title = titleController.text;
                          final price = double.tryParse(priceController.text) ?? 0.0;
                          if (title.isNotEmpty && price > 0) {
                            _addWish(title, price, priority);
                            Navigator.pop(context);
                          }
                        },
                        child: const Text(
                          'Tambahkan Keinginan',
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

    double totalWantedAmount = 0.0;
    int wantedCount = 0;
    for (var w in _wishes) {
      if (!w['isBought']) {
        totalWantedAmount += w['price'] as double;
        wantedCount++;
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Daftar Keinginan',
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
                      'Estimasi Dana yang Dibutuhkan',
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocale.formatCurrency(totalWantedAmount, '$currency '),
                      style: TextStyle(
                        color: mainTextColor,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Menampilkan $wantedCount barang impian belum terbeli.',
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
                'Impian & Keinginan Anda',
                style: TextStyle(
                  color: mainTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(height: 16),

              _wishes.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Column(
                          children: [
                            Icon(Icons.favorite_rounded, size: 64, color: subTextColor.withValues(alpha: 0.2)),
                            const SizedBox(height: 12),
                            Text('Belum ada barang impian terdaftar', style: TextStyle(color: mainTextColor, fontSize: 14)),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: _wishes.map((w) {
                        final color = w['color'] as Color;
                        final isBought = w['isBought'] as bool;
                        final priority = w['priority'] as int;

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
                                  color: isBought ? const Color(0xFF00D179).withValues(alpha: 0.12) : color.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isBought ? Icons.offline_pin_rounded : w['icon'] as IconData,
                                  color: isBought ? const Color(0xFF00D179) : color,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      w['title'] as String,
                                      style: TextStyle(
                                        color: mainTextColor,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        decoration: isBought ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: List.generate(5, (index) {
                                        return Icon(
                                          Icons.star_rounded,
                                          color: index < priority ? const Color(0xFFFFB300) : (isDark ? Colors.white12 : Colors.black12),
                                          size: 13,
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    AppLocale.formatCurrency(w['price'] as double, '$currency '),
                                    style: TextStyle(
                                      color: isBought ? subTextColor : mainTextColor,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      fontFamily: 'Outfit',
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  isBought
                                      ? GestureDetector(
                                          onTap: () => _removeWish(w['id'] as String),
                                          child: Text(
                                            'Hapus',
                                            style: TextStyle(
                                              color: Colors.redAccent.withValues(alpha: 0.8),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        )
                                      : GestureDetector(
                                          onTap: () => _buyWish(w['id'] as String),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF00D179).withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'Beli',
                                              style: TextStyle(
                                                color: Color(0xFF00D179),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
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
