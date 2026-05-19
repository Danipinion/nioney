import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/category.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int _activeTab = 0; // 0: Pengeluaran, 1: Pemasukan, 2: Sistem
  final Set<String> _expandedCategoryIds = {};

  final List<IconData> _availableIcons = [
    Icons.fastfood_rounded,
    Icons.directions_car_rounded,
    Icons.shopping_bag_rounded,
    Icons.home_rounded,
    Icons.movie_creation_rounded,
    Icons.healing_rounded,
    Icons.school_rounded,
    Icons.person_rounded,
    Icons.account_balance_wallet_rounded,
    Icons.trending_up_rounded,
    Icons.savings_rounded,
    Icons.payments_rounded,
    Icons.flight_takeoff_rounded,
    Icons.restaurant_rounded,
    Icons.sports_esports_rounded,
    Icons.work_rounded,
    Icons.pets_rounded,
    Icons.fitness_center_rounded,
    Icons.card_giftcard_rounded,
    Icons.build_rounded,
  ];

  final List<Color> _availableColors = [
    const Color(0xFFFF7043), // Coral
    const Color(0xFF42A5F5), // Blue
    const Color(0xFFEC407A), // Pink
    const Color(0xFFFFCA28), // Yellow
    const Color(0xFFAB47BC), // Purple
    const Color(0xFF26A69A), // Teal
    const Color(0xFF66BB6A), // Green
    const Color(0xFF26C6DA), // Cyan
    const Color(0xFF8D6E63), // Brown
    const Color(0xFF78909C), // Slate
    const Color(0xFFBA68C8), // Orchid
    const Color(0xFFFFA726), // Orange
  ];

  void _toggleExpanded(String id) {
    setState(() {
      if (_expandedCategoryIds.contains(id)) {
        _expandedCategoryIds.remove(id);
      } else {
        _expandedCategoryIds.add(id);
      }
    });
  }

  void _showAddCategoryDialog(BuildContext context, AppProvider provider) {
    final nameController = TextEditingController();
    IconData selectedIcon = _availableIcons.first;
    Color selectedColor = _availableColors.first;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(
                _activeTab == 1 ? 'Tambah Kategori Pemasukan' : 'Tambah Kategori Pengeluaran',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Outfit',
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name Field
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.black12,
                        ),
                      ),
                      child: TextField(
                        controller: nameController,
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Nama Kategori',
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Icon Picker
                    Text(
                      'Pilih Ikon',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : const Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _availableIcons.length,
                        itemBuilder: (context, index) {
                          final icon = _availableIcons[index];
                          final isSelected = selectedIcon == icon;
                          return GestureDetector(
                            onTap: () => setDialogState(() => selectedIcon = icon),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? selectedColor.withValues(alpha: 0.15)
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? selectedColor : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(icon, color: isSelected ? selectedColor : Colors.grey, size: 20),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Color Picker
                    Text(
                      'Pilih Warna',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : const Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _availableColors.length,
                        itemBuilder: (context, index) {
                          final color = _availableColors[index];
                          final isSelected = selectedColor == color;
                          return GestureDetector(
                            onTap: () => setDialogState(() => selectedColor = color),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 32,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(color: isDark ? Colors.white : Colors.black, width: 2)
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Batal',
                    style: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;

                    await provider.addCategory(
                      name: name,
                      icon: selectedIcon,
                      color: selectedColor,
                      isExpense: _activeTab != 1,
                    );
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text(
                    'Simpan',
                    style: TextStyle(color: selectedColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddSubCategorySheet(BuildContext context, AppProvider provider, String categoryId) {
    final subController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tambah Sub-kategori Baru',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Outfit',
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black12,
                    ),
                  ),
                  child: TextField(
                    controller: subController,
                    autofocus: true,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Nama sub-kategori...',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Batal',
                        style: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: () async {
                        final name = subController.text.trim();
                        if (name.isNotEmpty) {
                          await provider.addSubCategory(categoryId, name);
                        }
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text('Tambah', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
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

    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);
    final inputBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderCol = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04);

    // Filter categories based on active tab
    List<Category> displayedCategories = [];
    if (_activeTab == 0) {
      displayedCategories = provider.categories.where((c) => c.isExpense && c.id != 'other_expense').toList();
    } else if (_activeTab == 1) {
      displayedCategories = provider.categories.where((c) => !c.isExpense && c.id != 'other_income').toList();
    } else {
      // System Tab
      displayedCategories = [
        const Category(id: 'sys_transfer', name: 'Transfer', icon: Icons.swap_horiz_rounded, color: Colors.indigo, isExpense: true),
        const Category(id: 'sys_recurring', name: 'Berulang', icon: Icons.repeat_rounded, color: Colors.blueGrey, isExpense: true),
        const Category(id: 'sys_wishlist', name: 'Keinginan', icon: Icons.favorite_rounded, color: Colors.pinkAccent, isExpense: true),
        const Category(id: 'sys_bills', name: 'Tagihan', icon: Icons.receipt_long_rounded, color: Colors.redAccent, isExpense: true),
        const Category(id: 'sys_debt', name: 'Hutang Piutang', icon: Icons.account_balance_wallet_rounded, color: Colors.deepOrange, isExpense: true),
        const Category(id: 'sys_saving_target', name: 'Target Tabungan', icon: Icons.track_changes_rounded, color: Colors.green, isExpense: true),
        const Category(id: 'sys_bundled_notes', name: 'Catatan Terbundle', icon: Icons.library_books_rounded, color: Colors.brown, isExpense: true),
        const Category(id: 'sys_reimburse', name: 'Reimburse', icon: Icons.handshake_rounded, color: Colors.orange, isExpense: true),
        const Category(id: 'sys_adjustment', name: 'Penyesuaian Saldo', icon: Icons.adjust_rounded, color: Colors.teal, isExpense: true),
        const Category(id: 'sys_investasi', name: 'Investasi', icon: Icons.trending_up_rounded, color: Colors.cyan, isExpense: true),
      ];
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Kategori',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            fontFamily: 'Outfit',
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.swap_vert_rounded, color: textColor),
            onPressed: () {},
          ),
        ],
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Elegant Tab Segment Bar
          Container(
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _activeTab = 0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: _activeTab == 0 ? const Color(0xFF23354E) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          'Pengeluaran',
                          style: TextStyle(
                            color: _activeTab == 0 ? Colors.white : subTextColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _activeTab = 1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: _activeTab == 1 ? const Color(0xFF23354E) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          'Pemasukan',
                          style: TextStyle(
                            color: _activeTab == 1 ? Colors.white : subTextColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _activeTab = 2),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: _activeTab == 2 ? const Color(0xFF23354E) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          'Kategori Sistem',
                          style: TextStyle(
                            color: _activeTab == 2 ? Colors.white : subTextColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Categories List
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: displayedCategories.length,
              itemBuilder: (context, index) {
                final cat = displayedCategories[index];
                final isExpanded = _expandedCategoryIds.contains(cat.id);

                // Fetch dynamic subcategories
                final List<String> subs = _activeTab == 2
                    ? []
                    : provider.getSubCategoriesForCategory(cat.id);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderCol),
                  ),
                  child: Material(
                    color: inputBg,
                    borderRadius: BorderRadius.circular(20),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        onTap: _activeTab != 2 ? () => _toggleExpanded(cat.id) : null,
                        leading: Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: cat.color.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(cat.icon, color: cat.color, size: 22),
                        ),
                        title: Text(
                          cat.name,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        subtitle: _activeTab != 2 ? Text(
                          '${subs.length} sub-kategori',
                          style: TextStyle(
                            color: subTextColor,
                            fontSize: 11,
                          ),
                        ) : null,
                        trailing: _activeTab != 2 ? Icon(
                          isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                          color: subTextColor,
                        ) : null,
                      ),

                      // Expanded subcategories section
                      if (isExpanded) ...[
                        const Divider(height: 1, thickness: 0.5),
                        Container(
                          padding: const EdgeInsets.all(16),
                          alignment: Alignment.topLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (subs.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Text(
                                    'Belum ada sub-kategori.',
                                    style: TextStyle(
                                      color: subTextColor,
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                )
                              else
                                Column(
                                  children: subs.map((subName) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: borderCol),
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                          dense: true,
                                          title: Text(
                                            subName,
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          trailing: _activeTab != 2
                                              ? IconButton(
                                                  icon: Icon(
                                                    Icons.delete_outline_rounded,
                                                    size: 18,
                                                    color: Colors.redAccent.withValues(alpha: 0.8),
                                                  ),
                                                  onPressed: () => provider.deleteSubCategory(cat.id, subName),
                                                )
                                              : null,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              const SizedBox(height: 12),

                              // Quick actions row inside card
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Delete category button (only for non-system)
                                  if (_activeTab != 2)
                                    TextButton.icon(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.redAccent,
                                      ),
                                      onPressed: () async {
                                        await provider.deleteCategory(cat.id);
                                      },
                                      icon: const Icon(Icons.delete_outline_rounded, size: 16),
                                      label: const Text('Hapus Kategori', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    )
                                  else
                                    const SizedBox.shrink(),

                                  // Add subcategory button
                                  if (_activeTab != 2)
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: cat.color.withValues(alpha: 0.1),
                                        foregroundColor: cat.color,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      ),
                                      onPressed: () => _showAddSubCategorySheet(context, provider, cat.id),
                                      icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                                      label: const Text('Tambah Sub', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
              },
            ),
          ),
        ],
      ),

      // FAB to Add Category (Only for editable tabs)
      floatingActionButton: _activeTab != 2
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF23354E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () => _showAddCategoryDialog(context, provider),
            )
          : null,
    );
  }
}
