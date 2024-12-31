import 'package:first_app/Pages/fitness_app_theme.dart';
import 'package:first_app/main.dart';
import 'package:first_app/models/meals_list_data.dart';
import 'package:flutter/material.dart';


class MealsListView extends StatefulWidget {
  const MealsListView(
      {super.key, this.mainScreenAnimationController, this.mainScreenAnimation});

  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;

  @override
  _MealsListViewState createState() => _MealsListViewState();
}

class _MealsListViewState extends State<MealsListView>
    with TickerProviderStateMixin {
  AnimationController? animationController;
  List<MealsListData> mealsListData = MealsListData.tabIconsList;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.mainScreenAnimationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: widget.mainScreenAnimation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - widget.mainScreenAnimation!.value), 0.0),
            child: SizedBox(
              height: 216,
              width: double.infinity,
              child: ListView.builder(
                padding: const EdgeInsets.only(
                    right: 16, left: 16),
                scrollDirection: Axis.horizontal,
                itemCount: mealsListData.length,
                itemBuilder: (BuildContext context, int index) {
                  final Animation<double> animation =
                      Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animationController!,
                      curve: Interval((1 / mealsListData.length) * index, 1.0,
                          curve: Curves.fastOutSlowIn),
                    ),
                  );
                  animationController?.forward();

                  return MealsView(
                    mealsListData: mealsListData[index],
                    animation: animation,
                    animationController: animationController!,
                    onTap: () {
                      _showInstructionsDialog(context, mealsListData[index]);
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showInstructionsDialog(BuildContext context, MealsListData mealsListData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(mealsListData.titleTxt),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Duration: ${mealsListData.duration}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text('Instructions:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                ...mealsListData.instructions.map((instruction) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontSize: 16)),
                          Expanded(child: Text(instruction)),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }
}

class MealsView extends StatelessWidget {
  const MealsView(
      {Key? key,
      this.mealsListData,
      this.animationController,
      this.animation,
      this.onTap})
      : super(key: key);

  final MealsListData? mealsListData;
  final AnimationController? animationController;
  final Animation<double>? animation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                100 * (1.0 - animation!.value), 0.0, 0.0),
            child: SizedBox(
              width: 130,
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 32, left: 8, right: 8, bottom: 16),
                    child: InkWell(
                      onTap: onTap,
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: HexColor(mealsListData!.endColor)
                                  .withOpacity(0.6),
                              offset: const Offset(1.1, 4.0),
                              blurRadius: 8.0,
                            ),
                          ],
                          gradient: LinearGradient(
                            colors: <HexColor>[
                              HexColor(mealsListData!.startColor),
                              HexColor(mealsListData!.endColor),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(8.0),
                            bottomLeft: Radius.circular(8.0),
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(40.0),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 54, left: 16, right: 16, bottom: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                mealsListData!.titleTxt,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: FitnessAppTheme.fontName,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 0.2,
                                  color: FitnessAppTheme.white,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(top: 8, bottom: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        mealsListData!.duration,
                                        style: const TextStyle(
                                          fontFamily: FitnessAppTheme.fontName,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 10,
                                          letterSpacing: 0.2,
                                          color: FitnessAppTheme.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: FitnessAppTheme.nearlyWhite.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(mealsListData!.imagePath),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
