import 'dart:async';

import 'package:flutter/material.dart';

void main() => runApp(const BuildSimulatorApp());

class BuildSimulatorApp extends StatelessWidget {
  const BuildSimulatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BUILD SYSTEM // TRANSFORM LAB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF070B14),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF31C7F4),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const TransformLabPage(),
    );
  }
}

enum BottleSide { creature, inorganic }

class Bottle {
  const Bottle(this.id, this.name, this.image, this.side, this.price);

  final String id;
  final String name;
  final String image;
  final BottleSide side;
  final int price;
}

class Belt {
  const Belt(
    this.id,
    this.name,
    this.image, {
    this.supportsFullBottles = false,
    required this.price,
  });

  final String id;
  final String name;
  final String image;
  final bool supportsFullBottles;
  final int price;
}

const belts = [
  Belt(
    'build',
    'ビルドドライバー',
    'assets/images/belts/build_driver.png',
    supportsFullBottles: true,
    price: 3500,
  ),
  Belt(
    'scratch',
    'スクラッシュドライバー',
    'assets/images/belts/scratch_driver.png',
    price: 4200,
  ),
];

const hazardTriggerPrice = 1800;

const bottles = [
  Bottle(
    'rabbit',
    'ラビット',
    'assets/images/bottles/rabbit.png',
    BottleSide.creature,
    800,
  ),
  Bottle(
    'gorilla',
    'ゴリラ',
    'assets/images/bottles/gorilla.png',
    BottleSide.creature,
    700,
  ),
  Bottle(
    'hawk',
    'タカ',
    'assets/images/bottles/hawk.png',
    BottleSide.creature,
    750,
  ),
  Bottle(
    'panda',
    'パンダ',
    'assets/images/bottles/panda.png',
    BottleSide.creature,
    900,
  ),
  Bottle(
    'ninja',
    '忍者',
    'assets/images/bottles/ninja.png',
    BottleSide.creature,
    850,
  ),
  Bottle(
    'tank',
    'タンク',
    'assets/images/bottles/tank.png',
    BottleSide.inorganic,
    900,
  ),
  Bottle(
    'diamond',
    'ダイヤモンド',
    'assets/images/bottles/diamond.png',
    BottleSide.inorganic,
    1000,
  ),
  Bottle(
    'gatling',
    'ガトリング',
    'assets/images/bottles/gatling.png',
    BottleSide.inorganic,
    1100,
  ),
  Bottle(
    'rocket',
    'ロケット',
    'assets/images/bottles/rocket.png',
    BottleSide.inorganic,
    950,
  ),
  Bottle(
    'comic',
    'コミック',
    'assets/images/bottles/comic.png',
    BottleSide.inorganic,
    850,
  ),
];

const bestMatches = <String, String>{
  'rabbit:tank': 'ラビットタンクフォーム',
  'gorilla:diamond': 'ゴリラモンドフォーム',
  'hawk:gatling': 'ホークガトリングフォーム',
  'panda:rocket': 'パンダロケットフォーム',
  'ninja:comic': 'ニンニンコミックフォーム',
};

class TransformLabPage extends StatefulWidget {
  const TransformLabPage({super.key});

  @override
  State<TransformLabPage> createState() => _TransformLabPageState();
}

