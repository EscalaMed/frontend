import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../components/card_grid_menu.dart';
import '../../components/etapas_cadastro/etapa3.dart';
import '../pagina_calendario_gestao.dart';
import '../pagina_configuracoes.dart';

class PaginaCoordenador extends StatefulWidget {
  final String token;

  const PaginaCoordenador({
    super.key,
    required this.token,
  });

  @override
  State<PaginaCoordenador> createState() => _PaginaCoordenadorState();
}

class _PaginaCoordenadorState extends State<PaginaCoordenador> {
  static const _cor      = Color.fromARGB(255, 9, 17, 131);
  static const _vibrante = Color(0xFF3948F5);
  static const _fundo    = Color(0xFFF4F6FA);
  static const _baseUrl  = 'http://10.0.2.2:5000';

  bool _carregando = true;
  
  // Variáveis vindas dinamicamente do Banco de Dados
  String _nomeDoBanco = 'Carregando...';
  String _setorDoBanco = '...';
  List<Map<String, dynamic>> _trocasPendentes = [];

  @override
  void initState() {
    super.initState();
    _buscarTodosOsDados();
  }

  Future<void> _buscarTodosOsDados() async {
    try {
      final String tokenJwt = widget.token;

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $tokenJwt',
      };

      // Prepara as duas requisições para rodarem juntas
      final uriPerfil = Uri.parse('$_baseUrl/api/perfil');
      final uriTrocas = Uri.parse('$_baseUrl/pedidos_troca/pendentes');

      final respostas = await Future.wait([
        http.get(uriPerfil, headers: headers),
        http.get(uriTrocas, headers: headers),
      ]);

      final resPerfil = respostas[0];
      final resTrocas = respostas[1];

      // 1. Processa o Perfil do Coordenador
      if (resPerfil.statusCode == 200) {
        final dadosPerfil = jsonDecode(resPerfil.body);
        _nomeDoBanco = dadosPerfil['nome'] ?? 'Coordenador';
        _setorDoBanco = dadosPerfil['setor'] ?? 'Geral';
      }

      // 2. Processa os Pedidos de Troca do Setor
      if (resTrocas.statusCode == 200) {
        final body = jsonDecode(resTrocas.body);
        setState(() {
          _trocasPendentes = List<Map<String, dynamic>>.from(
              body is List ? body : body['pedidos'] ?? []);
        });
      }
    } catch (e) {
      debugPrint("Erro ao carregar dados do coordenador: $e");
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _responderTroca(int index, int idTroca, bool aceitar) async {
    setState(() => _trocasPendentes.removeAt(index));
    
    try {
      final String tokenJwt = widget.token;
      final statusStr = aceitar ? 'aprovar' : 'recusar';
      final uri = Uri.parse('$_baseUrl/pedidos_troca/$idTroca/$statusStr'); 
      
      final res = await http.put(uri, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $tokenJwt',
      });

      if (res.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(aceitar ? 'Troca aprovada!' : 'Troca recusada.'),
            backgroundColor: aceitar ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))));
      } else {
        _buscarTodosOsDados(); // Se falhar no back, recarrega os dados reais
      }
    } catch (_) {
      _buscarTodosOsDados();
    }
  }

  void _navegar(Widget pagina) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => pagina));

  String _formatarDataParaCard(String? dataIso) {
    if (dataIso == null) return '';
    final d = DateTime.parse(dataIso);
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} - ${d.hour.toString().padLeft(2, '0')}h';
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(
          backgroundColor: _fundo,
          body: Center(child: CircularProgressIndicator(color: _cor)));
    }

    return Scaffold(
      backgroundColor: _fundo,
      body: SafeArea(
          child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Olá, ${_nomeDoBanco.split(' ').first}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _cor)),
              const SizedBox(height: 4),
              Text('Coordenador – $_setorDoBanco',
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ])),
            Stack(children: [
              IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none_outlined, color: _cor, size: 28)),
              if (_trocasPendentes.isNotEmpty)
                Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(color: Color(0xFFC62828), shape: BoxShape.circle),
                        child: Center(
                            child: Text('${_trocasPendentes.length}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold))))),
            ]),
          ]),

          const SizedBox(height: 24),

          Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [_cor, _vibrante], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: _vibrante.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))
                  ]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Meu Setor – $_setorDoBanco',
                    style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                const Text('Gestão Diária',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const _Mini('-', 'Plantões Hoje'),
                  _Mini('${_trocasPendentes.length}', 'Pendentes'),
                ]),
              ])),

          const SizedBox(height: 24),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Trocas Pendentes (${_trocasPendentes.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _cor)),
            if (_trocasPendentes.isEmpty) const Icon(Icons.check_circle_outline, color: Color(0xFF2E7D32), size: 20),
          ]),
          const SizedBox(height: 12),

          if (_trocasPendentes.isEmpty)
            Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFB0B5D9), width: 1.5),
                    borderRadius: BorderRadius.circular(12)),
                child: const Center(
                    child: Text('Nenhuma solicitação pendente.',
                        style: TextStyle(fontSize: 14, color: Color(0xFF8A94C9)))))
          else
            ...List.generate(_trocasPendentes.length, (i) {
              final troca = _trocasPendentes[i];
              final mapVisual = {
                'id': troca['id'] ?? 0,
                'nome': troca['solicitante_nome'] ?? 'Colaborador',
                'de': _formatarDataParaCard(troca['plantao_atual_inicio']),
                'para': _formatarDataParaCard(troca['plantao_desejado_inicio']),
                'motivo': troca['motivo'] ?? 'Sem motivo informado',
                'tempo': troca['criado_em'] != null ? 'Recente' : '',
              };

              return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CardTroca(
                    troca: mapVisual,
                    onAceitar: () => _responderTroca(i, mapVisual['id'] as int, true),
                    onRecusar: () => _responderTroca(i, mapVisual['id'] as int, false),
                  ));
            }),

          const SizedBox(height: 24),

          const Text('Ações Rápidas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _cor)),
          const SizedBox(height: 16),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              CardGridMenu(
                icone: Icons.calendar_month_outlined,
                titulo: 'Escalas e\nTurnos',
                onTap: () => _navegar(PaginaCalendarioGestao(token: widget.token)),
              ),
              CardGridMenu(
                icone: Icons.local_hospital_outlined,
                titulo: 'Gerenciar\nHospital',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Etapa3(
                        ehTelaIndependente: true,
                        role: 'coordenador',
                      ),
                    ),
                  );
                },
              ),
              CardGridMenu(
                icone: Icons.settings_outlined,
                titulo: 'Configurações',
                onTap: () => _navegar(const PaginaConfiguracoes()),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ]),
      )),
    );
  }
}

