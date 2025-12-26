import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:pixel_runner/Componenets/EntityComponents/Level.dart';
import 'package:pixel_runner/Componenets/EntityComponents/Player/Player.dart';
import 'package:pixel_runner/Componenets/IOcomponents/IOComponent.dart';
import 'package:pixel_runner/Componenets/UIcomponents/LevelSelection.dart';
import 'package:pixel_runner/Componenets/UIcomponents/MainMenuPage.dart';

enum GameState { menu, levelSelection, playing, thankYou }

class PixelRunner extends FlameGame with HasCollisionDetection {
  @override
  Color backgroundColor() => const Color(0xFF211F30);
  
  late Player player = Player(characterName: 'Ninja Frog');
  late Level currentLevel;
  late CameraComponent cam;
  late IOComponent ioComponent;
  
  List<String> levelNames = ['level_01', 'level_02', 'level_03'];
  List<String> characterNames = ['Ninja Frog', 'Mask Dude', 'Pink Man'];
  int currentLevelIndex = 0;
  int savedLevelIndex = 0; // For continue functionality

  bool playSound = true;
  double soundVolume = 1.0;
  GameState gameState = GameState.menu;

  @override
  FutureOr<void> onLoad() async {
    await _loadImages();
    await _loadSounds();
    FlameAudio.bgm.play('bgm.mp3', volume: 0.3);
    showMainMenu();
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

  void showMainMenu() {
    gameState = GameState.menu;
    _clearGame();
    add(MainMenuPage());
  }

  void startGame() {
    gameState = GameState.playing;
    currentLevelIndex = 0;
    savedLevelIndex = 0;
    _clearGame();
    player = Player(characterName: characterNames[currentLevelIndex]);
    _loadLevel();
    _loadCamera();
    _addControls();
  }

  void showLevelSelection() {
    gameState = GameState.levelSelection;
    _clearGame();
    add(LevelSelectionPage());
  }

  void startGameFromLevel(int levelIndex) {
    gameState = GameState.playing;
    currentLevelIndex = levelIndex;
    _clearGame();
    player = Player(characterName: characterNames[currentLevelIndex]);
    _loadLevel();
    _loadCamera();
    _addControls();
  }

  void continueGame() {
    if (savedLevelIndex > 0) {
      gameState = GameState.playing;
      currentLevelIndex = savedLevelIndex;
      _clearGame();
      player = Player(characterName: characterNames[currentLevelIndex]);
      _loadLevel();
      _loadCamera();
      _addControls();
    } else {
      // If no progress, just start new game
      startGame();
    }
  }

  void exitGame() {
    pauseEngine();
    SystemNavigator.pop();
  }

  void returnToMenu() {
    savedLevelIndex = currentLevelIndex;
    showMainMenu();
  }

  void _clearGame() {
    removeWhere((component) => 
      component is Level || 
      component is CameraComponent ||
      component is IOComponent ||
      component is MainMenuPage ||
      component is LevelSelectionPage
    );
  }

  void _addControls() {
    // Add IOComponent which contains joystick and jump button
    ioComponent = IOComponent();
    add(ioComponent);
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
    showMainMenu();
  }
}