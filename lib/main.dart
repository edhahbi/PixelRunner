import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:pixel_runner/PixelRunner.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();
  
  PixelRunner game = PixelRunner();
  Future.delayed((Duration(microseconds: 850)),()=> runApp(
    GameWidget(game: game),
  ));

}
