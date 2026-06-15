// screens/home/pagina_funcionario.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../components/card_grid_menu.dart';
import '../pagina_meu_calendario.dart';
import '../pagina_troca_plantao.dart';
import '../pagina_configuracoes.dart';

class PaginaFuncionario extends StatefulWidget {
  final String token;

  const PaginaFuncionario({
    super.key,
    required this.token,
  });

  @override
  State<PaginaFuncionario> createState() => _PaginaFuncionarioState();
}

class _PaginaFuncionarioState extends State<PaginaFuncionario> {
  static const _cor = Color.fromARGB(255, 9, 17, 131);
  static const _vibrante = Color(0xFF3948F5);
  static const _fundo = Color(0xFFF4F6FA);
  static const _baseUrl = 'http://10.0.2.2:5000'; // IP do Emulador

  bool _carregando = true;

  // Variáveis do Banco de Dados
  String _nomeDoBanco = 'Carregando...';
  String _setorDoBanco = '...';

  Map<String, dynamic>? _proximoPlantao;
  List<_Item> _plantoesSemana = [];

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

      final hoje = DateTime.now();

      // Prepara as requisições
      final uriPerfil = Uri.parse('$_baseUrl/api/perfil');
      final uriCalendario = Uri.parse('$_baseUrl/api/calendario/mes')
          .replace(queryParameters: {'ano': '${hoje.year}', 'mes': '${hoje.month}'});

      // Dispara ao mesmo tempo
      final respostas = await Future.wait([
        http.get(uriPerfil, headers: headers),
        http.get(uriCalendario, headers: headers),
      ]);

      final resPerfil = respostas[0];
      final resCalendario = respostas[1];

      // Processa o Perfil
      if (resPerfil.statusCode == 200) {
        final dadosPerfil = jsonDecode(resPerfil.body);
        _nomeDoBanco = dadosPerfil['nome'] ?? 'Colaborador';
        _setorDoBanco = dadosPerfil['setor'] ?? 'Geral';
      }

      // Processa o Calendário
      if (resCalendario.statusCode == 200) {
        final bodyCal = jsonDecode(resCalendario.body);
        final lista = (bodyCal['plantoes_mes'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        _processarPlantoesLocais(lista, hoje);
      }
    } catch (e) {
      debugPrint("Erro ao conectar com o banco: $e");
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _processarPlantoesLocais(List<Map<String, dynamic>> plantoes, DateTime hoje) {
    // 1. Achar o Próximo Plantão
    final plantoesFuturos = plantoes.where((p) {
      final dataInicio = DateTime.parse(p['data_inicio']);
      return dataInicio.isAfter(hoje.subtract(const Duration(days: 1)));
    }).toList();

    plantoesFuturos.sort(
        (a, b) => DateTime.parse(a['data_inicio']).compareTo(DateTime.parse(b['data_inicio'])));

    if (plantoesFuturos.isNotEmpty) {
      _proximoPlantao = plantoesFuturos.first;
    }

    // 2. Montar a agenda "Desta Semana"
    _plantoesSemana = [];

    for (int i = 0; i < 7; i++) {
      final diaAtual = hoje.add(Duration(days: i));
      
      // Procura se tem plantão nesse exato dia
      final plantaoNoDia = plantoes.where((p) {
        final d = DateTime.parse(p['data_inicio']);
        return d.year == diaAtual.year && d.month == diaAtual.month && d.day == diaAtual.day;
      }).firstOrNull; 

      final diasSemanaStr = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
      final nomeDia = diasSemanaStr[diaAtual.weekday - 1];
      final dataFormatada =
          '${diaAtual.day.toString().padLeft(2, '0')}/${diaAtual.month.toString().padLeft(2, '0')}';

      if (plantaoNoDia != null) {
        final dataIn = DateTime.parse(plantaoNoDia['data_inicio']);
        
        String turnoStr = 'Manhã';
        _Turno tipoTurno = _Turno.manha;
        if (dataIn.hour >= 14 && dataIn.hour < 22) {
          turnoStr = 'Tarde';
          tipoTurno = _Turno.tarde;
        } else if (dataIn.hour >= 22 || dataIn.hour < 6) {
          turnoStr = 'Noite';
          tipoTurno = _Turno.noite;
        }

        _plantoesSemana.add(_Item(
            nomeDia, dataFormatada, turnoStr, plantaoNoDia['funcao'] ?? _setorDoBanco, tipoTurno));
      } else {
        _plantoesSemana.add(_Item(nomeDia, dataFormatada, 'Folga', '–', _Turno.folga));
      }
    }
  }

  void _navegar(BuildContext context, Widget pagina) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => pagina));

