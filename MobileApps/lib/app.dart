import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'presentation/shell_screen.dart';

class MeatFreshApp extends StatelessWidget {
  const MeatFreshApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MeatFresh AI',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const ShellScreen(),
    );
  }
}
