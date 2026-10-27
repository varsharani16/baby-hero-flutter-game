
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../game/enemy_data.dart';
import '../game/game_data.dart';
import '../game/game_painter.dart';
import '../game/health_powerup.dart';
import '../game/sound_manager.dart';
import '../widgets/game_controls.dart';
import '../widgets/score_board.dart';
import 'result_screen.dart';
import '../game/sprite_animation.dart';
import '../game/collection_effect.dart';



class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController ticker;
  final SoundManager soundManager = SoundManager();
  final Stopwatch clock = Stopwatch();
  final List<CollectionEffect> collectionEffects = [];

  Size screenSize = Size.zero;

  double lastTime = 0;
  double playerX = 40;
  double playerY = 0;
  double velocityY = 0;
  double cameraX = 0;

  bool initialized = false;
  bool leftPressed = false;
  bool rightPressed = false;
  bool jumping = false;
  bool navigating = false;

  int score = 0;
  int lives = 3;
  double invincibilityTimer = 0;
  static const double invincibilityDuration = 5.0;

  final Set<int> collected = {};

  static const double playerWidth = 36;
  static const double playerHeight = 48;
  static const double gravity = 1350;
  static const double jumpPower = -680;

  double get groundY => screenSize.height - 72;

  SpriteAnimation? idleAnimation;
  SpriteAnimation? runAnimation;
  SpriteAnimation? jumpAnimation;

  SpriteAnimation? activeAnimation;
  bool spritesLoaded = false;
  bool isPaused = false;
  bool facingLeft = false;


  final List<GameEnemy> gameEnemies = [
    // Enemy on the first platform
    GameEnemy(
      x: 240,
      y: 0,
      width: 40,
      height: 40,
      platformLeft: 210,
      platformRight: 335,
      speed: 50,
    ),

    // Ground enemy
    GameEnemy(
      x: 400,
      y: 0,
      width: 40,
      height: 40,
      platformLeft: 360,
      platformRight: 600,
      speed: 60,
      isGroundEnemy: true,
    ),
  ];


  bool gameOver = false;

  final List<HealthPowerUp> healthPowerUps = [
    HealthPowerUp(x: 500, y: 0),
    HealthPowerUp(x: 1000, y: 0),
  ];

  static const GameFinish levelFinish = GameFinish(x: 1850);



  @override
  void initState() {
    super.initState();
    print('BABY HERO GAME STARTED');
    clock.start();
    loadHeroAnimations();
    ticker = AnimationController(
      vsync: this,
      duration: const Duration(days: 1),
    )
      ..addListener(updateGame)
      ..repeat();
  }


  Future<void> loadHeroAnimations() async {
    try {
      final idle = await SpriteAnimation.load('idle', 5);
      final run = await SpriteAnimation.load('run', 6);
      final jump = await SpriteAnimation.load('jump', 4);

      if (!mounted) {
        idle.dispose();
        run.dispose();
        jump.dispose();
        return;
      }

      // debugPrint('Idle frames: ${idle.frames.length}');
      // debugPrint('Run frames: ${run.frames.length}');
      // debugPrint('Jump frames: ${jump.frames.length}');
      setState(() {
        idleAnimation = idle;
        runAnimation = run;
        jumpAnimation = jump;
        activeAnimation = idle;
        print('IDLE IMAGE: ${idle.image != null}');
        print('IDLE FRAME COUNT: ${idle.frames.length}');
        spritesLoaded = true;
      });
    } catch (e) {
      debugPrint('Could not load Baby Hero sprites: $e');
    }
  }

  void updateGame() {
    final now = clock.elapsedMicroseconds / 1000000.0;
    final dt = math.min(now - lastTime, 0.025);
    lastTime = now;

    if (!initialized ||
        dt <= 0 ||
        navigating ||
        isPaused ||
        gameOver) {
      return;
    }

    bool completed = false;

    setState(() {
      final previousY = playerY;

      if (leftPressed){  facingLeft = true;playerX -= 220 * dt;}
      if (rightPressed){  facingLeft = false;playerX += 220 * dt;}

      playerX = math.max(0, playerX);

      velocityY += gravity * dt;
      playerY += velocityY * dt;

      // bool landed = false;
      //
      // if (velocityY >= 0) {
      //   for (final platform in gamePlatforms) {
      //     final top = groundY - platform.height;
      //
      //     final overlaps = playerX + playerWidth > platform.x &&
      //         playerX < platform.x + platform.width;
      //
      //     final crossed = previousY + playerHeight <= top &&
      //         playerY + playerHeight >= top;
      //
      //     if (overlaps && crossed) {
      //       playerY = top - playerHeight;
      //       velocityY = 0;
      //       landed = true;
      //       break;
      //     }
      //   }
      // }

      bool landed = false;
      bool hitPlatformFromBelow = false;

      for (final platform in gamePlatforms) {
        final platformLeft = platform.x;
        final platformRight = platform.x + platform.width;
        final platformTop = groundY - platform.height;

        final platformBottom = platformTop + 20;

        final overlapsHorizontally =
            playerX + playerWidth > platformLeft &&
                playerX < platformRight;

        // Landing on top of a platform
        final crossedPlatformTop =
            previousY + playerHeight <= platformTop &&
                playerY + playerHeight >= platformTop;

        if (velocityY >= 0 &&
            overlapsHorizontally &&
            crossedPlatformTop) {

          playerY = platformTop - playerHeight;
          velocityY = 0;
          landed = true;
          break;
        }

        // Hitting the underside while jumping upward
        final crossedPlatformBottom =
            previousY >= platformBottom &&
                playerY <= platformBottom;

        if (velocityY < 0 &&
            overlapsHorizontally &&
            crossedPlatformBottom) {
          playerY = platformBottom;
          velocityY = 0;
          hitPlatformFromBelow = true;
          break;
        }
      }

      if (playerY + playerHeight >= groundY) {
        playerY = groundY - playerHeight;
        velocityY = 0;
        landed = true;
      }

      jumping = !landed;
      final SpriteAnimation? nextAnimation;

      if (jumping) {
        nextAnimation = jumpAnimation;
      } else if (leftPressed || rightPressed) {
        nextAnimation = runAnimation;
      } else {
        nextAnimation = idleAnimation;
      }

      if (nextAnimation != null &&
          nextAnimation != activeAnimation) {
        activeAnimation = nextAnimation;
        activeAnimation!.reset();
      }

      activeAnimation?.update(dt);

      for (final effect in collectionEffects) {
        effect.update(dt);
      }

      collectionEffects.removeWhere(
            (effect) => effect.isFinished,
      );

      cameraX = math.max(
        0,
        playerX - screenSize.width * 0.30,
      );

      final heroRect = Rect.fromLTWH(
        playerX,
        playerY,
        playerWidth,
        playerHeight,
      );

//enemy collision with baby


      for (final enemy in gameEnemies) {
        final enemyRect = Rect.fromLTWH(
          enemy.x,
          enemy.y,
          enemy.width,
          enemy.height,
        );

        if (heroRect.overlaps(enemyRect) &&
            invincibilityTimer <= 0) {
          lives--;

          // Protect Baby Hero for 2 seconds.
          invincibilityTimer = invincibilityDuration;

          velocityY = 0;
          jumping = false;
          leftPressed = false;
          rightPressed = false;

          if (lives <= 0) {
            lives = 0;
            gameOver = true;
          } else {
            playerX = 40;
            playerY = groundY - playerHeight;
            cameraX = 0;
          }

          break;
        }
      }

      //restore life, heart collection


      for (final heart in healthPowerUps) {
        final heartRect = Rect.fromLTWH(
          heart.x,
          groundY - heart.size - 50,
          heart.size,
          heart.size,
        );

        if (!heart.collected &&
            lives < 3 &&
            heroRect.overlaps(heartRect)) {
          lives = (lives + 1).clamp(0, 3);
          heart.collected = true;
        }
      }





      for (int i = 0; i < gameChocolates.length; i++) {
        if (collected.contains(i)) continue;

        final chocolate = gameChocolates[i];

        final chocolateRect = Rect.fromLTWH(
          chocolate.x,
          groundY - chocolate.height,
          38,
          29,
        );

        if (heroRect.overlaps(chocolateRect)) {
          collected.add(i);
          score += 10;
          collectionEffects.add(
            CollectionEffect(
              position: Offset(
                chocolate.x + 19,
                groundY - chocolate.height + 14,
              ),
            ),
          );
          soundManager.playChocolate();
        }
      }

      final finishRect = Rect.fromLTWH(
        levelFinish.x,
        groundY - levelFinish.height,
        levelFinish.width,
        levelFinish.height,
      );

      final allChocolatesCollected =
          collected.length == gameChocolates.length;

      final reachedFinish = heroRect.overlaps(finishRect);

      completed = allChocolatesCollected && reachedFinish;

      if (completed) {
        leftPressed = false;
        rightPressed = false;
      }
    });

    if (completed && !navigating) {
      navigating = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              score: score,
              collected: collected.length,
              total: gameChocolates.length,
            ),
          ),
        );
      });
    }

    //enemy position
    for (final enemy in gameEnemies) {
      if (enemy.isGroundEnemy) {
        enemy.y = groundY - enemy.height;
      } else {
        enemy.y = groundY - 105 - enemy.height;
      }

      enemy.update(dt);
    }

    //invicibility protection
    if (invincibilityTimer > 0) {
      invincibilityTimer -= dt;

      if (invincibilityTimer < 0) {
        invincibilityTimer = 0;
      }
    }
  }

  void jump() {
    if (!initialized || jumping || navigating) return;

    setState(() {
      velocityY = jumpPower;
      jumping = true;
    });
    soundManager.playJump();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            screenSize = Size(
              constraints.maxWidth,
              constraints.maxHeight,
            );

            if (!initialized && screenSize.height > 0) {
              playerY = groundY - playerHeight;
              initialized = true;
              lastTime =
                  clock.elapsedMicroseconds / 1000000.0;
            }

            return Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: GamePainter(
                      playerX: playerX,
                      playerY: playerY,
                      cameraX: cameraX,
                      groundY: groundY,
                      platforms: gamePlatforms,
                      chocolates: gameChocolates,
                      collected: collected,
                      collectionEffects: collectionEffects,
                      enemies: gameEnemies,
                      healthPowerUps: healthPowerUps,
                      finish: levelFinish,
                      facingLeft: facingLeft,
                      hideHero: invincibilityTimer > 0 &&
                          (invincibilityTimer * 10).floor().isEven,
                      heroAnimation: activeAnimation,

                    ),
                  ),
                ),

                Positioned(
                  top: 12,
                  left: 12,
                  child: ScoreBoard(
                    score: score,
                    collected: collected.length,
                    total: gameChocolates.length,
                    lives: lives,
                  ),
                ),

                Positioned(
                  top: 12,
                  right: 12,
                  child: IconButton.filled(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.home),
                    tooltip: 'Home',
                  ),
                ),

                Positioned(
                    left: 0,
                    right: 0,
                    bottom: 14,
                    child: Center(
                  child: GameControls(
                    onLeftDown: () => leftPressed = true,
                    onLeftUp: () => leftPressed = false,
                    onRightDown: () => rightPressed = true,
                    onRightUp: () => rightPressed = false,
                    onJump: jump,
                  ),
                    ),
                ),


                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        isPaused = !isPaused;
                      });
                    },
                    icon: Icon(
                      isPaused ? Icons.play_arrow : Icons.pause,
                      color: Colors.white,
                      size: 32,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                    ),
                  ),
                ),

                if (isPaused)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black54,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'GAME PAUSED',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),

                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    isPaused = false;
                                  });
                                },
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Resume'),
                              ),

                              const SizedBox(height: 10),

                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    isPaused = false;
                                    playerX = 0;
                                    playerY = groundY - playerHeight;
                                    velocityY = 0;
                                    score = 0;
                                    collected.clear();
                                    collectionEffects.clear();
                                    jumping = false;
                                    leftPressed = false;
                                    rightPressed = false;
                                    cameraX = 0;

                                    activeAnimation = idleAnimation;
                                    activeAnimation?.reset();
                                  });
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Restart'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),


                if (gameOver)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black87,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.sentiment_very_dissatisfied,
                                size: 60,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'GAME OVER!',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('Score: $score'),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    gameOver = false;
                                    isPaused = false;
                                    navigating = false;
                                    playerX = 40;
                                    playerY = groundY - playerHeight;
                                    velocityY = 0;
                                    score = 0;
                                    lives=3;
                                    invincibilityTimer = 0;
                                    collected.clear();
                                    collectionEffects.clear();
                                    jumping = false;
                                    leftPressed = false;
                                    rightPressed = false;
                                    cameraX = 0;

                                    for (final enemy in gameEnemies) {
                                      enemy.reset();
                                      enemy.y = groundY -
                                          gamePlatforms.firstWhere(
                                                (p) =>
                                            enemy.x + enemy.width > p.x &&
                                                enemy.x < p.x + p.width,
                                            orElse: () =>
                                                GamePlatform(0, 0, 0),
                                          ).height -
                                          enemy.height;
                                    }

                                    activeAnimation = idleAnimation;
                                    activeAnimation?.reset();
                                  });
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Play Again'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),


              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    ticker.dispose();
    clock.stop();
    idleAnimation?.dispose();
    runAnimation?.dispose();
    jumpAnimation?.dispose();
    soundManager.dispose();
    super.dispose();
  }
}