  String _formatarDataHora(String? dataIso) {
    if (dataIso == null) return '';
    final d = DateTime.parse(dataIso);
    final diasStr = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    
    // Calcula o turno
    String turnoStr = 'Manhã';
    if (d.hour >= 14 && d.hour < 22) turnoStr = 'Tarde';
    if (d.hour >= 22 || d.hour < 6) turnoStr = 'Noite';

    return '${diasStr[d.weekday - 1]} – $turnoStr (${d.hour.toString().padLeft(2, '0')}h)';
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
              Text('Setor: $_setorDoBanco', style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ])),
            IconButton(
                onPressed: () {},
                icon: const Badge(
                    label: Text('0'),
                    child: Icon(Icons.notifications_none_outlined, color: _cor, size: 28))),
          ]),
          const SizedBox(height: 24),
          
          // Novo Card Dinâmico da sua Amiga
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
                const Text('Próximo Plantão',
                    style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Text(
                    _proximoPlantao != null
                        ? _formatarDataHora(_proximoPlantao!['data_inicio'])
                        : 'Nenhum plantão agendado',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (_proximoPlantao != null) ...[
                  Builder(
                    builder: (context) {
                      final d = DateTime.parse(_proximoPlantao!['data_inicio']);
                      return Row(children: [
                        _Chip(icone: Icons.domain_outlined, texto: _proximoPlantao!['funcao'] ?? _setorDoBanco),
                        const SizedBox(width: 16),
                        _Chip(icone: Icons.access_time_outlined, texto: '${d.hour.toString().padLeft(2, '0')}h'),
                        const SizedBox(width: 16),
                        _Chip(icone: Icons.calendar_today_outlined, texto: '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}'),
                      ]);
                    }
                  )
                ]
              ])),
          const SizedBox(height: 24),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Esta Semana', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _cor)),
            GestureDetector(
                onTap: () => _navegar(context, PaginaMeuCalendario(token: widget.token, nomeUsuario: _nomeDoBanco)),
                child: const Text('Ver calendário',
                    style: TextStyle(fontSize: 13, color: _vibrante, fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: 12),

          ..._plantoesSemana.map((item) => Padding(padding: const EdgeInsets.only(bottom: 8), child: _CardDia(item: item))),

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
                icone: Icons.swap_horiz_outlined,
                titulo: 'Trocar\nPlantão',
                onTap: () => _navegar(context, const PaginaTrocaPlantao()),
              ),
              CardGridMenu(
                icone: Icons.settings_outlined,
                titulo: 'Configurações',
                onTap: () => _navegar(context, const PaginaConfiguracoes()),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ]),
      )),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icone;
  final String texto;
  const _Chip({required this.icone, required this.texto});
  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icone, size: 13, color: Colors.white70),
        const SizedBox(width: 4),
        Text(texto, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ]);
}

enum _Turno { manha, tarde, noite, folga }

class _Item {
  final String dia, data, turno, setor;
  final _Turno tipo;
  const _Item(this.dia, this.data, this.turno, this.setor, this.tipo);
}

class _CardDia extends StatelessWidget {
  final _Item item;
  const _CardDia({required this.item});

  static const _cores = {
    _Turno.manha: Color(0xFFF57F17),
    _Turno.tarde: Color(0xFF1565C0),
    _Turno.noite: Color(0xFF4A148C),
    _Turno.folga: Color(0xFF2E7D32)
  };
  static const _icones = {
    _Turno.manha: Icons.wb_sunny_outlined,
    _Turno.tarde: Icons.wb_cloudy_outlined,
    _Turno.noite: Icons.nights_stay_outlined,
    _Turno.folga: Icons.weekend_outlined
  };

  @override
  Widget build(BuildContext context) {
    const azul = Color.fromARGB(255, 9, 17, 131);
    final cor = _cores[item.tipo]!;
    final icone = _icones[item.tipo]!;
    final fol = item.tipo == _Turno.folga;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: fol ? Colors.transparent : const Color(0xFFB0B5D9), width: 1.5),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))
          ]),
      child: Row(children: [
        SizedBox(
            width: 40,
            child: Column(children: [
              Text(item.dia,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fol ? Colors.grey : azul)),
              Text(item.data.split('/')[0],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: fol ? Colors.grey : azul)),
            ])),
        Container(
            width: 1, height: 32, color: const Color(0xFFE0E4F0), margin: const EdgeInsets.symmetric(horizontal: 12)),
        Icon(icone, color: cor, size: 20),
        const SizedBox(width: 10),
        Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.turno,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: fol ? Colors.grey : azul)),
          if (!fol) Text(item.setor, style: const TextStyle(fontSize: 11, color: Color(0xFF8A94C9))),
        ])),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: cor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(item.turno, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: cor))),
      ]),
    );
  }
}