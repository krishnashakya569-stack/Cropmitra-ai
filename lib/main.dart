import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

import 'data/services/groq_api_service.dart';
import 'core/localization/app_strings.dart';

void main() {
  runApp(const CropMitraApp());
}

const kGreen = Color(0xFF2D6A4F);
const kGreenDark = Color(0xFF143D2A);
const kLeaf = Color(0xFF71A86A);
const kGreenLight = Color(0xFFDDEFD9);
const kBg = Color(0xFFF7F8F1);
const kSoil = Color(0xFF7A4E2D);
const kSky = Color(0xFF2F8DE4);
const kSun = Color(0xFFF6B73C);
const kInk = Color(0xFF173326);

class CropMitraApp extends StatefulWidget {
  const CropMitraApp({super.key});

  @override
  State<CropMitraApp> createState() => _CropMitraAppState();
}

class _CropMitraAppState extends State<CropMitraApp> {
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    AppStrings.language = _language;
    return MaterialApp(
      title: 'CropMitra AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kGreen),
        scaffoldBackgroundColor: kBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: kBg,
          foregroundColor: kInk,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFDAE6D6)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFDAE6D6)),
          ),
        ),
        useMaterial3: true,
      ),
      home: MainNavigation(
        language: _language,
        onLanguageChanged: (language) => setState(() => _language = language),
      ),
    );
  }
}
// ---------------------------------------------------------------------------
// HOME SCREEN — redesigned layout
// Sections: Crop selector -> Weather/Spray status -> 3-step CTA -> Tools -> Library
// Paste this over your existing HomeScreen + _MainNavigationState in main.dart
// ---------------------------------------------------------------------------

class HomeScreen extends StatefulWidget {
  final VoidCallback onOpenDiseaseDetection;
  final VoidCallback onOpenWeather;
  final VoidCallback onOpenTools;
  final VoidCallback onOpenChat;
  final String language;
  final VoidCallback onLanguagePressed;

  const HomeScreen({
    super.key,
    required this.onOpenDiseaseDetection,
    required this.onOpenWeather,
    required this.onOpenTools,
    required this.onOpenChat,
    required this.language,
    required this.onLanguagePressed,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _crops = ['Wheat', 'Cotton'];
  final int _selectedCrop = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: kGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.eco_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CropMitra AI',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: kInk,
                      ),
                    ),
                    Text(
                      AppStrings.t('smart companion'),
                      style: TextStyle(color: Color(0xFF5D7465)),
                    ),
                  ],
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: widget.onLanguagePressed,
                icon: const Icon(Icons.translate_rounded, size: 18),
                label: Text(widget.language == 'English' ? 'EN' : widget.language),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _FarmHero(selectedCrop: _crops[_selectedCrop]),
          const SizedBox(height: 18),
          _HomeActionCard(
            icon: Icons.document_scanner_outlined,
            title: AppStrings.t('detect disease'),
            description: AppStrings.t('detect disease sub'),
            color: kGreen,
            onTap: widget.onOpenDiseaseDetection,
          ),
          const SizedBox(height: 12),
          _HomeActionCard(
            icon: Icons.forum_outlined,
            title: AppStrings.t('farming advice'),
            description: AppStrings.t('farming advice sub'),
            color: kSoil,
            onTap: widget.onOpenChat,
          ),
          const SizedBox(height: 12),
          _CommunityPulseCard(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CommunityHubScreen()),
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: AppStrings.t('quick access')),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickCard(
                  icon: Icons.wb_sunny_outlined,
                  label: AppStrings.t('weather'),
                  accent: kSky,
                  onTap: widget.onOpenWeather,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickCard(
                  icon: Icons.handyman_outlined,
                  label: AppStrings.t('tools'),
                  accent: kGreen,
                  onTap: widget.onOpenTools,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickCard(
                  icon: Icons.chat_bubble_outline,
                  label: AppStrings.t('ai assistant'),
                  accent: kSoil,
                  onTap: widget.onOpenChat,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _FarmingTipCard(),
        ],
      ),
    );
  }
}

