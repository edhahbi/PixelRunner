import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pixel_runner/Componenets/ConstVars.dart';
import 'package:pixel_runner/PixelRunner.dart';

enum ChickenState { idle, run, hit }

class Chicken extends SpriteAnimationGroupComponent
    with HasGameReference<PixelRunner>, CollisionCallbacks {
  final double offNeg;
  final double offPos;
  Chicken({
    super.position,
    super.size,
    this.offNeg = 0,
    this.offPos = 0,
  });

  static const stepTime = 0.05;
  static const runSpeed = 80;
  static const _bounceHeight = 260.0;
  final textureSize = Vector2(32, 34);

  Vector2 velocity = Vector2.zero();
  late final Vector2 startPosition;
  double rangeNeg = 0;
  double rangePos = 0;
  double moveDirection = 1;
  double targetDirection = -1;
  bool gotStomped = false;

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runAnimation;
  late final SpriteAnimation hitAnimation;

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;

    startPosition = position.clone();

    add(
      RectangleHitbox(
        position: Vector2(4, 6),
        size: Vector2(24, 26),
      ),
    );
    _loadAnimations();
    _calculateRange();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!gotStomped) {
      _updateState();
      _movement(dt);
    }

    super.update(dt);
  }

  void _loadAnimations() {
    idleAnimation = _spriteAnimation('Idle', 13);
    runAnimation = _spriteAnimation('Run', 14);
    hitAnimation = _spriteAnimation('Hit', 15)..loop = false;

    animations = {
     ChickenState.idle : idleAnimation,
      ChickenState.run: runAnimation,
      ChickenState.hit: hitAnimation,
    };

    current = ChickenState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Enemies/Chicken/$state (32x34).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: textureSize,
      ),
    );
  }

  void _calculateRange() {
    rangeNeg = position.x - offNeg * tileSize;
    rangePos = position.x + offPos * tileSize;
  }

  void _movement(double dt) {
    // set velocity to 0;
    velocity.x = 0;

    double playerOffset = (game.player.scale.x > 0) ? 0 : -game.player.width;
    double chickenOffset = (scale.x > 0) ? 0 : -width;

    if (playerInRange()) {
      // player in range
      targetDirection =
          (game.player.x + playerOffset < position.x + chickenOffset) ? -1 : 1;
      velocity.x = targetDirection * runSpeed;
    }

    moveDirection = lerpDouble(moveDirection, targetDirection, 0.1) ?? 1;

    position.x += velocity.x * dt;
  }

  bool playerInRange() {
    double playerOffset = (game.player.scale.x > 0) ? 0 : -game.player.width;

    return game.player.x + playerOffset >= rangeNeg &&
        game.player.x + playerOffset <= rangePos &&
        game.player.y + game.player.height > position.y &&
        game.player.y < position.y + height;
  }

  void _updateState() {
    current = (velocity.x != 0) ? ChickenState.run : ChickenState.idle;

    if ((moveDirection > 0 && scale.x > 0) ||
        (moveDirection < 0 && scale.x < 0)) {
      flipHorizontallyAroundCenter();
    }
  }

  void collidedWithPlayer() async {
    if (game.player.velocity.y > 0 && game.player.y + game.player.height > position.y) {
      FlameAudio.play('bounce.wav', volume: game.soundVolume);
      gotStomped = true;
      current = ChickenState.hit;
      game.player.velocity.y = -_bounceHeight;
      await animationTicker?.completed;
      removeFromParent();
    } else {
      game.player.collidedwithEnemy();
    }
  }

  void reset() {
    gotStomped = false;
    position = startPosition.clone();
    velocity = Vector2.zero();
    moveDirection = 1;
    targetDirection = -1;
    _calculateRange();
    current = ChickenState.idle;
    animationTicker?.reset();
    if (scale.x < 0) {
      flipHorizontallyAroundCenter();
    }
  }
}