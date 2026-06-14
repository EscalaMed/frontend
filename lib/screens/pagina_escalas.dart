// screens/pagina_escalas.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../components/cabecalho2.dart';

class _Escala {
  final int id;
  final DateTime dataInicio;
  final DateTime dataFim;
  final String funcionario;
  final String setor;

  // 🌟 BLINDAGEM: tryParse evita que a tela quebre se o JSON vier com formato diferente
  _Escala.fromJson(Map<String, dynamic> j)
      : id = int.tryParse(j['id']?.toString() ?? '0') ?? 0,
        dataInicio = DateTime.tryParse(j['data_inicio']?.toString() ?? '') ?? DateTime.now(),
        dataFim = j['data_fim'] != null
            ? DateTime.tryParse(j['data_fim'].toString()) ?? DateTime.now()
            : DateTime.tryParse(j['data_inicio']?.toString() ?? '') ?? DateTime.now(),
        funcionario = j['funcionario']?.toString() ?? 'Sem Titular',
        setor = j['setor']?.toString() ?? 'Geral';

  String get turno {
    final h = dataInicio.hour;
    if (h >= 6 && h < 14) return 'Manhã';
    if (h >= 14 && h < 22) return 'Tarde';
    return 'Noite';
  }

  String get horario {
    String fmt(DateTime d) => '${d.hour.toString().padLeft(2, '0')}h';
    return '${fmt(dataInicio)}–${fmt(dataFim)}';
  }
}

class PaginaEscalas extends StatefulWidget {
  final String token; // 🌟 SEGURANÇA: Agora exige o token

  const PaginaEscalas({super.key, required this.token});
  @override
  State<PaginaEscalas> createState() => _PaginaEscalasState();
}

class _PaginaEscalasState extends State<PaginaEscalas> {
  static const _cor = Color.fromARGB(255, 9, 17, 131);
  static const _baseUrl = 'http://10.0.2.2:5000'; // IP para emulador Android

  DateTime _mes = DateTime.now();
  DateTime? _diaSel;
  bool _carregando = false;

  // Armazena os dados do backend agrupados por dia ('YYYY-MM-DD')
  Map<String, List<_Escala>> _dadosBackend = {};

  @override
  void initState() {
    super.initState();
    _buscarEscalas();
  }

  Future<void> _buscarEscalas() async {
    setState(() {
      _carregando = true;
      _dadosBackend = {};
    });

    try {
      final uri = Uri.parse('$_baseUrl/api/escalas/mes')
          .replace(queryParameters: {'ano': '${_mes.year}', 'mes': '${_mes.month}'});

      // 🌟 SEGURANÇA: Usa o token da página em vez de abrir o secure_storage
      final res = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      });

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final lista = body['escalas_mes'] as List? ?? [];
        
        final mapaTemporario = <String, List<_Escala>>{};
        
        for (final item in lista) {
          if (item is Map<String, dynamic>) {
            try { // Protege cada escala individual
              final escala = _Escala.fromJson(item);
              final chaveData = _ch(escala.dataInicio);
              mapaTemporario.putIfAbsent(chaveData, () => []).add(escala);
            } catch (e) {
              debugPrint("Erro ao ler uma escala específica: $e");
            }
          }
        }
        
