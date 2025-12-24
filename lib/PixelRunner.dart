import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/widgets.dart';
import 'package:pixel_runner/Componenets/EntityComponents/Level.dart';
import 'package:pixel_runner/Componenets/EntityComponents/Player.dart';
import 'package:pixel_runner/Componenets/IOcomponents/JumpButton.dart';

class PixelRunner extends FlameGame with HasCollisionDetection {
  @override
  Color backgroundColor() => const Color(0xFF211F30);
  late Player player = Player(characterName: 'Ninja Frog');
  late Level currentLevel;

  late CameraComponent cam;
  late JoystickComponent joystick;
  late JumpButton jumpButton;
  List<String> levelNames = ['level_01','level_02'];
  List<String> characterNames = ['Ninja Frog','Mask Dude'];
  int currentLevelIndex = 0;

  bool playSound = true;
  double soundVolume = 1.0;

  @override
  FutureOr<void> onLoad() async {
    await _loadImages();
    await _loadSounds();
    _loadLevel();
    _loadCamera();
    _addJumpButton();
    _addJoystick();
    FlameAudio.bgm.play('bgm.mp3');
    return super.onLoad();
  }

  void _addJoystick() {
    joystick = JoystickComponent(
      background: SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/Joystick.png')),
      ),
      knob: SpriteComponent(sprite: Sprite(images.fromCache('HUD/Knob.png'))),
      knobRadius: 20,
      margin: const EdgeInsets.only(left: 5, bottom: 32),
    );
    add(joystick);
  }

  void _addJumpButton() {
    jumpButton = JumpButton();
    add(jumpButton);
  }

  Future<void> _loadImages() async {
    await images.loadAllImages();
  }

  Future<void> _loadSounds() async {
    await FlameAudio.audioCache.loadAll([
      'disappear.wav',
      'bgm.mp3'
    ]);
  }

  void _loadLevel() {
    removeWhere((component) => component is Level);
    currentLevel = Level(
      levelName: levelNames[currentLevelIndex],
    );    
    add(currentLevel);
  }

  void _loadCamera(){
    cam = CameraComponent.withFixedResolution(
      world: currentLevel,
      width: 640,
      height: 360,
    );
    cam.viewfinder.anchor = Anchor.topLeft;
    add(cam);
  }

  void loadNextLevel() {
    if (currentLevelIndex < levelNames.length - 1) {
      currentLevelIndex++;
    } else {
      currentLevelIndex = 0;
    }
    player = Player(characterName: characterNames[currentLevelIndex]);
    _loadLevel();
    _loadCamera();
  }
}
