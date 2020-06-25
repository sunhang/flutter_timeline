import 'dart:core';
import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';
import 'ablums_model.dart';

AblumsList _ablumsList;

Future<AblumsList> data() async {
  if (_ablumsList == null) {
    List<AssetPathEntity> assetPathEntities =
        await PhotoManager.getAssetPathList();
    List<AssetEntity> assetEntities = await _assetEntities(assetPathEntities);
    _ablumsList = await compute(_getAblumsList, assetEntities);
  }

  return _ablumsList;
}

AblumsList _getAblumsList(List<AssetEntity> assetEntities) {
  List<PicEntity> list = [];
  for (var e in assetEntities) {
    list.add(PicEntity(e));
  }

  return buildAblumsList(list);
}

Future<List<AssetEntity>> _assetEntities(
    List<AssetPathEntity> assetPathEntities) async {
  List<AssetEntity> assetEntities = [];
  for (AssetPathEntity entity in assetPathEntities) {
    if (entity.name == "Screenshots" || entity.name == "DCIM") {
      List<AssetEntity> subList = await entity.getAssetListPaged(0, 100);
      assetEntities.addAll(subList);
    }
  }

  return assetEntities;
}

/*
/// 制造假数据
void _initPics(SendPort sendPort) {
  final url =
      "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1554110093883&di=9db9b92f1e6ee0396b574a093cc987d6&imgtype=0&src=http%3A%2F%2Fn.sinaimg.cn%2Fsinacn20%2F151%2Fw2048h1303%2F20180429%2F37c0-fzvpatr1915813.jpg";
  var milliseconds =
      DateTime.parse("2010-01-00 00:00:00").millisecondsSinceEpoch;

  List<PicEntity> list = <PicEntity>[];

  for (var i = 0; i < 100; i++) {
    PicEntity entity = PicEntity(url: url, timeStamp: milliseconds);
    list.add(entity);

    // 3小时以上
    milliseconds += (60 * 60 * 1000 * (3 + Random().nextDouble())).toInt();
  }

  sendPort.send(list);
}
 */
