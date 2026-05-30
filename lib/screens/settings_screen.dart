import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/app_provider.dart';
import 'categories_screen.dart';
import 'pin_lock_screen.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showCurrencyPicker(BuildContext context, AppProvider provider) {
    final List<String> currencies = ['Rp', '\$', '€', '£', '¥'];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mainTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Global Currency',
            style: TextStyle(color: mainTextColor, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: currencies.length,
              itemBuilder: (context, index) {
                final symbol = currencies[index];
                final isSelected = provider.currencySymbol == symbol;

                return ListTile(
                  title: Text(
                    symbol == 'Rp'
                        ? 'Rp (Rupiah)'
                        : (symbol == '\$'
                              ? '\$ (USD)'
                              : (symbol == '€'
                                    ? '€ (EUR)'
                                    : (symbol == '£' ? '£ (GBP)' : '¥ (JPY)'))),
                    style: TextStyle(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : subTextColor,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: Theme.of(context).primaryColor,
                        )
                      : null,
                  onTap: () {
                    provider.setCurrency(symbol);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showResetConfirm(BuildContext context, AppProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mainTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark
        ? Colors.white.withValues(alpha: 0.7)
        : const Color(0xFF64748B);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Reset All Data?',
            style: TextStyle(color: mainTextColor, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'This will permanently delete all your custom wallets, budgets, and transactions, and restore the default starter kit.\n\nThis action cannot be undone.',
            style: TextStyle(color: subTextColor, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Clear and reload
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Database reset completed successfully! Please restart the app.',
                    ),
                    backgroundColor: Colors.teal,
                  ),
                );
              },
              child: const Text(
                'Reset',
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

  void _showRestoreDialog(BuildContext context, AppProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mainTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Restore Data Cadangan',
            style: TextStyle(color: mainTextColor, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Memulihkan data akan menggantikan seluruh data transaksi, dompet, anggaran, celengan, tagihan, dan data keuangan Anda saat ini dengan data dari file cadangan.\n\nApakah Anda ingin melanjutkan?',
            style: TextStyle(color: subTextColor, fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog first
                try {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.any,
                  );

                  if (result != null && result.files.single.path != null) {
                    final file = File(result.files.single.path!);
                    final content = await file.readAsString();
                    final success = await provider.restoreBackupData(content);

                    if (context.mounted) {
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Data berhasil dipulihkan!'),
                            backgroundColor: Colors.teal,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'File cadangan tidak valid atau rusak.',
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal membaca file cadangan: $e'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'Pilih File',
                style: TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final mainTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark
        ? Colors.white.withValues(alpha: 0.45)
        : const Color(0xFF64748B);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.black.withValues(alpha: 0.05);
    final cardBgColor = isDark
        ? theme.cardColor.withValues(alpha: 0.3)
        : Colors.white;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(color: mainTextColor, fontWeight: FontWeight.w700),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Account & Core settings
              Text(
                'Account Settings',
                style: TextStyle(
                  color: subTextColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Currency & Preference Cards
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Material(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(24),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      // Currency
                      ListTile(
                        leading: Icon(
                          Icons.monetization_on_rounded,
                          color: theme.primaryColor,
                          size: 20,
                        ),
                        title: Text(
                          'Currency Symbol',
                          style: TextStyle(
                            color: mainTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          'Change symbols displayed across numbers.',
                          style: TextStyle(color: subTextColor, fontSize: 11),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.04)
                                : Colors.black.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            provider.currencySymbol,
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        onTap: () => _showCurrencyPicker(context, provider),
                      ),
                      Divider(color: borderColor, height: 1, indent: 56),
                      // Theme toggler (Information block)
                      ListTile(
                        leading: Icon(
                          Icons.dark_mode_rounded,
                          color: theme.primaryColor,
                          size: 20,
                        ),
                        title: Text(
                          'Display Mode',
                          style: TextStyle(
                            color: mainTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          'Force light theme or stick to battery-saving dark.',
                          style: TextStyle(color: subTextColor, fontSize: 11),
                        ),
                        trailing: Switch(
                          value: provider.themeMode == ThemeMode.dark,
                          activeThumbColor: theme.primaryColor,
                          onChanged: (val) {
                            provider.setThemeMode(
                              val ? ThemeMode.dark : ThemeMode.light,
                            );
                          },
                        ),
                      ),
                      Divider(color: borderColor, height: 1, indent: 56),
                      // Kelola Kategori
                      ListTile(
                        leading: Icon(
                          Icons.category_rounded,
                          color: theme.primaryColor,
                          size: 20,
                        ),
                        title: Text(
                          'Kelola Kategori',
                          style: TextStyle(
                            color: mainTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          'Atur kategori pemasukan, pengeluaran & sistem.',
                          style: TextStyle(color: subTextColor, fontSize: 11),
                        ),
                        trailing: Icon(
                          Icons.keyboard_arrow_right_rounded,
                          color: subTextColor,
                          size: 20,
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const CategoriesScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Security settings (PIN Lock)
              Text(
                'Keamanan & Sesi',
                style: TextStyle(
                  color: subTextColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor),
                ),
                child: Material(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(24),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.lock_rounded,
                          color: theme.primaryColor,
                          size: 20,
                        ),
                        title: Text(
                          'PIN Lock Pengaman',
                          style: TextStyle(
                            color: mainTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          'Amankan data keuangan dengan PIN 4 digit.',
                          style: TextStyle(color: subTextColor, fontSize: 11),
                        ),
                        trailing: Switch(
                          value: provider.isPinEnabled,
                          activeThumbColor: theme.primaryColor,
                          onChanged: (val) {
                            if (val) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PinLockScreen(mode: PinMode.setup),
                                ),
                              );
                            } else {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const PinLockScreen(
                                    mode: PinMode.disable,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      if (provider.isPinEnabled) ...[
                        Divider(color: borderColor, height: 1, indent: 56),
                        ListTile(
                          leading: Icon(
                            Icons.key_rounded,
                            color: theme.primaryColor,
                            size: 20,
                          ),
                          title: Text(
                            'Ubah PIN Keamanan',
                            style: TextStyle(
                              color: mainTextColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Text(
                            'Perbarui PIN keamanan 4 digit Anda.',
                            style: TextStyle(color: subTextColor, fontSize: 11),
                          ),
                          trailing: Icon(
                            Icons.keyboard_arrow_right_rounded,
                            color: subTextColor,
                            size: 20,
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PinLockScreen(mode: PinMode.change),
                              ),
                            );
                          },
                        ),
                        Divider(color: borderColor, height: 1, indent: 56),
                        ListTile(
                          leading: Icon(
                            Icons.timer_rounded,
                            color: theme.primaryColor,
                            size: 20,
                          ),
                          title: Text(
                            'Batas Waktu Sesi',
                            style: TextStyle(
                              color: mainTextColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Text(
                            'Kunci otomatis setelah tidak aktif.',
                            style: TextStyle(color: subTextColor, fontSize: 11),
                          ),
                          trailing: DropdownButton<int>(
                            value: provider.sessionTimeoutMinutes,
                            underline: const SizedBox(),
                            dropdownColor: theme.cardColor,
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 1,
                                child: Text('1 Menit'),
                              ),
                              DropdownMenuItem(
                                value: 5,
                                child: Text('5 Menit'),
                              ),
                              DropdownMenuItem(
                                value: 15,
                                child: Text('15 Menit'),
                              ),
                              DropdownMenuItem(
                                value: 30,
                                child: Text('30 Menit'),
                              ),
                              DropdownMenuItem(value: -1, child: Text('Never')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                provider.setSessionTimeout(val);
                              }
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Backup & Restore
              Text(
                'Cadangan Data (Backup)',
                style: TextStyle(
                  color: subTextColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor),
                ),
                child: Material(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(24),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.cloud_upload_rounded,
                          color: theme.primaryColor,
                          size: 20,
                        ),
                        title: Text(
                          'Backup Data Cadangan',
                          style: TextStyle(
                            color: mainTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          'Ekspor seluruh data keuangan Anda ke file JSON.',
                          style: TextStyle(color: subTextColor, fontSize: 11),
                        ),
                        trailing: Icon(
                          Icons.download_rounded,
                          color: subTextColor,
                          size: 18,
                        ),
                        onTap: () async {
                          try {
                            final backupStr = await provider.exportBackupData();
                            final tempDir = await getTemporaryDirectory();
                            final dateStr = DateTime.now().toString().split(
                              ' ',
                            )[0];
                            final file = File(
                              '${tempDir.path}/nioney_backup_$dateStr.json',
                            );
                            await file.writeAsString(backupStr);
                            await Share.shareXFiles([
                              XFile(file.path),
                            ], subject: 'Nioney Backup $dateStr');
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal membuat backup: $e'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                        },
                      ),
                      Divider(color: borderColor, height: 1, indent: 56),
                      ListTile(
                        leading: Icon(
                          Icons.cloud_download_rounded,
                          color: theme.primaryColor,
                          size: 20,
                        ),
                        title: Text(
                          'Restore Data Cadangan',
                          style: TextStyle(
                            color: mainTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          'Impor data keuangan Anda dari file JSON cadangan.',
                          style: TextStyle(color: subTextColor, fontSize: 11),
                        ),
                        trailing: Icon(
                          Icons.upload_file_rounded,
                          color: subTextColor,
                          size: 18,
                        ),
                        onTap: () => _showRestoreDialog(context, provider),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Danger Zone
              const Text(
                'Danger Zone',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Reset Card
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.redAccent.withValues(alpha: 0.12),
                  ),
                ),
                child: Material(
                  color: Colors.redAccent.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(24),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    leading: const Icon(
                      Icons.restart_alt_rounded,
                      color: Colors.redAccent,
                      size: 22,
                    ),
                    title: const Text(
                      'Erase All Data',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    subtitle: const Text(
                      'Wipe the persistent box storage cleanly.',
                      style: TextStyle(color: Colors.redAccent, fontSize: 11),
                    ),
                    onTap: () => _showResetConfirm(context, provider),
                  ),
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
