// screens/pagina_meu_calendario.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../components/cabecalho2.dart';
import 'pagina_troca_plantao.dart';

// ── Modelo de plantão vindo do back-end (Agora 100% Blindado) ───────
class _PlantaoItem {
  final int id;
  final DateTime dataInicio;
  final DateTime dataFim;
  final String funcao;
  final String status;

  const _PlantaoItem({
    required this.id,
    required this.dataInicio,
    required this.dataFim,
    required this.funcao,
    required this.status,
  });

  factory _PlantaoItem.fromJson(Map<String, dynamic> j) {
    // Conversão de data ultra segura (sem alterar o fuso horário que quebra os dias)
    final dataIn = DateTime.tryParse(j['data_inicio']?.toString() ?? '') ?? DateTime.now();
    final dataOut = j['data_fim'] != null 
        ? DateTime.tryParse(j['data_fim'].toString()) ?? dataIn
        : dataIn;

    return _PlantaoItem(
      // tryParse garante que não vai quebrar se o ID vier como String ou faltar
      id:         int.tryParse(j['id']?.toString() ?? '0') ?? 0, 
      dataInicio: dataIn,
      dataFim:    dataOut,
      funcao:     j['funcao']?.toString() ?? 'Plantão',
      status:     j['status']?.toString() ?? 'agendado',
    );
  }

  String get turno {
    final h = dataInicio.hour;
    if (h >= 6  && h < 14) return 'Manhã';
    if (h >= 14 && h < 22) return 'Tarde';
    return 'Noite';
  }

  String get horario {
    String fmt(DateTime d) => '${d.hour.toString().padLeft(2,'0')}h';
    return '${fmt(dataInicio)}–${fmt(dataFim)}';
  }
}

class PaginaMeuCalendario extends StatefulWidget {
  final String token;
  final String nomeUsuario;

  const PaginaMeuCalendario({
    super.key,
    required this.token,
    this.nomeUsuario = 'Funcionário',
  });

  @override
  State<PaginaMeuCalendario> createState() => _State();
}

class _State extends State<PaginaMeuCalendario> {
  static const _cor      = Color.fromARGB(255, 9, 17, 131);
  static const _baseUrl  = 'http://10.0.2.2:5000'; // IP Local

  DateTime  _mes      = DateTime.now();
  DateTime? _diaSel;
  bool      _carregando = false;

  Map<String, List<_PlantaoItem>> _plantoesMes = {};
  List<_PlantaoItem> _plantoesDia = [];

  int get _totalMes   => _plantoesMes.values.fold(0, (s, l) => s + l.length);
  int get _diasTrabalhados => _plantoesMes.keys.where((k) => k.startsWith(_prefMes)).length;

