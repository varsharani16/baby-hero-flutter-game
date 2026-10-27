
import 'package:flutter/material.dart';

class ScoreBoard extends StatelessWidget {
  final int score;
  final int collected;
  final int total;
  final int lives;

  const ScoreBoard({
    super.key,
    required this.score,
    required this.collected,
    required this.total,
    required this.lives,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🍫 Score: $score',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF54158B),
            ),
          ),
          Text(
            'Collected: $collected / $total',
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            '❤️ Lives: $lives / 3',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
