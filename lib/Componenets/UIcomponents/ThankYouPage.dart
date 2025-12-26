import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:pixel_runner/PixelRunner.dart';

class ThankYouPage extends Component
    with HasGameReference<PixelRunner>, TapCallbacks {
  late TextComponent thankYouText;
  late TextComponent completionText;
  late TextComponent tapToContinueText;
  late List<PixelParticle> particles;
  late List<FloatingPixelHeart> hearts;
  double blinkTimer = 0;
  bool showTapText = true;

  @override
  FutureOr<void> onLoad() {
    // Add floating pixel particles
    particles = [];
    for (int i = 0; i < 40; i++) {
      particles.add(PixelParticle(
        position: Vector2(
          (i * 20) % game.size.x,
          (i * 15) % game.size.y,
        ),
      ));
    }
    addAll(particles);

    // Add floating hearts
    hearts = [];
    for (int i = 0; i < 5; i++) {
      hearts.add(FloatingPixelHeart(
        position: Vector2(
          50 + i * 130.0,
          game.size.y / 2 + 120,
        ),
      ));
    }
    addAll(hearts);

    // Pixel trophy/star decoration at top
    add(PixelTrophy(
      position: Vector2(game.size.x / 2, game.size.y / 2 - 160),
    ));

    // Title shadow
    final titleShadow = TextComponent(
      text: 'THANK YOU',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF1A1826),
          fontSize: 64,
          fontFamily: 'Pixelated',
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(game.size.x / 2 + 3, game.size.y / 2 - 77),
    );
    add(titleShadow);

    // Main thank you text
    thankYouText = TextComponent(
      text: 'THANK YOU',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF92E426),
          fontSize: 64,
          fontFamily: 'Pixelated',
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(game.size.x / 2, game.size.y / 2 - 80),
    );
    add(thankYouText);

    // Completion message
    completionText = TextComponent(
      text: 'FOR PLAYING!',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 32,
          fontFamily: 'Pixelated',
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(game.size.x / 2, game.size.y / 2 - 20),
    );
    add(completionText);

    // Pixelated decorative line
    add(PixelDivider(
      position: Vector2(game.size.x / 2 - 100, game.size.y / 2 + 20),
      width: 200,
    ));

    // "Tap to return to menu" text
    tapToContinueText = TextComponent(
      text: 'TAP TO RETURN TO MENU',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 24,
          fontFamily: 'Pixelated',
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(game.size.x / 2, game.size.y / 2 + 80),
    );
    add(tapToContinueText);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    // Blinking effect for tap text
    blinkTimer += dt;
    if (blinkTimer > 0.5) {
      showTapText = !showTapText;
      tapToContinueText.textRenderer = TextPaint(
        style: TextStyle(
          color: showTapText 
              ? const Color(0xFFFFFFFF) 
              : const Color(0x00FFFFFF),
          fontSize: 24,
          fontFamily: 'Pixelated',
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      );
      blinkTimer = 0;
    }
    super.update(dt);
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Return to main menu
    game.returnToMenu();
  }
}

class PixelParticle extends PositionComponent {
  double timer = 0;
  double blinkSpeed = 1.0;
  bool isVisible = true;
  Color color;

  PixelParticle({required Vector2 position})
      : color = const Color(0xFF92E426),
        super(position: position, size: Vector2.all(3)) {
    blinkSpeed = 0.3 + (position.x % 5) * 0.3;
    if (position.x % 3 == 0) {
      color = const Color(0xFFFFD700);
    }
  }

  @override
  void render(Canvas canvas) {
    if (isVisible) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, 0, 3, 3), paint);
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

class FloatingPixelHeart extends PositionComponent {
  double timer = 0;
  double floatSpeed = 2.0;
  double floatAmount = 20.0;
  Vector2 originalPosition;

  FloatingPixelHeart({required Vector2 position})
      : originalPosition = position.clone(),
        super(position: position, size: Vector2(12, 12)) {
    floatSpeed = 1.5 + (position.x % 3) * 0.5;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFFFF6B9D)
      ..style = PaintingStyle.fill;

    // Draw pixel heart shape
    // Top left bump
    canvas.drawRect(Rect.fromLTWH(0, 3, 3, 3), paint);
    canvas.drawRect(Rect.fromLTWH(3, 0, 3, 6), paint);
    
    // Top right bump
    canvas.drawRect(Rect.fromLTWH(6, 0, 3, 6), paint);
    canvas.drawRect(Rect.fromLTWH(9, 3, 3, 3), paint);
    
    // Middle and bottom
    canvas.drawRect(Rect.fromLTWH(0, 6, 12, 3), paint);
    canvas.drawRect(Rect.fromLTWH(3, 9, 6, 3), paint);
  }

  @override
  void update(double dt) {
    timer += dt * floatSpeed;
    position.y = originalPosition.y + (floatAmount * (timer % 1.0) - floatAmount / 2);
    super.update(dt);
  }
}

class PixelTrophy extends PositionComponent {
  PixelTrophy({required Vector2 position})
      : super(position: position, size: Vector2(40, 40), anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;

    // Trophy cup
    canvas.drawRect(Rect.fromLTWH(8, 8, 24, 4), paint);
    canvas.drawRect(Rect.fromLTWH(12, 12, 16, 12), paint);
    canvas.drawRect(Rect.fromLTWH(16, 24, 8, 4), paint);
    
    // Base
    canvas.drawRect(Rect.fromLTWH(8, 28, 24, 4), paint);
    
    // Handles
    canvas.drawRect(Rect.fromLTWH(4, 12, 4, 8), paint);
    canvas.drawRect(Rect.fromLTWH(32, 12, 4, 8), paint);
    
    // Star on top
    paint.color = const Color(0xFF92E426);
    canvas.drawRect(Rect.fromLTWH(18, 0, 4, 4), paint);
    canvas.drawRect(Rect.fromLTWH(14, 4, 4, 4), paint);
    canvas.drawRect(Rect.fromLTWH(22, 4, 4, 4), paint);
  }
}

class PixelDivider extends PositionComponent {
  final double width;

  PixelDivider({required Vector2 position, required this.width})
      : super(position: position, size: Vector2(width, 4));

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFF92E426)
      ..style = PaintingStyle.fill;

    for (double x = 0; x < width; x += 12) {
      canvas.drawRect(Rect.fromLTWH(x, 0, 8, 4), paint);
    }
  }
}