  String get _prefMes => '${_mes.year}-${_mes.month.toString().padLeft(2,'0')}';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${widget.token}',
  };

  @override
  void initState() {
    super.initState();
    _carregarMes();
  }

  Future<void> _carregarMes() async {
    setState(() { _carregando = true; _plantoesMes = {}; _diaSel = null; _plantoesDia = []; });
    try {
      final uri = Uri.parse('$_baseUrl/api/calendario/mes')
          .replace(queryParameters: {'ano': '${_mes.year}', 'mes': '${_mes.month}'});
      final res = await http.get(uri, headers: _headers);

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final lista = body['plantoes_mes'] as List? ?? [];
        final mapa = <String, List<_PlantaoItem>>{};
        
        for (final j in lista) {
          if (j is Map<String, dynamic>) {
            try { // Protege o loop: se 1 plantão estiver corrompido, carrega o resto!
              final item = _PlantaoItem.fromJson(j);
              final chave = _chave(item.dataInicio);
              mapa.putIfAbsent(chave, () => []).add(item);
            } catch (e) {
              debugPrint('Erro ao converter plantão (Mês): $e');
            }
          }
        }
        _plantoesMes = mapa;
      }
    } catch (e) {
      debugPrint("Erro ao carregar calendário: $e");
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _carregarDia(DateTime dia) async {
    setState(() { _diaSel = dia; _plantoesDia = []; _carregando = true; });
    try {
      final uri = Uri.parse('$_baseUrl/api/calendario/dia').replace(queryParameters: {
        'ano': '${dia.year}', 'mes': '${dia.month}', 'dia': '${dia.day}',
      });
      final res = await http.get(uri, headers: _headers);
      
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final lista = body['plantoes_dia'] as List? ?? [];
        
        final plantoes = <_PlantaoItem>[];
        for (final j in lista) {
          if (j is Map<String, dynamic>) {
            try {
              plantoes.add(_PlantaoItem.fromJson(j));
            } catch (e) {
              debugPrint('Erro ao converter plantão (Dia): $e');
            }
          }
        }
        _plantoesDia = plantoes;
      } else {
        _plantoesDia = _plantoesMes[_chave(dia)] ?? [];
      }
    } catch (_) {
      _plantoesDia = _plantoesMes[_chave(dia)] ?? [];
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _mudarMes(int delta) {
    _mes = DateTime(_mes.year, _mes.month + delta);
    _carregarMes();
  }

  String _chave(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';

  bool _temPlantao(DateTime d) => _plantoesMes.containsKey(_chave(d));

  static const _meses = [
    'Janeiro','Fevereiro','Março','Abril','Maio','Junho',
    'Julho','Agosto','Setembro','Outubro','Novembro','Dezembro',
  ];
  String _nomeMes(DateTime d) => '${_meses[d.month - 1]} ${d.year}';
  String _nomeMesS(int m)     => _meses[m - 1].substring(0, 3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: Column(children: [
        Cabecalho2(
          titulo: 'Meu Calendário',
          metricas: [
            Metrica('$_totalMes',        'Plantões'),
            Metrica('$_diasTrabalhados', 'Dias'),
          ],
          acaoDireita: _carregando
              ? const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70))
              : IconButton(
                  onPressed: _carregarMes,
                  icon: const Icon(Icons.refresh, color: Colors.white70, size: 20),
                  padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          extras: [
            const SizedBox(height: 12),
            Row(children: [
              _BotaoAcao(
                icone: Icons.add,
                label: 'Agendar\nPlantão',
                cor: const Color(0xFF00C9C8),
                onTap: () {},
              ),
              const SizedBox(width: 10),
              _BotaoAcao(
                icone: Icons.search,
                label: 'Pesquisar\nPlantão',
                cor: _cor,
                onTap: () {},
              ),
              const SizedBox(width: 10),
              _BotaoAcao(
                icone: Icons.swap_horiz_outlined,
                label: 'Confirmar\nTroca',
                cor: const Color(0xFF00C9C8).withValues(alpha: 0.6),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PaginaTrocaPlantao())),
              ),
            ]),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              IconButton(
                onPressed: _carregando ? null : () => _mudarMes(-1),
                icon: const Icon(Icons.chevron_left, color: Colors.white)),
              Text(_nomeMes(_mes),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              IconButton(
                onPressed: _carregando ? null : () => _mudarMes(1),
                icon: const Icon(Icons.chevron_right, color: Colors.white)),
              GestureDetector(
                onTap: () { _mes = DateTime.now(); _carregarMes(); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.calendar_today_outlined, color: Colors.white70, size: 13),
                    SizedBox(width: 4),
                    Text('Hoje', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ]))),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['DOM','SEG','TER','QUA','QUI','SEX','SÁB']
                  .map((d) => SizedBox(width: 38,
                      child: Text(d, textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white60))))
                  .toList()),
            const SizedBox(height: 6),
            ..._buildGrade(),
          ],
        ),
        Expanded(child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                _diaSel != null
                    ? '${_diaSel!.day == DateTime.now().day && _diaSel!.month == DateTime.now().month ? 'Hoje, ' : ''}${_diaSel!.day} de ${_nomeMesS(_diaSel!.month)}'
                    : 'Selecione um dia',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _cor)),
              if (_plantoesDia.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _cor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(20)),
                  child: Text('${_plantoesDia.length} plantão',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _cor))),
            ]),
            const SizedBox(height: 12),
            Expanded(child: _buildListaDia()),
          ]),
        )),
      ])),
    );
  }

  List<Widget> _buildGrade() {
    final primeiro = DateTime(_mes.year, _mes.month, 1);
    final ultimo   = DateTime(_mes.year, _mes.month + 1, 0);
    final semanas  = <Widget>[];
    int dia = 1 - (primeiro.weekday % 7);

    while (dia <= ultimo.day) {
      final celulas = <Widget>[];
      for (int c = 0; c < 7; c++, dia++) {
        if (dia < 1 || dia > ultimo.day) {
          celulas.add(const SizedBox(width: 38, height: 44));
          continue;
        }
        final d      = DateTime(_mes.year, _mes.month, dia);
        final sel    = _diaSel?.day == dia && _diaSel?.month == _mes.month;
        final hoje   = DateTime.now();
        final ehHoje = d.day == hoje.day && d.month == hoje.month && d.year == hoje.year;
        final tem    = _temPlantao(d);

        celulas.add(GestureDetector(
          onTap: () => _carregarDia(d),
          child: SizedBox(width: 38, height: 44,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                width: 34, height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: sel
                      ? Colors.white
                      : ehHoje
                          ? Colors.white24
                          : tem
                              ? Colors.white.withValues(alpha: 0.15)
                              : Colors.transparent,
                  shape: BoxShape.circle,
                  border: tem && !sel && !ehHoje
                      ? Border.all(color: Colors.white54, width: 1.5)
                      : null,
                ),
                child: Text('$dia', style: TextStyle(
                  fontSize: 13,
                  fontWeight: (sel || ehHoje || tem) ? FontWeight.bold : FontWeight.normal,
                  color: sel ? _cor : Colors.white,
                ))),
              if (tem && !sel)
                Container(width: 4, height: 4,
                    decoration: const BoxDecoration(color: Color(0xFF00C9C8), shape: BoxShape.circle)),
            ])),
        ));
      }
      semanas.add(Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: celulas)));
    }
    return semanas;
  }

  Widget _buildListaDia() {
    if (_diaSel == null) {
      return _vazio(Icons.touch_app_outlined, 'Toque em um dia para ver seus plantões');
    }
    if (_carregando) {
      return const Center(child: CircularProgressIndicator(color: _cor));
    }
    if (_plantoesDia.isEmpty) {
      return _vazio(Icons.event_available_outlined, 'Nenhum plantão agendado neste dia');
    }
    return ListView.separated(
      itemCount: _plantoesDia.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _CardPlantao(item: _plantoesDia[i]),
    );
  }

  Widget _vazio(IconData ic, String msg) => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(ic, size: 52, color: _cor.withValues(alpha: 0.2)),
      const SizedBox(height: 12),
      Text(msg, textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: _cor.withValues(alpha: 0.4))),
    ]));
}

