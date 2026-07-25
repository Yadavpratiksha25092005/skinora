import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_theme.dart';
import '../../data/wellness_data.dart';
import '../../models/wellness_topic.dart';
import '../../services/cycle_service.dart';

class WellnessInfoScreen extends StatefulWidget {
  const WellnessInfoScreen({super.key});

  @override
  State<WellnessInfoScreen> createState() => _WellnessInfoScreenState();
}

class _WellnessInfoScreenState extends State<WellnessInfoScreen> {
  final TextEditingController _searchController = TextEditingController();
  final CycleService _cycleService = CycleService();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String? _expandedTitle;
  String? _currentPhase;

  static const List<String> _categories = [
    'All',
    'PCOS',
    'PCOD',
    'Hormonal Health',
    'Diet',
    'Exercise',
    'Self-Care',
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentPhase();
  }

  Future<void> _loadCurrentPhase() async {
    final phase = await _cycleService.getCurrentPhase();
    if (!mounted) return;
    setState(() => _currentPhase = phase);
  }

  List<WellnessTopic> get _filteredTopics {
    return wellnessTopics.where((topic) {
      final matchesCategory = _selectedCategory == 'All' || topic.category == _selectedCategory;
      final matchesQuery =
          _searchQuery.isEmpty || topic.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  List<WellnessTopic> get _recommendedTopics {
    if (_currentPhase == null) return [];
    return wellnessTopics
        .where((topic) => topic.relevantPhases.contains(_currentPhase))
        .take(4)
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topics = _filteredTopics;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('PCOS/PCOD & Wellness'),
      ),
      body: Column(
        children: [
          if (_recommendedTopics.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: FadeInDown(child: _buildRecommendedSection()),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: FadeInDown(child: _buildDisclaimerBanner()),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: FadeInDown(
              delay: const Duration(milliseconds: 50),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search topics',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedCategory = category),
                  selectedColor: AppTheme.primaryColor,
                  backgroundColor: AppTheme.surfaceColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide.none,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: topics.isEmpty
                ? const Center(child: Text('No topics found'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: topics.length,
                    itemBuilder: (context, index) {
                      final topic = topics[index];
                      return FadeInUp(
                        delay: Duration(milliseconds: index * 60),
                        child: _buildTopicCard(topic),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended For You',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Based on your current cycle phase',
          style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondaryColor),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _recommendedTopics.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final topic = _recommendedTopics[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = 'All';
                    _searchController.text = topic.title;
                    _searchQuery = topic.title;
                    _expandedTitle = topic.title;
                  });
                },
                child: Container(
                  width: 160,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryColor, Color(0xFFF7A8C4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(topic.icon, color: Colors.white, size: 22),
                      const SizedBox(height: 8),
                      Text(
                        topic.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDisclaimerBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'This content is for educational purposes only and is not a substitute for professional medical advice.',
              style: TextStyle(color: AppTheme.textPrimaryColor.withOpacity(0.85), fontSize: 12.5, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicCard(WellnessTopic topic) {
    final isExpanded = _expandedTitle == topic.title;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              setState(() => _expandedTitle = isExpanded ? null : topic.title);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(topic.icon, color: AppTheme.primaryColor),
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
                                topic.title,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        _buildCategoryBadge(topic.category),
                        const SizedBox(height: 6),
                        Text(
                          topic.summary,
                          style: const TextStyle(color: AppTheme.textSecondaryColor, fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: AppTheme.textSecondaryColor,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 1, color: Colors.grey.shade300),
                  const SizedBox(height: 14),
                  Text(
                    topic.content.trim(),
                    style: const TextStyle(color: AppTheme.textPrimaryColor, fontSize: 13.5, height: 1.55),
                  ),
                ],
              ),
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        category,
        style: const TextStyle(color: AppTheme.primaryColor, fontSize: 10.5, fontWeight: FontWeight.w600),
      ),
    );
  }
}