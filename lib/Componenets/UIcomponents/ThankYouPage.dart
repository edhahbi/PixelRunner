import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:pixel_runner/PixelRunner.dart';

class ThankYouPage extends Component
    with HasGameReference<PixelRunner>, TapCallbacks {
  late TextComponent thankYouText;
  late TextComponent tapToContinueText;
  double blinkTimer = 0;
  bool showTapText = true;

  @override
  FutureOr<void> onLoad() {
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
      position: Vector2(game.size.x / 2, game.size.y / 2 - 60),
    );
    add(thankYouText);

    // "Tap to exit" text
    tapToContinueText = TextComponent(
      text: 'TAP TO EXIT',
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
      position: Vector2(game.size.x / 2, game.size.y / 2 + 80),
    );
    add(tapToContinueText);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    // Blinking effect for "TAP TO EXIT"
    blinkTimer += dt;
    if (blinkTimer > 0.5) {
      showTapText = !showTapText;
      blinkTimer = 0;
    }
    super.update(dt);
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Exit the app completely
    game.pauseEngine();
    SystemNavigator.pop();
  }
}
