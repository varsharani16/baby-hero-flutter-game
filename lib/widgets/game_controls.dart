
import 'package:flutter/material.dart';

class GameControls extends StatelessWidget {
  final VoidCallback onLeftDown;
  final VoidCallback onLeftUp;
  final VoidCallback onRightDown;
  final VoidCallback onRightUp;
  final VoidCallback onJump;

  const GameControls({
    super.key,
    required this.onLeftDown,
    required this.onLeftUp,
    required this.onRightDown,
    required this.onRightUp,
    required this.onJump,
  });

  Widget control(
      String label,
      VoidCallback onDown,
      VoidCallback onUp,
      ) {
    return GestureDetector(
      onTapDown: (_) => onDown(),
      onTapUp: (_) => onUp(),
      onTapCancel: onUp,
      child: Container(
        width: 62,
        height: 58,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color(0xFF54158B),
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.bold,
            color: Color(0xFF54158B),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          control('◀', onLeftDown, onLeftUp),
         // const SizedBox(width: 8),
          control('⬆', onJump, () {}),
         // const SizedBox(width: 8),
          control('▶', onRightDown, onRightUp),
        ],
      ),
    );

  }
}
