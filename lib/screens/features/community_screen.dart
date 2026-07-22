import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_theme.dart';

class _Remedy {
  final String title;
  final String category;
  final String ingredients;
  final String author;
  final IconData icon;
  final Color iconColor;
  int likes;
  int comments;
  bool isLiked;
  bool isSaved;

  _Remedy({
    required this.title,
    required this.category,
    required this.ingredients,
    required this.author,
    required this.icon,
    required this.iconColor,
    required this.likes,
    required this.comments,
  })  : isLiked = false,
        isSaved = false;
}

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

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

  late final List<_Remedy> _remedies = [
    _Remedy(
      title: 'Multani Mitti Glow Pack',
      category: 'Oily Skin',
      ingredients: 'Multani mitti, rose water, a pinch of turmeric mixed into a smooth paste.',
      author: 'Ananya',
      icon: Icons.spa_rounded,
      iconColor: const Color(0xFFB08968),
      likes: 128,
      comments: 24,
    ),
    _Remedy(
      title: 'Honey-Cinnamon Acne Treatment',
      category: 'Acne',
      ingredients: 'Raw honey mixed with a dash of cinnamon powder, applied as a spot treatment.',
      author: 'Riya',
      icon: Icons.local_florist_rounded,
      iconColor: const Color(0xFFE8A33D),
      likes: 214,
      comments: 41,
    ),
    _Remedy(
      title: 'Onion Juice for Hair Fall',
      category: 'Hair Fall',
      ingredients: 'Freshly extracted onion juice massaged into the scalp, rinsed after 30 minutes.',
      author: 'Karan',
      icon: Icons.eco_rounded,
      iconColor: const Color(0xFF8FA31E),
      likes: 96,
      comments: 18,
    ),
    _Remedy(
      title: 'Curd-Turmeric Tan Removal',
      category: 'Tan Removal',
      ingredients: 'Fresh curd blended with turmeric and a few drops of lemon juice.',
      author: 'Simran',
      icon: Icons.wb_sunny_rounded,
      iconColor: const Color(0xFFF2B705),
      likes: 172,
      comments: 33,
    ),
    _Remedy(
      title: 'Coconut Oil-Lemon Dandruff Remedy',
      category: 'Dandruff',
      ingredients: 'Warm coconut oil mixed with lemon juice, massaged and left overnight.',
      author: 'Devika',
      icon: Icons.water_drop_rounded,
      iconColor: const Color(0xFF4FB0A5),
      likes: 150,
      comments: 27,
    ),
    _Remedy(
      title: 'Sugar-Honey Lip Scrub',
      category: 'Lips Care',
      ingredients: 'Brown sugar mixed with honey, gently massaged onto lips for soft, smooth skin.',
      author: 'Meera',
      icon: Icons.favorite_rounded,
      iconColor: const Color(0xFFE07A9E),
      likes: 88,
      comments: 12,
    ),
  ];

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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to add-remedy flow once the sharing form is built.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sharing your remedy — coming soon!')),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Share', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
                onPressed: () => setState(() => remedy.isSaved = !remedy.isSaved),
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
                onTap: () {
                  setState(() {
                    remedy.isLiked = !remedy.isLiked;
                    remedy.likes += remedy.isLiked ? 1 : -1;
                  });
                },
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
