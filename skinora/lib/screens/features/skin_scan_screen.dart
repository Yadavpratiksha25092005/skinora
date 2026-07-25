import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animate_do/animate_do.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';

enum _ScanState { initial, preview, analyzing, result, error }
enum _ScanMode { skin, hair }

class SkinScanScreen extends StatefulWidget {
  const SkinScanScreen({super.key});

  @override
  State<SkinScanScreen> createState() => _SkinScanScreenState();
}

class _SkinScanScreenState extends State<SkinScanScreen> {
  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();

  _ScanState _state = _ScanState.initial;
  _ScanMode _mode = _ScanMode.skin;
  File? _imageFile;
  Map<String, dynamic>? _result;
  String? _errorMessage;

  bool get _isSkin => _mode == _ScanMode.skin;

  Color get _accentColor => _isSkin ? AppTheme.primaryColor : const Color(0xFFD4537E);

  List<Color> get _gradientColors =>
      _isSkin ? const [AppTheme.primaryColor, Color(0xFFF7A8C4)] : const [Color(0xFFEC6FA6), Color(0xFFF7A8C4)];

  IconData get _modeIcon => _isSkin ? Icons.face_retouching_natural_rounded : Icons.content_cut_rounded;

  String get _title => _isSkin ? 'AI Skin Scan' : 'AI Hair Scan';

  String get _subject => _isSkin ? 'skin' : 'hair';

  void _switchMode(_ScanMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      _imageFile = null;
      _result = null;
      _errorMessage = null;
      _state = _ScanState.initial;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80, maxWidth: 1024);
    if (picked == null) return;

    setState(() {
      _imageFile = File(picked.path);
      _state = _ScanState.preview;
    });
  }

  Future<void> _analyze() async {
    if (_imageFile == null) return;

    setState(() => _state = _ScanState.analyzing);

    try {
      final bytes = await _imageFile!.readAsBytes();
      final base64Image = base64Encode(bytes);
      final result = _isSkin
          ? await _apiService.analyzeSkin(base64Image)
          : await _apiService.analyzeHair(base64Image);

      if (!mounted) return;
      setState(() {
        _result = result;
        _state = _ScanState.result;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _state = _ScanState.error;
      });
    }
  }

  void _reset() {
    setState(() {
      _imageFile = null;
      _result = null;
      _errorMessage = null;
      _state = _ScanState.initial;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(_title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_state == _ScanState.initial) _buildModeToggle(context),
              if (_state == _ScanState.initial) const SizedBox(height: 20),
              Expanded(child: _buildBody(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeToggle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(child: _modeButton('Skin', _ScanMode.skin)),
          Expanded(child: _modeButton('Hair', _ScanMode.hair)),
        ],
      ),
    );
  }

  Widget _modeButton(String label, _ScanMode mode) {
    final isSelected = _mode == mode;
    return GestureDetector(
      onTap: () => _switchMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (mode == _ScanMode.skin ? AppTheme.primaryColor : const Color(0xFFD4537E))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textSecondaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_state) {
      case _ScanState.initial:
        return _buildInitial(context);
      case _ScanState.preview:
        return _buildPreview(context);
      case _ScanState.analyzing:
        return _buildAnalyzing(context);
      case _ScanState.result:
        return _buildResult(context);
      case _ScanState.error:
        return _buildError(context);
    }
  }

  Widget _buildInitial(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: FadeInUp(
              key: ValueKey(_mode),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: _gradientColors),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_modeIcon, color: Colors.white, size: 56),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Take a clear photo of your ${_isSkin ? 'face' : 'scalp/hair'} in good lighting for the most accurate AI analysis.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13.5, color: Colors.grey.shade600, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        FadeInUp(
          delay: const Duration(milliseconds: 100),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
                  label: const Text('Take Photo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: Icon(Icons.photo_library_outlined, color: _accentColor),
                  label: Text('Choose from Gallery', style: TextStyle(color: _accentColor, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _accentColor),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 16, color: Colors.amber.shade800),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'AI-generated estimate for general wellness, not a medical diagnosis.',
                        style: TextStyle(fontSize: 11, color: Colors.amber.shade900, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreview(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.file(_imageFile!, fit: BoxFit.cover, width: double.infinity),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _reset,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _accentColor),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Retake', style: TextStyle(color: _accentColor, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _analyze,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Analyze ${_isSkin ? 'Skin' : 'Hair'}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalyzing(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: _accentColor),
          const SizedBox(height: 24),
          Text('Analyzing your $_subject...', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 8),
          Text(
            'Our AI is examining your photo. This takes a few seconds.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    final summary = _result!['summary'] ?? '';
    final score = _result!['score'] ?? 0;
    final concerns = (_result!['concerns'] as List?)?.cast<String>() ?? [];
    final tips = (_result!['tips'] as List?)?.cast<String>() ?? [];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInUp(
            child: Center(
              child: CircularPercentIndicator(
                radius: 70,
                lineWidth: 12,
                percent: score / 100,
                animation: true,
                animationDuration: 1200,
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: _accentColor,
                backgroundColor: _accentColor.withOpacity(0.1),
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$score', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
                    Text('/100', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(summary, style: const TextStyle(fontSize: 13.5, height: 1.5)),
            ),
          ),
          const SizedBox(height: 20),
          if (concerns.isNotEmpty) ...[
            FadeInUp(
              delay: const Duration(milliseconds: 150),
              child: const Text('Observations', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            ),
            const SizedBox(height: 10),
            FadeInUp(
              delay: const Duration(milliseconds: 150),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: concerns.map((c) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCE7EF),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: const Color(0xFFF6D3E0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.circle, size: 6, color: Color(0xFFEC6FA6)),
                        const SizedBox(width: 6),
                        Text(c, style: const TextStyle(fontSize: 12, color: Color(0xFFB03D66), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (tips.isNotEmpty) ...[
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: const Text('Tips for You', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            ),
            const SizedBox(height: 10),
            ...tips.asMap().entries.map((entry) {
              return FadeInUp(
                delay: Duration(milliseconds: 200 + (entry.key * 50)),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_rounded, color: _accentColor, size: 18),
                      const SizedBox(width: 10),
                      Expanded(child: Text(entry.value, style: const TextStyle(fontSize: 13, height: 1.4))),
                    ],
                  ),
                ),
              );
            }),
          ],
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: Colors.amber.shade800),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This is an AI-generated estimate for general wellness, not a medical diagnosis. Consult a ${_isSkin ? 'dermatologist' : 'dermatologist/trichologist'} for $_subject concerns.',
                    style: TextStyle(fontSize: 11, color: Colors.amber.shade900, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _reset,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: _accentColor),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('Scan Again', style: TextStyle(color: _accentColor, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Something went wrong. Please try again.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _reset,
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Try Again', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}