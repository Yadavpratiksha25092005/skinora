import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_theme.dart';
import '../../models/progress_entry.dart';
import '../../services/progress_service.dart';
import '../../widgets/progress/progress_photo_tile.dart';
import 'progress_compare_screen.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final ProgressService _service = ProgressService();
  final ImagePicker _picker = ImagePicker();

  List<ProgressEntry> _entries = [];
  bool _loading = true;

  bool _compareMode = false;
  final List<ProgressEntry> _selectedForCompare = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries = await _service.getEntries();
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  Future<void> _addPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null || !mounted) return;

    String category = 'Skin';
    final noteController = TextEditingController();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Progress Photo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              Row(
                children: [
                  _categoryChip('Skin', category, (v) => setModalState(() => category = v)),
                  const SizedBox(width: 10),
                  _categoryChip('Hair', category, (v) => setModalState(() => category = v)),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Add a note (optional)',
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Save Photo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      final entry = ProgressEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        imagePath: picked.path,
        note: noteController.text.trim(),
        category: category,
        date: DateTime.now(),
      );
      await _service.addEntry(entry);
      _loadEntries();
    }
  }

  Widget _categoryChip(String label, String selectedCategory, ValueChanged<String> onSelect) {
    final selected = selectedCategory == label;
    return GestureDetector(
      onTap: () => onSelect(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppTheme.textSecondaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  void _toggleCompareMode() {
    setState(() {
      _compareMode = !_compareMode;
      _selectedForCompare.clear();
    });
  }

  void _onPhotoTap(ProgressEntry entry) {
    if (!_compareMode) return;

    setState(() {
      if (_selectedForCompare.contains(entry)) {
        _selectedForCompare.remove(entry);
      } else if (_selectedForCompare.length < 2) {
        _selectedForCompare.add(entry);
      }
    });

    if (_selectedForCompare.length == 2) {
      final sorted = [..._selectedForCompare]..sort((a, b) => a.date.compareTo(b.date));
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProgressCompareScreen(before: sorted[0], after: sorted[1]),
        ),
      ).then((_) {
        setState(() {
          _compareMode = false;
          _selectedForCompare.clear();
        });
      });
    }
  }

  Future<void> _deleteEntry(ProgressEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete photo'),
        content: const Text('This will permanently remove this progress photo. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _service.deleteEntry(entry.id);
      _loadEntries();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }

    final grouped = _service.groupByMonth(_entries);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      floatingActionButton: _compareMode
          ? null
          : FloatingActionButton.extended(
              onPressed: _addPhoto,
              backgroundColor: AppTheme.primaryColor,
              icon: const Icon(Icons.add_a_photo_rounded, color: Colors.white),
              label: const Text('Add Photo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Progress Tracking', style: Theme.of(context).textTheme.displaySmall),
                  if (_entries.length >= 2)
                    TextButton.icon(
                      onPressed: _toggleCompareMode,
                      icon: Icon(
                        _compareMode ? Icons.close_rounded : Icons.compare_rounded,
                        size: 18,
                        color: AppTheme.primaryColor,
                      ),
                      label: Text(
                        _compareMode ? 'Cancel' : 'Compare',
                        style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ),

            if (_compareMode)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                child: Text(
                  'Select 2 photos to compare (${_selectedForCompare.length}/2 selected)',
                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                ),
              ),

            const SizedBox(height: 16),

            if (_entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.photo_camera_outlined, size: 40, color: AppTheme.primaryColor),
                      ),
                      const SizedBox(height: 20),
                      const Text('No progress photos yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(
                        'Tap "Add Photo" to start tracking your\nskin & hair journey over time.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...grouped.entries.map((monthGroup) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        monthGroup.key,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textSecondaryColor),
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: monthGroup.value.length,
                        itemBuilder: (context, index) {
                          final entry = monthGroup.value[index];
                          return ProgressPhotoTile(
                            entry: entry,
                            selected: _selectedForCompare.contains(entry),
                            onTap: () => _onPhotoTap(entry),
                            onLongPress: _compareMode ? null : () => _deleteEntry(entry),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 80), // space for FAB
          ],
        ),
      ),
    );
  }
}