import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaginaListarPlantoes extends StatefulWidget {
  const PaginaListarPlantoes({super.key});

  @override
  State<PaginaListarPlantoes> createState() => _PaginaListarPlantoesState();
}

class _PaginaListarPlantoesState extends State<PaginaListarPlantoes> {
  late Future<List<dynamic>> _plantoesFuture;

  @override
  void initState() {
    super.initState();
    _plantoesFuture = _buscarPlantoes();
  }

  Future<List<dynamic>> _buscarPlantoes() async {
    const storage = FlutterSecureStorage();
    String? tokenJWT = await storage.read(key: 'token_jwt');

    if (tokenJWT == null) {
      throw Exception('Sessão expirada. Faça login novamente.');
    }

    final urlPlantoes = Uri.parse('http://10.0.2.2:5000/plantoes');
    final urlSetores = Uri.parse('http://10.0.2.2:5000/admin/setores');

    try {
      List<dynamic> setores = [];
      try {
        final resSetores = await http.get(urlSetores, headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${tokenJWT.trim()}',
        });
        if (resSetores.statusCode == 200) {
          setores = json.decode(resSetores.body);
        }
      } catch (_) {}

      final response = await http.get(
        urlPlantoes,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${tokenJWT.trim()}',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> todosPlantoes = json.decode(response.body);

        for (var p in todosPlantoes) {
          final sId = p['setor_id'];
          final setorEncontrado = setores.firstWhere(
            (s) => s['id'] == sId,
            orElse: () => null,
          );
          p['setor_nome'] = setorEncontrado != null ? setorEncontrado['nome'] : 'Setor não identificado';
        }

        return todosPlantoes;
      } else if (response.statusCode == 404) {
        throw Exception('A API de listar plantões ainda não foi adicionada no backend.');
      } else {
        throw Exception('Erro ao carregar plantões: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Falha ao conectar ao servidor: $e');
    }
  }

  String _formatarDataHora(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '--/--/---- --:--';
    try {
      final data = DateTime.parse(isoDate);
      final dia = data.day.toString().padLeft(2, '0');
      final mes = data.month.toString().padLeft(2, '0');
      final ano = data.year.toString();
      final hora = data.hour.toString().padLeft(2, '0');
      final minuto = data.minute.toString().padLeft(2, '0');
      return '$dia/$mes/$ano às $hora:$minuto';
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    const corAzulEscuro = Color.fromARGB(255, 9, 17, 131);
    const corFundoApp = Color(0xFFF4F6FA);
    const corAzulVibrante = Color(0xFF3948F5);

    return Scaffold(
      backgroundColor: corFundoApp,
      appBar: AppBar(
        backgroundColor: corFundoApp,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: corAzulEscuro),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Plantões Agendados',
          style: TextStyle(color: corAzulEscuro, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _plantoesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: corAzulVibrante));
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  '${snapshot.error}'.replaceAll('Exception: ', ''),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum plantão agendado encontrado.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final plantoes = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(24.0),
            itemCount: plantoes.length,
            itemBuilder: (context, index) {
              final p = plantoes[index];

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            p['funcao'] ?? 'Plantão',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: corAzulEscuro, fontSize: 16),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: corAzulEscuro.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              p['status'] ?? 'Agendado',
                              style: const TextStyle(color: corAzulEscuro, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(p['medico_nome'] ?? 'Em Aberto', style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.local_hospital, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text('Setor: ${p['setor_nome'] ?? 'Não informado'}', style: const TextStyle(color: Colors.black87)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Início: ${_formatarDataHora(p['data_inicio'])}\nFim: ${_formatarDataHora(p['data_fim'])}',
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}