import 'package:flutter/material.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  // Local state for notes
  final List<Map<String, dynamic>> _notes = [
    {
      'id': '1',
      'title': 'Rencana Belanja Bulanan',
      'content':
          'Beli beras pandan wangi, minyak goreng sunco, sabun cuci piring, kopi arabika, dan susu UHT ultra.',
      'tag': 'Shopping Plan',
      'date': '18 Mei 2026',
      'color': const Color(0xFFFFECE2),
      'textColor': const Color(0xFFFF7043),
    },
    {
      'id': '2',
      'title': 'Strategi Investasi 2026',
      'content':
          'Alokasikan 50% di Reksa Dana Obligasi, 30% di Saham Bluechip BCA/BBRI, dan 20% di Emas fisik Antam.',
      'tag': 'Investasi',
      'date': '12 Mei 2026',
      'color': const Color(0xFFE8F5E9),
      'textColor': const Color(0xFF66BB6A),
    },
    {
      'id': '3',
      'title': 'Ide Bisnis Sampingan',
      'content':
          'Jual kaos katun custom di Tokopedia/Shopee menggunakan sistem print on demand. Modal relatif kecil.',
      'tag': 'Bisnis',
      'date': '02 Mei 2026',
      'color': const Color(0xFFE3F2FD),
      'textColor': const Color(0xFF42A5F5),
    },
  ];

  void _addNote(String title, String content, String tag) {
    setState(() {
      _notes.insert(0, {
        'id': DateTime.now().toString(),
        'title': title,
        'content': content,
        'tag': tag.isNotEmpty ? tag : 'General',
        'date': '19 Mei 2026',
        'color': const Color(0xFFF3E5F5),
        'textColor': const Color(0xFFAB47BC),
      });
    });
  }

  void _removeNote(String id) {
    setState(() {
      _notes.removeWhere((n) => n['id'] == id);
    });
  }

  void _showAddSheet() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final tagController = TextEditingController();

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
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
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
                  'Buat Catatan Baru',
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
                    labelText: 'Judul Catatan',
                    labelStyle: TextStyle(color: subColor),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withValues(alpha: 0.03)
                        : Colors.black.withValues(alpha: 0.015),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(color: textColor),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: tagController,
                  decoration: InputDecoration(
                    labelText: 'Kategori / Tag (e.g. Bisnis)',
                    labelStyle: TextStyle(color: subColor),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withValues(alpha: 0.03)
                        : Colors.black.withValues(alpha: 0.015),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(color: textColor),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Isi Catatan Keuangan',
                    labelStyle: TextStyle(color: subColor),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withValues(alpha: 0.03)
                        : Colors.black.withValues(alpha: 0.015),
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
                      final content = contentController.text;
                      final tag = tagController.text;
                      if (title.isNotEmpty && content.isNotEmpty) {
                        _addNote(title, content, tag);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      'Simpan Catatan',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final mainTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark
        ? Colors.white.withValues(alpha: 0.45)
        : const Color(0xFF64748B);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.black.withValues(alpha: 0.05);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Catatan Finansial',
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
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: mainTextColor,
            size: 20,
          ),
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

              _notes.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 80.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.edit_note_rounded,
                              size: 64,
                              color: subTextColor.withValues(alpha: 0.2),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Belum ada catatan finansial',
                              style: TextStyle(
                                color: mainTextColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: _notes.map((note) {
                        final bgCol = note['color'] as Color;
                        final txtCol = note['textColor'] as Color;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark ? theme.cardColor : bgCol,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isDark ? borderColor : bgCol,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? txtCol.withValues(alpha: 0.12)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      (note['tag'] as String).toUpperCase(),
                                      style: TextStyle(
                                        color: txtCol,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () =>
                                        _removeNote(note['id'] as String),
                                    child: Icon(
                                      Icons.delete_outline_rounded,
                                      color: isDark
                                          ? subTextColor.withValues(alpha: 0.4)
                                          : txtCol.withValues(alpha: 0.6),
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                note['title'] as String,
                                style: TextStyle(
                                  color: mainTextColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                note['content'] as String,
                                style: TextStyle(
                                  color: isDark
                                      ? subTextColor
                                      : const Color(0xFF334155),
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                note['date'] as String,
                                style: TextStyle(
                                  color: isDark
                                      ? subTextColor.withValues(alpha: 0.6)
                                      : txtCol.withValues(alpha: 0.8),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
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
