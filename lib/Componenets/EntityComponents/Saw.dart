import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_runner/Componenets/ConstVars.dart';
import 'package:pixel_runner/PixelRunner.dart';

class Saw extends SpriteAnimationComponent
    with HasGameReference<PixelRunner>{
      final bool isVertical; 
      final double offNeg,offPos;
      final double stepTime = 0.03;
      final double moveSpeed = 50;
      double moveDirection = 1;
      double rangeNeg = 0;
      double rangePos = 0;

  Saw({
    position,
    size,
    required this.isVertical,
    required this.offNeg, 
    required this.offPos
  }) : super(
          position: position,
          size: size,
          priority: entityPriority
        );

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    _handleDirection();
    _loadHitBox();
    _loadAnimation();

    return super.onLoad();
  }

  void _loadAnimation(){
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Saw/On (38x38).png'),
      SpriteAnimationData.sequenced(
        amount: 8,
        stepTime: stepTime,
        textureSize: Vector2.all(38),
      ),
    );
  }

  void _loadHitBox(){
    add(CircleHitbox(
      collisionType: CollisionType.passive
    ));
  }

  void _handleDirection(){
    if(isVertical){
      rangeNeg = position.y - offNeg * tileSize;
      rangePos = position.y + offPos * tileSize;
    }else{
      rangeNeg = position.x - offNeg * tileSize;
      rangePos = position.x + offPos * tileSize;
    }
  }

  @override
  void update(double dt) {
    isVertical? _moveVertical(dt):_moveHorizontal(dt);
    super.update(dt);
  }
  
  void _moveVertical(double dt){
    if(position.y <= rangeNeg || position.y >= rangePos){
      moveDirection = -moveDirection;
    }
    position.y += moveDirection * moveSpeed * dt;
    
  }

  void _moveHorizontal(double dt){
    if(position.x >= rangePos || position.x <= rangeNeg){
      moveDirection = -moveDirection;
    }
    position.x += moveDirection * moveSpeed * dt; 
  
  }
}