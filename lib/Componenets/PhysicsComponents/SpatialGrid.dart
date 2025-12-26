import 'dart:math';
import 'dart:ui';

import 'package:pixel_runner/Componenets/EntityComponents/PlatformingElements/CollisionBlock.dart';

class SpatialGrid {
  final double cellSize;
  final Map<Point<int>, List<CollisionBlock>> _cells = {};

  SpatialGrid({required this.cellSize});

  void clear() => _cells.clear();

  void insert(CollisionBlock block) {
    final int x0 = (block.x / cellSize).floor();
    final int y0 = (block.y / cellSize).floor();
    final int x1 = ((block.x + block.width) / cellSize).floor();
    final int y1 = ((block.y + block.height) / cellSize).floor();

    for (int gx = x0; gx <= x1; gx++) {
      for (int gy = y0; gy <= y1; gy++) {
        final key = Point<int>(gx, gy);
        final list = _cells.putIfAbsent(key, () => <CollisionBlock>[]);
        list.add(block);
      }
    }
  }

  void buildFromBlocks(List<CollisionBlock> blocks) {
    clear();
    for (final b in blocks) {
      insert(b);
    }
  }

  Iterable<CollisionBlock> queryAabb(Rect aabb) {
    final int x0 = (aabb.left / cellSize).floor();
    final int y0 = (aabb.top / cellSize).floor();
    final int x1 = (aabb.right / cellSize).floor();
    final int y1 = (aabb.bottom / cellSize).floor();

    final Set<CollisionBlock> results = <CollisionBlock>{};
    for (int gx = x0; gx <= x1; gx++) {
      for (int gy = y0; gy <= y1; gy++) {
        final key = Point<int>(gx, gy);
        final list = _cells[key];
        if (list != null) {
          results.addAll(list);
        }
      }
    }
    return results;
  }
}