class _TransformLabPageState extends State<TransformLabPage>
    with TickerProviderStateMixin {
  String selectedBelt = 'build';
  String selectedBottle1 = 'rabbit';
  String selectedBottle2 = 'tank';
  bool hazardEnabled = false;
  bool isTransforming = false;
  bool transformed = false;
  bool dimmed = false;
  String? displayedForm;
  String? displayedFormName;
  String line = 'ベストマッチ！';
  int _runId = 0;

  Belt get _belt => belts.firstWhere((item) => item.id == selectedBelt);
  Bottle get _leftBottle =>
      bottles.firstWhere((item) => item.id == selectedBottle1);
  Bottle get _rightBottle =>
      bottles.firstWhere((item) => item.id == selectedBottle2);
  bool get _isBestMatch =>
      bestMatches.containsKey('$selectedBottle1:$selectedBottle2');
  bool get _canTransform => _belt.supportsFullBottles && !isTransforming;
  int get _equipmentTotal =>
      _belt.price +
      _leftBottle.price +
      _rightBottle.price +
      (hazardEnabled ? hazardTriggerPrice : 0);
  String get _restingLine => hazardEnabled
      ? (_isBestMatch ? 'スーパーベストマッチ！' : 'ハザードオン！')
      : (_isBestMatch ? 'ベストマッチ！' : 'トライアルフォーム');

  String get _formPath {
    if (!_isBestMatch) return 'assets/images/forms/trial.png';
    final key = [selectedBottle1, selectedBottle2].join('_');
    return 'assets/images/forms/$key${hazardEnabled ? '_hazard' : ''}.png';
  }

  String get _formName {
    if (!_isBestMatch) return 'トライアルフォーム';
    return bestMatches['$selectedBottle1:$selectedBottle2']!;
  }

  void _resetResult() {
    _runId++;
    setState(() {
      isTransforming = false;
      transformed = false;
      dimmed = false;
      displayedForm = null;
      displayedFormName = null;
      line = _restingLine;
    });
  }

  void _selectBelt(String id) {
    if (selectedBelt == id) return;
    selectedBelt = id;
    _resetResult();
  }

  void _selectBottle(Bottle bottle) {
    if (bottle.side == BottleSide.creature) {
      if (selectedBottle1 == bottle.id) return;
      selectedBottle1 = bottle.id;
    } else {
      if (selectedBottle2 == bottle.id) return;
      selectedBottle2 = bottle.id;
    }
    _resetResult();
  }

  void _toggleHazard(bool value) {
    if (hazardEnabled == value) return;
    hazardEnabled = value;
    _resetResult();
  }

  Future<void> _transform() async {
    if (!_canTransform) return;
    final run = ++_runId;
    final left = _leftBottle;
    final right = _rightBottle;
    final match = _isBestMatch;
    final hazard = hazardEnabled;
    final formPath = _formPath;
    final formName = _formName;
    setState(() {
      isTransforming = true;
      transformed = false;
      displayedForm = null;
      displayedFormName = null;
      dimmed = true;
      line = 'システム起動…';
    });

    Future<void> step(String message, [int milliseconds = 620]) async {
      if (!mounted || run != _runId) return;
      setState(() => line = message);
      await Future<void>.delayed(Duration(milliseconds: milliseconds));
    }

    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted || run != _runId) return;
    await step('${left.name}！', 650);
    if (!mounted || run != _runId) return;
    await step('${right.name}！', 650);
    if (!mounted || run != _runId) return;
    await step(match ? 'ベストマッチ！' : 'トライアルフォーム！', 700);
    if (!mounted || run != _runId) return;
    if (hazard) {
      await step('ハザードオン！', 800);
      if (!mounted || run != _runId) return;
      await step(match ? 'スーパーベストマッチ！' : '制御レベル上昇…', 700);
      if (!mounted || run != _runId) return;
    }
    setState(() {
      displayedForm = formPath;
      displayedFormName = formName;
      transformed = true;
      dimmed = false;
      line = hazard
          ? (match ? 'スーパーベストマッチ！' : 'ハザードオン！')
          : (match ? 'ベストマッチ！' : 'トライアルフォーム');
      isTransforming = false;
    });
  }

  @override
  void dispose() {
    _runId++;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hazard = hazardEnabled;
    final accent = hazard ? const Color(0xFFFF3B45) : const Color(0xFF43D8FF);
    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: Icon(Icons.science_outlined, color: accent),
        title: const Text(
          '変身研究ラボ',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    hazard ? Icons.warning_amber_rounded : Icons.circle,
                    color: accent,
                    size: 12,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    hazard ? 'HAZARD' : 'ONLINE',
                    style: TextStyle(
                      color: accent,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 450),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: hazard
                ? const [
                    Color(0xFF20080E),
                    Color(0xFF09070B),
                    Color(0xFF16090C),
                  ]
                : const [
                    Color(0xFF0B1B2D),
                    Color(0xFF070B14),
                    Color(0xFF101527),
                  ],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: width < 600 ? 16 : 28,
                      vertical: 18,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildControls(accent),
                        const SizedBox(height: 16),
                        _buildResult(accent),
                        const SizedBox(height: 18),
                        _Footer(hazard: hazard),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: AnimatedOpacity(
                opacity: dimmed ? 0.57 : 0,
                duration: const Duration(milliseconds: 380),
                child: Container(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(Color accent) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _Panel(
        accent: accent,
        eyebrow: '01 / DRIVER SYSTEM',
        title: '変身ベルト',
        child: Column(
          children: [
            Row(
              children: [
                for (final belt in belts)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: belt == belts.first ? 10 : 0,
                      ),
                      child: _BeltOption(
                        belt: belt,
                        selected: belt.id == selectedBelt,
                        accent: accent,
                        onTap: () => _selectBelt(belt.id),
                      ),
                    ),
                  ),
              ],
            ),
            if (!_belt.supportsFullBottles) ...[
              const SizedBox(height: 12),
              const _Notice(
                message: '現在のフルボトル構成には対応していません',
                icon: Icons.info_outline,
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 16),
      _Panel(
        accent: accent,
        eyebrow: '02 / FULL BOTTLE LOAD',
        title: 'フルボトルをセット',
        trailing: Text(
          '左右を各1本選択',
          style: TextStyle(
            color: Colors.white.withValues(alpha: .55),
            fontSize: 11,
          ),
        ),
        child: Column(
          children: [
            _BottleRail(
              title: '生物ボトル',
              subtitle: 'BIOLOGY',
              side: BottleSide.creature,
              selectedId: selectedBottle1,
              accent: accent,
              onSelect: _selectBottle,
            ),
            const SizedBox(height: 12),
            _BottleRail(
              title: '無機物ボトル',
              subtitle: 'TECHNOLOGY',
              side: BottleSide.inorganic,
              selectedId: selectedBottle2,
              accent: accent,
              onSelect: _selectBottle,
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _Panel(
        accent: hazardEnabled ? const Color(0xFFFF3B45) : accent,
        eyebrow: '03 / HAZARD CONTROL',
        title: 'ハザードトリガー',
        child: _HazardControl(
          enabled: hazardEnabled,
          onChanged: _toggleHazard,
          accent: accent,
        ),
      ),
    ],
  );

  Widget _buildResult(Color accent) {
    final activePath = displayedForm ?? 'assets/images/forms/no_form.png';
    final isHazard = hazardEnabled && (transformed || isTransforming);
    return _Panel(
      accent: isHazard ? const Color(0xFFFF3B45) : accent,
      eyebrow: transformed ? 'SYSTEM OUTPUT / READY' : '04 / TRANSFORMATION',
      title: '変身シークエンス',
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 305,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: (isHazard ? const Color(0xFFFF3B45) : accent).withValues(
                  alpha: .32,
                ),
              ),
              color: const Color(0xFF080D17),
              boxShadow: isTransforming || transformed
                  ? [
                      BoxShadow(
                        color: (isHazard ? Colors.red : accent).withValues(
                          alpha: .16,
                        ),
                        blurRadius: 32,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: CustomPaint(
                      painter: _GridPainter(
                        color: accent.withValues(alpha: .08),
                      ),
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 750),
                  switchInCurve: Curves.easeOutCubic,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(
                        begin: .94,
                        end: 1,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: displayedForm == null
                      ? Column(
                          key: const ValueKey('no-form'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 205,
                              width: 260,
                              child: _AssetImage(
                                _belt.image,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'SYSTEM STANDBY',
                              style: TextStyle(
                                color: accent.withValues(alpha: .72),
                                letterSpacing: 3,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        )
                      : Padding(
                          key: ValueKey(activePath),
                          padding: const EdgeInsets.all(8),
                          child: _AssetImage(activePath, fit: BoxFit.contain),
                        ),
                ),
                if (isTransforming)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .28),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(child: _PulseRing(color: accent)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              line,
              key: ValueKey(line),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w800,
                fontSize: 19,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 5),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              transformed ? (displayedFormName ?? '') : _formName,
              key: ValueKey('${transformed}_$_formName'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: .72),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              Expanded(
                child: _BeltSummary(bottle: _leftBottle, accent: accent),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.add, size: 17, color: accent),
              ),
              Expanded(
                child: _BeltSummary(bottle: _rightBottle, accent: accent),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _BudgetPanel(
            accent: hazardEnabled ? const Color(0xFFFF3B45) : accent,
            belt: _belt,
            leftBottle: _leftBottle,
            rightBottle: _rightBottle,
            hazardEnabled: hazardEnabled,
            total: _equipmentTotal,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton.icon(
              onPressed: _canTransform ? _transform : null,
              style: FilledButton.styleFrom(
                backgroundColor: hazardEnabled
                    ? const Color(0xFFD92D3B)
                    : const Color(0xFF087DAE),
                disabledBackgroundColor: Colors.white.withValues(alpha: .08),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                textStyle: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              icon: Icon(isTransforming ? Icons.hourglass_top : Icons.bolt),
              label: Text(isTransforming ? '変身中…' : '変身！'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.accent,
    required this.eyebrow,
    required this.title,
    required this.child,
    this.trailing,
  });

  final Color accent;
  final String eyebrow;
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: const Color(0xFF111A29).withValues(alpha: .92),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: accent.withValues(alpha: .2)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x33000000),
          blurRadius: 22,
          offset: Offset(0, 9),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eyebrow,
                    style: TextStyle(
                      color: accent.withValues(alpha: .78),
                      fontSize: 9,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );
}

class _BeltOption extends StatelessWidget {
  const _BeltOption({
    required this.belt,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final Belt belt;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: .12)
              : const Color(0xFF0B111D),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? accent : Colors.white.withValues(alpha: .1),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: .18),
                    blurRadius: 15,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            SizedBox(
              height: 96,
              child: _AssetImage(belt.image, fit: BoxFit.contain),
            ),
            const SizedBox(height: 7),
            Text(
              belt.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _BottleRail extends StatelessWidget {
  const _BottleRail({
    required this.title,
    required this.subtitle,
    required this.side,
    required this.selectedId,
    required this.accent,
    required this.onSelect,
  });

  final String title;
  final String subtitle;
  final BottleSide side;
  final String selectedId;
  final Color accent;
  final ValueChanged<Bottle> onSelect;

  @override
  Widget build(BuildContext context) {
    final items = bottles.where((bottle) => bottle.side == side).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: .38),
                fontSize: 8,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 126,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final bottle = items[index];
              final selected = bottle.id == selectedId;
              return _BottleCard(
                bottle: bottle,
                selected: selected,
                accent: accent,
                onTap: () => onSelect(bottle),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BottleCard extends StatelessWidget {
  const _BottleCard({
    required this.bottle,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final Bottle bottle;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 92,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: .13)
                : const Color(0xFF0A101B),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: selected ? accent : Colors.white.withValues(alpha: .1),
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: .22),
                      blurRadius: 13,
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Expanded(child: _AssetImage(bottle.image, fit: BoxFit.contain)),
              const SizedBox(height: 2),
              Text(
                bottle.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _HazardControl extends StatelessWidget {
  const _HazardControl({
    required this.enabled,
    required this.onChanged,
    required this.accent,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;
  final Color accent;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () => onChanged(!enabled),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFF3A1118) : const Color(0xFF0A101B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: enabled
                ? const Color(0xFFFF3B45)
                : Colors.white.withValues(alpha: .1),
            width: enabled ? 1.5 : 1,
          ),
          boxShadow: enabled
              ? const [BoxShadow(color: Color(0x44FF2637), blurRadius: 20)]
              : null,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 86,
              height: 86,
              child: _AssetImage(
                'assets/images/items/hazard_trigger.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    enabled ? 'HAZARD ON' : 'HAZARD STANDBY',
                    style: TextStyle(
                      color: enabled ? const Color(0xFFFF5B64) : accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    enabled ? '危険な力を解放中' : 'タップして装着する',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: .85),
                    ),
                  ),
                ],
              ),
            ),
            Checkbox(
              value: enabled,
              activeColor: const Color(0xFFE3283C),
              onChanged: (value) => onChanged(value ?? false),
            ),
          ],
        ),
      ),
    ),
  );
}

class _BeltSummary extends StatelessWidget {
  const _BeltSummary({required this.bottle, required this.accent});

  final Bottle bottle;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .035),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.white.withValues(alpha: .08)),
    ),
    child: Row(
      children: [
        SizedBox(
          width: 30,
          height: 35,
          child: _AssetImage(bottle.image, fit: BoxFit.contain),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            bottle.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

class _BudgetPanel extends StatelessWidget {
  const _BudgetPanel({
    required this.accent,
    required this.belt,
    required this.leftBottle,
    required this.rightBottle,
    required this.hazardEnabled,
    required this.total,
  });

  final Color accent;
  final Belt belt;
  final Bottle leftBottle;
  final Bottle rightBottle;
  final bool hazardEnabled;
  final int total;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFF0A101B),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: accent.withValues(alpha: .23)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              color: accent,
              size: 17,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'この装備にかかる費用（目安）',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              'SIMULATED',
              style: TextStyle(
                color: accent.withValues(alpha: .75),
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _BudgetRow(label: belt.name, price: belt.price),
        const SizedBox(height: 7),
        _BudgetRow(label: leftBottle.name, price: leftBottle.price),
        const SizedBox(height: 7),
        _BudgetRow(label: rightBottle.name, price: rightBottle.price),
        const SizedBox(height: 7),
        _BudgetRow(
          label: 'ハザードトリガー',
          price: hazardEnabled ? hazardTriggerPrice : 0,
          note: hazardEnabled ? null : '未装着',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Divider(color: Colors.white.withValues(alpha: .14), height: 1),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '合計',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            Text(
              '¥${_yen(total)}',
              style: TextStyle(
                color: accent,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: .5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          'シミュレーター内の設定価格による概算です。',
          style: TextStyle(
            color: Colors.white.withValues(alpha: .45),
            fontSize: 9,
          ),
        ),
      ],
    ),
  );
}

class _BudgetRow extends StatelessWidget {
  const _BudgetRow({required this.label, required this.price, this.note});

  final String label;
  final int price;
  final String? note;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(label, style: const TextStyle(fontSize: 11))),
      Text(
        note ?? '¥${_yen(price)}',
        style: TextStyle(
          color: note == null
              ? Colors.white.withValues(alpha: .78)
              : Colors.white38,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

String _yen(int amount) => amount.toString().replaceAllMapped(
  RegExp(r'\B(?=(\d{3})+(?!\d))'),
  (match) => ',',
);

class _Notice extends StatelessWidget {
  const _Notice({required this.message, required this.icon});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: const Color(0xFF281C16),
      borderRadius: BorderRadius.circular(11),
      border: Border.all(color: const Color(0xFFFFB54A).withValues(alpha: .4)),
    ),
    child: Row(
      children: [
        const Icon(Icons.info_outline, size: 16, color: Color(0xFFFFB54A)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: Color(0xFFFFD28F),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class _Footer extends StatelessWidget {
  const _Footer({required this.hazard});

  final bool hazard;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(Icons.memory, size: 13, color: Colors.white.withValues(alpha: .35)),
      const SizedBox(width: 7),
      Expanded(
        child: Text(
          hazard ? '警告：ハザードレベル上昇中' : 'BUILD DRIVER / FULL BOTTLE SYSTEM',
          style: TextStyle(
            color: Colors.white.withValues(alpha: .4),
            fontSize: 9,
            letterSpacing: 1.2,
          ),
        ),
      ),
      Text(
        'PERSONAL SIMULATOR',
        style: TextStyle(
          color: Colors.white.withValues(alpha: .28),
          fontSize: 8,
          letterSpacing: 1.1,
        ),
      ),
    ],
  );
}

class _AssetImage extends StatelessWidget {
  const _AssetImage(this.path, {this.fit = BoxFit.cover});

  final String path;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) => Image.asset(
    path,
    fit: fit,
    errorBuilder: (context, error, stackTrace) => Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF172236),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.broken_image_outlined,
            color: Color(0xFF8FA5C6),
            size: 26,
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              'IMAGE\nUNAVAILABLE',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: .5),
                fontSize: 7,
                letterSpacing: .7,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _PulseRing extends StatefulWidget {
  const _PulseRing({required this.color});

  final Color color;

  @override
  State<_PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<_PulseRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, child) {
      final size = 38 + _controller.value * 26;
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.color.withValues(alpha: .9 - _controller.value * .45),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: .22),
              blurRadius: 20,
            ),
          ],
        ),
        child: Center(child: Icon(Icons.bolt, color: widget.color, size: 19)),
      );
    },
  );
}

class _GridPainter extends CustomPainter {
  const _GridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const spacing = 24.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.color != color;
}
