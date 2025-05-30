import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:fruit_collector/components/HUD/widgets/main_menu/main_menu.dart';

import '../../../../fruit_collector.dart';

class CreditsScreen extends Component {
  final Function gameAdd;
  final Function gameRemove;
  final FruitCollector game;

  CreditsScreen({required this.gameAdd, required this.gameRemove, required this.game});

  final List<_ScrollingCreditLine> creditLines = [];
  late Vector2 screenSize;
  late RectangleComponent _fadeOverlay;
  late _FadeUpdateComponent _fadeUpdateComponent;

  bool _hasFinished = false;

  Future<void> show() async {
    screenSize = game.size;
    game.toggleBlockWindowResize(false);
    game.toggleBlockButtons(false);
    _startFadeOverlay();
    _spawnCreditLines();
  }

  void _startFadeOverlay() {
    _fadeOverlay = RectangleComponent(
      size: Vector2(screenSize.x, screenSize.y),
      position: Vector2.zero(),
      paint: Paint()..color = Colors.black.withOpacity(0),
      priority: 1000,
    );

    gameAdd(_fadeOverlay);

    final double durationInSeconds = 2.5;
    double elapsed = 0;

    _fadeUpdateComponent = _FadeUpdateComponent(
      onUpdate: (double dt) {
        elapsed += dt;
        final double progress = (elapsed / durationInSeconds).clamp(0, 1);
        _fadeOverlay.paint.color = Colors.black.withOpacity(progress);

        if (progress >= 1) {
          _fadeUpdateComponent.removeFromParent();
        }
      },
    );

    gameAdd(_fadeUpdateComponent);
  }

  void _spawnCreditLines() {
    final List<String> lines = [
      '< - - - FRUIT COLLECTOR - - - >',
      '',
      'Developed   by:',
      'Amán   Lama   &   Víctor   Sánchez',
      'Survived   87   hours   of   coding   with   only   coffee   and   hope',
      '',
      'Art   &   Assets   Department:',
      'Pixel   Adventure   (huge   shout-out)',
      'Edits   lovingly   drawn   at   2AM   by   Amán   “Ctrl+Z   is   life”   Lama',
      '',
      'Sound   Engineers   (ish):',
      'ElevenUps   made   it   epic,   our   mouths   made   it   weird',
      'Víctor   once   recorded   a   jump   sound   with   a   banana',
      '',
      'Code   Division:',
      'Over   20,000   lines   written,   19,999   removed',
      'One   stayed   because   it   just   looked   cool',
      '',
      'UX   /   UI   Gurus:',
      'Designed   buttons   that   scream   “click   me”   without   yelling',
      'Everything   aligned   by   eye...   we   trust   our   instincts',
      '',
      'Testing   Team:',
      'Amán’s   cat   walked   on   the   keyboard...   and   fixed   a   bug',
      'Víctor’s   little   cousin   found   the   secret   level   by   accident',
      '',
      'Known   Bugs:',
      'They   know   who   they   are',
      'We’ll   pretend   it’s   “emergent   gameplay”',
      '',
      'Optimization   Wizards:',
      'Now   runs   even   on   calculators   (not   really)',
      'RAM   usage   lower   than   your   daily   screen   time',
      '',
      'Special   Thanks   to:',
      'Everyone   who   played   or   at   least   opened   the   game   once',
      'Also   you,   reading   this...   you’re   amazing',
      '',
      'Year   of   Release:',
      'This   nonsense   was   made   in   the   glorious   year   2025',
      'Bugs   from   the   future   may   have   been   included',
      '',
      'Powered   by:',
      'Flutter,   FLAME,   duct   tape   and   broken   dreams',
      '',
      'Executive   Producer:',
      'Caffeine.   Lots   of   it.   Like...   dangerously   much',
      '',
      'Marketing   Department:',
      'One   tweet,   a   fridge   magnet,   and   a   note   to   grandma',
      '',
      'Spiritual   Advisors:',
      'StackOverflow   &   that   one   obscure   GitHub   issue',
      '',
      'Inspirations:',
      'Fruit   Ninja,   90s   cartoons,   and   gravity   being   annoying',
      '',
      'Easter   Eggs:',
      'If   you   found   them,   congratulations.   You’re   a   wizard',
      'If   not,   try   pressing   every   key   at   once.   Maybe.   Who   knows',
      '',
      'Quantum   Debugging   Unit:',
      'Bugs   observed   ceased   to   exist   upon   observation',
      'Schrödinger’s   exception   was   real',
      '',
      'Time-travel   Department:',
      'Sent   a   patch   back   to   1995.   Still   waiting   for   feedback',
      '',
      'Meme   Curation   Team:',
      'Every   variable   name   is   a   secret   joke.   No,   really',
      '',
      'Thank   you   for   playing!',
      'Now   go   outside   and   collect   some   real   fruit.!',
      'Or   don’t   :) !',
      '',
      '',
      'THE   END   (maybe)!',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      'NOW   THE   REAL   END   GOODBYE   FELLAS!',
    ];

    final double spacing = 60.0;
    final double startY = screenSize.y + 50;

    final TextStyle baseStyle = const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      fontFamily: 'ArcadeClassic',
      color: Colors.white,
    );

