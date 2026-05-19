import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../main.dart';

class ReimburseScreen extends StatefulWidget {
  const ReimburseScreen({super.key});

  @override
  State<ReimburseScreen> createState() => _ReimburseScreenState();
}

class _ReimburseScreenState extends State<ReimburseScreen> {
  // Local state for claims
  final List<Map<String, dynamic>> _claims = [
    {
      'id': '1',
      'title': 'Beli Tiket Kereta Dinas BDG-JKT',
      'amount': 350000.0,
      'company': 'PT Teknologi Maju',
      'date': '15 Mei 2026',
      'status': 'Diproses', // Diproses, Disetujui, Lunas
      'color': const Color(0xFFFFB300),
    },
    {
      'id': '2',
      'title': 'Makan Malam Bersama Klien',
      'amount': 820000.0,
      'company': 'PT Teknologi Maju',
      'date': '10 Mei 2026',
      'status': 'Disetujui',
      'color': const Color(0xFF42A5F5),
    },
    {
      'id': '3',
      'title': 'Pembelian Lisensi Figma Team',
      'amount': 1500000.0,
      'company': 'Design Studio X',
      'date': '28 April 2026',
      'status': 'Lunas',
      'color': const Color(0xFF66BB6A),
    },
  ];

  void _addClaim(String title, double amount, String company, String date) {
    setState(() {
      _claims.insert(0, {
        'id': DateTime.now().toString(),
        'title': title,
        'amount': amount,
        'company': company.isNotEmpty ? company : 'Mandiri',
        'date': date.isNotEmpty ? date : '19 Mei 2026',
        'status': 'Diproses',
        'color': const Color(0xFFFFB300),
      });
    });
  }

  void _approveClaim(String id) {
    setState(() {
      final index = _claims.indexWhere((c) => c['id'] == id);
      if (index != -1) {
        final currentStatus = _claims[index]['status'];
        if (currentStatus == 'Diproses') {
          _claims[index]['status'] = 'Disetujui';
          _claims[index]['color'] = const Color(0xFF42A5F5);
        } else if (currentStatus == 'Disetujui') {
          _claims[index]['status'] = 'Lunas';
          _claims[index]['color'] = const Color(0xFF66BB6A);
        }
      }
    });
  }

  void _removeClaim(String id) {
    setState(() {
      _claims.removeWhere((c) => c['id'] == id);
    });
  }

  void _showAddSheet() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final companyController = TextEditingController();
    final dateController = TextEditingController();

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
                  'Tambah Klaim Reimbursement',
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
                    labelText: 'Nama Pengeluaran / Tiket',
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
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Jumlah Nominal Klaim',
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
                  controller: companyController,
                  decoration: InputDecoration(
                    labelText: 'Nama Perusahaan / Project',
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
                  controller: dateController,
                  decoration: InputDecoration(
                    labelText: 'Tanggal Klaim (e.g. 19 Mei 2026)',
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
                      final title = titleController.text;
                      final amount = double.tryParse(amountController.text) ?? 0.0;
                      final company = companyController.text;
                      final date = dateController.text;
                      if (title.isNotEmpty && amount > 0) {
                        _addClaim(title, amount, company, date);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      'Ajukan Reimbursement',
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

    double totalPending = 0.0;
    double totalApproved = 0.0;
    double totalPaid = 0.0;

    for (var c in _claims) {
      final amt = c['amount'] as double;
      final st = c['status'] as String;
      if (st == 'Diproses') {
        totalPending += amt;
      } else if (st == 'Disetujui') {
        totalApproved += amt;
      } else if (st == 'Lunas') {
        totalPaid += amt;
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Reimbursement',
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

              // Overview Grid (3 columns for Pending, Approved, Paid)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DIPROSES', style: TextStyle(color: const Color(0xFFFFB300), fontSize: 8, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 6),
                          Text(
                            AppLocale.formatCurrency(totalPending, '$currency '),
                            style: TextStyle(color: mainTextColor, fontSize: 11, fontWeight: FontWeight.w800, fontFamily: 'Outfit'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DISETUJUI', style: TextStyle(color: const Color(0xFF42A5F5), fontSize: 8, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 6),
                          Text(
                            AppLocale.formatCurrency(totalApproved, '$currency '),
                            style: TextStyle(color: mainTextColor, fontSize: 11, fontWeight: FontWeight.w800, fontFamily: 'Outfit'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('LUNAS', style: TextStyle(color: const Color(0xFF66BB6A), fontSize: 8, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 6),
                          Text(
                            AppLocale.formatCurrency(totalPaid, '$currency '),
                            style: TextStyle(color: mainTextColor, fontSize: 11, fontWeight: FontWeight.w800, fontFamily: 'Outfit'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),
              Text(
                'Daftar Klaim Anda',
                style: TextStyle(
                  color: mainTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(height: 16),

              _claims.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Column(
                          children: [
                            Icon(Icons.currency_exchange_rounded, size: 64, color: subTextColor.withValues(alpha: 0.2)),
                            const SizedBox(height: 12),
                            Text('Belum ada klaim reimburse', style: TextStyle(color: mainTextColor, fontSize: 14)),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: _claims.map((c) {
                        final color = c['color'] as Color;
                        final status = c['status'] as String;

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
                                  status == 'Lunas' ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
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
                                      c['title'] as String,
                                      style: TextStyle(
                                        color: mainTextColor,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${c['company']} • ${c['date']}',
                                      style: TextStyle(
                                        color: subTextColor,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    AppLocale.formatCurrency(c['amount'] as double, '$currency '),
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
                                      if (status != 'Lunas') ...[
                                        GestureDetector(
                                          onTap: () => _approveClaim(c['id'] as String),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: color.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              status == 'Diproses' ? 'Approve' : 'Lunas',
                                              style: TextStyle(
                                                color: color,
                                                fontSize: 9,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      GestureDetector(
                                        onTap: () => _removeClaim(c['id'] as String),
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
        onPressed: _showAddSheet,
        backgroundColor: const Color(0xFF1E293B),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}