class _FarmHero extends StatelessWidget {
  final String selectedCrop;
  const _FarmHero({required this.selectedCrop});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [kGreenDark, kGreen],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(26),
    ),
    child: Stack(
      children: [
        const Positioned(right: 8, bottom: 2, child: _CartoonFarmer()),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.t('namaste farmer'),
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 220,
              child: Text(
                AppStrings.t('hero message'),
                style: TextStyle(
                  color: Color(0xFFE7F5E4),
                  fontSize: 15,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .16),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${AppStrings.t('currently growing')}: $selectedCrop',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _CartoonFarmer extends StatelessWidget {
  const _CartoonFarmer();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 126,
    height: 150,
    child: Stack(
      alignment: Alignment.bottomCenter,
      children: [
        const Positioned(
          top: 7,
          child: Text('🌾', style: TextStyle(fontSize: 30)),
        ),
        Positioned(
          top: 26,
          child: Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: Color(0xFFFFC994),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('👨🏽‍🌾', style: TextStyle(fontSize: 46)),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            width: 86,
            height: 66,
            decoration: const BoxDecoration(
              color: Color(0xFF4D8E56),
              borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
            ),
            child: const Icon(
              Icons.agriculture_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
        ),
        const Positioned(
          right: 0,
          bottom: 23,
          child: Text('✨', style: TextStyle(fontSize: 25)),
        ),
      ],
    ),
  );
}

class _HomeActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;
  const _HomeActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFDFEADF)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 29),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: kInk,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Color(0xFF597064),
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 18, color: color),
          ],
        ),
      ),
    ),
  );
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;
  final VoidCallback onTap;
  const _QuickCard({
    required this.icon,
    required this.label,
    required this.accent,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: accent, size: 29),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: kInk,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _FarmingTipCard extends StatelessWidget {
  const _FarmingTipCard();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF4D6),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          backgroundColor: Color(0xFFFFD66F),
          child: Icon(Icons.lightbulb_outline, color: Color(0xFF805900)),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.t('farming tip'),
                style: const TextStyle(fontWeight: FontWeight.w800, color: kInk),
              ),
              SizedBox(height: 4),
              Text(
                AppStrings.t('tip body'),
                style: const TextStyle(height: 1.35, color: Color(0xFF5E542F)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Crop selector: horizontal avatars + add button
// ---------------------------------------------------------------------------
// ignore: unused_element
class _CropSelectorRow extends StatelessWidget {
  final List<String> crops;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;

  const _CropSelectorRow({
    required this.crops,
    required this.selectedIndex,
    required this.onSelect,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (int i = 0; i < crops.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: GestureDetector(
                onTap: () => onSelect(i),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: i == selectedIndex
                          ? kGreen
                          : kGreenLight,
                      child: Icon(
                        Icons.eco,
                        color: i == selectedIndex ? Colors.white : kGreen,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(crops[i], style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          GestureDetector(
            onTap: onAdd,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.add, color: kGreen),
                ),
                const SizedBox(height: 6),
                const Text('Add', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status row: date/temp chip + spraying-condition chip (tap -> weather tab)
// ---------------------------------------------------------------------------
// ignore: unused_element
class _StatusRow extends StatelessWidget {
  final VoidCallback onWeatherTap;
  const _StatusRow({required this.onWeatherTap});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return GestureDetector(
      onTap: onWeatherTap,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kGreenLight, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.wb_cloudy_outlined, color: kGreen),
                  const SizedBox(width: 8),
                  Text(
                    '${today.day}/${today.month}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kGreenLight, width: 1.5),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tap for spraying conditions',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3-step flow card: Take picture -> See diagnosis -> Get treatment
// ---------------------------------------------------------------------------
// ignore: unused_element
class _DiagnosisFlowCard extends StatelessWidget {
  final VoidCallback onTakePicture;
  const _DiagnosisFlowCard({required this.onTakePicture});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kGreenLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              _FlowStep(
                icon: Icons.camera_alt_outlined,
                label: 'Take a\npicture',
              ),
              Icon(Icons.chevron_right, color: Colors.black38),
              _FlowStep(icon: Icons.eco_outlined, label: 'See\ndiagnosis'),
              Icon(Icons.chevron_right, color: Colors.black38),
              _FlowStep(
                icon: Icons.medication_outlined,
                label: 'Get\ntreatment',
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onTakePicture,
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Take a Picture',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowStep extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FlowStep({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white,
          child: Icon(icon, color: kGreen),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tools row: calculators
// ---------------------------------------------------------------------------

// ignore: unused_element
class _ToolsRow extends StatelessWidget {
  final VoidCallback onToolsTap;
  const _ToolsRow({required this.onToolsTap});
  @override
  Widget build(BuildContext context) {
    final tools = [
      ('Fertilizer\ncalculator', Icons.science_outlined),
      ('Pesticide\ncalculator', Icons.bug_report_outlined),
      ('Farming\ncalculator', Icons.calculate_outlined),
    ];
    return Row(
      children: [
        for (int i = 0; i < tools.length; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () {
                  onToolsTap();
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kGreenLight, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(tools[i].$2, color: kGreen),
                      const SizedBox(height: 10),
                      Text(
                        tools[i].$1,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Library grid: Crops / Cultivation tips / Pests & diseases / Disease alerts
// ---------------------------------------------------------------------------
// ignore: unused_element
class _LibraryGrid extends StatelessWidget {
  const _LibraryGrid();

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Crops', Icons.grass_outlined, null),
      ('Cultivation\nTips', Icons.spa_outlined, null),
      ('Pests &\ndiseases', Icons.pest_control_outlined, null),
      ('Disease\nAlerts', Icons.notifications_active_outlined, 4),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.7,
      children: [
        for (final item in items)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kGreenLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(item.$2, color: kGreen),
                    const Spacer(),
                    Text(
                      item.$1,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                if (item.$3 != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.redAccent,
                      child: Text(
                        '${item.$3}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2C1A0E),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// MainNavigation update — pass callbacks so Home can switch tabs
// ---------------------------------------------------------------------------
class MainNavigation extends StatefulWidget {
  const MainNavigation({
    super.key,
    required this.language,
    required this.onLanguageChanged,
  });

  final String language;
  final ValueChanged<String> onLanguageChanged;

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  void _goTo(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        onOpenDiseaseDetection: () => _goTo(1),
        onOpenWeather: () => _goTo(3),
        onOpenTools: () => _goTo(4),
        onOpenChat: () => _goTo(2),
        language: widget.language,
        onLanguagePressed: () => _showLanguagePicker(context),
      ),
      DiseaseDetectionScreen(language: widget.language),
      ChatAssistantScreen(language: widget.language),
      const WeatherScreen(),
      const ToolsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _goTo,
        height: 74,
        backgroundColor: Colors.white,
        indicatorColor: kGreenLight,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? kGreenDark
                : const Color(0xFF66776C),
          ),
        ),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: _navLabel('Home'),
          ),
          NavigationDestination(
            icon: Icon(Icons.eco_outlined),
            selectedIcon: Icon(Icons.eco_rounded),
            label: _navLabel('Disease'),
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: _navLabel('Chat'),
          ),
          NavigationDestination(
            icon: Icon(Icons.cloud_outlined),
            selectedIcon: Icon(Icons.cloud_rounded),
            label: _navLabel('Weather'),
          ),
          NavigationDestination(
            icon: Icon(Icons.handyman_outlined),
            selectedIcon: Icon(Icons.handyman_rounded),
            label: _navLabel('Tools'),
          ),
        ],
      ),
    );
  }

  String _navLabel(String english) {
    const hindi = {
      'Home': 'होम',
      'Disease': 'रोग',
      'Chat': 'चैट',
      'Weather': 'मौसम',
      'Tools': 'टूल्स',
    };
    return widget.language == 'Hindi' ? hindi[english]! : english;
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => LanguagePicker(
        selected: widget.language,
        onSelected: (language) {
          Navigator.pop(context);
          widget.onLanguageChanged(language);
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// DISEASE DETECTION
// ---------------------------------------------------------------------------
class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({super.key, required this.language});
  final String language;
  @override
  State<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
  Uint8List? _imageBytes;
  String _result = '';
  bool _loading = false;
  final FlutterTts _tts = FlutterTts();
  final GroqApiService _groq = GroqApiService();
  bool _isHindi = false;

  Future<void> _pickAndAnalyzeImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _loading = true;
      _result = '';
    });

    try {
      final base64Image = base64Encode(bytes);
      final text = await _groq.analyzeCropImage(
        base64Image: base64Image,
        language: widget.language,
      );
      setState(() {
        _result = text
            .replaceAll(RegExp(r'<think>[\s\S]*?</think>', caseSensitive: false), '')
            .trim();
        _loading = false;
      });
      await _tts.setLanguage(_isHindi ? 'hi-IN' : 'en-US');
      await _tts.speak(_result);
    } catch (e) {
      setState(() {
        _result = e is GroqApiException
            ? e.message
            : 'No internet connection or server error. Please try again.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text(
          'Detect Crop Disease',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() => _isHindi = !_isHindi),
            child: Text(
              _isHindi ? 'हिं' : 'EN',
              style: const TextStyle(
                color: kGreen,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 260,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kGreen, width: 2),
              ),
              clipBehavior: Clip.antiAlias,
              child: _imageBytes != null
                  ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.document_scanner_outlined,
                            size: 44,
                            color: kGreen,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Take a clear photo\nof the affected leaf',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: kInk,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _pickAndAnalyzeImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                icon: const Icon(Icons.camera_alt_outlined, size: 26),
                label: Text(
                  _imageBytes == null ? 'Scan Crop' : 'Scan Another Crop',
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_loading)
              Column(
                children: const [
                  CircularProgressIndicator(color: kGreen),
                  SizedBox(height: 12),
                  Text(
                    'Checking your crop...',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            if (_result.isNotEmpty && !_loading)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2FAF0),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kGreenLight, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.eco, color: kGreen),
                        SizedBox(width: 8),
                        Text(
                          'Disease result',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: kGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _result,
                      style: const TextStyle(fontSize: 16, height: 1.4),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CHAT ASSISTANT
// ---------------------------------------------------------------------------
class ChatAssistantScreen extends StatefulWidget {
  const ChatAssistantScreen({super.key, required this.language});
  final String language;
  @override
  State<ChatAssistantScreen> createState() => _ChatAssistantScreenState();
}

class _ChatAssistantScreenState extends State<ChatAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isListening = false;
  bool _isHindi = false;
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  final GroqApiService _groq = GroqApiService();
  bool _loading = false;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        localeId: _isHindi ? 'hi_IN' : 'en_US',
        onResult: (result) {
          setState(() {
            _controller.text = result.recognizedWords;
          });
        },
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _speak(String text) async {
    await _tts.setLanguage(_isHindi ? 'hi-IN' : 'en-US');
    await _tts.speak(text);
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _loading = true;
      _controller.clear();
    });
    try {
      final reply = await _groq.getChatReply(
        question: text,
        language: widget.language,
      );
      setState(() {
        _messages.add({'role': 'ai', 'text': reply});
        _loading = false;
      });
      _speak(reply);
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'ai',
          'text': e is GroqApiException
              ? e.message
              : 'No internet connection. Please try again.',
        });
        _loading = false;
      });
    }
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kGreen,
        foregroundColor: Colors.white,
        title: const Text(
          'AI Farming Assistant',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() => _isHindi = !_isHindi),
            child: Text(
              _isHindi ? 'हिं' : 'EN',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(
                            radius: 38,
                            backgroundColor: kGreenLight,
                            child: Icon(
                              Icons.smart_toy_outlined,
                              size: 42,
                              color: kGreen,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Ask anything about your crops',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: kInk,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Simple answers on pests, fertilizer and sowing.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFF64766B)),
                          ),
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              _SuggestionChip(
                                label: 'How to grow wheat?',
                                onTap: () {
                                  _controller.text = 'How to grow wheat?';
                                  _sendMessage();
                                },
                              ),
                              _SuggestionChip(
                                label: 'Which fertilizer is best?',
                                onTap: () {
                                  _controller.text =
                                      'Which fertilizer is best?';
                                  _sendMessage();
                                },
                              ),
                              _SuggestionChip(
                                label: 'How can I control pests?',
                                onTap: () {
                                  _controller.text = 'How can I control pests?';
                                  _sendMessage();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(14),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isUser = msg['role'] == 'user';
                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.78,
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isUser ? kGreen : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isUser ? 16 : 4),
                              bottomRight: Radius.circular(isUser ? 4 : 16),
                            ),
                            border: isUser
                                ? null
                                : Border.all(color: kGreenLight, width: 1.5),
                          ),
                          child: Text(
                            msg['text'] ?? '',
                            style: TextStyle(
                              color: isUser ? Colors.white : Colors.black87,
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: kGreen,
                ),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Ask about your crops...',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: kGreen,
                    ),
                    onPressed: _isListening ? _stopListening : _startListening,
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _loading ? null : _sendMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreen,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(14),
                    ),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// WEATHER (placeholder — replace with your real screen if you have one)
// ---------------------------------------------------------------------------
class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SuggestionChip({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => ActionChip(
    onPressed: onTap,
    avatar: const Icon(Icons.eco_outlined, size: 18, color: kGreen),
    label: Text(label),
    labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: kInk),
    backgroundColor: Colors.white,
    side: const BorderSide(color: Color(0xFFD7E7D3)),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
  );
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});
  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();
  bool _loading = false;
  String _error = '';
  Map<String, dynamic>? _weather;
  String _cityName = '';

  Future<void> _searchWeather() async {
    final city = _cityController.text.trim();
    if (city.isEmpty) return;

    setState(() {
      _loading = true;
      _error = '';
      _weather = null;
    });

    try {
      // Step A: convert city name to lat/lon
      final geoUrl = Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(city)}&count=1',
      );
      final geoResponse = await http.get(geoUrl);
      final geoData = jsonDecode(geoResponse.body);

      if (geoData['results'] == null || geoData['results'].isEmpty) {
        setState(() {
          _error = 'City not found. Try another name.';
          _loading = false;
        });
        return;
      }

      final lat = geoData['results'][0]['latitude'];
      final lon = geoData['results'][0]['longitude'];
      _cityName = geoData['results'][0]['name'];

      // Step B: get weather for that lat/lon
      final weatherUrl = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m',
      );
      final weatherResponse = await http.get(weatherUrl);

      if (weatherResponse.statusCode == 200) {
        final data = jsonDecode(weatherResponse.body);
        setState(() {
          _weather = data['current'];
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Could not fetch weather. Try again.';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Something went wrong: $e';
        _loading = false;
      });
    }
  }

  String _weatherDescription(int code) {
    if (code == 0) return 'Clear sky ☀️';
    if (code <= 3) return 'Partly cloudy ⛅';
    if (code <= 48) return 'Foggy 🌫️';
    if (code <= 57) return 'Drizzle 🌦️';
    if (code <= 67) return 'Rain 🌧️';
    if (code <= 77) return 'Snow ❄️';
    if (code <= 82) return 'Rain showers 🌦️';
    if (code <= 99) return 'Thunderstorm ⛈️';
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kGreen,
        foregroundColor: Colors.white,
        title: const Text(
          'Weather & Forecast',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _searchWeather(),
                    decoration: InputDecoration(
                      hintText: 'Enter city name...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _loading ? null : _searchWeather,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreen,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Icon(Icons.search, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_loading) const CircularProgressIndicator(color: kGreen),
            if (_error.isNotEmpty)
              Text(
                _error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            if (_weather != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: kSky,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      _cityName,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_weather!['temperature_2m']}°C',
                      style: const TextStyle(
                        fontSize: 48,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _weatherDescription(_weather!['weather_code']),
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.water_drop, color: Colors.white),
                            Text(
                              '${_weather!['relative_humidity_2m']}%',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const Text(
                              'Humidity',
                              style: TextStyle(
                                color: Color(0xFFD8F3DC),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Icon(Icons.air, color: Colors.white),
                            Text(
                              '${_weather!['wind_speed_10m']} km/h',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const Text(
                              'Wind',
                              style: TextStyle(
                                color: Color(0xFFD8F3DC),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            if (_weather != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4D6),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline, color: Color(0xFF9A6900)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Farming advice',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: kInk,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Check soil moisture before irrigation. Use today’s weather to plan spraying safely.',
                            style: TextStyle(
                              height: 1.35,
                              color: Color(0xFF665426),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// NEARBY SHOPS (placeholder — replace with your real screen if you have one)
// ---------------------------------------------------------------------------
class NearbyShopScreen extends StatelessWidget {
  const NearbyShopScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kGreen,
        foregroundColor: Colors.white,
        title: const Text(
          'Nearby Shops',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: const Center(child: Text('Nearby shops screen coming soon')),
    );
  }
}

// ---------------------------------------------------------------------------
// TOOLS
// ---------------------------------------------------------------------------
class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text(
          'Farming Tools',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [kGreenDark, kGreen]),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 27,
                  backgroundColor: Color(0x33FFFFFF),
                  child: Icon(
                    Icons.agriculture_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Smart tools for smarter farming',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Make confident decisions for every crop.',
                        style: TextStyle(color: Color(0xFFE1F4DD)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _ToolsScreenCard(
            title: 'Fertilizer Calculator',
            description: 'Calculate fertilizer requirements',
            icon: Icons.science_outlined,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const FertilizerCalculatorScreen(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _ToolsScreenCard(
            title: 'Pesticide Calculator',
            description: 'Calculate the right pesticide quantity',
            icon: Icons.bug_report_outlined,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PesticideCalculatorScreen(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _ToolsScreenCard(
            title: 'Farming Calculator',
            description: 'Calculate seeds, yield, cost and more',
            icon: Icons.calculate_outlined,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const FarmingCalculatorScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolsScreenCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _ToolsScreenCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kGreenLight, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(icon, color: kGreen, size: 30),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(description, style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: kGreen),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FERTILIZER CALCULATOR
// ---------------------------------------------------------------------------
class FertilizerCalculatorScreen extends StatefulWidget {
  const FertilizerCalculatorScreen({super.key});

  @override
  State<FertilizerCalculatorScreen> createState() =>
      _FertilizerCalculatorScreenState();
}

class _FertilizerCalculatorScreenState
    extends State<FertilizerCalculatorScreen> {
  final TextEditingController _areaController = TextEditingController();
  String _selectedCrop = 'Wheat';

  // kg needed per acre: [Urea, DAP, MOP]
  final Map<String, List<double>> _perAcre = {
    'Wheat': [50, 25, 15],
    'Cotton': [60, 30, 20],
    'Rice': [55, 20, 15],
    'Sugarcane': [80, 40, 25],
  };

  List<double>? _result;

  void _calculate() {
    final area = double.tryParse(_areaController.text.trim());
    if (area == null || area <= 0) {
      setState(() => _result = null);
      return;
    }
    final base = _perAcre[_selectedCrop]!;
    setState(() {
      _result = [base[0] * area, base[1] * area, base[2] * area];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kGreen,
        foregroundColor: Colors.white,
        title: const Text(
          'Fertilizer Calculator',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select crop',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kGreenLight, width: 1.5),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCrop,
                  isExpanded: true,
                  items: _perAcre.keys
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCrop = v!),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Area (in acres)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _areaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g. 2',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: kGreenLight),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _calculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Calculate',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_result != null)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kGreenLight, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recommended fertilizer',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: kGreen,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ResultRow(label: 'Urea', value: _result![0]),
                    _ResultRow(label: 'DAP', value: _result![1]),
                    _ResultRow(label: 'MOP', value: _result![2]),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PesticideCalculatorScreen extends StatefulWidget {
  const PesticideCalculatorScreen({super.key});

  @override
  State<PesticideCalculatorScreen> createState() =>
      _PesticideCalculatorScreenState();
}

class _PesticideCalculatorScreenState extends State<PesticideCalculatorScreen> {
  final TextEditingController _areaController = TextEditingController();
  String _selectedCrop = 'Wheat';
  String _selectedPest = 'Aphids / Sucking pests';
  final Map<String, double> _dosePerAcre = {
    'Aphids / Sucking pests': 250,
    'Caterpillars / Borers': 300,
    'Fungal disease': 200,
    'Weeds': 400,
  };
  double? _result;

  void _calculate() {
    final area = double.tryParse(_areaController.text.trim());
    setState(
      () => _result = area != null && area > 0
          ? area * _dosePerAcre[_selectedPest]!
          : null,
    );
  }

  @override
  void dispose() {
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _CalculatorPage(
      title: 'Pesticide Calculator',
      icon: Icons.pest_control_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DropdownField(
            label: 'Select crop',
            value: _selectedCrop,
            items: const ['Wheat', 'Cotton', 'Rice', 'Sugarcane'],
            onChanged: (value) => setState(() => _selectedCrop = value),
          ),
          const SizedBox(height: 18),
          _DropdownField(
            label: 'Pest / issue type',
            value: _selectedPest,
            items: _dosePerAcre.keys.toList(),
            onChanged: (value) => setState(() => _selectedPest = value),
          ),
          const SizedBox(height: 18),
          _CalculatorField(
            label: 'Area (in acres)',
            controller: _areaController,
            hint: 'e.g. 2',
          ),
          const SizedBox(height: 22),
          _CalculateButton(onPressed: _calculate),
          if (_result != null)
            _ResultPanel(
              title: 'Recommended pesticide dose',
              value: '${_result!.toStringAsFixed(0)} ml',
              detail: 'For $_selectedCrop • $_selectedPest',
            ),
        ],
      ),
    );
  }
}

class FarmingCalculatorScreen extends StatefulWidget {
  const FarmingCalculatorScreen({super.key});

  @override
  State<FarmingCalculatorScreen> createState() =>
      _FarmingCalculatorScreenState();
}

class _FarmingCalculatorScreenState extends State<FarmingCalculatorScreen> {
  final TextEditingController _areaController = TextEditingController();
  String _selectedCrop = 'Wheat';
  final Map<String, double> _seedRate = {
    'Wheat': 40,
    'Cotton': 1.5,
    'Rice': 25,
    'Sugarcane': 3500,
  };
  double? _result;

  void _calculate() {
    final area = double.tryParse(_areaController.text.trim());
    setState(
      () => _result = area != null && area > 0
          ? area * _seedRate[_selectedCrop]!
          : null,
    );
  }

  @override
  void dispose() {
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _CalculatorPage(
      title: 'Farming Calculator',
      icon: Icons.agriculture_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DropdownField(
            label: 'Select crop',
            value: _selectedCrop,
            items: _seedRate.keys.toList(),
            onChanged: (value) => setState(() => _selectedCrop = value),
          ),
          const SizedBox(height: 18),
          _CalculatorField(
            label: 'Area (in acres)',
            controller: _areaController,
            hint: 'e.g. 2',
          ),
          const SizedBox(height: 22),
          _CalculateButton(onPressed: _calculate),
          if (_result != null)
            _ResultPanel(
              title: 'Seed requirement',
              value:
                  '${_result!.toStringAsFixed(_selectedCrop == 'Sugarcane' ? 0 : 1)} ${_selectedCrop == 'Sugarcane' ? 'setts' : 'kg'}',
              detail: 'Based on the standard $_selectedCrop rate per acre',
            ),
        ],
      ),
    );
  }
}

class _CalculatorPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _CalculatorPage({
    required this.title,
    required this.icon,
    required this.child,
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: kBg,
    appBar: AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [kGreenDark, kGreen]),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: .18),
                  child: Icon(icon, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Easy crop planning, one step at a time.',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          child,
        ],
      ),
    ),
  );
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w800, color: kInk),
      ),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD7E7D3)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            items: items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (next) {
              if (next != null) onChanged(next);
            },
          ),
        ),
      ),
    ],
  );
}

class _CalculateButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _CalculateButton({required this.onPressed});
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 56,
    child: ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: kGreen,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      icon: const Icon(Icons.calculate_rounded),
      label: const Text(
        'Calculate',
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
      ),
    ),
  );
}

class _ResultPanel extends StatelessWidget {
  final String title;
  final String value;
  final String detail;
  const _ResultPanel({
    required this.title,
    required this.value,
    required this.detail,
  });
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 22),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFFE8F6E5),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: kLeaf.withValues(alpha: .45)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, color: kInk),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: kGreen,
          ),
        ),
        const SizedBox(height: 4),
        Text(detail, style: const TextStyle(color: Color(0xFF567061))),
      ],
    ),
  );
}

// ignore: unused_element
class _CalculatorScaffold extends StatelessWidget {
  final String title;
  final List<_CalculatorField> fields;
  final VoidCallback onCalculate;
  final String? result;

  const _CalculatorScaffold({
    required this.title,
    required this.fields,
    required this.onCalculate,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kGreen,
        foregroundColor: Colors.white,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...fields.expand((field) => [field, const SizedBox(height: 20)]),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: onCalculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Calculate',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            if (result != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kGreenLight, width: 2),
                ),
                child: Text(
                  result!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: kGreen,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CalculatorField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;

  const _CalculatorField({
    required this.label,
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kGreenLight),
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final double value;
  const _ResultRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          Text(
            '${value.toStringAsFixed(1)} kg',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SIH COMMUNITY MODULES — local prototype data until a backend is connected.
// ---------------------------------------------------------------------------

class FarmerReport {
  const FarmerReport({
    required this.crop,
    required this.issue,
    required this.location,
    required this.symptoms,
    required this.status,
    required this.date,
  });

  final String crop;
  final String issue;
  final String location;
  final String symptoms;
  final String status;
  final DateTime date;
}

class FarmerReportStore extends ChangeNotifier {
  final List<FarmerReport> _reports = [
    FarmerReport(
      crop: 'Wheat',
      issue: 'Leaf rust',
      location: 'Haridwar',
      symptoms: 'Orange-brown spots on leaves',
      status: 'High risk',
      date: DateTime.now(),
    ),
    FarmerReport(
      crop: 'Tomato',
      issue: 'Early blight',
      location: 'Roorkee',
      symptoms: 'Dark rings on older leaves',
      status: 'Medium risk',
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  List<FarmerReport> get reports => List.unmodifiable(_reports);
  void add(FarmerReport report) {
    _reports.insert(0, report);
    notifyListeners();
  }
}

final reportStore = FarmerReportStore();

class LanguagePicker extends StatelessWidget {
  const LanguagePicker({super.key, required this.selected, required this.onSelected});
  final String selected;
  final ValueChanged<String> onSelected;

  static const languages = [
    ('English', 'EN'), ('Hindi', 'हिं'), ('Marathi', 'म'), ('Punjabi', 'ਪੰ'),
    ('Bengali', 'বা'), ('Gujarati', 'ગુ'), ('Tamil', 'த'), ('Telugu', 'తె'),
    ('Kannada', 'ಕ'), ('Malayalam', 'മ'),
  ];

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.t('choose language'), style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: kInk)),
        const SizedBox(height: 6),
        Text(AppStrings.t('language hint'), style: const TextStyle(color: Color(0xFF61766A))),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: languages.map((item) => ChoiceChip(
            label: Text('${item.$2}  ${item.$1}'),
            selected: selected == item.$1,
            selectedColor: kGreenLight,
            onSelected: (_) => onSelected(item.$1),
          )).toList(),
        ),
      ],
    ),
  );
}

class _CommunityPulseCard extends StatelessWidget {
  const _CommunityPulseCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Ink(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF7A2453), Color(0xFFE06F4F)]),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            const CircleAvatar(radius: 27, backgroundColor: Color(0x33FFFFFF), child: Icon(Icons.radar_rounded, color: Colors.white, size: 29)),
            const SizedBox(width: 13),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(AppStrings.t('community pulse'), style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text(AppStrings.t('community pulse sub'), style: const TextStyle(color: Color(0xFFFFE9DE), height: 1.25)),
            ])),
            const Icon(Icons.arrow_forward_rounded, color: Colors.white),
          ],
        ),
      ),
    ),
  );
}

class CommunityHubScreen extends StatelessWidget {
  const CommunityHubScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: kBg,
    appBar: AppBar(title: const Text('Crop Community Pulse', style: TextStyle(fontWeight: FontWeight.w800))),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF7A2453), Color(0xFFE06F4F)]), borderRadius: BorderRadius.circular(26)),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Together, we protect more crops. 🌾', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800)),
            SizedBox(height: 7),
            Text('Your field report can help identify local disease risk early.', style: TextStyle(color: Color(0xFFFFE9DE), height: 1.35)),
          ]),
        ),
        const SizedBox(height: 18),
        _CommunityAction(title: AppStrings.t('report disease'), subtitle: 'Share crop, symptoms, photo and location', icon: Icons.add_a_photo_outlined, color: kGreen, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DiseaseReportScreen()))),
        const SizedBox(height: 12),
        _CommunityAction(title: AppStrings.t('hotspot map'), subtitle: AppStrings.t('map subtitle'), icon: Icons.map_outlined, color: const Color(0xFFE06F4F), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HotspotMapScreen()))),
        const SizedBox(height: 12),
        _CommunityAction(title: AppStrings.t('officer dashboard'), subtitle: AppStrings.t('dashboard subtitle'), icon: Icons.dashboard_outlined, color: const Color(0xFF5865B5), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OfficerDashboardScreen()))),
        const SizedBox(height: 12),
        _CommunityAction(title: AppStrings.t('treatment follow up'), subtitle: AppStrings.t('follow subtitle'), icon: Icons.timeline_rounded, color: kSoil, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FollowUpScreen()))),
      ],
    ),
  );
}

