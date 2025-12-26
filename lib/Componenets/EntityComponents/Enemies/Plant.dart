import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pixel_runner/Componenets/EntityComponents/Player/Player.dart';
import 'package:pixel_runner/PixelRunner.dart';

enum PlantState { idle, attack, hit }

class Plant extends SpriteAnimationGroupComponent
    with HasGameReference<PixelRunner>, CollisionCallbacks {


  Plant({
    super.position,
    super.size,
    this.isRight = false,
  });

  static const stepTime = 0.05;
  static const _bounceHeight = 260.0;
  static const shootCooldown = 2.0;
  final textureSize = Vector2(44, 42);

  late final Vector2 startPosition;
  bool gotStomped = false;
  double timeSinceLastShot = 0;
  bool isShooting = false;
  final bool isRight;


  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation attackAnimation;
  late final SpriteAnimation hitAnimation;

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;

    startPosition = position.clone();

    add(
      RectangleHitbox(
        position: Vector2(8, 10),
        size: Vector2(28, 28),
      ),
    );

    _loadAnimations();

    // Ensure size is valid for range/overlap checks and rendering
    if (width == 0 || height == 0) {
      size = textureSize.clone();
    }

    // Set initial orientation based on isLeft flag
    if (isRight && scale.x < 0) {
      flipHorizontallyAroundCenter();
    } else if (!isRight && scale.x > 0) {
      flipHorizontallyAroundCenter();
    }
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!gotStomped) {
      timeSinceLastShot += dt;
      _checkAndShoot();
      _updateState();
    }

    super.update(dt);
  }

  void _loadAnimations() {
    idleAnimation = _spriteAnimation('Idle', 11);
    attackAnimation = _spriteAnimation('Attack', 8)..loop = false;
    hitAnimation = _spriteAnimation('Hit', 8)..loop = false;

    animations = {
      PlantState.idle: idleAnimation,
      PlantState.attack: attackAnimation,
      PlantState.hit: hitAnimation,
    };

    current = PlantState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Enemies/Plant/$state (44x42).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: textureSize,
      ),
    );
  }



  bool _isPlayerInRange() {
    final playerTop = game.player.y;
    final playerBottom = game.player.y + game.player.height;
    final plantHeadY = position.y;
    final plantBaseY = position.y + height;

    // Side check: only shoot in facing direction
    final playerCenterX = game.player.x + game.player.width * 0.5;
    final plantCenterX = position.x + width * 0.5;
    final correctSide = isRight ? (playerCenterX < plantCenterX) : (playerCenterX > plantCenterX);

    // Vertical check: player overlaps the plant vertically
    final verticalOverlap = playerBottom > plantHeadY && playerTop < plantBaseY;

    return correctSide && verticalOverlap;
  }

  void _checkAndShoot() {
    if (isShooting || timeSinceLastShot < shootCooldown) {
      return;
    }

    if (_isPlayerInRange()) {
      _shoot();
    }
  }

  void _shoot() async {
    isShooting = true;
    timeSinceLastShot = 0;
    current = PlantState.attack;

    double offsetX = isRight? width:-width;
    final plantCenter = position + Vector2(offsetX * .5, height * .5);
    final forward = isRight ? Vector2(-1, 0) : Vector2(1, 0);

    // Burst: fire 3 bullets straight ahead
    for (int i = 0; i < 3; i++) {
      if (gotStomped || parent == null) break;

      parent?.add(
        Bullet(
          position: plantCenter.clone(),
          direction: forward,
        ),
      );

      if (i < 2) {
        await Future.delayed(const Duration(milliseconds: 120));
      }
    }

    // Wait for attack animation to complete once
    await animationTicker?.completed;

    if (!gotStomped) {
      current = PlantState.idle;
      isShooting = false;
    }
  }

  void _updateState() {
    // Orientation is fixed by isLeft; no auto-facing.
  }

  void collidedWithPlayer() async {
    if (game.player.velocity.y > 0 &&
        game.player.y + game.player.height > position.y) {
      FlameAudio.play('bounce.wav', volume: game.soundVolume);
      gotStomped = true;
      isShooting = false;
      current = PlantState.hit;
      game.player.velocity.y = -_bounceHeight;
      await animationTicker?.completed;
      removeFromParent();
    } else {
      game.player.collidedwithEnemy();
    }
  }

  void reset() {
    gotStomped = false;
    isShooting = false;
    timeSinceLastShot = 0;
    position = startPosition.clone();
    current = PlantState.idle;
    animationTicker?.reset();
    // Restore orientation based on isLeft
    if (isRight && scale.x < 0) {
      flipHorizontallyAroundCenter();
    } else if (!isRight && scale.x > 0) {
      flipHorizontallyAroundCenter();
    }
  }
}

class Bullet extends SpriteComponent
    with HasGameReference<PixelRunner>, CollisionCallbacks {
  final Vector2 direction;
  static const double speed = 150.0;
  static const double lifetime = 5.0;
  double age = 0;

  Bullet({
    required super.position,
    required this.direction,
  }) : super(
          size: Vector2(8, 8),
          anchor: Anchor.center,
        );

  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache('Enemies/Plant/Bullet.png'));
    
    add(
      CircleHitbox(
        radius: 4,
        collisionType: CollisionType.passive,
      ),
    );
    
    return super.onLoad();
  }

  @override
  void update(double dt) {
    position += direction * speed * dt;
    age += dt;
    
    if (age >= lifetime) {
      removeFromParent();
    }
    
    super.update(dt);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      other.collidedwithEnemy();
      removeFromParent();
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}