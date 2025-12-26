import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/cupertino.dart';
import 'package:pixel_runner/Componenets/EntityComponents/Checkpoint.dart';
import 'package:pixel_runner/Componenets/EntityComponents/Chicken.dart';
import 'package:pixel_runner/Componenets/EntityComponents/CollisionBlock.dart';
import 'package:pixel_runner/Componenets/EntityComponents/Fruit.dart';
import 'package:pixel_runner/Componenets/EntityComponents/Plant.dart';
import 'package:pixel_runner/Componenets/EntityComponents/Rino.dart';
import 'package:pixel_runner/Componenets/ConstVars.dart';
import 'package:pixel_runner/Componenets/EntityComponents/Saw.dart';
import 'package:pixel_runner/PixelRunner.dart';
import 'package:flame/parallax.dart';

class Level extends World with HasGameReference<PixelRunner> {
  late String levelName;

  late TiledComponent level;
  List<CollisionBlock> collisionBlocks = [];
  late int collectedFruits = 0;
  late int fruits = 0;
  
  // Store fruit spawn data for respawning
  List<Fruit> fruitSpawnData = [];
  List<Chicken> chickenSpawnData = []; 
  List<Rino> rinoSpawnData = [];
  List<Plant> plantSpawnData = [];
  // Reference to checkpoint for resetting
  Checkpoint? checkpoint;

  Level({required this.levelName});

  @override
  FutureOr<void> onLoad() async {
    //debugMode = true;
    //creating the level
    await _loadLevel();

    //spawning objects: player, enemies, collectables
    _loadSpawnObjects();
    //spawning collisionblocks
    _loadCollisions();

    _scrollingBackground();

    return super.onLoad();
  }

  FutureOr<void> _loadLevel() async {
    level = await TiledComponent.load("$levelName.tmx", Vector2.all(16));
    add(level);
  }

  void _loadSpawnObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>("SpawnPoints");

    for (final spawnPoint in spawnPointsLayer!.objects) {
      switch (spawnPoint.class_) {
        case 'Player':
          game.player.position = Vector2(spawnPoint.x, spawnPoint.y);
          add(game.player);
          break;
        case 'Fruit':
          
          final fruit = Fruit(
            fruit: spawnPoint.name,
            position: Vector2(spawnPoint.x, spawnPoint.y),
            size: Vector2(spawnPoint.width, spawnPoint.height),
          );
          // Store fruit spawn data for respawning
          fruitSpawnData.add(fruit);
          fruits++;
          add(fruit);
          break;
        case 'Saw':
          final saw = Saw(
            position: Vector2(spawnPoint.x, spawnPoint.y),
            size: Vector2(spawnPoint.width, spawnPoint.height),
            isVertical: spawnPoint.properties.getValue('isVertical'),
            offNeg: spawnPoint.properties.getValue('offNeg'),
            offPos: spawnPoint.properties.getValue('offPos'),
          );
          add(saw);
          break;
        case 'Chicken':
          final chicken = Chicken(
            position: Vector2(spawnPoint.x, spawnPoint.y),
            size: Vector2(spawnPoint.width, spawnPoint.height),
            offNeg: spawnPoint.properties.getValue('offNeg'),
            offPos: spawnPoint.properties.getValue('offPos')
          );
          add(chicken);
          chickenSpawnData.add(chicken);
          break;
        case 'Rino':
          final rino = Rino(
            position: Vector2(spawnPoint.x, spawnPoint.y),
            size: Vector2(spawnPoint.width, spawnPoint.height),
            offNeg: spawnPoint.properties.getValue('offNeg'),
            offPos: spawnPoint.properties.getValue('offPos')
          );
          add(rino);
          rinoSpawnData.add(rino);
          break;
        case 'Plant':
          final plant = Plant(
            position: Vector2(spawnPoint.x, spawnPoint.y),
            size: Vector2(spawnPoint.width, spawnPoint.height),
            isRight: spawnPoint.properties.getValue('isRight'),
          );
          add(plant);
          plantSpawnData.add(plant);
          break;
        case 'Checkpoint':
          checkpoint = Checkpoint(
            position: Vector2(spawnPoint.x, spawnPoint.y),
            size: Vector2(spawnPoint.width, spawnPoint.height),
          );
          add(checkpoint!);
          break;
      }
      
    }
    // Normalize total fruits count based on saved spawn data
    fruits = fruitSpawnData.length;
  }

  void _loadCollisions() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>("Collisions");

    for (final collision in collisionsLayer!.objects) {
      switch (collision.class_) {
        case 'Platform':
          final platform = CollisionBlock(
            position: Vector2(collision.x, collision.y),
            size: Vector2(collision.width, collision.height),
            isPlatform: true,
          );
          add(platform);
          collisionBlocks.add(platform);
          break;
        default:
          final block = CollisionBlock(
            position: Vector2(collision.x, collision.y),
            size: Vector2(collision.width, collision.height),
          );
          add(block);
          collisionBlocks.add(block);
      }
    }
  }

  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer('Background');
    if (backgroundLayer != null) {
      final backgroundColor = backgroundLayer.properties.getValue(
        'backgroundColor',
      );

      final background = ParallaxComponent(
        priority: backgroundPriority,
        parallax: Parallax([
          ParallaxLayer(
            ParallaxImage(
              game.images.fromCache('Background/$backgroundColor.png'),
              repeat: ImageRepeat.repeat,
              fill: LayerFill.none,
            ),
          ),
        ], baseVelocity: Vector2(0, -50)),
      );
      add(background);
    }
  }

  bool collectedAllFruits(){
    return collectedFruits == fruits;
  }
  
  // Respawn all fruits at their original positions

  void respawnFruit(){
    // Reset collected fruits counter
    collectedFruits = 0;
    // Normalize total fruits count (safety in case of mismatches)
    fruits = fruitSpawnData.length;
    // Respawn all fruits from saved spawn data
    for (final fruit in fruitSpawnData) {
      if(fruit.parent == null){
        fruit.reset();
        add(fruit);
      }
    }
  }

  void respawnChicken(){
    for(final chicken in chickenSpawnData) {
      chicken.removeFromParent();
      chicken.reset();
      add(chicken);
    }
  }

  void respawnRino(){
    for(final rino in rinoSpawnData){
      if(rino.parent == null){
        rino.reset();
        add(rino);
      }
    }
  }

  void respawnPlant(){
    for(final plant in plantSpawnData){
      if(plant.parent == null){
        plant.reset();
        add(plant);
      }
    }
  }

  void resetCheckPoint(){
    checkpoint?.resetCheckpoint();
  }

  void respawnAll() {
    respawnFruit();  
    respawnChicken();
    respawnRino();
    respawnPlant();
    resetCheckPoint();
  }
}
