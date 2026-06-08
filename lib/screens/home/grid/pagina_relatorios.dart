import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../components/card_resumo.dart';
import '../../../components/grafico.dart';
import '../../../components/lista_de_contrato.dart';
import 'relatorios/tela_detalhes_contratacao.dart';

class TelaRelatorios extends StatefulWidget {
  final String token;

  const TelaRelatorios({super.key, required this.token});

  @override
  State<TelaRelatorios> createState() => _TelaRelatoriosState();
}

class _TelaRelatoriosState extends State<TelaRelatorios> {
  late Future<Map<String, dynamic>> _dadosDashboardFuture;
  final int _anoAtual = DateTime.now().year;
  final int _mesAtual = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() {
    _dadosDashboardFuture = _buscarDadosDashboard(_anoAtual, _mesAtual);
  }

  Future<Map<String, dynamic>> _buscarDadosDashboard(int ano, int mes) async {
    final url = Uri.parse(
      'http://10.0.2.2:5000/relatorios/dashboard/mensal?ano=$ano&mes=$mes',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Erro do servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Falha ao conectar ao backend: $e');
    }
  }

  Color _obterCorSetor(String nome) {
    switch (nome.toLowerCase()) {
      case 'clínica médica':
      case 'clinica medica':
        return const Color(0xFF3948F5);
      case 'pediatria':
        return Colors.orange;
      case 'cirurgia geral':
        return Colors.teal;
      case 'enfermagem':
        return Colors.redAccent;
      case 'recepção':
      case 'recepcao':
        return Colors.amber;
      default:
        return Colors.blueGrey;
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
          'Relatórios',
          style: TextStyle(color: corAzulEscuro, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: corAzulEscuro),
            onPressed: () => setState(() {
              _carregarDados();
            }),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dadosDashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: corAzulVibrante),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                ),
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Nenhum dado encontrado.'));
          }

          final dados = snapshot.data!;

          final int totalEquipe = dados['total_equipe'] ?? 0;
          final int plantoesConcluidos = dados['plantoes_concluidos'] ?? 0;
          final int trocasEfetuadas = dados['trocas_efetuadas'] ?? 0;

          final absenteismo = dados['absenteismo'] ?? {};
          final int totalFaltas =
              (absenteismo['justificado'] ?? 0) +
              (absenteismo['injustificado'] ?? 0);

          final Map<String, dynamic> horasPorSetor =
              dados['horas_por_setor'] ?? {};
          final Map<String, dynamic> ocupacaoPorSetor =
              dados['percentual_equipe_por_setor'] ?? {};
          final Map<String, dynamic> formasContratacao =
              dados['formas_contratacao'] ?? {};

          double maxHoras = horasPorSetor.values.fold(
            0.0,
            (max, e) => (e as num).toDouble() > max ? e.toDouble() : max,
          );
          if (maxHoras == 0) maxHoras = 1.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Visão Geral do Mês',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: corAzulEscuro,
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: CardResumo(
                        titulo: 'Total de\nFuncionários',
                        valor: totalEquipe.toString(),
                        icone: Icons.people_alt_outlined,
                        cor: corAzulVibrante,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CardResumo(
                        titulo: 'Plantões\nRealizados',
                        valor: plantoesConcluidos.toString(),
                        icone: Icons.check_circle_outline,
                        cor: Colors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                const Text(
                  'Frequência e Assiduidade',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: corAzulEscuro,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CardResumo(
                        titulo: 'Faltas e\nAtestados',
                        valor: totalFaltas.toString(),
                        icone: Icons.warning_amber_rounded,
                        cor: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CardResumo(
                        titulo: 'Trocas de\nPlantão',
                        valor: trocasEfetuadas.toString(),
                        icone: Icons.swap_horiz_rounded,
                        cor: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Horas Trabalhadas por Setor',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: corAzulEscuro,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (horasPorSetor.isEmpty)
                        const Text('Nenhum plantão concluído neste mês.')
                      else
                        ...horasPorSetor.entries.map((entry) {
                          double horas = (entry.value as num).toDouble();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Grafico(
                              label: entry.key,
                              porcentagem:
                                  horas /
                                  maxHoras,
                              valorTexto: '${horas.toStringAsFixed(1)}h',
                              cor: _obterCorSetor(entry.key),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Distribuição da Equipe por Setor',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: corAzulEscuro,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (ocupacaoPorSetor.isEmpty)
                        const Text('Sem funcionários vinculados a setores.')
                      else
                        ...ocupacaoPorSetor.entries.map((entry) {
                          double pct = (entry.value as num).toDouble();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Grafico(
                              label: entry.key,
                              porcentagem:
                                  pct /
                                  100,
                              valorTexto: '${pct.toStringAsFixed(1)}%',
                              cor: _obterCorSetor(entry.key),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                const Text(
                  'Forma de Contratação',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: corAzulEscuro,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      ItemListaContrato(
                        titulo: 'CLT',
                        subtitulo:
                            '${formasContratacao['CLT'] ?? 0} funcionários',
                        icone: Icons.badge_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TelaDetalhesContratacao(
                                tipoContrato: 'CLT',
                                token: widget.token,
                              ),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      ItemListaContrato(
                        titulo: 'PJ',
                        subtitulo:
                            '${formasContratacao['PJ'] ?? 0} funcionários',
                        icone: Icons.business_center_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TelaDetalhesContratacao(
                                tipoContrato: 'PJ',
                                token: widget.token,
                              ),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      ItemListaContrato(
                        titulo: 'Cooperado',
                        subtitulo:
                            '${formasContratacao['Cooperado'] ?? 0} funcionários',
                        icone: Icons.handshake_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TelaDetalhesContratacao(
                                tipoContrato: 'Cooperado',
                                token: widget.token,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}