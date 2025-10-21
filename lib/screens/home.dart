import 'package:escolaflutter2023/screens/splash.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<dynamic> turmas = [];
  bool carregando = true;
  String? get dados => null;

  Future<void> listarTurmas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('user_data')) {
        setState(() {
          dados = prefs.getString('user_data');
        });
      }
    } catch (e) {
      setState(() {
        turmas = [];
      });
    } finally {
      setState(() {
        carregando = false;
      });
    }
  }

  Future<void> sair() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Splash()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Home'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                sair();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
              ),
              child: Text('Sair'),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Tela Home',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(dados.toString()),
          ],
        ),
      ),
    );
  }
}
