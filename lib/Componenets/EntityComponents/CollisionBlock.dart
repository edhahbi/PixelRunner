import 'package:flame/components.dart';

class CollisionBlock extends PositionComponent {
  bool isPlatform;
  bool isWall;
  CollisionBlock({
    required Vector2 position,
    required Vector2 size,
    this.isPlatform = false,
    this.isWall = false,
  }) : super(position: position, size: size);
  
}
