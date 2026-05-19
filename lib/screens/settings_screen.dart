import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/app_provider.dart';
import '../widgets/glass_card.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showCurrencyPicker(BuildContext context, AppProvider provider) {
    final List<String> currencies = ['Rp', '\$', '€', '£', '¥'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Global Currency',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                          : Colors.white70,
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Reset All Data?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'This will permanently delete all your custom wallets, budgets, and transactions, and restore the default starter kit.\n\nThis action cannot be undone.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white38),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Clear and reload
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                // We can trigger reload by reinstantiating or restarting,
                // for simplicity we trigger provider load which fetches empty and applies defaults
                Navigator.of(context).pop();

                // Fast restart lookalike
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final theme = Theme.of(context);

    final currentPalette = provider.currentPalette;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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

              // Custom Theme Palette Switcher Card
              const Text(
                'Aesthetics & Theme',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              GlassCard(
                borderRadius: 24,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.palette_rounded,
                          color: theme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Dark Color Theme',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Personalize the dark workspace with unique neon colors.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Palette List Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 2.1,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                          ),
                      itemCount: AppTheme.palettes.length,
                      itemBuilder: (context, index) {
                        final key = AppTheme.palettes.keys.elementAt(index);
                        final val = AppTheme.palettes[key]!;
                        final isSelected = currentPalette == key;

                        return GestureDetector(
                          onTap: () => provider.setPalette(key),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? val.primary.withValues(alpha: 0.08)
                                  : Colors.white.withValues(alpha: 0.02),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? val.primary
                                    : Colors.white.withValues(alpha: 0.04),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Theme indicator pill
                                Container(
                                  height: 24,
                                  width: 24,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: val.cardGradient,
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    key,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white54,
                                      fontWeight: isSelected
                                          ? FontWeight.w800
                                          : FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Account & Core settings
              const Text(
                'Account Settings',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Currency & Preference Cards
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
                child: Column(
                  children: [
                    // Currency
                    ListTile(
                      leading: Icon(
                        Icons.monetization_on_rounded,
                        color: theme.primaryColor,
                        size: 20,
                      ),
                      title: const Text(
                        'Currency Symbol',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        'Change symbols displayed across numbers.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.35),
                          fontSize: 11,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
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
                    Divider(
                      color: Colors.white.withValues(alpha: 0.04),
                      height: 1,
                      indent: 56,
                    ),
                    // Theme toggler (Information block)
                    ListTile(
                      leading: Icon(
                        Icons.dark_mode_rounded,
                        color: theme.primaryColor,
                        size: 20,
                      ),
                      title: const Text(
                        'Display Mode',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        'Force light theme or stick to battery-saving dark.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.35),
                          fontSize: 11,
                        ),
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
                  ],
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
                  color: Colors.redAccent.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.redAccent.withValues(alpha: 0.12),
                  ),
                ),
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

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
