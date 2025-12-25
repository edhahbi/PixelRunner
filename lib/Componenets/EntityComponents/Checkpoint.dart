import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_runner/Componenets/EntityComponents/Player.dart';
import 'package:pixel_runner/PixelRunner.dart';

class Checkpoint extends SpriteAnimationComponent
    with HasGameReference<PixelRunner>, CollisionCallbacks {
  bool hasBeenReached = false;
  
  Checkpoint({
    position,
    size,
  }) : super(
          position: position,
          size: size,
        );

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    _loadAnimation(1, "No Flag", 1);
    _loadHitBox();
    return super.onLoad();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!hasBeenReached && other is Player && game.currentLevel.collectedAllFruits()) {
      hasBeenReached = true;
      _reachedCheckpoint();
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void _loadAnimation(int amount, String state, double stepTime,[bool loop = true]){
    animation = SpriteAnimation.fromFrameData(
      game.images
          .fromCache('Items/Checkpoints/Checkpoint/Checkpoint ($state) (64x64).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(64),
        loop: loop
      ),
    );
  }

  void _loadHitBox(){
    add(RectangleHitbox(
      position: Vector2(18, 56),
      size: Vector2(12, 8),
      collisionType: CollisionType.passive,
    ));
  }
  
  void _reachedCheckpoint() async{
    _loadAnimation(26, "Flag Out", 0.05,false);
    await animationTicker?.completed;
    _loadAnimation(10, "Flag Idle", 0.05);
  }
  
  // Reset checkpoint to initial state after player respawn
  void resetCheckpoint() {
    hasBeenReached = false;
    _loadAnimation(1, "No Flag", 1);
  }
}