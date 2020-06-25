import 'package:flutter/foundation.dart';
import 'package:fluttertimeline/ablums/pic_entity.dart';
import 'package:tuple/tuple.dart';
import 'package:intl/intl.dart';

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
        String date = format.format(DateTime.fromMillisecondsSinceEpoch(timeStamp));
        return Tuple2<bool, String>(true, date);
      }
    }

    return Tuple2<bool, String>(false, null);
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
    final dtOfEntity = DateTime.fromMillisecondsSinceEpoch(entity.timeStamp);

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
