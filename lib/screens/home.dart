import 'dart:convert';

import 'package:escolaflutter2023/_root/api.dart';
import 'package:escolaflutter2023/_root/app_colors.dart';
import 'package:escolaflutter2023/screens/atividades.dart';
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
  String? userId;
  String nome = '';

  @override
  void initState() {
    super.initState();
    listarTurmas();
  }

  Future<void> listarTurmas() async {
    setState(() {
      carregando = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey('user_data')) {
        // Se não há dados do usuário, limpa e retorna
        setState(() {
          dados = null;
          turmas = [];
          carregando = false;
        });
        return;
      }

      dados = prefs.getString('user_data');

      // Protege caso o JSON não contenha 'id'
      final decoded = jsonDecode(dados!);
      if (decoded == null || decoded['id'] == null) {
        setState(() {
          turmas = [];
          carregando = false;
        });
        return;
      }
      setState(() {
        userId = decoded['id'].toString();
      });
      final uri = Uri.parse('${Api.baseUrl}${Api.turmaEndpoint}/$userId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // Tenta decodificar como lista. Se vier um objeto, trata como lista vazia.
        final dynamic body = json.decode(response.body);
        if (body is List) {
          setState(() {
            turmas = body;
          });
        } else {
          // Se o endpoint retornar um objeto, tente extrair a lista correta
          // Exemplo: {"data": [...]}
          if (body is Map && body['data'] is List) {
            setState(() {
              turmas = body['data'];
            });
          } else {
            setState(() {
              turmas = [];
            });
          }
        }
      } else {
        setState(() {
          turmas = [];
        });
      }
    } catch (e) {
      // Log opcional: print(e);
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
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Splash()),
    );
  }

  Future<void> modalCadastro() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cadastrar turma'),
        content: TextField(
          onChanged: (value) {
            nome = value;
          },
          decoration: const InputDecoration(labelText: 'Nome da turma'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (nome.isEmpty) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Erro'),
                    content: const Text('Preencha o nome'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
                return;
              }
              final payload = json.encode({
                'nome': nome,
                'professorId': int.tryParse(userId!),
              });
              Navigator.pop(context);
              try {
                final url = Uri.parse('${Api.baseUrl}${Api.turmaEndpoint}');
                final resp = await http.post(
                  url,
                  headers: {'Content-Type': 'application/json'},
                  body: payload,
                );
                if (resp.statusCode == 200 || resp.statusCode == 201) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Sucesso'),
                      content: const Text('Turma cadastrada'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                  listarTurmas();
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Erro'),
                      content: const Text('Erro ao enviar dados para a API'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              } catch (e) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Erro'),
                    content: Text('Erro ao conectar a API. erro: $e'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: const Text('Cadastrar'),
          ),
        ],
      ),
    );
  }

  Future<void> excluir(String turma) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir'),
        content: Text('Confirma a exclusão da turma: $turma'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.c5),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final url = Uri.parse(
                  '${Api.baseUrl}${Api.turmaEndpoint}/$turma',
                );
                final resp = await http.delete(url);
                if (resp.statusCode == 200 || resp.statusCode == 204) {
                  listarTurmas();
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Erro'),
                      content: Text(jsonDecode(resp.body)['message']),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              } catch (e) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Erro'),
                    content: Text('$e'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: const Text('Ok', style: TextStyle(color: AppColors.c6)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          dados != null ? jsonDecode(dados!)['nome'] ?? 'Home' : 'Home',
        ),
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
              child: const Text('Sair'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // Não centralizar verticalmente todo o conteúdo — permite o ListView expandir
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                modalCadastro();
              },
              child: const Text('  Cadastrar turma  '),
            ),
            const SizedBox(height: 12),
            const Text(
              'Turmas',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Dá espaço para o ListView ocupar o restante da tela
            Expanded(
              child: carregando
                  ? const Center(child: CircularProgressIndicator())
                  : turmas.isEmpty
                  ? const Center(child: Text('Nenhuma turma encontrada.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: turmas.length,
                      itemBuilder: (context, index) {
                        final item = turmas[index];
                        final id = item['id'] ?? '';
                        final nome = item['nome'] ?? '';
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('$id - $nome'),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.c6,
                                  ),
                                  onPressed: () {
                                    excluir(id.toString());
                                  },
                                  child: Text(
                                    'Excluir',
                                    style: TextStyle(color: AppColors.c1),
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.c5,
                                ),
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Atividades(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Visualizar',
                                  style: TextStyle(color: AppColors.c1),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
