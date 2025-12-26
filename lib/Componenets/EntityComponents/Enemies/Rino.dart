import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pixel_runner/Componenets/ConstVars.dart';
import 'package:pixel_runner/PixelRunner.dart';

enum RinoState { idle, run, hit }

class Rino extends SpriteAnimationGroupComponent
    with HasGameReference<PixelRunner>, CollisionCallbacks {
  final double offNeg;
  final double offPos;

  Rino({
    super.position,
    super.size,
    this.offNeg = 0,
    this.offPos = 0,
  });

  static const stepTime = 0.05;
  static const rushSpeed = 80.0;
  static const _bounceHeight = 260.0;
  final textureSize = Vector2(52, 34);
  static const double hitboxOffsetX = 6;
  static const double hitboxOffsetY = 4;
  static const double hitboxWidth = 40;
  static const double hitboxHeight = 26;

  Vector2 velocity = Vector2.zero();
  late final Vector2 startPosition;
  double rangeNeg = 0;
  double rangePos = 0;
  double moveDirection = 1;
  bool rushing = false;
  bool gotStomped = false;

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runAnimation;
  late final SpriteAnimation hitAnimation;

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;

    startPosition = position.clone();
    rushing = true;

    add(
      RectangleHitbox(
        position: Vector2(hitboxOffsetX, hitboxOffsetY),
        size: Vector2(hitboxWidth, hitboxHeight),
      ),
    );

    _loadAnimations();
    _calculateRange();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _move(dt);
    _updateState();
    super.update(dt);
  }

  void _loadAnimations() {
    idleAnimation = _spriteAnimation('Idle',11);
    runAnimation = _spriteAnimation('Run',6);
    hitAnimation = _spriteAnimation('Hit',5, loop: false);

    animations = {
      RinoState.idle: idleAnimation,
      RinoState.run: runAnimation,
      RinoState.hit: hitAnimation,
    };

    current = RinoState.idle;
  }

  SpriteAnimation _spriteAnimation(String state,int amount, {bool loop = true}) {
    final image = game.images.fromCache('Enemies/Rino/$state (52x34).png');
    return SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: textureSize,
        loop: loop,
      ),
    );
  }

  void _calculateRange() {
    rangeNeg = position.x - offNeg * tileSize;
    rangePos = position.x + offPos * tileSize;
  }

  void _move(double dt) {
    if (!rushing || gotStomped) {
      return;
    }

    velocity.x = moveDirection * rushSpeed;
    position.x += velocity.x * dt;
    _checkPatrolBounds();
  }

  void _checkPatrolBounds() {
    if (position.x <= rangeNeg) {
      position.x = rangeNeg;
      moveDirection = 1;
    } else if (position.x + width >= rangePos) {
      position.x = rangePos - width;
      moveDirection = -1;
    }
  }


  void _updateState() {
    if (gotStomped) {
      return;
    }
    current = rushing ? RinoState.run : RinoState.idle;

    if ((moveDirection > 0 && scale.x > 0) || (moveDirection < 0 && scale.x < 0)) {
      flipHorizontallyAroundCenter();
    }
  }

  void collidedWithPlayer() async {
    if (game.player.velocity.y > 0 && game.player.y + game.player.height > position.y) {
      FlameAudio.play('bounce.wav', volume: game.soundVolume);
      gotStomped = true;
      rushing = false;
      current = RinoState.hit;
      game.player.velocity.y = -_bounceHeight;
      await animationTicker?.completed;
      removeFromParent();
    } else {
      game.player.collidedwithEnemy();
    }
    print('rino hit by player');
  }

  void reset() {
    rushing = true;
    gotStomped = false;
    position = startPosition.clone();
    velocity = Vector2.zero();
    moveDirection = 1;
    _calculateRange();
    current = RinoState.idle;
    animationTicker?.reset();
    if (scale.x < 0) {
      flipHorizontallyAroundCenter();
    }
  }
}