class _CommunityAction extends StatelessWidget {
  const _CommunityAction({required this.title, required this.subtitle, required this.icon, required this.color, required this.onTap});
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => _HomeActionCard(icon: icon, title: title, description: subtitle, color: color, onTap: onTap);
}

class DiseaseReportScreen extends StatefulWidget {
  const DiseaseReportScreen({super.key});
  @override
  State<DiseaseReportScreen> createState() => _DiseaseReportScreenState();
}

class _DiseaseReportScreenState extends State<DiseaseReportScreen> {
  final _location = TextEditingController();
  final _symptoms = TextEditingController();
  String _crop = 'Wheat';
  String _issue = 'Leaf rust';
  Uint8List? _photo;

  @override
  void dispose() { _location.dispose(); _symptoms.dispose(); super.dispose(); }

  Future<void> _addPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) setState(() async => _photo = await picked.readAsBytes());
  }

  void _submit() {
    if (_location.text.trim().isEmpty || _symptoms.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add location and symptoms.')));
      return;
    }
    reportStore.add(FarmerReport(crop: _crop, issue: _issue, location: _location.text.trim(), symptoms: _symptoms.text.trim(), status: 'Pending review', date: DateTime.now()));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted. Thank you for protecting your community!')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: kBg,
    appBar: AppBar(title: const Text('Report Crop Problem', style: TextStyle(fontWeight: FontWeight.w800))),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Help build an early-warning network', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kInk)),
      const SizedBox(height: 6),
      const Text('Reports are stored locally in this prototype. A backend will securely send them to officers.'),
      const SizedBox(height: 18),
      _ReportDropdown(label: 'Crop', value: _crop, items: const ['Wheat', 'Rice', 'Cotton', 'Tomato', 'Potato'], onChanged: (v) => setState(() => _crop = v)),
      const SizedBox(height: 14),
      _ReportDropdown(label: 'Disease / pest', value: _issue, items: const ['Leaf rust', 'Aphids', 'Early blight', 'Fall armyworm', 'Unknown'], onChanged: (v) => setState(() => _issue = v)),
      const SizedBox(height: 14),
      TextField(controller: _location, decoration: const InputDecoration(labelText: 'Village / district', prefixIcon: Icon(Icons.location_on_outlined))),
      const SizedBox(height: 14),
      TextField(controller: _symptoms, maxLines: 3, decoration: const InputDecoration(labelText: 'Symptoms you see', alignLabelWithHint: true)),
      const SizedBox(height: 14),
      OutlinedButton.icon(onPressed: _addPhoto, icon: const Icon(Icons.photo_camera_back_outlined), label: Text(_photo == null ? 'Add crop photo (optional)' : 'Photo added ✓')),
      const SizedBox(height: 22),
      SizedBox(height: 54, child: ElevatedButton.icon(onPressed: _submit, icon: const Icon(Icons.send_rounded), label: const Text('Submit community report'))),
    ]),
  );
}

