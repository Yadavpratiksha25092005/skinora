import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';

/// Maps a remedy category to a display icon/color pair. The backend only
/// stores the category string, so the icon is derived client-side.
class _CategoryStyle {
  final IconData icon;
  final Color color;
  const _CategoryStyle(this.icon, this.color);
}

const Map<String, _CategoryStyle> _categoryStyles = {
  'Acne': _CategoryStyle(Icons.local_florist_rounded, Color(0xFFE8A33D)),
  'Pigmentation': _CategoryStyle(Icons.brightness_5_rounded, Color(0xFFD98E4A)),
  'Dry Skin': _CategoryStyle(Icons.water_drop_rounded, Color(0xFF4FB0A5)),
  'Oily Skin': _CategoryStyle(Icons.spa_rounded, Color(0xFFB08968)),
  'Tan Removal': _CategoryStyle(Icons.wb_sunny_rounded, Color(0xFFF2B705)),
  'Hair Fall': _CategoryStyle(Icons.eco_rounded, Color(0xFF8FA31E)),
  'Dandruff': _CategoryStyle(Icons.water_drop_rounded, Color(0xFF4FB0A5)),
  'Dry Hair': _CategoryStyle(Icons.grass_rounded, Color(0xFF6FA36B)),
  'Lips Care': _CategoryStyle(Icons.favorite_rounded, Color(0xFFE07A9E)),
  'Hand & Foot Care': _CategoryStyle(Icons.back_hand_rounded, Color(0xFFB03D66)),
};

_CategoryStyle _styleFor(String category) =>
    _categoryStyles[category] ?? const _CategoryStyle(Icons.eco_rounded, AppTheme.primaryColor);

class _Remedy {
  final int id;
  final String title;
  final String category;
  final String ingredients;
  final String preparationSteps;
  final String author;
  int likes;
  int comments;
  bool isLiked;
  bool isSaved;

  _Remedy({
    required this.id,
    required this.title,
    required this.category,
    required this.ingredients,
    required this.preparationSteps,
    required this.author,
    required this.likes,
    required this.comments,
    required this.isLiked,
    required this.isSaved,
  });

  IconData get icon => _styleFor(category).icon;
  Color get iconColor => _styleFor(category).color;

