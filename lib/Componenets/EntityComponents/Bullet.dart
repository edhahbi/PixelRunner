import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_runner/Componenets/EntityComponents/Player.dart';
import 'package:pixel_runner/PixelRunner.dart';

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
