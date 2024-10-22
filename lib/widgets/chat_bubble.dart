import 'package:flutter/material.dart';
import 'package:typewritertext/typewritertext.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
      alignment: Alignment.centerLeft,
      child: TypeWriter.text(
        text,
        duration: const Duration(milliseconds: 50),
        style: textTheme.bodyLarge?.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }
}
