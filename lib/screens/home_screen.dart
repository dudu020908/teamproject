import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: Center(
      child: FilledButton(
        onPressed: () => Navigator.pushNamed(context, '/userinfo'),
        child: const Text('시작하기'),
      ),
    ),
  );
}
