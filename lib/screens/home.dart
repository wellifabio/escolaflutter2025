import 'dart:convert';

import 'package:escolaflutter2023/_root/api.dart';
import 'package:escolaflutter2023/screens/splash.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<dynamic> turmas = [];
  bool carregando = true;
  String? dados;

  @override
  void initState() {
    super.initState();
    listarTurmas();
  }

  Future<void> listarTurmas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('user_data')) {
        setState(() {
          dados = prefs.getString('user_data');
        });
      }

      final uri = Uri.parse(
        '${Api.baseUrl}${Api.turmaEndpoint}/${jsonDecode(dados!)['id']}',
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          turmas = data;
        });
      } else {
        // Em caso de erro, mantém lista vazia
        setState(() {
          turmas = [];
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
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
        title: Text(dados != null ? jsonDecode(dados!)['nome'] : 'Home'),
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
            Text(turmas.toString()),
          ],
        ),
      ),
    );
  }
}
