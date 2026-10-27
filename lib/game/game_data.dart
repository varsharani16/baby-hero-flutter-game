
class GamePlatform {
  final double x;
  final double height;
  final double width;

  const GamePlatform(this.x, this.height, this.width);
}

class Chocolate {
  final double x;
  final double height;

  const Chocolate(this.x, this.height);
}

const List<GamePlatform> gamePlatforms = [
  GamePlatform(210, 105, 125),
  GamePlatform(430, 155, 125),
  GamePlatform(660, 105, 140),
  GamePlatform(900, 160, 135),
  GamePlatform(1150, 110, 140),
  GamePlatform(1410, 155, 150),
  GamePlatform(1680, 105, 150),
];

const List<Chocolate> gameChocolates = [
  Chocolate(140, 65),
  Chocolate(255, 150),
  Chocolate(325, 150),
  Chocolate(475, 205),
  Chocolate(555, 65),
  Chocolate(700, 150),
  Chocolate(760, 150),
  Chocolate(945, 210),
  Chocolate(1040, 65),
  Chocolate(1190, 155),
  Chocolate(1260, 155),
  Chocolate(1455, 205),
  Chocolate(1550, 65),
  Chocolate(1720, 150),
  Chocolate(1810, 65),
];


class GameFinish {
  const GameFinish({
    required this.x,
    this.width = 50,
    this.height = 80,
  });

  final double x;
  final double width;
  final double height;
}

