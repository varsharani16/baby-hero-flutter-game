

class GameEnemy {
  GameEnemy({
    required this.x,
    required this.y,
    this.width = 40,
    this.height = 40,
    required this.platformLeft,
    required this.platformRight,
    this.speed = 50,
    this.isGroundEnemy = false,
  })  : startX = x,
        movingRight = true;

  double x;
  double y;

  final double width;
  final double height;
  final double speed;
  final double startX;

  final double platformLeft;
  final double platformRight;

  bool movingRight;
  final bool isGroundEnemy;

  void update(double dt) {
    if (movingRight) {
      x += speed * dt;

      if (x + width >= platformRight) {
        x = platformRight - width;
        movingRight = false;
      }
    } else {
      x -= speed * dt;

      if (x <= platformLeft) {
        x = platformLeft;
        movingRight = true;
      }
    }
  }

  void reset() {
    x = startX;
    movingRight = true;
  }
}

