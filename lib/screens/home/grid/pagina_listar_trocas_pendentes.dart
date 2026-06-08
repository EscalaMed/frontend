import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaginaListarTrocasPendentes extends StatefulWidget {
  const PaginaListarTrocasPendentes({super.key});

  @override
  State<PaginaListarTrocasPendentes> createState() => _PaginaListarTrocasPendentesState();
}

class _PaginaListarTrocasPendentesState extends State<PaginaListarTrocasPendentes> {
  late Future<List<dynamic>> _trocasFuture;

  @override
  void initState() {
    super.initState();
    _trocasFuture = _buscarTrocas();
  }

  Future<List<dynamic>> _buscarTrocas() async {
    const storage = FlutterSecureStorage();
    String? tokenJWT = await storage.read(key: 'token_jwt');

    if (tokenJWT == null) {
      throw Exception('Sessão expirada. Faça login novamente.');
    }

    final url = Uri.parse('http://10.0.2.2:5000/pedidos_troca/pendentes');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${tokenJWT.trim()}',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else if (response.statusCode == 404) {
        throw Exception('Rota de listar trocas não encontrada no servidor.');
      } else {
        throw Exception('Erro ao carregar trocas pendentes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Falha ao conectar ao servidor: $e');
    }
  }

  Future<void> _avaliarTroca(int idPedido, String status) async {
    const storage = FlutterSecureStorage();
    String? tokenJWT = await storage.read(key: 'token_jwt');

    if (tokenJWT == null) return;

    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:5000/pedidos_troca/$idPedido/avaliar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${tokenJWT.trim()}',
        },
        body: json.encode({'status': status}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == 'aprovado' ? 'Troca aprovada com sucesso!' : 'Troca recusada com sucesso.'),
            backgroundColor: status == 'aprovado' ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
          ),
        );
        setState(() {
          _trocasFuture = _buscarTrocas();
        });
      } else {
        final erro = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(erro['msg'] ?? 'Erro ao processar troca.'), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha de conexão com o servidor.'), backgroundColor: Colors.red),
      );
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
          'Trocas Pendentes',
          style: TextStyle(color: corAzulEscuro, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _trocasFuture,
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
                'Nenhuma solicitação pendente no momento.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final trocas = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(24.0),
            itemCount: trocas.length,
            itemBuilder: (context, index) {
              final t = trocas[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFB0B5D9), width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: Color(0xFFF4F6FA),
                          child: Icon(Icons.person_outline, color: corAzulEscuro, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t['medico_solicitante'] ?? 'Médico Desconhecido',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: corAzulEscuro),
                              ),
                              Text(
                                t['setor_nome'] ?? 'Setor não informado',
                                style: TextStyle(fontSize: 12, color: corAzulEscuro.withValues(alpha: 0.6)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFF4F6FA), borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _LinhaInfo(icone: Icons.arrow_upward_outlined, cor: const Color(0xFFC62828), label: 'Cede: ', valor: t['plantao_atual'] ?? 'Não informado'),
                          const SizedBox(height: 6),
                          _LinhaInfo(icone: Icons.arrow_downward_outlined, cor: const Color(0xFF2E7D32), label: 'Recebe: ', valor: t['plantao_desejado'] ?? 'Substituto'),
                          const SizedBox(height: 6),
                          _LinhaInfo(icone: Icons.notes_outlined, cor: corAzulEscuro, label: 'Motivo: ', valor: t['motivo'] ?? 'Sem motivo'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: SizedBox(height: 40, child: OutlinedButton.icon(onPressed: () => _avaliarTroca(t['id'], 'recusado'), icon: const Icon(Icons.close, size: 18), label: const Text('Recusar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFC62828), side: const BorderSide(color: Color(0xFFC62828), width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))))),
                        const SizedBox(width: 12),
                        Expanded(child: SizedBox(height: 40, child: ElevatedButton.icon(onPressed: () => _avaliarTroca(t['id'], 'aprovado'), icon: const Icon(Icons.check, size: 18), label: const Text('Aprovar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))))),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _LinhaInfo extends StatelessWidget {
  final IconData icone; final Color cor; final String label, valor;
  const _LinhaInfo({required this.icone, required this.cor, required this.label, required this.valor});
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icone, size: 14, color: cor), const SizedBox(width: 6), Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 9, 17, 131))), Expanded(child: Text(valor, style: const TextStyle(fontSize: 13, color: Color.fromARGB(255, 9, 17, 131))))]);
}