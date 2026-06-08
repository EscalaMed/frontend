import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../components/card_colaborador_contrato.dart';

class TelaDetalhesContratacao extends StatefulWidget {
  final String tipoContrato;
  final String token;

  const TelaDetalhesContratacao({super.key, required this.tipoContrato, required this.token});

  @override
  State<TelaDetalhesContratacao> createState() => _TelaDetalhesContratacaoState();
}

class _TelaDetalhesContratacaoState extends State<TelaDetalhesContratacao> {
  late Future<List<dynamic>> _funcionariosFuture;

  @override
  void initState() {
    super.initState();
    _funcionariosFuture = _buscarFuncionariosPorContrato();
  }

  Future<List<dynamic>> _buscarFuncionariosPorContrato() async {
    const storage = FlutterSecureStorage();
    String? tokenJWT = await storage.read(key: 'token_jwt');

    if (tokenJWT == null) {
      throw Exception('Sessão expirada. Faça login novamente.');
    }

    final url = Uri.parse('http://10.0.2.2:5000/admin/usuarios');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${tokenJWT.trim()}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> todosUsuarios = json.decode(response.body);
        final filtrados = todosUsuarios.where((u) {
          final formaContratoUsuario = u['forma_contratacao']?.toString().trim().toUpperCase() ?? '';
          final contratoTela = widget.tipoContrato.trim().toUpperCase();
          return formaContratoUsuario == contratoTela;
        }).toList();

        return filtrados;
      } else {
        throw Exception('Erro ao carregar dados do servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Falha ao conectar ao servidor: $e');
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
        title: Text(
          'Regime: ${widget.tipoContrato}',
          style: const TextStyle(color: corAzulEscuro, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _funcionariosFuture,
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
            return Center(
              child: Text(
                'Nenhum colaborador ativo em ${widget.tipoContrato}.',
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final funcionarios = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(24.0),
            itemCount: funcionarios.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Colaboradores Ativos (${widget.tipoContrato})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: corAzulEscuro),
                  ),
                );
              }

              final f = funcionarios[index - 1];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: CardColaboradorContrato(
                  nome: f['nome'] ?? 'Sem Nome',
                  cargo: f['funcao'] ?? f['tipo'] ?? 'Funcionário',
                  regime: widget.tipoContrato,
                  matricula: f['registro_profissional'] ?? f['id'].toString(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}