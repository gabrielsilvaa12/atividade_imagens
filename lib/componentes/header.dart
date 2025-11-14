import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: const BoxDecoration(
        color: Color(0xFFFF1744),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 8),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/Sparkos.png', height: 200),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}
