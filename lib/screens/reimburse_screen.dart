import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
    final companyController = TextEditingController();

    String amountStr = '0';
    bool showOperators = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final sheetBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
        final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
        final subColor = isDark ? Colors.white54 : Colors.black54;
        final borderCol = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04);
        final inputBg = isDark ? const Color(0xFF1E293B) : Colors.white;

        double evaluateExpr(String expr) {
          String cleanExpr = expr.replaceAll('x', '*').replaceAll('÷', '/').replaceAll(' ', '');
          try {
            final RegExp regExp = RegExp(r'(\d+\.?\d*)|([\+\-\*\/])');
            final matches = regExp.allMatches(cleanExpr);
            if (matches.isEmpty) return 0.0;

            List<double> numbers = [];
            List<String> operators = [];

            for (var m in matches) {
              String token = m.group(0)!;
              if (token == '+' || token == '-' || token == '*' || token == '/') {
                operators.add(token);
              } else {
                numbers.add(double.tryParse(token) ?? 0.0);
              }
            }

            if (numbers.isEmpty) return 0.0;

            int i = 0;
            while (i < operators.length) {
              if (operators[i] == '*' || operators[i] == '/') {
                double left = numbers[i];
                double right = i + 1 < numbers.length ? numbers[i + 1] : 0.0;
                double res = 0.0;
                if (operators[i] == '*') {
                  res = left * right;
                } else {
                  res = right != 0.0 ? left / right : 0.0;
                }
                numbers[i] = res;
                if (i + 1 < numbers.length) numbers.removeAt(i + 1);
                operators.removeAt(i);
              } else {
                i++;
              }
            }

            double total = numbers[0];
            for (int j = 0; j < operators.length; j++) {
              double nextVal = j + 1 < numbers.length ? numbers[j + 1] : 0.0;
              if (operators[j] == '+') {
                total += nextVal;
              } else if (operators[j] == '-') {
                total -= nextVal;
              }
            }
            return total;
          } catch (e) {
            return 0.0;
          }
        }

        String formatAmount(String value) {
          if (value.isEmpty || value == '0') return '0';

          final hasOps = value.contains('+') || value.contains('-') || value.contains('x') || value.contains('÷');
          if (!hasOps) {
            final n = double.tryParse(value.replaceAll('.', '')) ?? 0;
            final formatter = NumberFormat('#,###', 'id_ID');
            return formatter.format(n);
          }

          final RegExp pattern = RegExp(r'(\d+\.?\d*)|([^\d\.]+)');
          final matches = pattern.allMatches(value);

          StringBuffer sb = StringBuffer();
          for (var m in matches) {
            String token = m.group(0)!;
            if (token.contains('+') || token.contains('-') || token.contains('x') || token.contains('÷') || token.trim().isEmpty) {
              sb.write(token);
            } else {
              final cleanNum = token.replaceAll('.', '');
              final n = double.tryParse(cleanNum) ?? 0;
              final formatter = NumberFormat('#,###', 'id_ID');
              sb.write(formatter.format(n));
            }
          }
          return sb.toString();
        }

        return StatefulBuilder(
          builder: (context, setSheetState) {
            void performCalculation() {
              final result = evaluateExpr(amountStr);
              setSheetState(() {
                if (result == result.toInt()) {
                  amountStr = result.toInt().toString();
                } else {
                  amountStr = result.toStringAsFixed(1);
                  if (amountStr.endsWith('.0')) {
                    amountStr = amountStr.substring(0, amountStr.length - 2);
                  }
                }
              });
            }

            void onKeyboardTap(String value) {
              setSheetState(() {
                if (amountStr == '0') {
                  if (value != '0' && value != '000' && value != '.') {
                    amountStr = value;
                  } else if (value == '.') {
                    amountStr = '0.';
                  }
                } else {
                  if (value == '.') {
                    final lastPart = amountStr.split(RegExp(r'[\+\-\*\/x÷]')).last.trim();
                    if (!lastPart.contains('.')) {
                      amountStr += '.';
                    }
                  } else {
                    amountStr += value;
                  }
                }
              });
            }

            void onBackspace() {
              setSheetState(() {
                if (amountStr.length > 1) {
                  if (amountStr.endsWith(' ')) {
                    amountStr = amountStr.trimRight();
                    amountStr = amountStr.substring(0, amountStr.length - 1).trimRight();
                  } else {
                    amountStr = amountStr.substring(0, amountStr.length - 1);
                  }
                  if (amountStr.isEmpty) amountStr = '0';
                } else {
                  amountStr = '0';
                }
              });
            }

            Widget buildKey({
              required Widget child,
              required Color bgColor,
              required VoidCallback onTap,
            }) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: onTap,
                      child: Center(
                        child: child,
                      ),
                    ),
                  ),
                ),
              );
            }

            Widget buildOperatorIconBtn({
              IconData? icon,
              String? label,
              required Color color,
              required VoidCallback onTap,
            }) {
              return GestureDetector(
                onTap: onTap,
                child: Container(
                  height: 34,
                  width: 34,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: icon != null
                        ? Icon(icon, color: color, size: 16)
                        : Text(
                            label!,
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
              );
            }

            void submitClaim() {
              final hasOps = amountStr.contains('+') || amountStr.contains('-') || amountStr.contains('x') || amountStr.contains('÷');
              if (hasOps) {
                performCalculation();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Hasil perhitungan diperbarui. Ketuk done sekali lagi untuk menambah klaim.'),
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }

              final title = titleController.text.trim();
              final amount = double.tryParse(amountStr.replaceAll('.', '')) ?? 0.0;
              final company = companyController.text.trim();

              if (title.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Masukkan nama pengeluaran/tiket')),
                );
                return;
              }
              if (amount <= 0.0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Masukkan nominal klaim')),
                );
                return;
              }

              final now = DateTime.now();
              final monthsIndo = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
              final dateStr = '${now.day} ${monthsIndo[now.month - 1]} ${now.year}';

              _addClaim(title, amount, company, dateStr);
              Navigator.pop(context);
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: sheetBg,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tambah Klaim',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Outfit',
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.close, color: textColor, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Title & Company Inputs inside Scrollable view
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: inputBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: borderCol),
                              ),
                              child: TextField(
                                controller: titleController,
                                style: TextStyle(color: textColor, fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'Nama Pengeluaran / Tiket',
                                  hintStyle: TextStyle(color: subColor.withValues(alpha: 0.5), fontSize: 12),
                                  prefixIcon: Icon(Icons.receipt_long_rounded, color: subColor, size: 18),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              decoration: BoxDecoration(
                                color: inputBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: borderCol),
                              ),
                              child: TextField(
                                controller: companyController,
                                style: TextStyle(color: textColor, fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'Nama Perusahaan / Project (Opsional)',
                                  hintStyle: TextStyle(color: subColor.withValues(alpha: 0.5), fontSize: 12),
                                  prefixIcon: Icon(Icons.business_rounded, color: subColor, size: 18),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Amount Display Row
                            Text(
                              'Nominal Klaim',
                              style: TextStyle(color: subColor, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Rp',
                                    style: TextStyle(
                                      color: isDark ? Colors.white : const Color(0xFF23354E),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      formatAmount(amountStr),
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 28,
                                        fontFamily: 'Outfit',
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(left: 2),
                                      width: 2,
                                      height: 24,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),

                    // Built-in Keyboard
                    Container(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 20),
                      child: Column(
                        children: [
                          if (showOperators)
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: borderCol),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  buildOperatorIconBtn(
                                    icon: Icons.add,
                                    color: Theme.of(context).primaryColor,
                                    onTap: () {
                                      setSheetState(() {
                                        amountStr += ' + ';
                                        showOperators = false;
                                      });
                                    },
                                  ),
                                  buildOperatorIconBtn(
                                    icon: Icons.remove,
                                    color: Colors.orange,
                                    onTap: () {
                                      setSheetState(() {
                                        amountStr += ' - ';
                                        showOperators = false;
                                      });
                                    },
                                  ),
                                  buildOperatorIconBtn(
                                    icon: Icons.close,
                                    color: Colors.blue,
                                    onTap: () {
                                      setSheetState(() {
                                        amountStr += ' x ';
                                        showOperators = false;
                                      });
                                    },
                                  ),
                                  buildOperatorIconBtn(
                                    label: '÷',
                                    color: Colors.purple,
                                    onTap: () {
                                      setSheetState(() {
                                        amountStr += ' ÷ ';
                                        showOperators = false;
                                      });
                                    },
                                  ),
                                  buildOperatorIconBtn(
                                    label: '=',
                                    color: Colors.teal,
                                    onTap: () {
                                      performCalculation();
                                      setSheetState(() {
                                        showOperators = false;
                                      });
                                    },
                                  ),
                                  buildOperatorIconBtn(
                                    label: 'C',
                                    color: Colors.redAccent,
                                    onTap: () {
                                      setSheetState(() {
                                        amountStr = '0';
                                        showOperators = false;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          Row(
                            children: [
                              buildKey(
                                bgColor: inputBg,
                                onTap: () => onKeyboardTap('1'),
                                child: Text('1', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                              buildKey(
                                bgColor: inputBg,
                                onTap: () => onKeyboardTap('2'),
                                child: Text('2', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                              buildKey(
                                bgColor: inputBg,
                                onTap: () => onKeyboardTap('3'),
                                child: Text('3', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                              buildKey(
                                bgColor: isDark ? const Color(0xFF3F2022) : const Color(0xFFFEE2E2),
                                onTap: onBackspace,
                                child: Icon(Icons.backspace_outlined, color: Colors.redAccent.shade400, size: 18),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              buildKey(
                                bgColor: inputBg,
                                onTap: () => onKeyboardTap('4'),
                                child: Text('4', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                              buildKey(
                                bgColor: inputBg,
                                onTap: () => onKeyboardTap('5'),
                                child: Text('5', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                              buildKey(
                                bgColor: inputBg,
                                onTap: () => onKeyboardTap('6'),
                                child: Text('6', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                              buildKey(
                                bgColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                onTap: () {
                                  setSheetState(() {
                                    showOperators = !showOperators;
                                  });
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('+-', style: TextStyle(color: subColor, fontSize: 10, fontWeight: FontWeight.w800, height: 1.0)),
                                    Text('x=', style: TextStyle(color: subColor, fontSize: 10, fontWeight: FontWeight.w800, height: 1.0)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              buildKey(
                                bgColor: inputBg,
                                onTap: () => onKeyboardTap('7'),
                                child: Text('7', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                              buildKey(
                                bgColor: inputBg,
                                onTap: () => onKeyboardTap('8'),
                                child: Text('8', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                              buildKey(
                                bgColor: inputBg,
                                onTap: () => onKeyboardTap('9'),
                                child: Text('9', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                              buildKey(
                                bgColor: inputBg,
                                onTap: () {},
                                child: Text(
                                  'Hari\nIni',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'Outfit',
                                    height: 1.1,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              buildKey(
                                bgColor: inputBg,
                                onTap: () => onKeyboardTap('.'),
                                child: Text('.', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                              buildKey(
                                bgColor: inputBg,
                                onTap: () => onKeyboardTap('0'),
                                child: Text('0', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                              buildKey(
                                bgColor: inputBg,
                                onTap: () => onKeyboardTap('000'),
                                child: Text('000', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                              buildKey(
                                bgColor: const Color(0xFF23354E),
                                onTap: submitClaim,
                                child: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
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
