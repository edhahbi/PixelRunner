import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pixel_runner/Componenets/PhysicsComponents/CustomHitBox.dart';
import 'package:pixel_runner/PixelRunner.dart';

class Fruit extends SpriteAnimationComponent
    with HasGameReference<PixelRunner>{
  final String fruit;
  final double stepTime = 0.05;
  bool collected = false;

  Fruit({
    this.fruit = 'Apple',
    position,
    size,
  }) : super(
          position: position,
          size: size,
        );

  final hitbox = CustomHitbox(
    offsetX: 10,
    offsetY: 10,
    width: 12,
    height: 12,
  );
  

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    _loadHitBox();
    _loadAnimation();
    return super.onLoad();
  }

  void _loadAnimation(){
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Items/Fruits/$fruit.png'),
      SpriteAnimationData.sequenced(
        amount: 17,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }

  void _loadHitBox(){
    add(
      RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
        collisionType: CollisionType.passive,
      ),
    );
  }
  void collidedWithPlayer() async {
    if (!collected) {
      collected = true; // Set immediately to prevent multiple calls
      game.currentLevel.collectedFruits++;
      FlameAudio.play('collect_fruit.wav', volume: game.soundVolume);
      
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Items/Fruits/Collected.png'),
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: stepTime,
          textureSize: Vector2.all(32),
          loop: false,
        ),
      );

      await animationTicker?.completed;
      removeFromParent();
    }
  }

  void reset(){
    collected = false;
    _loadAnimation();
    animationTicker?.reset();
  }
}