    final TextStyle titleStyle = baseStyle.copyWith(fontSize: 24, color: Colors.yellow);

    final TextStyle finalStyle = baseStyle.copyWith(fontSize: 28, color: Colors.green);

    final double titleFontSize = 36;

    bool _isFinalLine(String line) => line.trim().endsWith('!');
    bool _isSectionTitle(String line) => line.trim().endsWith(':');
    bool _isBigTitle(String line) => line.trim().startsWith('<') && line.trim().endsWith('>');

    for (int i = 0; i < lines.length; i++) {
      final String rawText = lines[i];
      final String trimmed = rawText.trim();
      final bool isFinal = _isFinalLine(trimmed);
      final bool isSectionTitle = _isSectionTitle(trimmed);
      final bool isBigTitle = _isBigTitle(trimmed);
      final bool isLast = i == lines.length - 1;

      if (isBigTitle) {
        final String clean = trimmed.substring(1, trimmed.length - 1);
        final double yOffset = startY + i * spacing;
        final List<Color> rainbow = [
          Colors.red,
          Colors.orange,
          Colors.yellow,
          Colors.green,
          Colors.cyan,
          Colors.blue,
          Colors.purple,
          Colors.pink,
        ];

        for (int j = 0; j < clean.length; j++) {
          final String char = clean[j];
          final color = rainbow[j % rainbow.length];
          final letter = _ScrollingCreditLine(
            text: char,
            startPosition: Vector2(screenSize.x / 2 - (clean.length * 12) + j * 24, yOffset),
            screenHeight: screenSize.y,
            textStyle: baseStyle.copyWith(fontSize: titleFontSize, color: color),
            onRemoved: isLast ? _onCreditsFinished : null,
          );
          creditLines.add(letter);
          gameAdd(letter);
        }
      } else {
        final String clean = isFinal ? trimmed.substring(0, trimmed.length - 1) : trimmed;

        final double yOffset = startY + i * spacing;

        final TextStyle style = isFinal ? finalStyle : (isSectionTitle ? titleStyle : baseStyle);

        final creditLine = _ScrollingCreditLine(
          text: clean,
          startPosition: Vector2(screenSize.x / 2, yOffset),
          screenHeight: screenSize.y,
          textStyle: style,
          onRemoved: isLast ? _onCreditsFinished : null,
        );

        creditLines.add(creditLine);
        gameAdd(creditLine);
      }
    }
  }

  void _onCreditsFinished() {
    if (_hasFinished) return;
    _hasFinished = true;

    for (final line in creditLines) {
      line.removeFromParent();
    }

    _fadeOverlay.removeFromParent();
    _fadeUpdateComponent.removeFromParent();

    creditLines.clear();
    game.toggleBlockWindowResize(true);
    game.toggleBlockButtons(true);
    game.overlays.add(MainMenu.id);
  }
}

class _ScrollingCreditLine extends TextComponent {
  final double screenHeight;
  final double speed = 30.0;
  final VoidCallback? onRemoved;

  _ScrollingCreditLine({
    required String text,
    required Vector2 startPosition,
    required this.screenHeight,
    required TextStyle textStyle,
    this.onRemoved,
  }) : super(
    text: text,
    position: startPosition.clone(),
    anchor: Anchor.center,
    priority: 1001,
    textRenderer: TextPaint(style: textStyle),
  );

  @override
  void update(double dt) {
    position.y -= speed * dt;
    if (position.y + 30 < 0) {
      removeFromParent();
      onRemoved?.call();
    }
  }
}

class _FadeUpdateComponent extends Component {
  final void Function(double dt) onUpdate;

  _FadeUpdateComponent({required this.onUpdate});

  @override
  void update(double dt) {
    onUpdate(dt);
  }
}