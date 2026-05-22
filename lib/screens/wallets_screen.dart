import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/wallet.dart';
import '../models/savings_target.dart';
import 'savings_targets_screen.dart';
import 'savings_target_detail_screen.dart';
import 'wallet_detail_screen.dart';

class WalletsScreen extends StatelessWidget {
  const WalletsScreen({super.key});

  void _showAddWalletScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddWalletScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);
    final scaffoldBg = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF1F5F9);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderCol = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.04);

    // Calculate totals
    double totalBalance = provider.wallets.fold(0, (sum, w) => sum + w.balance);
    double totalSavings = provider.savingsTargets.fold(0.0, (sum, t) => sum + t.savedAmount);
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 2,
    );

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        leading: const SizedBox.shrink(),
        leadingWidth: 0,
        title: Text(
          'Dompet Saya',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            fontFamily: 'Outfit',
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showAddWalletScreen(context),
            icon: Icon(Icons.add_rounded, color: textColor),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Consolidated Wealth Card (Matches Dashboard)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E293B).withValues(alpha: 0.15),
                    blurRadius: 20,
                    spreadRadius: -4,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Decorative Circle top-right
                  Positioned(
                    top: -40,
                    right: -40,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.035),
                      ),
                    ),
                  ),
                  // Decorative Circle bottom-left
                  Positioned(
                    bottom: -30,
                    left: -40,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.035),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Dapat Dibelanjakan (IDR)',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.swap_horiz_rounded,
                              color: Colors.white.withValues(alpha: 0.7),
                              size: 14,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formatter.format(totalBalance),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.arrow_downward_rounded,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '-0.0%',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '(Rp1,00) 30 hari terakhir',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Grid 2x2
                        Row(
                          children: [
                            Expanded(
                              child: _buildMiniStatCard(
                                'Saldo Bersih',
                                formatter.format(totalBalance),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMiniStatCard(
                                'Hutang Aktif',
                                formatter.format(0),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMiniStatCard(
                                'Tabungan Aktif',
                                formatter.format(totalSavings),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMiniStatCard(
                                'Pembayaran Mendatang',
                                formatter.format(0),
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
            const SizedBox(height: 30),

            // Wallet Sections
            _buildWalletSection(
              'Tunai',
              'Cash',
              provider,
              cardBg,
              textColor,
              subTextColor,
              borderCol,
              formatter,
              context,
            ),
            _buildWalletSection(
              'Akun Bank',
              'Bank',
              provider,
              cardBg,
              textColor,
              subTextColor,
              borderCol,
              formatter,
              context,
            ),
            _buildWalletSection(
              'E-Wallet',
              'E-Wallet',
              provider,
              cardBg,
              textColor,
              subTextColor,
              borderCol,
              formatter,
              context,
            ),
            _buildWalletSection(
              'Investasi',
              'Investment',
              provider,
              cardBg,
              textColor,
              subTextColor,
              borderCol,
              formatter,
              context,
            ),
            _buildWalletSection(
              'Kartu Kredit',
              'Credit Card',
              provider,
              cardBg,
              textColor,
              subTextColor,
              borderCol,
              formatter,
              context,
            ),
            _buildSavingsSection(
              provider,
              cardBg,
              textColor,
              subTextColor,
              borderCol,
              formatter,
              context,
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStatCard(String title, String amount) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletSection(
    String title,
    String type,
    AppProvider provider,
    Color cardBg,
    Color textColor,
    Color subTextColor,
    Color borderCol,
    NumberFormat formatter,
    BuildContext context,
  ) {
    final wallets = provider.wallets.where((w) => w.type == type).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        if (wallets.isEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderCol),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: subTextColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    type == 'Bank'
                        ? Icons.account_balance_rounded
                        : type == 'E-Wallet'
                        ? Icons.account_balance_wallet_rounded
                        : type == 'Investment'
                        ? Icons.trending_up_rounded
                        : Icons.account_balance_wallet_rounded,
                    color: subTextColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Belum ada dompet $title',
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ketuk + di pojok kanan atas untuk menambahkan',
                        style: TextStyle(
                          color: subTextColor.withValues(alpha: 0.6),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: wallets.map((wallet) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderCol),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WalletDetailScreen(walletId: wallet.id),
                        ),
                      );
                    },
                    onLongPress: () =>
                        _confirmDelete(context, provider, wallet),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: wallet.color.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              wallet.icon,
                              color: wallet.color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  wallet.name,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${wallet.type.toUpperCase()} • IDR',
                                  style: TextStyle(
                                    color: subTextColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Saldo Saat Ini',
                                style: TextStyle(
                                  color: subTextColor,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatter.format(wallet.balance),
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        if (wallets.isNotEmpty) const SizedBox(height: 12),
      ],
    );
  }

  void _confirmDelete(
    BuildContext context,
    AppProvider provider,
    Wallet wallet,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Hapus Dompet?'),
          content: Text(
            'Apakah Anda yakin ingin menghapus "${wallet.name}"? Semua transaksi terkait juga akan dihapus.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                provider.deleteWallet(wallet.id);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Hapus',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSavingsSection(
    AppProvider provider,
    Color cardBg,
    Color textColor,
    Color subTextColor,
    Color borderCol,
    NumberFormat formatter,
    BuildContext context,
  ) {
    final targets = provider.savingsTargets;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tabungan & Celengan',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SavingsTargetsScreen()),
                );
              },
              child: Text(
                'Lihat Semua',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (targets.isEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderCol),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: subTextColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.savings_rounded,
                    color: subTextColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Belum ada target tabungan',
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ketuk "Lihat Semua" untuk membuat celengan pertama Anda.',
                        style: TextStyle(
                          color: subTextColor.withValues(alpha: 0.6),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: targets.map((target) {
              final isAchieved = target.isAchieved;
              final progress = target.targetAmount > 0 ? (target.savedAmount / target.targetAmount).clamp(0.0, 1.0) : 0.0;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderCol),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SavingsTargetDetailScreen(targetId: target.id),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: target.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              target.icon,
                              color: target.color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        target.title,
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isAchieved
                                            ? const Color(0xFF00D179).withValues(alpha: 0.12)
                                            : Colors.amber.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        isAchieved ? 'Tercapai' : 'Belum Tercapai',
                                        style: TextStyle(
                                          color: isAchieved ? const Color(0xFF00D179) : Colors.amber,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.04),
                                    valueColor: AlwaysStoppedAnimation<Color>(isAchieved ? const Color(0xFF00D179) : target.color),
                                    minHeight: 4,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Terkumpul: ${formatter.format(target.savedAmount)} dari ${formatter.format(target.targetAmount)} (${(progress * 100).toStringAsFixed(0)}%)',
                                  style: TextStyle(
                                    color: subTextColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        if (targets.isNotEmpty) const SizedBox(height: 12),
      ],
    );
  }
}

class AddWalletScreen extends StatefulWidget {
  const AddWalletScreen({super.key});

  @override
  State<AddWalletScreen> createState() => _AddWalletScreenState();
}

class _AddWalletScreenState extends State<AddWalletScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();

  String _selectedType = 'Cash'; // Internal type
  Color _selectedColor = const Color(0xFF66BB6A);
  IconData _selectedIcon = Icons.payments_rounded;
  bool _excludeFromTotal = false;
  bool _linkAsPocket = false;

  final List<String> _types = [
    'Cash',
    'Bank',
    'E-Wallet',
    'Credit Card',
    'Investment',
  ];

  String _getDisplayType(String type) {
    switch (type) {
      case 'Cash':
        return 'Kas';
      case 'Bank':
        return 'Akun Bank';
      case 'Credit Card':
        return 'Kartu Kredit';
      case 'Investment':
        return 'Investasi';
      default:
        return type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final double balance =
        double.tryParse(_balanceController.text.replaceAll(',', '')) ?? 0.0;
    final provider = Provider.of<AppProvider>(context, listen: false);
    provider.addWallet(
      name: _nameController.text.trim(),
      type: _selectedType,
      initialBalance: balance,
      color: _selectedColor,
      icon: _selectedIcon,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);
    final scaffoldBg = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF1F5F9);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderCol = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.04);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Tambah Dompet Baru',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            fontFamily: 'Outfit',
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.check_rounded, color: textColor),
            onPressed: _submit,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Warning Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tidak ada template tersedia',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Impor paket ikon di Pengaturan untuk melihat paket ikon bank/e-wallet',
                            style: TextStyle(color: subTextColor, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Detail Dompet',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),

              _buildLabel('Nama Dompet', subTextColor),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                style: TextStyle(color: textColor, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'misal: BCA, GoPay, Tunai',
                  hintStyle: TextStyle(
                    color: subTextColor.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: cardBg,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'Masukkan nama dompet'
                    : null,
              ),
              const SizedBox(height: 16),

              _buildLabel('Mata Uang Dompet', subTextColor),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: subTextColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.public_rounded,
                        color: subTextColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'IDR',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Indonesian Rupiah',
                            style: TextStyle(color: subTextColor, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: subTextColor,
                      size: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _buildLabel('Saldo Awal', subTextColor),
              const SizedBox(height: 8),
              TextFormField(
                controller: _balanceController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: textColor, fontSize: 14),
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: TextStyle(
                    color: subTextColor.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: cardBg,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildLabel('Tipe', subTextColor),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    ..._types.map((type) {
                      final isSelected = _selectedType == type;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _selectedType = type;
                          if (type == 'Cash') {
                            _selectedColor = const Color(0xFF66BB6A);
                            _selectedIcon = Icons.payments_rounded;
                          }
                          if (type == 'Bank') {
                            _selectedColor = const Color(0xFF42A5F5);
                            _selectedIcon = Icons.account_balance_rounded;
                          }
                          if (type == 'E-Wallet') {
                            _selectedColor = const Color(0xFFAB47BC);
                            _selectedIcon =
                                Icons.account_balance_wallet_rounded;
                          }
                          if (type == 'Credit Card') {
                            _selectedColor = const Color(0xFFFF7043);
                            _selectedIcon = Icons.credit_card_rounded;
                          }
                          if (type == 'Investment') {
                            _selectedColor = const Color(0xFF26C6DA);
                            _selectedIcon = Icons.trending_up_rounded;
                          }
                        }),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.primaryColor.withValues(alpha: 0.1)
                                : cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? theme.primaryColor
                                  : borderCol,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                type == 'Cash'
                                    ? Icons.payments_rounded
                                    : type == 'Bank'
                                    ? Icons.account_balance_rounded
                                    : type == 'E-Wallet'
                                    ? Icons.account_balance_wallet_rounded
                                    : type == 'Investment'
                                    ? Icons.trending_up_rounded
                                    : Icons.credit_card_rounded,
                                size: 16,
                                color: isSelected
                                    ? theme.primaryColor
                                    : subTextColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getDisplayType(type),
                                style: TextStyle(
                                  color: isSelected
                                      ? theme.primaryColor
                                      : textColor,
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardBg,
                        shape: BoxShape.circle,
                        border: Border.all(color: borderCol),
                      ),
                      child: Icon(
                        Icons.shuffle_rounded,
                        size: 16,
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Switches
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderCol),
                ),
                child: SwitchListTile(
                  title: Text(
                    'Kecualikan dari Total',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Saldo dompet ini tidak dihitung ke total saldo utama.',
                    style: TextStyle(color: subTextColor, fontSize: 11),
                  ),
                  value: _excludeFromTotal,
                  activeThumbColor: theme.primaryColor,
                  onChanged: (val) => setState(() => _excludeFromTotal = val),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderCol),
                ),
                child: SwitchListTile(
                  title: Text(
                    'Hubungkan sebagai Pocket?',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Jadikan ini sub-akun dari wallet lain',
                    style: TextStyle(color: subTextColor, fontSize: 11),
                  ),
                  value: _linkAsPocket,
                  activeThumbColor: theme.primaryColor,
                  onChanged: (val) => setState(() => _linkAsPocket = val),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Text(text, style: TextStyle(color: color, fontSize: 12));
  }
}