class _BotaoAcao extends StatelessWidget {
  final IconData icone;
  final String label;
  final Color cor;
  final VoidCallback onTap;
  const _BotaoAcao({required this.icone, required this.label, required this.cor, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(12)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icone, color: Colors.white, size: 22),
          const SizedBox(height: 6),
          Text(label, textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, height: 1.2)),
        ]),
      ),
    ),
  );
}

class _CardPlantao extends StatelessWidget {
  final _PlantaoItem item;
  const _CardPlantao({required this.item});

  static const _coresTurno = {
    'Manhã': Color(0xFFF57F17),
    'Tarde': Color(0xFF1565C0),
    'Noite': Color(0xFF4A148C),
  };
  static const _iconesTurno = {
    'Manhã': Icons.wb_sunny_outlined,
    'Tarde': Icons.wb_cloudy_outlined,
    'Noite': Icons.nights_stay_outlined,
  };

  Color    get _corTurno   => _coresTurno[item.turno]  ?? const Color(0xFF4A148C);
  IconData get _iconeTurno => _iconesTurno[item.turno] ?? Icons.schedule_outlined;

  Color  _corStatus(String s) {
    switch (s) {
      case 'agendado':          return const Color(0xFF1565C0);
      case 'concluido':
      case 'realizado':         return const Color(0xFF2E7D32);
      case 'solicitada_troca':  return const Color(0xFFF57F17);
      case 'em_aberto':         return const Color(0xFF8A94C9);
      case 'falta_justificada':
      case 'falta_injustificada': return const Color(0xFFC62828);
      default:                  return const Color(0xFF8A94C9);
    }
  }

  String _labelStatus(String s) {
    switch (s) {
      case 'agendado':             return 'Agendado';
      case 'concluido':            return 'Concluído';
      case 'realizado':            return 'Realizado';
      case 'solicitada_troca':     return 'Troca solicitada';
      case 'em_aberto':            return 'Em aberto';
      case 'falta_justificada':    return 'Falta justificada';
      case 'falta_injustificada':  return 'Falta injustificada';
      default:                     return s;
    }
  }

  @override
  Widget build(BuildContext context) {
    const azul = Color.fromARGB(255, 9, 17, 131);
    final corS = _corStatus(item.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFB0B5D9), width: 1.5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0,2))],
      ),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(color: _corTurno.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(_iconeTurno, color: _corTurno, size: 22)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.funcao,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: azul)),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.access_time_outlined, size: 13, color: azul.withValues(alpha: 0.5)),
            const SizedBox(width: 4),
            Text(item.horario,
                style: TextStyle(fontSize: 12, color: azul.withValues(alpha: 0.6))),
            const SizedBox(width: 10),
            Icon(Icons.label_outline, size: 13, color: azul.withValues(alpha: 0.5)),
            const SizedBox(width: 4),
            Text(item.turno,
                style: TextStyle(fontSize: 12, color: azul.withValues(alpha: 0.6))),
          ]),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: corS.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20)),
          child: Text(_labelStatus(item.status),
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: corS))),
      ]),
    );
  }
}