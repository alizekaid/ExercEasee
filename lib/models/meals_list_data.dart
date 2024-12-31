class MealsListData {
  MealsListData({
    this.imagePath = '',
    this.titleTxt = '',
    this.startColor = '',
    this.endColor = '',
    this.instructions = const [],
    this.duration = '',
  });

  String imagePath;
  String titleTxt;
  String startColor;
  String endColor;
  List<String> instructions;
  String duration;

  static List<MealsListData> tabIconsList = <MealsListData>[
    MealsListData(
      imagePath: 'assets/images/leg.png',
      titleTxt: 'Leg Stretches',
      startColor: '#FA7D82',
      endColor: '#FFB295',
      instructions: [
        'Hamstring stretch: Sit on the floor with one leg extended, reach for your toes',
        'Calf stretch: Stand facing a wall, place one foot behind you',
        'Quad stretch: Stand on one leg, bend the other knee behind you'
      ],
      duration: '5-10 minutes',
    ),
    MealsListData(
      imagePath: 'assets/images/stretch.png',
      titleTxt: 'Full Body Stretch',
      startColor: '#738AE6',
      endColor: '#5C5EDD',
      instructions: [
        'Start with neck rotations: slowly roll your head in circles',
        'Arm circles: Make forward and backward circles with your arms',
        'Touch your toes: Slowly bend forward keeping legs straight',
        'Side stretches: Raise arms above head and lean side to side'
      ],
      duration: '10-15 minutes',
    ),
    MealsListData(
      imagePath: 'assets/images/quadriceps.png',
      titleTxt: 'Quads',
      startColor: '#FE95B6',
      endColor: '#FF5287',
      instructions: [
        'Standing quad stretch: Hold your foot behind your back',
        'Lunges: Step forward into a lunge position',
        'Wall sits: Lean against wall in sitting position'
      ],
      duration: '5-8 minutes',
    ),
    MealsListData(
      imagePath: 'assets/images/shoulder.png',
      titleTxt: 'Shoulder Mobility',
      startColor: '#6F72CA',
      endColor: '#1E1466',
      instructions: [
        'Cross-body arm stretch: Pull one arm across chest',
        'Shoulder rolls: Roll shoulders forward and backward',
        'Arm circles: Make small to large circles with arms',
        'Wall slides: Slide arms up and down against wall'
      ],
      duration: '5-7 minutes',
    ),
  ];
}