class _Mini extends StatelessWidget {
  final String valor, label;
  const _Mini(this.valor, this.label);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(valor, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ]);
}

class _CardTroca extends StatelessWidget {
  final Map<String, dynamic> troca;
  final VoidCallback onAceitar, onRecusar;
  const _CardTroca({required this.troca, required this.onAceitar, required this.onRecusar});

  @override
  Widget build(BuildContext context) {
    const cor = Color.fromARGB(255, 9, 17, 131);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFB0B5D9), width: 1.5),
          borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFF4F6FA),
              child: Icon(Icons.person_outline, color: cor, size: 18)),
          const SizedBox(width: 10),
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(troca['nome'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: cor)),
            Text(troca['tempo'].toString(), style: TextStyle(fontSize: 11, color: cor.withValues(alpha: 0.4))),
          ])),
        ]),
        const SizedBox(height: 10),
        Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF4F6FA), borderRadius: BorderRadius.circular(8)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _LinhaTroca(
                  icone: Icons.arrow_upward_outlined,
                  cor: const Color(0xFFC62828),
                  label: 'Cede',
                  valor: troca['de'].toString()),
              const SizedBox(height: 4),
              _LinhaTroca(
                  icone: Icons.arrow_downward_outlined,
                  cor: const Color(0xFF2E7D32),
                  label: 'Recebe',
                  valor: troca['para'].toString()),
              const SizedBox(height: 4),
              _LinhaTroca(icone: Icons.notes_outlined, cor: cor, label: 'Motivo', valor: troca['motivo'].toString()),
            ])),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child: SizedBox(
                  height: 36,
                  child: OutlinedButton.icon(
                      onPressed: onRecusar,
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Recusar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFC62828),
                          side: const BorderSide(color: Color(0xFFC62828), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))))),
          const SizedBox(width: 10),
          Expanded(
              child: SizedBox(
                  height: 36,
                  child: ElevatedButton.icon(
                      onPressed: onAceitar,
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Aprovar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))))),
        ]),
      ]),
    );
  }
}

class _LinhaTroca extends StatelessWidget {
  final IconData icone; final Color cor; final String label, valor;
  const _LinhaTroca({required this.icone, required this.cor, required this.label, required this.valor});
  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icone, size: 13, color: cor), const SizedBox(width: 6),
        Text('$label: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: cor)),
        Expanded(child: Text(valor, style: const TextStyle(fontSize: 12, color: Color.fromARGB(255, 9, 17, 131)), overflow: TextOverflow.ellipsis)),
      ]);
}