        setState(() {
          _dadosBackend = mapaTemporario;
        });
      }
    } catch (e) {
      debugPrint("Erro ao buscar escalas: $e");
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _mudarMes(int delta) {
    setState(() {
      _mes = DateTime(_mes.year, _mes.month + delta);
      _diaSel = null;
    });
    _buscarEscalas();
  }

  String _ch(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      
  List<_Escala> get _doDia => _diaSel == null ? [] : (_dadosBackend[_ch(_diaSel!)] ?? []);
  bool _tem(DateTime d) => _dadosBackend.containsKey(_ch(d));

  // Calculo de Métricas Dinâmicas
  int get _totalMes => _dadosBackend.values.fold(0, (s, l) => s + l.length);
  int get _diasMes => _dadosBackend.keys.length;
  int get _setoresUnicos {
    final setores = <String>{};
    for (var lista in _dadosBackend.values) {
      for (var e in lista) {
        setores.add(e.setor);
      }
    }
    return setores.length;
  }

  static const _meses = ['Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'];
  String _nomeMes(DateTime d) => '${_meses[d.month - 1]} ${d.year}';
  String _nomeMesS(int m) => _meses[m - 1].substring(0, 3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Column(children: [

        Cabecalho2(
          titulo: 'Escalas e Turnos',
          metricas: [
            Metrica('$_totalMes', 'Plantões'),
            Metrica('$_diasMes', 'Dias'),
            Metrica('$_setoresUnicos', 'Setores')
          ],
          acaoDireita: _carregando
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : IconButton(
                  onPressed: _buscarEscalas,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
          extras: [
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              IconButton(
                  onPressed: _carregando ? null : () => _mudarMes(-1),
                  icon: const Icon(Icons.chevron_left, color: Colors.white)),
              Text(_nomeMes(_mes),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              IconButton(
                  onPressed: _carregando ? null : () => _mudarMes(1),
                  icon: const Icon(Icons.chevron_right, color: Colors.white)),
            ]),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['D', 'S', 'T', 'Q', 'Q', 'S', 'S']
                    .map((d) => SizedBox(
                        width: 36,
                        child: Text(d,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white60))))
                    .toList()),
            const SizedBox(height: 6),
            ..._grade(),
          ],
        ),

        Expanded(
            child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                  _diaSel != null
                      ? '${_diaSel!.day} de ${_nomeMesS(_diaSel!.month)}'
                      : 'Selecione um dia',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _cor)),
              if (_doDia.isNotEmpty)
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: _cor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(20)),
                    child: Text('${_doDia.length} turno(s)',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _cor))),
            ]),
            const SizedBox(height: 12),
            Expanded(child: _lista()),
          ]),
        )),
      ])),
    );
  }

  // Grade do calendário
  List<Widget> _grade() {
    final primeiro = DateTime(_mes.year, _mes.month, 1);
    final ultimo = DateTime(_mes.year, _mes.month + 1, 0);
    final semanas = <Widget>[];
    int dia = 1 - (primeiro.weekday % 7);

    while (dia <= ultimo.day) {
      final celulas = <Widget>[];
      for (int c = 0; c < 7; c++, dia++) {
        if (dia < 1 || dia > ultimo.day) {
          celulas.add(const SizedBox(width: 36, height: 40));
          continue;
        }
        final d = DateTime(_mes.year, _mes.month, dia);
        final sel = _diaSel?.day == dia && _diaSel?.month == _mes.month;
        final hoje = DateTime.now();
        final ehHoje = d.day == hoje.day && d.month == hoje.month && d.year == hoje.year;

        celulas.add(GestureDetector(
          onTap: () => setState(() => _diaSel = d),
          child: SizedBox(
              width: 36,
              height: 40,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: sel ? Colors.white : ehHoje ? Colors.white24 : Colors.transparent,
                        shape: BoxShape.circle),
                    child: Text('$dia',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: (sel || ehHoje) ? FontWeight.bold : FontWeight.normal,
                            color: sel ? _cor : Colors.white))),
                if (_tem(d) && !sel)
                  Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(color: Colors.white70, shape: BoxShape.circle)),
              ])),
        ));
      }
      semanas.add(Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: celulas)));
    }
    return semanas;
  }

  // Lista de escalas do dia selecionado
  Widget _lista() {
    if (_diaSel == null) return _vazio(Icons.touch_app_outlined, 'Toque em um dia para ver as escalas');
    if (_doDia.isEmpty) return _vazio(Icons.event_busy_outlined, 'Nenhuma escala para este dia');
    return ListView.separated(
      itemCount: _doDia.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _CardEscala(escala: _doDia[i]),
    );
  }

  Widget _vazio(IconData ic, String msg) => Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(ic, size: 52, color: _cor.withValues(alpha: 0.2)),
        const SizedBox(height: 12),
        Text(msg, style: TextStyle(fontSize: 14, color: _cor.withValues(alpha: 0.4))),
      ]));
}

// Card de escala
class _CardEscala extends StatelessWidget {
  final _Escala e;
  const _CardEscala({required _Escala escala}) : e = escala;

  static const _cores = {
    'Manhã': Color(0xFFF57F17),
    'Tarde': Color(0xFF1565C0),
    'Noite': Color(0xFF4A148C)
  };
  static const _icones = {
    'Manhã': Icons.wb_sunny_outlined,
    'Tarde': Icons.wb_cloudy_outlined,
    'Noite': Icons.nights_stay_outlined
  };

  Color get _cor => _cores[e.turno] ?? const Color(0xFF4A148C);
  IconData get _ic => _icones[e.turno] ?? Icons.schedule_outlined;

  @override
  Widget build(BuildContext context) {
    const azul = Color.fromARGB(255, 9, 17, 131);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFB0B5D9), width: 1.5),
          borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: _cor.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(_ic, color: _cor, size: 20)),
        const SizedBox(width: 12),
        Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(e.funcionario, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: azul)),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.domain_outlined, size: 12, color: azul.withValues(alpha: 0.5)),
            const SizedBox(width: 4),
            Text(e.setor, style: TextStyle(fontSize: 12, color: azul.withValues(alpha: 0.6))),
            const SizedBox(width: 10),
            Icon(Icons.access_time_outlined, size: 12, color: azul.withValues(alpha: 0.5)),
            const SizedBox(width: 4),
            Text(e.horario, style: TextStyle(fontSize: 12, color: azul.withValues(alpha: 0.6))),
          ]),
        ])),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: _cor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(e.turno, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _cor))),
      ]),
    );
  }
}