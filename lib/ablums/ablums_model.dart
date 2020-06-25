import 'package:tuple/tuple.dart';
import 'package:intl/intl.dart';
import 'package:fluttertimeline/ablums/ablums_widgets.dart';
import 'package:photo_manager/photo_manager.dart';

class AblumsList {
  List<OneDay> oneDays;
  int visualSize;

  AblumsList(this.oneDays, this.visualSize);

  PicEntity operator [](int index) {
    for (var oneDay in oneDays) {
      if (oneDay.hit(index)) {
        return oneDay.getEntity(index);
      }
    }

    return null;
  }

  Tuple2<bool, String> isHeaderOfDay(int index) {
    var format = new DateFormat('yy-MM-dd');

    for (var oneDay in oneDays) {
      if (oneDay.hit(index)) {
        bool b = oneDay.isFirstOfDay(index);
        if (!b) {
          break;
        }

        final timeStamp = oneDay.getEntity(index).timeStamp;
        String date = format.format(DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000));
        return Tuple2<bool, String>(true, date);
      }
    }

    return Tuple2<bool, String>(false, null);
  }
}

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

AblumsList buildAblumsList(List<PicEntity> list) {
  final onedayRanges = _buildOneDayRanges(list);

  final List<OneDay> oneDays = [];
  var offset = 0;
  for (var oneDayRange in onedayRanges) {
    OneDay temp = OneDay(
        realStart: oneDayRange._realStart,
        realLength: oneDayRange._realLength,
        visualStartIndex: offset,
        baseList: list);
    oneDays.add(temp);

    offset += temp.visualLength;
  }

  final visualSize = offset;
  final wrapper = AblumsList(oneDays, visualSize);
  return wrapper;
}

class _OneDayRange {
  final int _realStart;
  final int _realLength;

  _OneDayRange({int realStart, int realLength})
      : _realStart = realStart,
        _realLength = realLength;
}

List<_OneDayRange> _buildOneDayRanges(List<PicEntity> list) {
  var startDt = DateTime.fromMillisecondsSinceEpoch(0);

  var realStart = -1;
  var realLength = -1;

  List<_OneDayRange> oneDayRanges = [];

  for (var i = 0; i < list.length; i++) {
    final entity = list[i];
    final dtOfEntity = DateTime.fromMillisecondsSinceEpoch(entity.timeStamp * 1000);

    if (startDt.year == dtOfEntity.year &&
        startDt.month == dtOfEntity.month &&
        startDt.day == dtOfEntity.day) {
      realLength++;
    } else {
      if (realStart != -1) {
        final oneDayRange =
            _OneDayRange(realStart: realStart, realLength: realLength);
        oneDayRanges.add(oneDayRange);
      }

      startDt = dtOfEntity;
      realStart = i;
      realLength = 1;
    }
  }

  if (realStart != -1) {
    final oneDayRange =
        _OneDayRange(realStart: realStart, realLength: realLength);
    oneDayRanges.add(oneDayRange);
  }

  return oneDayRanges;
}
