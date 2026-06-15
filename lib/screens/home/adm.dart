// screens/home/adm.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http; // Importante para buscar as trocas
import '../../components/card_destaque.dart';
import '../../components/card_grid_menu.dart';
import '../../components/etapas_cadastro/etapa3.dart';
import 'grid/pagina_cadastro_funcionarios.dart';
import 'grid/pagina_relatorios.dart';
import '../pagina_calendario_gestao.dart'; // 🌟 Import atualizado pela sua amiga

class HomeAdmin extends StatefulWidget {
  final String token;
  const HomeAdmin({super.key, required this.token});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  int _qtdTrocasPendentes = 0;

  @override
  void initState() {
    super.initState();
    _buscarQuantidadeTrocas();
  }

  // ── Lógica Backend: Contagem para o Balão ──
  Future<void> _buscarQuantidadeTrocas() async {
    try {
      final uri = Uri.parse('http://10.0.2.2:5000/pedidos_troca/pendentes');
      final res = await http.get(uri, headers: {
        'Authorization': 'Bearer ${widget.token}',
      });

      if (res.statusCode == 200) {
        final dynamic body = jsonDecode(res.body);
        
        // Se o log mostrou [{...}, {...}], body é uma List.
        if (body is List) {
          // Filtra manualmente pelo status para garantir
          int contagem = body.where((item) {
            final status = item['status']?.toString().toLowerCase() ?? '';
            return status == 'pendente';
          }).length;

          if (mounted) {
            setState(() {
              _qtdTrocasPendentes = contagem;
            });
            debugPrint("DEBUG: Contagem atualizada para $_qtdTrocasPendentes");
          }
        }
      }
    } catch (e) {
      debugPrint('Erro: $e');
    }
  }

  String? _extrairRoleDoToken(String tokenJWT) {
    try {
      final partes = tokenJWT.split('.');
      if (partes.length < 2) return null;
      String payloadNormalizado = base64Url.normalize(partes[1]);
      String payloadDecodificado = utf8.decode(base64Url.decode(payloadNormalizado));
      final Map<String, dynamic> mapaToken = jsonDecode(payloadDecodificado);
      return mapaToken['role']?.toString();
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    const corAzulEscuro = Color.fromARGB(255, 9, 17, 131);
    const corFundoApp = Color(0xFFF4F6FA);
    final String? usuarioRole = _extrairRoleDoToken(widget.token);

    return Scaffold(
      backgroundColor: corFundoApp,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Olá, Administrador', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: corAzulEscuro)),
                      SizedBox(height: 4),
                      Text('Painel Geral de Controle', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                  StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return IconButton(
                        onPressed: () {},
                        icon: Badge(
                          label: Text('$_qtdTrocasPendentes'),
                          child: const Icon(Icons.notifications_none_outlined, color: corAzulEscuro, size: 28),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const CardDestaque(),
              const SizedBox(height: 32),
              const Text('Ações Rápidas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: corAzulEscuro)),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    CardGridMenu(
                      icone: Icons.local_hospital_outlined,
                      titulo: 'Gerenciar\nHospital',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Etapa3(ehTelaIndependente: true, role: usuarioRole))),
                    ),
                    CardGridMenu(
                      icone: Icons.person_add_alt_1_outlined,
                      titulo: 'Adicionar\nFuncionários',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PaginaCadastroFuncionarios(ehTelaIndependente: true))),
                    ),
                    CardGridMenu(
                      icone: Icons.calendar_month_outlined,
                      titulo: 'Escalas e\nTurnos',
                      // 🌟 Nova rota integrada: aponta para a Gestão de Calendário passando o token
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PaginaCalendarioGestao(token: widget.token))),
                    ),
                    CardGridMenu(
                      icone: Icons.bar_chart_outlined,
                      titulo: 'Relatórios\nEstatísticos',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TelaRelatorios(token: widget.token))),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}