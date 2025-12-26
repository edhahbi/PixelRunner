import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:pixel_runner/PixelRunner.dart';

/// IOComponent - Composant centralisé pour la gestion des entrées utilisateur
/// Contient le joystick et le bouton de saut
class IOComponent extends Component with HasGameReference<PixelRunner> {
  late JoystickComponent joystick;
  late JumpButton jumpButton;

  @override
  FutureOr<void> onLoad() async {
    // Création du joystick
    joystick = JoystickComponent(
      background: SpriteComponent(
        sprite: Sprite(game.images.fromCache('HUD/Joystick.png')),
      ),
      knob: SpriteComponent(
        sprite: Sprite(game.images.fromCache('HUD/Knob.png'))
      ),
      knobRadius: 20,
      margin: const EdgeInsets.only(left: 5, bottom: 32),
      priority: 100,
    );
    add(joystick);

    // Création du bouton de saut (classe interne)
    jumpButton = JumpButton();
    add(jumpButton);

    return super.onLoad();
  }

  /// Récupère le delta du joystick pour le mouvement
  Vector2 getJoystickDelta() => joystick.delta;

  /// Récupère la direction du joystick
  JoystickDirection getJoystickDirection() => joystick.direction;

  /// Vérifie si le bouton de saut est pressé
  bool isJumpButtonPressed() => jumpButton.isPressed;
}

/// JumpButton - Classe interne pour le bouton de saut
/// Définie dans IOComponent.dart car elle fait partie du système d'entrée
class JumpButton extends SpriteComponent
    with HasGameReference<PixelRunner>, TapCallbacks {
  JumpButton();

  final buttonSize = 25;
  bool isPressed = false;

  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache('HUD/JumpButton.png'));
    position = Vector2(
      game.size.x - 45 - buttonSize,
      game.size.y - 60 - buttonSize,
    );
    priority = 100;
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    isPressed = true;
    game.player.hasJumped = true;
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    isPressed = false;
    game.player.hasJumped = false;
    super.onTapUp(event);
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    isPressed = false;
    game.player.hasJumped = false;
    super.onTapCancel(event);
  }
}
