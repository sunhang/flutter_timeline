import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertimeline/ablums/ablums_model.dart';

const COLUMN_COUNT = 3;
const TIMELINE_WIDTH_FLEX = 2;
const IMAGE_WIDTH_FLEX = 3;
const DOT_COUNT = 8;

/// 用时间线展示相册图片
class TimelineAblums extends StatelessWidget {
  final AblumsList ablumsList;

  TimelineAblums({this.ablumsList});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: ablumsList.visualSize ~/ COLUMN_COUNT,
        itemBuilder: (context, index) {
          final tuple = ablumsList.isHeaderOfDay(index * COLUMN_COUNT);
          final isTimelineHeader = tuple.item1;
          final strDate = tuple.item2;

          final timelineWidget = _TimelineWidget(
            child: isTimelineHeader
                ? _TimelineHeader(strDate)
                : _TimelineDot(dotCount: DOT_COUNT),
          );

          final row = Row(
            children: <Widget>[
              Expanded(
                flex: TIMELINE_WIDTH_FLEX,
                child: timelineWidget,
              ),
              Expanded(
                flex: IMAGE_WIDTH_FLEX,
                child: _Card(ablumsList[index * COLUMN_COUNT]),
              ),
              Expanded(
                flex: IMAGE_WIDTH_FLEX,
                child: _Card(ablumsList[index * COLUMN_COUNT + 1]),
              ),
              Expanded(
                flex: IMAGE_WIDTH_FLEX,
                child: _Card(ablumsList[index * COLUMN_COUNT + 2]),
              ),
            ],
          );

          final topPadding = isTimelineHeader && index != 0 ? 16.0 : 0.0;
          return Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: row,
          );
        });
  }
}

/// 每一个图片
class _Card extends StatelessWidget {
  final PicEntity _picEntity;

  _Card(PicEntity picEntity) : _picEntity = picEntity;

  @override
  Widget build(BuildContext context) {
    if (_picEntity == null) {
      return SizedBox.shrink();
    }

    if (_picEntity == PicEntity.blank) {
      return SizedBox.shrink();
    }

    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: FutureBuilder(
          future: _picEntity.assetEntity.file,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return SizedBox.shrink();
            }

            return Image.file(
              snapshot.data,
              fit: BoxFit.cover,
            );
          },
        ),
      ),
    );
  }
}

/// 显示日期和很多小圆点
class _TimelineWidget extends StatelessWidget {
  final Widget child;

  _TimelineWidget({this.child});

  @protected
  double computeHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth *
        IMAGE_WIDTH_FLEX /
        (TIMELINE_WIDTH_FLEX + IMAGE_WIDTH_FLEX * 3);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: computeHeight(context),
      child: child,
    );
  }
}

/// 显示日期
class _TimelineHeader extends StatelessWidget {
  final String strDate;

  _TimelineHeader(this.strDate);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.center,
            child: Text(
              strDate,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: _TimelineDot(
            dotCount: DOT_COUNT ~/ 2,
          ),
        )
      ],
    );
  }
}

/// 显示小圆点
class _TimelineDot extends StatelessWidget {
  final int dotCount;

  _TimelineDot({this.dotCount});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DotPainter(dotCount: dotCount),
    );
  }
}

class _DotPainter extends CustomPainter {
  final int dotCount;

  _DotPainter({this.dotCount});

  /// 绘制多个圆点
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = Colors.blue;

    final rect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);

    final circleRadius = rect.height / dotCount / 2 / 2;
    var offset = Offset(rect.width / 2, circleRadius * 2);
    for (var i = 0; i < dotCount; i++) {
      canvas.drawCircle(offset, circleRadius, paint);
      offset = offset.translate(0, circleRadius * 4);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
