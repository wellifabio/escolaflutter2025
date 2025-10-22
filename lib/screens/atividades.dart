import 'dart:convert';

import 'package:escolaflutter2023/_root/api.dart';
import 'package:escolaflutter2023/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Atividades extends StatefulWidget {
  const Atividades({super.key});

  @override
  State<Atividades> createState() => _AtividadesState();
}

class _AtividadesState extends State<Atividades> {
  List<dynamic> atividades = [];
  bool carregando = true;
  String? dados;
  String? turmaId;
  String descricao = '';

  @override
  void initState() {
    super.initState();
    listaratividades();
  }

  Future<void> listaratividades() async {
    setState(() {
      carregando = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey('user_data')) {
        // Se não há dados do usuário, limpa e retorna
        setState(() {
          dados = null;
          atividades = [];
          carregando = false;
        });
        return;
      }

      dados = prefs.getString('user_data');

      // Protege caso o JSON não contenha 'id'
      final decoded = jsonDecode(dados!);
      if (decoded == null || decoded['id'] == null) {
        setState(() {
          atividades = [];
          carregando = false;
        });
        return;
      }
      setState(() {
        turmaId = decoded['id'].toString();
      });
      final uri = Uri.parse('${Api.baseUrl}${Api.atividadeEndpoint}/$turmaId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // Tenta decodificar como lista. Se vier um objeto, trata como lista vazia.
        final dynamic body = json.decode(response.body);
        if (body is List) {
          setState(() {
            atividades = body;
          });
        } else {
          // Se o endpoint retornar um objeto, tente extrair a lista correta
          // Exemplo: {"data": [...]}
          if (body is Map && body['data'] is List) {
            setState(() {
              atividades = body['data'];
            });
          } else {
            setState(() {
              atividades = [];
            });
          }
        }
      } else {
        setState(() {
          atividades = [];
        });
      }
    } catch (e) {
      // Log opcional: print(e);
      setState(() {
        atividades = [];
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
      MaterialPageRoute(builder: (context) => const Home()),
    );
  }

  Future<void> modalCadastro() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cadastrar atividade'),
        content: TextField(
          onChanged: (value) {
            descricao = value;
          },
          decoration: const InputDecoration(
            labelText: 'descricao da atividade',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (descricao.isEmpty) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Erro'),
                    content: const Text('Preencha a descricao'),
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
                'descricao': descricao,
                'turmaId': int.tryParse(turmaId!),
              });
              Navigator.pop(context);
              try {
                final url = Uri.parse('${Api.baseUrl}${Api.atividadeEndpoint}');
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
                      content: const Text('atividade cadastrada'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                  listaratividades();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          dados != null
              ? jsonDecode(dados!)['descricao'] ?? 'Atividades'
              : 'Atividades',
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
              child: const Text('  Cadastrar atividade  '),
            ),
            const SizedBox(height: 12),
            const Text(
              'Atividades',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Dá espaço para o ListView ocupar o restante da tela
            Expanded(
              child: carregando
                  ? const Center(child: CircularProgressIndicator())
                  : atividades.isEmpty
                  ? const Center(child: Text('Nenhuma atividade encontrada.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: atividades.length,
                      itemBuilder: (context, index) {
                        final item = atividades[index];
                        final id = item['id'] ?? '';
                        final descricao = item['descricao'] ?? '';
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [Text('$id - $descricao')],
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
