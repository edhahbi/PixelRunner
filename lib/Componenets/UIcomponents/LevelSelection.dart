import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:pixel_runner/PixelRunner.dart';

class LevelSelectionPage extends Component with HasGameReference<PixelRunner> {
  late TextComponent titleText;
  late List<LevelCard> levelCards;
  late BackButton backButton;
  late List<PixelStar> stars;

  @override
  FutureOr<void> onLoad() {
    // Add background stars
    stars = [];
    for (int i = 0; i < 25; i++) {
      stars.add(PixelStar(
        position: Vector2(
          (i * 60) % game.size.x,
          (i * 40) % game.size.y,
        ),
      ));
    }
    addAll(stars);

    // Title shadow
    final titleShadow = TextComponent(
      text: 'SELECT LEVEL',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF1A1826),
          fontSize: 56,
          fontFamily: 'Pixelated',
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(game.size.x / 2 + 3, game.size.y / 2 - 127),
    );
    add(titleShadow);

    // Title
    titleText = TextComponent(
      text: 'SELECT LEVEL',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF92E426),
          fontSize: 56,
          fontFamily: 'Pixelated',
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(game.size.x / 2, game.size.y / 2 - 130),
    );
    add(titleText);

    // Level cards
    levelCards = [];
    final cardSpacing = 120.0;
    final startX = game.size.x / 2 - cardSpacing;

    for (int i = 0; i < 3; i++) {
      levelCards.add(LevelCard(
        levelIndex: i,
        levelName: 'LEVEL ${i + 1}',
        characterName: game.characterNames[i],
        position: Vector2(startX + i * cardSpacing, game.size.y / 2 - 20),
        onTap: () => game.startGameFromLevel(i),
      ));
    }

    for (var card in levelCards) {
      add(card);
    }

    // Back button
    backButton = BackButton(
      position: Vector2(60, 40),
      onTap: () => game.returnToMenu(),
    );
    add(backButton);

    return super.onLoad();
  }
}

class LevelCard extends PositionComponent with TapCallbacks {
  final int levelIndex;
  final String levelName;
  final String characterName;
  final VoidCallback onTap;
  late RectangleComponent background;
  late RectangleComponent shadow;
  late TextComponent levelText;
  late TextComponent characterText;
  late PixelCharacterIcon characterIcon;
  bool isHovered = false;

  LevelCard({
    required this.levelIndex,
    required this.levelName,
    required this.characterName,
    required Vector2 position,
    required this.onTap,
  }) : super(
          position: position,
          anchor: Anchor.center,
          size: Vector2(100, 140),
        );

  @override
  FutureOr<void> onLoad() {
    // Shadow
    shadow = RectangleComponent(
      position: Vector2(3, 3),
      size: size,
      paint: Paint()
        ..color = const Color(0xFF1A1826)
        ..style = PaintingStyle.fill,
    );
    add(shadow);

    // Background
    background = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = const Color(0xFF2A2839)
        ..style = PaintingStyle.fill,
    );
    add(background);

    // Border
    final border = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = const Color(0xFF92E426)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    add(border);

    // Corner pixels
    _addCornerPixels();

    // Character icon area
    characterIcon = PixelCharacterIcon(
      position: Vector2(size.x / 2, 35),
    );
    add(characterIcon);

    // Level number
    levelText = TextComponent(
      text: levelName,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF92E426),
          fontSize: 20,
          fontFamily: 'Pixelated',
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, 80),
    );
    add(levelText);

    // Character name
    characterText = TextComponent(
      text: _shortenName(characterName),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 12,
          fontFamily: 'Pixelated',
          letterSpacing: 1,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, 105),
    );
    add(characterText);

    // "TAP TO PLAY" text
    final playText = TextComponent(
      text: 'PLAY',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 14,
          fontFamily: 'Pixelated',
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, 125),
    );
    add(playText);

    return super.onLoad();
  }

  String _shortenName(String name) {
    // Shorten character names to fit
    if (name == 'Ninja Frog') return 'NINJA';
    if (name == 'Mask Dude') return 'MASK';
    if (name == 'Pink Man') return 'PINK';
    return name;
  }

  void _addCornerPixels() {
    final pixelPaint = Paint()
      ..color = const Color(0xFF92E426)
      ..style = PaintingStyle.fill;

    // Corner decorations
    add(RectangleComponent(
      position: Vector2(6, 6),
      size: Vector2(3, 3),
      paint: pixelPaint,
    ));
    add(RectangleComponent(
      position: Vector2(size.x - 9, 6),
      size: Vector2(3, 3),
      paint: pixelPaint,
    ));
    add(RectangleComponent(
      position: Vector2(6, size.y - 9),
      size: Vector2(3, 3),
      paint: pixelPaint,
    ));
    add(RectangleComponent(
      position: Vector2(size.x - 9, size.y - 9),
      size: Vector2(3, 3),
      paint: pixelPaint,
    ));
  }

  @override
  void onTapDown(TapDownEvent event) {
    position = position + Vector2(2, 2);
    background.paint.color = const Color(0xFF3A3849);
    onTap();
  }

  @override
  void onTapUp(TapUpEvent event) {
    position = position - Vector2(2, 2);
    background.paint.color = const Color(0xFF2A2839);
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    position = position - Vector2(2, 2);
    background.paint.color = const Color(0xFF2A2839);
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    return point.x >= 0 && point.x <= size.x && point.y >= 0 && point.y <= size.y;
  }
}

