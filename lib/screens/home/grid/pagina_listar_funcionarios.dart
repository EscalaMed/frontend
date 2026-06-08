import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PaginaListarFuncionarios extends StatefulWidget {
  const PaginaListarFuncionarios({super.key});

  @override
  State<PaginaListarFuncionarios> createState() => _PaginaListarFuncionariosState();
}

class _PaginaListarFuncionariosState extends State<PaginaListarFuncionarios> {
  late Future<List<dynamic>> _funcionariosFuture;

  @override
  void initState() {
    super.initState();
    _funcionariosFuture = _buscarFuncionarios();
  }

  Future<List<dynamic>> _buscarFuncionarios() async {
    const storage = FlutterSecureStorage();
    String? tokenJWT = await storage.read(key: 'token_jwt');

    if (tokenJWT == null) {
      throw Exception('Sessão expirada. Faça login novamente.');
    }

    final prefs = await SharedPreferences.getInstance();
    final meuUserId = prefs.getInt('user_id');

    String? role;
    String? jwtUserId;
    try {
      final partes = tokenJWT.split('.');
      if (partes.length >= 2) {
        String payload = base64Url.normalize(partes[1]);
        String decodificado = utf8.decode(base64Url.decode(payload));
        final jsonMap = jsonDecode(decodificado);
        role = jsonMap['role']?.toString().toLowerCase();
        jwtUserId = jsonMap['sub']?.toString();
      }
    } catch (_) {}

    final idDesteUsuario = meuUserId?.toString() ?? jwtUserId;

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
        List<dynamic> todosUsuarios = json.decode(response.body);

        if (role == 'coordenador') {
          if (idDesteUsuario != null) {
            Map<String, dynamic>? meuUsuario;
            for (var u in todosUsuarios) {
              if (u['id']?.toString() == idDesteUsuario) {
                meuUsuario = u;
                break;
              }
            }

            if (meuUsuario != null && meuUsuario['setor_id'] != null) {
              final meuSetorId = meuUsuario['setor_id'].toString();
              return todosUsuarios.where((u) => u['setor_id']?.toString() == meuSetorId).toList();
            }
          }
          
          return [];
        }

        return todosUsuarios;
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
        title: const Text(
          'Lista de Funcionários',
          style: TextStyle(color: corAzulEscuro, fontWeight: FontWeight.bold),
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
            return const Center(
              child: Text(
                'Nenhum funcionário encontrado.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final funcionarios = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(24.0),
            itemCount: funcionarios.length,
            itemBuilder: (context, index) {
              final f = funcionarios[index];

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  leading: CircleAvatar(
                    backgroundColor: corAzulEscuro.withValues(alpha: 0.1),
                    child: const Icon(Icons.person, color: corAzulEscuro),
                  ),
                  title: Text(
                    f['nome'] ?? 'Sem Nome',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: corAzulEscuro),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Função: ${f['funcao'] ?? f['tipo'] ?? 'Não informada'}'),
                      Text('Regime: ${f['forma_contratacao'] ?? 'Não informado'}'),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}