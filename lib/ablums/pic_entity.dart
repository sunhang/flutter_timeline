import 'package:fluttertimeline/ablums/timeline_ablums.dart';
import 'package:photo_manager/photo_manager.dart';

class PicEntity {
  final AssetEntity assetEntity;
  int get timeStamp => assetEntity.modifiedDateSecond;

  const PicEntity(this.assetEntity);

  static const blank = PicEntity(null);
}

class OneDay {
  List<PicEntity> _base;

  final int realStart;
  final int realLength;

  int visualStartIndex;

  OneDay(
      {this.realStart,
      this.realLength,
      this.visualStartIndex,
      List<PicEntity> baseList})
      : _base = baseList;

  int get visualLength {
    final count = realLength;
    return ((count + COLUMN_COUNT - 1) ~/ COLUMN_COUNT) * COLUMN_COUNT;
  }

  bool hit(int index) {
    return index >= visualStartIndex && index < visualStartIndex + visualLength;
  }

  bool isFirstOfDay(int index) {
    return index == visualStartIndex;
  }

  PicEntity getEntity(int index) {
    if (!hit(index)) {
      return null;
    }

    if (index - visualStartIndex >= realLength) {
      return PicEntity.blank;
    } else {
      final realIndex = realStart + (index - visualStartIndex);
      return _base[realIndex];
    }
  }
}
