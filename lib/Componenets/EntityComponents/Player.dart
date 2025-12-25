import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pixel_runner/Componenets/EntityComponents/Checkpoint.dart';
import 'package:pixel_runner/Componenets/EntityComponents/CollisionBlock.dart';
import 'package:pixel_runner/Componenets/EntityComponents/Fruit.dart';
import 'package:pixel_runner/Componenets/EntityComponents/Saw.dart';
import 'package:pixel_runner/Componenets/PhysicsComponents/CustomHitBox.dart';
import 'package:pixel_runner/Componenets/ConstVars.dart';
import 'package:pixel_runner/Componenets/PhysicsComponents/CollisionDetection.dart';
import 'package:pixel_runner/PixelRunner.dart';



enum PlayerState { idle, running, jumping, falling, hit, appearing, desappearing}

class Player extends SpriteAnimationGroupComponent
    with HasGameReference<PixelRunner>, CollisionCallbacks {
  String characterName;

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation appearingAnimation;
  late final SpriteAnimation desappearingAnimation;


  Vector2 velocity = Vector2.zero();
  late final Vector2 startPosition;
  double horizontalMovement = 0;

  final double stepTime = 0.05;
  final double moveSpeed = 100;
  final double gravity = 9.8;
  final double jumpForce = 250;
  final double terminalVelocity = 400;
  
  bool isOnGround = true;
  bool hasJumped = false;
  bool gotHit = false;
  bool reachedCheckpoint = false;

  final double fixedDelta = 1/60;
  double accumulatedTime = 0;

  final hitbox = CustomHitbox(
    offsetX: 10,
    offsetY: 4,
    width: 14,
    height: 28);
  List<CollisionBlock> collisionBlocks = [];

  
  Player({this.characterName = "Mask Dude", position})
    : super(position: position, priority: entityPriority);

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    startPosition = Vector2(position.x,position.y);
    _loadAllAnimations();
    _loadHitBox();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    accumulatedTime+= dt;
    while(accumulatedTime >= fixedDelta){
      if(!gotHit && !reachedCheckpoint){
        _updatePlayerState();
        _updatePlayerMovement(fixedDelta);
        _checkHorizontalCollisions();
        _applyGravity(fixedDelta);
        _checkVerticalCollision();
      }
      accumulatedTime -= fixedDelta;
    }
    print('${game.currentLevel.collectedFruits}');
    super.update(dt);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!reachedCheckpoint) {
      if (other is Fruit) {
        other.collidedWithPlayer();
      } else if (other is Saw) {
        _respawn();
      } else if (other is Checkpoint && game.currentLevel.collectedAllFruits()) {
        _reachedCheckpoint();
      }
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void _loadAllAnimations() {
    idleAnimation = _loadSpriteAnimation(11, "Idle");
    runningAnimation = _loadSpriteAnimation(12, "Run");
    fallingAnimation = _loadSpriteAnimation(1, "Fall");
    jumpingAnimation = _loadSpriteAnimation(1, "Jump");
    hitAnimation = _loadSpriteAnimation(7,"Hit")..loop=false;
    appearingAnimation = _loadSpecialSpriteAnimation(7, "Appearing")..loop=false;
    desappearingAnimation = _loadSpecialSpriteAnimation(7, "Desappearing")..loop=false;

    //mapping player state to certain animation
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.appearing: appearingAnimation, 
      PlayerState.desappearing: desappearingAnimation
    };

    //setting the current animations
    //current => current player state
    current = PlayerState.idle;
  }

  void _loadHitBox(){
    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height)
    ));
  }

  SpriteAnimation _loadSpriteAnimation(int amount, String state) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache(
        "Main Characters/$characterName/$state (32x32).png",
      ),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32))
    );
  }

  SpriteAnimation _loadSpecialSpriteAnimation(int amount, String state){
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$state (96x96).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(96),
      ),
    );
  }

  void _handleMovement() {
    switch (game.joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        horizontalMovement = 1;
        break;
      default:
        horizontalMovement = 0;
    }

  }

  void _updatePlayerState() {
    PlayerState state = PlayerState.idle;

    //moving right and facing left or moving left and facing right
    if ((velocity.x > 0 && scale.x < 0) || (velocity.x < 0 && scale.x > 0)) {
      flipHorizontallyAroundCenter();
    }
    // player is running
    if (velocity.x != 0) {
      state = PlayerState.running;
    }

    //player is falling
    if (velocity.y > 0) {
      state = PlayerState.falling;
    } else if (velocity.y < 0) {
      //player is jumping 
      state = PlayerState.jumping;
    }

    current = state;
  }
  void _updatePlayerMovement(double dt) {
    _handleMovement();

    if (hasJumped && isOnGround) {
      _playerJump(dt);
    }

    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      //handeling collisions
      if (checkCollision(this, block) && !block.isPlatform
      ) {
        if (velocity.x > 0) {
          velocity.x = 0;
          position.x = block.x - hitbox.offsetX - hitbox.width;
        } else if (velocity.x < 0) {
          velocity.x = 0;
          position.x = block.x + block.width + hitbox.offsetX + hitbox.width;
        }
        break;
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += gravity;
    velocity.y = velocity.y.clamp(-jumpForce, terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollision() {
    for (final block in collisionBlocks) {
      //if there is a collision
      if (checkCollision(this, block)) {
        //treat it the blocks the same way when falling
        if (velocity.y > 0) {
          velocity.y = 0;
          position.y = block.y - hitbox.offsetY - hitbox.height;
          isOnGround = true;
        }
        //add the handeling of normal blocks
        else if (!block.isPlatform) {
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
          }
        }
        break;
      }
    }
  }

  void _playerJump(double dt) {
    FlameAudio.play('jump.wav');
    velocity.y = -jumpForce;
    position.y += velocity.y * dt;
    hasJumped = false;
    isOnGround = false;
  }
  
  void _respawn() async{
    FlameAudio.play('hit.wav');
    gotHit = true;
    if (game.playSound) {
      FlameAudio.play('hit.wav', volume: game.soundVolume);
    }
    current = PlayerState.hit;

    await animationTicker?.completed;
    animationTicker?.reset();

    // Respawn all fruits and reset score
    game.currentLevel.respawnAllFruits();

    scale.x = 1;
    position = startPosition - Vector2.all(32);
    velocity = Vector2.all(0);

    current = PlayerState.appearing;

    await animationTicker?.completed;
    animationTicker?.reset();
    
    position = startPosition;
    gotHit = false;
    
  }
  
  void _reachedCheckpoint() async{
    reachedCheckpoint = true; 
    if (game.playSound) {
      FlameAudio.play('disappear.wav', volume: game.soundVolume);
    }

    if(scale.x > 0){
      position = position - Vector2.all(32);
    }else{
      position = position + Vector2(32,-32);
    }

    current = PlayerState.desappearing;
    
    await animationTicker?.completed;
    animationTicker?.reset();

    reachedCheckpoint = false;
    position = Vector2.all(-640);

    const waitToChange = Duration(seconds: 1);
    velocity = Vector2.all(0);
    Future.delayed(waitToChange,() => game.loadNextLevel());
  }
}