class _ReportDropdown extends StatelessWidget {
  const _ReportDropdown({required this.label, required this.value, required this.items, required this.onChanged});
  final String label, value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(value: value, decoration: InputDecoration(labelText: label), items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(), onChanged: (value) { if (value != null) onChanged(value); });
}

class HotspotMapScreen extends StatelessWidget {
  const HotspotMapScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: kBg,
    appBar: AppBar(title: const Text('Disease Hotspot Map', style: TextStyle(fontWeight: FontWeight.w800))),
    body: AnimatedBuilder(
      animation: reportStore,
      builder: (_, _) => ListView(padding: const EdgeInsets.all(16), children: [
        Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: const Color(0xFFE7F3FF), borderRadius: BorderRadius.circular(22)), child: const Row(children: [Icon(Icons.info_outline, color: kSky), SizedBox(width: 10), Expanded(child: Text('Prototype map: risk markers use local demo and session reports. Connect GPS + backend for live hotspots.'))])),
        const SizedBox(height: 18),
        Container(height: 270, decoration: BoxDecoration(color: const Color(0xFFDDF1D9), borderRadius: BorderRadius.circular(26)), child: Stack(children: const [
          Positioned(left: 30, top: 36, child: _RiskPin(label: 'Haridwar\nHigh', color: Colors.red)),
          Positioned(right: 35, top: 84, child: _RiskPin(label: 'Roorkee\nMedium', color: Colors.orange)),
          Positioned(left: 140, bottom: 30, child: _RiskPin(label: 'Dehradun\nLow', color: kGreen)),
          Positioned(left: 18, bottom: 16, child: Text('Community disease signal', style: TextStyle(fontWeight: FontWeight.w800, color: kGreenDark))),
        ])),
        const SizedBox(height: 18),
        const Text('Recent field signals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        ...reportStore.reports.map(
          (report) => Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: report.status == 'High risk'
                    ? Colors.red.shade100
                    : Colors.orange.shade100,
                child: Icon(
                  Icons.bug_report_outlined,
                  color: report.status == 'High risk' ? Colors.red : Colors.orange,
                ),
              ),
              title: Text('${report.issue} • ${report.crop}'),
              subtitle: Text(report.location),
              trailing: Text(
                report.status,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ]),
    ),
  );
}

