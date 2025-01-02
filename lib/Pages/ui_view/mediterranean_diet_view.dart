import 'package:first_app/Pages/fitness_app_theme.dart';
import 'package:first_app/Services/progressFetcher.dart';
import 'package:first_app/main.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class MediterranesnDietView extends StatelessWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;
  final String titleTxt;

  const MediterranesnDietView(
      {super.key, this.animationController, this.animation, this.titleTxt = ''});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: ProgressFetcher.fetchUserProgress(), // Fetch the progress
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While waiting for the future to resolve, show a loading spinner
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // If there was an error, show an error message
          return Center(child: Text('Error fetching progress'));
        } else if (snapshot.hasData) {
          // If the future completed successfully, use the data
          double avgProgress = snapshot.data!;
          return buildContent(context, avgProgress);
        } else {
          // If the future returned null
          return Center(child: Text('No progress data available'));
        }
      },
    );
  }

  Widget buildContent(BuildContext context, double avgProgress) {
    // Get screen dimensions to make the UI responsive işte
    final Size screenSize = MediaQuery.of(context).size;
    
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - animation!.value), 0.0),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.06, // 6% of screen width
                vertical: screenSize.height * 0.02,  // 2% of screen height
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: FitnessAppTheme.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(screenSize.width * 0.02),
                    bottomLeft: Radius.circular(screenSize.width * 0.02),
                    bottomRight: Radius.circular(screenSize.width * 0.02),
                    topRight: Radius.circular(screenSize.width * 0.17),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: FitnessAppTheme.grey.withOpacity(0.2),
                      offset: const Offset(1.1, 1.1),
                      blurRadius: 10.0),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(screenSize.width * 0.04),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(screenSize.width * 0.02),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        height: screenSize.height * 0.06,
                                        width: 2,
                                        decoration: BoxDecoration(
                                          color: HexColor('#87A0E5').withOpacity(0.5),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(screenSize.width * 0.01)),
                                          ),
                                        ),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.all(screenSize.width * 0.02),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                'Your Overall Progress',
                                                style: TextStyle(
                                                  fontFamily: FitnessAppTheme.fontName,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: screenSize.width * 0.04,
                                                  letterSpacing: -0.1,
                                                  color: FitnessAppTheme.grey.withOpacity(0.5),
                                                ),
                                              ),
                                              Text(
                                                avgProgress == 0 || avgProgress.isNaN ? 
                                                  ' please start an exercise!' : 
                                                  ' keep going!',
                                                style: TextStyle(
                                                  fontFamily: FitnessAppTheme.fontName,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: screenSize.width * 0.035,
                                                  color: FitnessAppTheme.grey.withOpacity(0.5),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: screenSize.width * 0.04),
                            child: Center(
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(screenSize.width * 0.02),
                                    child: Container(
                                      width: screenSize.width * 0.25,
                                      height: screenSize.width * 0.25,
                                      decoration: BoxDecoration(
                                        color: FitnessAppTheme.white,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(screenSize.width * 0.25),
                                        ),
                                        border: Border.all(
                                          width: screenSize.width * 0.01,
                                          color: FitnessAppTheme.nearlyDarkBlue.withOpacity(0.2)
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            '%${(avgProgress.isNaN ? 0 : avgProgress).toStringAsFixed(2)}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: FitnessAppTheme.fontName,
                                              fontWeight: FontWeight.normal,
                                              fontSize: screenSize.width * 0.06,
                                              color: FitnessAppTheme.nearlyDarkBlue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(screenSize.width * 0.01),
                                    child: SizedBox(
                                      width: screenSize.width * 0.27,
                                      height: screenSize.width * 0.27,
                                      child: CustomPaint(
                                        painter: CurvePainter(
                                          colors: [
                                            FitnessAppTheme.nearlyDarkBlue,
                                            HexColor("#8A98E8"),
                                            HexColor("#8A98E8")
                                          ],
                                          angle: (avgProgress.isNaN ? 0 : avgProgress) * 360/100
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CurvePainter extends CustomPainter {
  final double? angle;
  final List<Color>? colors;

  CurvePainter({this.colors, this.angle = 140});

  @override
  void paint(Canvas canvas, Size size) {
    print("Angle value: ${angle}");
    List<Color> colorsList = [];
    if (colors != null) {
      colorsList = colors ?? [];
    } else {
      colorsList.addAll([Colors.white, Colors.white]);
    }

    final shdowPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    final shdowPaintCenter = Offset(size.width / 2, size.height / 2);
    final shdowPaintRadius =
        math.min(size.width / 2, size.height / 2) - (14 / 2);
    canvas.drawArc(
        Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.3);
    shdowPaint.strokeWidth = 16;
    canvas.drawArc(
        Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.2);
    shdowPaint.strokeWidth = 20;
    canvas.drawArc(
        Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.1);
    shdowPaint.strokeWidth = 22;
    canvas.drawArc(
        Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        shdowPaint);

    final rect = Rect.fromLTWH(0.0, 0.0, size.width, size.width);
    final gradient = SweepGradient(
      startAngle: degreeToRadians(268),
      endAngle: degreeToRadians(270.0 + 360),
      tileMode: TileMode.repeated,
      colors: colorsList,
    );
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeCap = StrokeCap.round // StrokeCap.round is not recommended.
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - (14 / 2);

    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        paint);

    const gradient1 = SweepGradient(
      tileMode: TileMode.repeated,
      colors: [Colors.white, Colors.white],
    );

    var cPaint = Paint();
    cPaint.shader = gradient1.createShader(rect);
    cPaint.color = Colors.white;
    cPaint.strokeWidth = 14 / 2;
    canvas.save();

    final centerToCircle = size.width / 2;
    canvas.save();

    canvas.translate(centerToCircle, centerToCircle);
    canvas.rotate(degreeToRadians(angle! + 2));

    canvas.save();
    canvas.translate(0.0, -centerToCircle + 14 / 2);
    canvas.drawCircle(const Offset(0, 0), 14 / 5, cPaint);

    canvas.restore();
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  double degreeToRadians(double degree) {
    var redian = (math.pi / 180) * degree;
    return redian;
  }
}