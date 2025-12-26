import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:pixel_runner/Componenets/EntityComponents/Level.dart';
import 'package:pixel_runner/Componenets/EntityComponents/Player.dart';
import 'package:pixel_runner/Componenets/IOcomponents/JumpButton.dart';
import 'package:pixel_runner/Componenets/UIcomponents/ThankYouPage.dart';
import 'package:pixel_runner/Componenets/UIcomponents/MainMenuPage.dart';

enum GameState { menu, playing, thankYou }

class PixelRunner extends FlameGame with HasCollisionDetection {
  @override
  Color backgroundColor() => const Color(0xFF211F30);
  
  late Player player = Player(characterName: 'Ninja Frog');
  late Level currentLevel;
  late CameraComponent cam;
  late JoystickComponent joystick;
  late JumpButton jumpButton;
  
  List<String> levelNames = ['level_01', 'level_02', 'level_03'];
  List<String> characterNames = ['Ninja Frog', 'Mask Dude', 'Pink Man'];
  int currentLevelIndex = 0;

  bool playSound = true;
  double soundVolume = 1.0;
  GameState gameState = GameState.menu;

  @override
  FutureOr<void> onLoad() async {
    await _loadImages();
    await _loadSounds();
    FlameAudio.bgm.play('bgm.mp3', volume: 0.3);
    _showMainMenu();
    return super.onLoad();
  }

  Future<void> _loadImages() async {
    await images.loadAllImages();
  }

  Future<void> _loadSounds() async {
    await FlameAudio.audioCache.loadAll([
      'jump.wav',
      'collect_fruit.wav',
      'hit.wav',
      'disappear.wav',
      'bounce.wav',
      'bgm.mp3'
    ]);
  }

  void _showMainMenu() {
    gameState = GameState.menu;
    _clearGame();
    add(MainMenuPage());
  }

  void startGame() {
    gameState = GameState.playing;
    currentLevelIndex = 0;
    _clearGame();
    player = Player(characterName: characterNames[currentLevelIndex]);
    _loadLevel();
    _loadCamera();
    _addJumpButton();
    _addJoystick();
  }

  void exitGame() {
    pauseEngine();
    SystemNavigator.pop();
  }

  void returnToMenu() {
    _showMainMenu();
  }

  void _clearGame() {
    removeWhere((component) => 
      component is Level || 
      component is CameraComponent ||
      component is JoystickComponent ||
      component is JumpButton ||
      component is MainMenuPage ||
      component is ThankYouPage
    );
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

  void _loadLevel() {
    removeWhere((component) => component is Level);
    currentLevel = Level(
      levelName: levelNames[currentLevelIndex],
    );
    add(currentLevel);
  }

  void _loadCamera() {
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
      player = Player(characterName: characterNames[currentLevelIndex]);
      _loadLevel();
      _loadCamera();
    } else {
      gameState = GameState.thankYou;
      _clearGame();
      add(ThankYouPage());
    }
  }
}