class _RiskPin extends StatelessWidget {
  const _RiskPin({required this.label, required this.color});
  final String label; final Color color;
  @override
  Widget build(BuildContext context) => Column(children: [Icon(Icons.location_on_rounded, color: color, size: 42), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800))]);
}

class OfficerDashboardScreen extends StatelessWidget {
  const OfficerDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: kBg,
    appBar: AppBar(title: const Text('Officer Dashboard • Demo', style: TextStyle(fontWeight: FontWeight.w800))),
    body: AnimatedBuilder(animation: reportStore, builder: (_, _) => ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Field intelligence at a glance', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kInk)),
      const SizedBox(height: 6),
      const Text('Demo dashboard — connect authenticated backend for officer access.'),
      const SizedBox(height: 16),
      Row(children: [Expanded(child: _Metric(label: 'Reports', value: '${reportStore.reports.length}', color: kGreen)), const SizedBox(width: 10), Expanded(child: _Metric(label: 'High risk', value: '1', color: Colors.red)), const SizedBox(width: 10), Expanded(child: _Metric(label: 'Active diseases', value: '3', color: kSoil))]),
      const SizedBox(height: 18),
      Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: const Color(0xFFFFE6DF), borderRadius: BorderRadius.circular(22)), child: const Row(children: [Icon(Icons.trending_up_rounded, color: Colors.red), SizedBox(width: 10), Expanded(child: Text('Leaf rust reports are increasing around Haridwar. Consider issuing a local advisory.', style: TextStyle(fontWeight: FontWeight.w700)))])),
      const SizedBox(height: 18),
      const Text('Recent reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      ...reportStore.reports.map((r) => Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.agriculture_outlined)), title: Text('${r.crop} • ${r.issue}'), subtitle: Text('${r.location}\n${r.symptoms}'), isThreeLine: true, trailing: const Icon(Icons.chevron_right_rounded)))),
    ])),
  );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.color});
  final String label, value; final Color color;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(18)), child: Column(children: [Text(value, style: TextStyle(fontSize: 22, color: color, fontWeight: FontWeight.w900)), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))]));
}