class PixelCharacterIcon extends PositionComponent {
  PixelCharacterIcon({required Vector2 position})
      : super(position: position, size: Vector2(32, 32), anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFF92E426)
      ..style = PaintingStyle.fill;

    // Simple pixelated character silhouette
    // Head
    canvas.drawRect(Rect.fromLTWH(8, 4, 16, 12), paint);
    
    // Body
    canvas.drawRect(Rect.fromLTWH(10, 16, 12, 10), paint);
    
    // Arms
    canvas.drawRect(Rect.fromLTWH(4, 18, 6, 6), paint);
    canvas.drawRect(Rect.fromLTWH(22, 18, 6, 6), paint);
    
    // Legs
    canvas.drawRect(Rect.fromLTWH(10, 26, 5, 6), paint);
    canvas.drawRect(Rect.fromLTWH(17, 26, 5, 6), paint);

    // Eyes (make it look alive)
    paint.color = const Color(0xFF211F30);
    canvas.drawRect(Rect.fromLTWH(12, 8, 3, 3), paint);
    canvas.drawRect(Rect.fromLTWH(19, 8, 3, 3), paint);
  }
}

class BackButton extends PositionComponent with TapCallbacks {
  final VoidCallback onTap;
  late RectangleComponent background;
  late TextComponent backText;

  BackButton({
    required Vector2 position,
    required this.onTap,
  }) : super(
          position: position,
          anchor: Anchor.center,
          size: Vector2(100, 40),
        );

  @override
  FutureOr<void> onLoad() {
    // Shadow
    add(RectangleComponent(
      position: Vector2(2, 2),
      size: size,
      paint: Paint()
        ..color = const Color(0xFF1A1826)
        ..style = PaintingStyle.fill,
    ));

    // Background
    background = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = const Color(0xFF2A2839)
        ..style = PaintingStyle.fill,
    );
    add(background);

    // Border
    add(RectangleComponent(
      size: size,
      paint: Paint()
        ..color = const Color(0xFF92E426)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    ));

    // Arrow and text
    backText = TextComponent(
      text: '< BACK',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 18,
          fontFamily: 'Pixelated',
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
      anchor: Anchor.center,
      position: size / 2,
    );
    add(backText);

    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    position = position + Vector2(1, 1);
    background.paint.color = const Color(0xFF3A3849);
    onTap();
  }

  @override
  void onTapUp(TapUpEvent event) {
    position = position - Vector2(1, 1);
    background.paint.color = const Color(0xFF2A2839);
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    position = position - Vector2(1, 1);
    background.paint.color = const Color(0xFF2A2839);
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    return point.x >= 0 && point.x <= size.x && point.y >= 0 && point.y <= size.y;
  }
}

class PixelStar extends PositionComponent {
  double timer = 0;
  double blinkSpeed = 1.0;
  bool isVisible = true;

  PixelStar({required Vector2 position})
      : super(position: position, size: Vector2.all(4)) {
    blinkSpeed = 0.5 + (position.x % 3) * 0.5;
  }

  @override
  void render(Canvas canvas) {
    if (isVisible) {
      final paint = Paint()
        ..color = const Color(0xFF92E426)
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, 0, 4, 4), paint);
    }
  }

  @override
  void update(double dt) {
    timer += dt;
    if (timer > blinkSpeed) {
      isVisible = !isVisible;
      timer = 0;
    }
    super.update(dt);
  }
}