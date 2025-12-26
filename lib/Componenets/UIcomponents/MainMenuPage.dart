import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:pixel_runner/PixelRunner.dart';

class MainMenuPage extends Component with HasGameReference<PixelRunner> {
  late TextComponent titleText;
  late List<MenuButton> menuButtons;
  late List<PixelStar> stars;
  
  @override
  FutureOr<void> onLoad() {
    // Add pixelated stars background
    stars = [];
    for (int i = 0; i < 30; i++) {
      stars.add(PixelStar(
        position: Vector2(
          (i * 50) % game.size.x,
          (i * 30) % game.size.y,
        ),
      ));
    }
    addAll(stars);

    // Pixelated decorative border
    final topBorder = PixelBorder(
      startPos: Vector2(0, 20),
      endPos: Vector2(game.size.x, 20),
      isHorizontal: true,
    );
    add(topBorder);

    final bottomBorder = PixelBorder(
      startPos: Vector2(0, game.size.y - 20),
      endPos: Vector2(game.size.x, game.size.y - 20),
      isHorizontal: true,
    );
    add(bottomBorder);

    // Game title with pixel shadow effect
    final titleShadow = TextComponent(
      text: 'PIXEL RUNNER',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF1A1826),
          fontSize: 72,
          fontFamily: 'Pixelated',
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(game.size.x / 2 + 4, game.size.y / 2 - 116),
    );
    add(titleShadow);

    titleText = TextComponent(
      text: 'PIXEL RUNNER',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF92E426),
          fontSize: 72,
          fontFamily: 'Pixelated',
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(game.size.x / 2, game.size.y / 2 - 120),
    );
    add(titleText);

    // Subtitle
    final subtitle = TextComponent(
      text: '- ADVENTURE AWAITS -',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 18,
          fontFamily: 'Pixelated',
          letterSpacing: 2,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(game.size.x / 2, game.size.y / 2 - 60),
    );
    add(subtitle);

    // Menu buttons with pixel art style
    menuButtons = [
      MenuButton(
        text: 'START GAME',
        position: Vector2(game.size.x / 2, game.size.y / 2 + 10),
        onTap: () => game.startGame(),
      ),
      MenuButton(
        text: 'EXIT',
        position: Vector2(game.size.x / 2, game.size.y / 2 + 80),
        onTap: () => game.exitGame(),
      ),
    ];

    for (var button in menuButtons) {
      add(button);
    }

    return super.onLoad();
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

class PixelBorder extends Component {
  final Vector2 startPos;
  final Vector2 endPos;
  final bool isHorizontal;

  PixelBorder({
    required this.startPos,
    required this.endPos,
    required this.isHorizontal,
  });

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFF92E426)
      ..style = PaintingStyle.fill;

    if (isHorizontal) {
      for (double x = startPos.x; x < endPos.x; x += 12) {
        canvas.drawRect(Rect.fromLTWH(x, startPos.y, 8, 4), paint);
      }
    } else {
      for (double y = startPos.y; y < endPos.y; y += 12) {
        canvas.drawRect(Rect.fromLTWH(startPos.x, y, 4, 8), paint);
      }
    }
  }
}

class MenuButton extends PositionComponent with TapCallbacks {
  final String text;
  final VoidCallback onTap;
  late TextComponent textComponent;
  late RectangleComponent background;
  late RectangleComponent shadow;
  bool isPressed = false;
  double animationTimer = 0;

  MenuButton({
    required this.text,
    required Vector2 position,
    required this.onTap,
  }) : super(
          position: position,
          anchor: Anchor.center,
          size: Vector2(300, 50),
        );

  @override
  FutureOr<void> onLoad() {
    // Pixel shadow
    shadow = RectangleComponent(
      position: Vector2(4, 4),
      size: size,
      paint: Paint()
        ..color = const Color(0xFF1A1826)
        ..style = PaintingStyle.fill,
    );
    add(shadow);

    // Button background
    background = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = const Color(0xFF2A2839)
        ..style = PaintingStyle.fill,
    );
    add(background);

    // Pixelated corner decorations
    _addCornerPixels();

    // Pixel border (chunky style)
    final borderPaint = Paint()
      ..color = const Color(0xFF92E426)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    
    final border = RectangleComponent(
      size: size,
      paint: borderPaint,
    );
    add(border);

    // Button text
    textComponent = TextComponent(
      text: text,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 28,
          fontFamily: 'Pixelated',
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
      anchor: Anchor.center,
      position: size / 2,
    );
    add(textComponent);

    return super.onLoad();
  }

  void _addCornerPixels() {
    final pixelPaint = Paint()
      ..color = const Color(0xFF92E426)
      ..style = PaintingStyle.fill;

    // Top-left corner pixels
    add(RectangleComponent(
      position: Vector2(8, 8),
      size: Vector2(4, 4),
      paint: pixelPaint,
    ));

    // Top-right corner pixels
    add(RectangleComponent(
      position: Vector2(size.x - 12, 8),
      size: Vector2(4, 4),
      paint: pixelPaint,
    ));

    // Bottom-left corner pixels
    add(RectangleComponent(
      position: Vector2(8, size.y - 12),
      size: Vector2(4, 4),
      paint: pixelPaint,
    ));

    // Bottom-right corner pixels
    add(RectangleComponent(
      position: Vector2(size.x - 12, size.y - 12),
      size: Vector2(4, 4),
      paint: pixelPaint,
    ));
  }

  @override
  void update(double dt) {
    animationTimer += dt;
    if (animationTimer > 0.5) {
      // Subtle pulse effect
      final scale = 1.0 + (animationTimer % 1.0) * 0.02;
      this.scale = Vector2.all(scale);
      if (animationTimer > 1.0) animationTimer = 0;
    }
    super.update(dt);
  }

  @override
  void onTapDown(TapDownEvent event) {
    isPressed = true;
    position = position + Vector2(2, 2);
    background.paint.color = const Color(0xFF3A3849);
    onTap();
  }

  @override
  void onTapUp(TapUpEvent event) {
    isPressed = false;
    position = position - Vector2(2, 2);
    background.paint.color = const Color(0xFF2A2839);
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    isPressed = false;
    position = position - Vector2(2, 2);
    background.paint.color = const Color(0xFF2A2839);
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    return point.x >= 0 && point.x <= size.x && point.y >= 0 && point.y <= size.y;
  }
}