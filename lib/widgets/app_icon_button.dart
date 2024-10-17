import 'package:flutter/material.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      style: IconButton.styleFrom(
        shape: const CircleBorder(),
        fixedSize: const Size(70, 70),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      icon: Icon(
        icon,
        color: Colors.white,
      ),
    );
  }
}
