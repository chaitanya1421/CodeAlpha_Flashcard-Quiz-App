import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(FlashForgeApp());
}

class Flashcard {
  final int id;
  final String question;
  final String answer;

  Flashcard({required this.id, required this.question, required this.answer});

  Flashcard copyWith({int? id, String? question, String? answer}) {
    return Flashcard(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'answer': answer,
  };

  factory Flashcard.fromJson(Map<String, dynamic> j) => Flashcard(
    id: (j['id'] is int)
        ? j['id']
        : int.tryParse('${j['id']}') ?? DateTime.now().millisecondsSinceEpoch,
    question: j['question'] ?? '',
    answer: j['answer'] ?? '',
  );
}

class FlashForgeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlashForge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF8243)),
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: HomeRouter(),
    );
  }
}

class HomeRouter extends StatefulWidget {
  @override
  State<HomeRouter> createState() => _HomeRouterState();
}

class _HomeRouterState extends State<HomeRouter> {
  bool _started = false;

  @override
  Widget build(BuildContext context) {
    return _started
        ? FlashcardHomeScreen()
        : SplashHome(onStart: () => setState(() => _started = true));
  }
}

class SplashHome extends StatelessWidget {
  final VoidCallback onStart;
  const SplashHome({required this.onStart});

  @override
  Widget build(BuildContext context) {
    final palette = [
      const Color(0xFFFF8243),
      const Color(0xFFFFC0CB),
      const Color(0xFFFCE883),
      const Color(0xFF069494),
    ];

    return Scaffold(
      // subtle full-screen background gradient for nicer appearance
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey.shade50],
            stops: const [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isWide = width >= 900;

              // keep the content readable: limit width via SizedBox (not ConstrainedBox)
              final content = SizedBox(
                width: width > 1200 ? 1100 : width * 0.95,
                child: isWide
                    ? _WideSplash(palette: palette, onStart: onStart)
                    : _NarrowSplash(palette: palette, onStart: onStart),
              );

              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    vertical: 28,
                    horizontal: 16,
                  ),
                  child: content,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Wide screen layout: left = hero text, right = CTA + features
class _WideSplash extends StatelessWidget {
  final List<Color> palette;
  final VoidCallback onStart;
  const _WideSplash({required this.palette, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left: logo + headline + description
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.only(right: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // small header row with logo and name
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _Logo(size: 200, palette: palette),
                    const SizedBox(width: 18),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'FlashForge',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            height: 1.02,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Study faster. Remember longer.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                // big hero headline
                const Text(
                  'Make studying playful — not painful',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 18),

                // supportive description with generous line-height for readability
                Text(
                  'Create your own flashcards in seconds, flip to reveal answers, and use focused study sessions designed to boost recall and retention. '
                  'FlashForge keeps everything local and distraction-free.',
                  style: TextStyle(
                    fontSize: 16.5,
                    color: Colors.grey[700],
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 26),

                // soft visual separator and a small hint line
                Container(height: 1, width: 120, color: Colors.grey.shade200),
                const SizedBox(height: 12),
                Text(
                  'Tip: Your cards are saved locally on this device.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
        ),

        // Right: CTA card-like column (but not a Card wrapper of whole screen)
        Expanded(
          flex: 4,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // CTA block — visually prominent
              PrimaryCta(palette: palette, onTap: onStart),

              const SizedBox(height: 18),

              // small features list with icons
              Column(
                children: [
                  _FeatureTile(
                    icon: Icons.flash_on,
                    title: 'Quick creation',
                    subtitle: 'Add cards fast with an intuitive editor.',
                  ),
                  const SizedBox(height: 12),
                  _FeatureTile(
                    icon: Icons.auto_awesome_motion,
                    title: 'Smooth flip',
                    subtitle:
                        'Tap to reveal answers with a pleasant animation.',
                  ),
                  const SizedBox(height: 12),
                  _FeatureTile(
                    icon: Icons.palette,
                    title: 'Colorful cards',
                    subtitle: 'Each card uses your theme colors for clarity.',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Narrow (mobile) layout: stacked hero then CTA + features
class _NarrowSplash extends StatelessWidget {
  final List<Color> palette;
  final VoidCallback onStart;
  const _NarrowSplash({required this.palette, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // compact header
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Logo(size: 120, palette: palette),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FlashForge',
                  style: TextStyle(fontSize: 45, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'Study faster. Remember longer.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 22),

        const Text(
          'Make studying playful — not painful',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 6.0),
        //   child: Text(
        //     'Create your own flashcards in seconds — flip to check answers, repeat for mastery, and keep all progress locally on your device.',
        //     textAlign: TextAlign.center,
        //     style: TextStyle(
        //       fontSize: 12,
        //       color: Colors.grey[700],
        //       height: 1.5,
        //     ),
        //   ),
        // ),
        const SizedBox(height: 70),

        PrimaryCta(palette: palette, onTap: onStart),

        const SizedBox(height: 70),

        _FeatureTile(
          icon: Icons.flash_on,
          title: 'Quick creation',
          subtitle: 'Add cards fast.',
        ),
        const SizedBox(height: 8),
        _FeatureTile(
          icon: Icons.flip,
          title: 'Tap to flip',
          subtitle: 'Reveal answers quickly.',
        ),
        const SizedBox(height: 12),
        _FeatureTile(
          icon: Icons.palette,
          title: 'Colorful cards',
          subtitle: 'Each card uses your theme colors for clarity.',
        ),
      ],
    );
  }
}

/// Prominent CTA widget (reusable)
class PrimaryCta extends StatelessWidget {
  final List<Color> palette;
  final VoidCallback onTap;
  const PrimaryCta({required this.palette, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // card-like container for CTA with subtle elevation
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // headline inside CTA
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ready to start studying?',
                      style: TextStyle(
                        fontSize: 18.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[900],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Create a deck and try your first card.',
                      style: TextStyle(fontSize: 13.5, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // big gradient button
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [palette[0], palette[3]]),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: palette[0].withOpacity(0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('✨', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 10),
                  Text(
                    'Get started',
                    style: TextStyle(
                      fontSize: 16.5,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
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

/// simple feature row used in both narrow and wide layouts
class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 45, color: Colors.grey[800]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Logo extends StatelessWidget {
  final double size;
  final List<Color> palette;
  const _Logo({required this.size, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [palette[0], palette[3]]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 6)),
        ],
      ),
      child: const Center(
        child: Icon(Icons.menu_book, color: Colors.white, size: 36),
      ),
    );
  }
}

class FlashcardHomeScreen extends StatefulWidget {
  @override
  State<FlashcardHomeScreen> createState() => _FlashcardHomeScreenState();
}

class _FlashcardHomeScreenState extends State<FlashcardHomeScreen> {
  static const String STORAGE_KEY = 'flashcards_v1';
  final List<Color> colors = const [
    Color(0xFFFF8243),
    Color(0xFFFFC0CB),
    Color(0xFFFCE883),
    Color(0xFF069494),
  ];

  List<Flashcard> cards = [];
  int currentIndex = 0; // index into filtered list
  bool showAnswer = false;
  bool loading = true;
  String searchQuery = ''; // kept for internal filtering but no UI search field

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(STORAGE_KEY);
    if (raw != null) {
      try {
        final List<dynamic> parsed = jsonDecode(raw);
        cards = parsed
            .map((e) => Flashcard.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } catch (_) {
        cards = [];
      }
    }

    if (cards.isEmpty) {
      cards = [
        Flashcard(
          id: DateTime.now().millisecondsSinceEpoch,
          question: 'What is spaced repetition?',
          answer: 'A learning technique that spaces reviews over time.',
        ),
        Flashcard(
          id: DateTime.now().millisecondsSinceEpoch + 1,
          question: 'What is active recall?',
          answer: 'Actively trying to remember information without cues.',
        ),
      ];
      await _saveCards();
    }

    setState(() {
      loading = false;
      currentIndex = 0;
      showAnswer = false;
    });
  }

  Future<void> _saveCards() async {
    final sp = await SharedPreferences.getInstance();
    final encoded = jsonEncode(cards.map((c) => c.toJson()).toList());
    await sp.setString(STORAGE_KEY, encoded);
  }

  List<Flashcard> get filteredCards {
    if (searchQuery.trim().isEmpty) return cards;
    final q = searchQuery.toLowerCase();
    return cards
        .where(
          (c) =>
              c.question.toLowerCase().contains(q) ||
              c.answer.toLowerCase().contains(q),
        )
        .toList();
  }

  Color _textForBackground(Color bg) {
    final r = bg.red, g = bg.green, b = bg.blue;
    final yiq = (r * 299 + g * 587 + b * 114) / 1000;
    return yiq >= 128 ? Colors.black87 : Colors.white;
  }

  Future<void> _addCard() async {
    final result = await showDialog<Flashcard?>(
      context: context,
      builder: (_) => const CardEditorDialog(),
    );
    if (result != null) {
      setState(() {
        cards.add(result);
        currentIndex = cards.length - 1;
        showAnswer = false;
      });
      await _saveCards();
    }
  }

  Future<void> _editCard(Flashcard card) async {
    final result = await showDialog<Flashcard?>(
      context: context,
      builder: (_) => CardEditorDialog(initial: card),
    );
    if (result != null) {
      final idx = cards.indexWhere((c) => c.id == card.id);
      if (idx != -1) {
        setState(() {
          cards[idx] = result;
          showAnswer = false;
        });
        await _saveCards();
      }
    }
  }

  Future<void> _deleteCard(Flashcard card) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete card?'),
        content: const Text('This will permanently remove the card.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok == true) {
      setState(() {
        cards.removeWhere((c) => c.id == card.id);
        currentIndex = 0;
        showAnswer = false;
      });
      await _saveCards();
    }
  }

  void _next() {
    final len = filteredCards.length;
    if (len == 0) return;
    setState(() {
      showAnswer = false;
      currentIndex = (currentIndex + 1) % len;
    });
  }

  void _prev() {
    final len = filteredCards.length;
    if (len == 0) return;
    setState(() {
      showAnswer = false;
      currentIndex = (currentIndex - 1 + len) % len;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredCards;
    final hasCards = filtered.isNotEmpty;
    final safeIndex = hasCards
        ? currentIndex.clamp(0, filtered.length - 1).toInt()
        : 0;
    final Flashcard? current = hasCards ? filtered[safeIndex] : null;

    Color? bgColor;
    Color? txtColor;
    if (current != null) {
      final origIndex = cards.indexWhere((c) => c.id == current.id);
      final colorIndex =
          (origIndex >= 0 ? origIndex : safeIndex) % colors.length;
      bgColor = colors[colorIndex];
      txtColor = _textForBackground(bgColor);
    }

    // compute screen width and keep AppBar actions compact to avoid overflow
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            _LogoSmall(colors: colors),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FlashForge',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${cards.length} cards saved',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // compact Next button in AppBar
          IconButton(
            tooltip: 'Next',
            onPressed: _next,
            icon: const Icon(Icons.navigate_next),
            color: colors[0],
          ),
          // Add button: show icon on small screens to keep layout tight
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: screenWidth < 480
                ? IconButton(
                    onPressed: _addCard,
                    icon: const Icon(Icons.add),
                    color: colors[0],
                  )
                : ElevatedButton(
                    onPressed: _addCard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors[0],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Add'),
                  ),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // left: viewer
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    OutlinedButton(
                                      onPressed: _prev,
                                      child: const Text('Previous'),
                                    ),
                                    const SizedBox(width: 8),

                                    const SizedBox(width: 8),
                                    OutlinedButton(
                                      onPressed: _next,
                                      child: const Text('Next'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: Center(
                                child: current != null
                                    ? SizedBox(
                                        width: constraints.maxWidth * 0.6,
                                        child: AnimatedFlashcard(
                                          card: current,
                                          showAnswer: showAnswer,
                                          onFlip: () => setState(
                                            () => showAnswer = !showAnswer,
                                          ),
                                          frontColor: bgColor,
                                          backColor: bgColor,
                                          textColor: txtColor,
                                        ),
                                      )
                                    : Container(
                                        width: constraints.maxWidth * 0.6,
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                        child: Text(
                                          'No cards yet. Tap Add to create cards.',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (current != null)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      OutlinedButton(
                                        onPressed: () => _editCard(current),
                                        child: const Text('Edit'),
                                      ),
                                      const SizedBox(width: 8),
                                      OutlinedButton(
                                        onPressed: () => _deleteCard(current),
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${cards.indexWhere((c) => c.id == current.id) + 1}/${cards.length}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // right: list + tips
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'All cards',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '${cards.length}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  // Fixed-height, scrollable list that shows only colored number boxes
                                  SizedBox(
                                    height: 360,
                                    child: ListView.separated(
                                      padding: EdgeInsets.zero,
                                      itemCount: filtered.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 12),
                                      itemBuilder: (context, idx) {
                                        final c = filtered[idx];
                                        final origIndex = cards.indexWhere(
                                          (x) => x.id == c.id,
                                        );
                                        final colorIndex =
                                            (origIndex >= 0 ? origIndex : idx) %
                                            colors.length;
                                        final bg = colors[colorIndex];
                                        final txt = _textForBackground(bg);

                                        return InkWell(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          onTap: () {
                                            setState(() {
                                              currentIndex = idx;
                                              showAnswer = false;
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 6,
                                            ),
                                            child: Row(
                                              children: [
                                                // Colored square with number only
                                                Container(
                                                  width: 50,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    color: bg,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black12,
                                                        blurRadius: 6,
                                                        offset: Offset(0, 3),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '${idx + 1}',
                                                      style: TextStyle(
                                                        color: txt,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                const Spacer(),

                                                // Small arrow to indicate tappable row (optional)
                                                const Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 14,
                                                  color: Colors.grey,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Study tips',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '•Keep questions short and focused.',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    '•Use active recall — try before checking the answer.',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    '•Mix cards often to build durable memory.',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
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
                },
              ),
            ),
    );
  }
}

/// Animated flip card — encapsulates AnimationController and prevents lookup issues.
class AnimatedFlashcard extends StatefulWidget {
  final Flashcard card;
  final bool showAnswer;
  final VoidCallback? onFlip;
  final Color? frontColor;
  final Color? backColor;
  final Color? textColor;

  const AnimatedFlashcard({
    Key? key,
    required this.card,
    required this.showAnswer,
    this.onFlip,
    this.frontColor,
    this.backColor,
    this.textColor,
  }) : super(key: key);

  @override
  State<AnimatedFlashcard> createState() => _AnimatedFlashcardState();
}

class _AnimatedFlashcardState extends State<AnimatedFlashcard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flipController;
  late final Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _rotation = Tween<double>(begin: 0.0, end: pi).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    // initialize position
    if (widget.showAnswer) {
      _flipController.value = 1.0;
    } else {
      _flipController.value = 0.0;
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedFlashcard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showAnswer != widget.showAnswer) {
      if (widget.showAnswer) {
        _flipController.forward();
      } else {
        _flipController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onFlip != null) {
      widget.onFlip!();
    } else {
      if (_flipController.status == AnimationStatus.completed ||
          _flipController.value == 1.0) {
        _flipController.reverse();
      } else {
        _flipController.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final frontColor = widget.frontColor ?? Colors.white;
    final backColor = widget.backColor ?? Colors.white;
    final txtColor = widget.textColor ?? _textForBackground(frontColor);

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _rotation,
        builder: (context, child) {
          final angle = _rotation.value;
          final isBackVisible = angle > (pi / 2);
          final displayAngle = isBackVisible ? angle - pi : angle;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(displayAngle),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isBackVisible ? backColor : frontColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: isBackVisible
                  ? _buildBack(txtColor)
                  : _buildFront(txtColor),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFront(Color txtColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Q',
          style: TextStyle(fontSize: 14, color: txtColor.withOpacity(0.85)),
        ),
        const SizedBox(height: 8),
        Text(
          widget.card.question,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: txtColor,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _handleTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: txtColor,
            foregroundColor: txtColor.computeLuminance() > 0.5
                ? Colors.black
                : Colors.white,
            shape: const StadiumBorder(),
          ),
          child: const Text('Show Answer'),
        ),
      ],
    );
  }

  Widget _buildBack(Color txtColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'A',
          style: TextStyle(fontSize: 14, color: txtColor.withOpacity(0.85)),
        ),
        const SizedBox(height: 8),
        Text(
          widget.card.answer,
          style: TextStyle(fontSize: 18, color: txtColor),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _handleTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: txtColor,
            foregroundColor: txtColor.computeLuminance() > 0.5
                ? Colors.black
                : Colors.white,
            shape: const StadiumBorder(),
          ),
          child: const Text('Back'),
        ),
      ],
    );
  }

  Color _textForBackground(Color bg) {
    final r = bg.red, g = bg.green, b = bg.blue;
    final yiq = (r * 299 + g * 587 + b * 114) / 1000;
    return yiq >= 128 ? Colors.black87 : Colors.white;
  }
}

class _LogoSmall extends StatelessWidget {
  final List<Color> colors;
  const _LogoSmall({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [colors[0], colors[3]]),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.menu_book, color: Colors.white, size: 24),
    );
  }
}

class CardEditorDialog extends StatefulWidget {
  final Flashcard? initial;
  const CardEditorDialog({this.initial});

  @override
  State<CardEditorDialog> createState() => _CardEditorDialogState();
}

class _CardEditorDialogState extends State<CardEditorDialog> {
  late final TextEditingController qController;
  late final TextEditingController aController;

  @override
  void initState() {
    super.initState();
    qController = TextEditingController(text: widget.initial?.question ?? '');
    aController = TextEditingController(text: widget.initial?.answer ?? '');
  }

  @override
  void dispose() {
    qController.dispose();
    aController.dispose();
    super.dispose();
  }

  void _save() {
    final q = qController.text.trim();
    final a = aController.text.trim();
    if (q.isEmpty || a.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both question and answer')),
      );
      return;
    }
    final card = Flashcard(
      id: widget.initial?.id ?? DateTime.now().millisecondsSinceEpoch,
      question: q,
      answer: a,
    );
    Navigator.pop(context, card);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Add new card' : 'Edit card'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qController,
              decoration: const InputDecoration(labelText: 'Question'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: aController,
              decoration: const InputDecoration(labelText: 'Answer'),
              maxLines: 4,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