  factory _Remedy.fromJson(Map<String, dynamic> json) {
    return _Remedy(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      ingredients: json['ingredients'] as String? ?? '',
      preparationSteps: json['preparation_steps'] as String? ?? '',
      author: json['author_name'] as String? ?? 'Anonymous',
      likes: (json['like_count'] as num?)?.toInt() ?? 0,
      comments: (json['comment_count'] as num?)?.toInt() ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      isSaved: json['is_saved'] as bool? ?? false,
    );
  }
}

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  bool _loading = true;
  String? _errorMessage;
  List<_Remedy> _remedies = [];

  final List<String> _categories = const [
    'All',
    'Acne',
    'Pigmentation',
    'Dry Skin',
    'Oily Skin',
    'Tan Removal',
    'Hair Fall',
    'Dandruff',
    'Dry Hair',
    'Lips Care',
    'Hand & Foot Care',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final data = await _apiService.getAllRemedies();
      final remedies = data.map((json) => _Remedy.fromJson(json as Map<String, dynamic>)).toList();
      if (!mounted) return;
      setState(() {
        _remedies = remedies;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _loading = false;
      });
    }
  }

  List<_Remedy> get _filteredRemedies {
    return _remedies.where((remedy) {
      final matchesCategory = _selectedCategory == 'All' || remedy.category == _selectedCategory;
      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          remedy.title.toLowerCase().contains(query) ||
          remedy.ingredients.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<void> _toggleLike(_Remedy remedy) async {
    // Optimistic update — flip immediately, roll back if the request fails.
    final wasLiked = remedy.isLiked;
    final previousLikes = remedy.likes;
    setState(() {
      remedy.isLiked = !wasLiked;
      remedy.likes += remedy.isLiked ? 1 : -1;
    });

    try {
      await _apiService.toggleLikeRemedy(remedy.id);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        remedy.isLiked = wasLiked;
        remedy.likes = previousLikes;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _toggleSave(_Remedy remedy) async {
    final wasSaved = remedy.isSaved;
    setState(() => remedy.isSaved = !wasSaved);

    try {
      await _apiService.toggleSaveRemedy(remedy.id);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => remedy.isSaved = wasSaved);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _openShareSheet() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ShareRemedySheet(apiService: _apiService, categories: _categories.skip(1).toList()),
    );

    if (created == true) {
      await _load();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRemedies;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Home Remedies'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            FadeInDown(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search remedies or ingredients...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondaryColor),
                    filled: true,
                    fillColor: AppTheme.surfaceColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FadeInDown(
              delay: const Duration(milliseconds: 100),
              child: SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedCategory = category),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: isSelected ? Colors.white : AppTheme.textSecondaryColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                  : _errorMessage != null
                      ? _buildErrorState()
                      : RefreshIndicator(
                          color: AppTheme.primaryColor,
                          onRefresh: _load,
                          child: filtered.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) {
                                    final remedy = filtered[index];
                                    return FadeInUp(
                                      delay: Duration(milliseconds: 80 * index),
                                      child: _buildRemedyCard(remedy),
                                    );
                                  },
                                ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openShareSheet,
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Share', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 64, color: AppTheme.textSecondaryColor),
            const SizedBox(height: 16),
            Text(_errorMessage ?? 'Something went wrong', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      // Wrapped in ListView (not Center) so pull-to-refresh still works when the list is empty.
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 80),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off_rounded, size: 64, color: AppTheme.textSecondaryColor.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'No remedies found',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Try a different search or category.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textSecondaryColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRemedyCard(_Remedy remedy) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: remedy.iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(remedy.icon, color: remedy.iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        remedy.category,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      remedy.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _toggleSave(remedy),
                icon: Icon(
                  remedy.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: remedy.isSaved ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            remedy.ingredients,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppTheme.textSecondaryColor, height: 1.4),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
                child: Text(
                  remedy.author.isNotEmpty ? remedy.author[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                remedy.author,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textPrimaryColor),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _toggleLike(remedy),
                child: Row(
                  children: [
                    Icon(
                      remedy.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      size: 18,
                      color: remedy.isLiked ? AppTheme.errorColor : AppTheme.textSecondaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text('${remedy.likes}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  const Icon(Icons.mode_comment_outlined, size: 17, color: AppTheme.textSecondaryColor),
                  const SizedBox(width: 4),
                  Text('${remedy.comments}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet form for sharing a new remedy — pops `true` on success so the
/// caller knows to refresh the list.
class _ShareRemedySheet extends StatefulWidget {
  final ApiService apiService;
  final List<String> categories;

  const _ShareRemedySheet({required this.apiService, required this.categories});

  @override
  State<_ShareRemedySheet> createState() => _ShareRemedySheetState();
}

class _ShareRemedySheetState extends State<_ShareRemedySheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _stepsController = TextEditingController();
  String? _selectedCategory;
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _ingredientsController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await widget.apiService.createRemedy(
        title: _titleController.text.trim(),
        category: _selectedCategory!,
        ingredients: _ingredientsController.text.trim(),
        preparationSteps: _stepsController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Share a Remedy', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'e.g. Multani Mitti Glow Pack',
                    filled: true,
                    fillColor: AppTheme.surfaceColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Title is required' : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    filled: true,
                    fillColor: AppTheme.surfaceColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                  items: widget.categories
                      .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedCategory = value),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _ingredientsController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Ingredients',
                    hintText: 'e.g. Multani mitti, rose water, turmeric',
                    filled: true,
                    fillColor: AppTheme.surfaceColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Ingredients are required' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _stepsController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Preparation Steps',
                    hintText: 'How to prepare and use it',
                    filled: true,
                    fillColor: AppTheme.surfaceColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Preparation steps are required' : null,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text('Share Remedy', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