class FollowUpScreen extends StatefulWidget {
  const FollowUpScreen({super.key});
  @override
  State<FollowUpScreen> createState() => _FollowUpScreenState();
}

class _FollowUpScreenState extends State<FollowUpScreen> {
  final Map<int, Uint8List?> _photos = {1: null, 7: null, 14: null};
  Future<void> _pick(int day) async {
    final photo = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (photo != null) {
      final bytes = await photo.readAsBytes();
      setState(() => _photos[day] = bytes);
    }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: kBg,
    appBar: AppBar(title: const Text('Treatment Follow-up', style: TextStyle(fontWeight: FontWeight.w800))),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: kGreenLight, borderRadius: BorderRadius.circular(22)), child: const Text('Track your crop after treatment. Upload photos on Day 1, Day 7 and Day 14 to build an improvement record.', style: TextStyle(height: 1.4, fontWeight: FontWeight.w600))),
      const SizedBox(height: 20),
      Row(
        children: [
          for (final day in [1, 7, 14])
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () => _pick(day),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    height: 165,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: kGreenLight, width: 2)),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      _photos[day] == null ? const Icon(Icons.add_a_photo_outlined, color: kGreen, size: 32) : ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.memory(_photos[day]!, height: 72, fit: BoxFit.cover)),
                      const SizedBox(height: 8),
                      Text('Day $day', style: const TextStyle(fontWeight: FontWeight.w800)),
                      const Text('Tap to upload', style: TextStyle(fontSize: 10, color: Color(0xFF757575))),
                    ]),
                  ),
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 22),
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: const Color(0xFFFFF4D6), borderRadius: BorderRadius.circular(20)),
        child: const Row(children: [
          Icon(Icons.health_and_safety_outlined, color: Color(0xFF9A6900)),
          SizedBox(width: 10),
          Expanded(child: Text('If symptoms spread or worsen, report again for expert review.', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF665426)))),
        ]),
      ),
    ]),
  );
}
