import 'package:escolaflutter2023/_root/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:escolaflutter2023/screens/login.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    // Simula um carregamento de 3 segundos
    Future.delayed(const Duration(seconds: 1), () {
      navigateToLogin();
    });
  }

  void navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Carregando...',
              style: TextStyle(fontSize: 18, color: AppColors.c4),
            ),
          ],
        ),
      ),
    );
  }
}
