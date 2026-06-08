// screens/pagina_escalas.dart
import 'package:flutter/material.dart';
import '../components/cabecalho2.dart';

class PaginaEscalas extends StatefulWidget {
  const PaginaEscalas({super.key});
  @override
  State<PaginaEscalas> createState() => _PaginaEscalasState();
}

class _PaginaEscalasState extends State<PaginaEscalas> {
  static const _cor = Color.fromARGB(255, 9, 17, 131);

  DateTime _mes = DateTime(2025, 6);
  DateTime? _diaSel;

  final _dados = <String, List<_Escala>>{
    '2025-06-10': [_Escala('Manhã','Dr. Carlos Mendes','UTI','06h–14h'),
                   _Escala('Tarde','Enf. Ana Paula','Clínica Geral','14h–22h')],
    '2025-06-12': [_Escala('Noite','Tec. Roberto Lima','Emergência','22h–06h')],
    '2025-06-15': [_Escala('Manhã','Dra. Fernanda Costa','Pediatria','06h–14h'),
                   _Escala('Tarde','Dr. Carlos Mendes','UTI','14h–22h'),
                   _Escala('Noite','Enf. Ana Paula','Clínica Geral','22h–06h')],
    '2025-06-20': [_Escala('Tarde','Tec. Roberto Lima','Emergência','14h–22h')],
  };

  String _ch(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
  List<_Escala> get _doDia => _diaSel == null ? [] : (_dados[_ch(_diaSel!)] ?? []);
  bool _tem(DateTime d) => _dados.containsKey(_ch(d));

  String get _prefMes => '${_mes.year}-${_mes.month.toString().padLeft(2,'0')}';
  int get _totalMes => _dados.entries.where((e) => e.key.startsWith(_prefMes)).fold(0,(s,e)=>s+e.value.length);
  int get _diasMes  => _dados.keys.where((k) => k.startsWith(_prefMes)).length;

  static const _meses = ['Janeiro','Fevereiro','Março','Abril','Maio','Junho',
                          'Julho','Agosto','Setembro','Outubro','Novembro','Dezembro'];
  String _nomeMes(DateTime d)   => '${_meses[d.month-1]} ${d.year}';
  String _nomeMesS(int m)       => _meses[m-1].substring(0,3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: Column(children: [
        // ── Cabeçalho com calendário embutido ──────────────────────
        Cabecalho2(
          titulo: 'Escalas e Turnos',
          metricas: [Metrica('$_totalMes','Plantões'), Metrica('$_diasMes','Dias'), Metrica('3','Setores')],
          extras: [
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              IconButton(
                onPressed: () => setState(() { _mes = DateTime(_mes.year, _mes.month-1); _diaSel=null; }),
                icon: const Icon(Icons.chevron_left, color: Colors.white)),
              Text(_nomeMes(_mes),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              IconButton(
                onPressed: () => setState(() { _mes = DateTime(_mes.year, _mes.month+1); _diaSel=null; }),
                icon: const Icon(Icons.chevron_right, color: Colors.white)),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['D','S','T','Q','Q','S','S'].map((d) => SizedBox(width: 36,
                  child: Text(d, textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white60)))).toList()),
            const SizedBox(height: 6),
            ..._grade(),
          ],
        ),

        // ── Área inferior: título + lista ────────────────────────────
        Expanded(child: Padding(
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
                  decoration: BoxDecoration(color: _cor.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
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

  // ── Grade do calendário ────────────────────────────────────────────
  List<Widget> _grade() {
    final primeiro = DateTime(_mes.year, _mes.month, 1);
    final ultimo   = DateTime(_mes.year, _mes.month + 1, 0);
    final semanas  = <Widget>[];
    int dia = 1 - (primeiro.weekday % 7);

    while (dia <= ultimo.day) {
      final celulas = <Widget>[];
      for (int c = 0; c < 7; c++, dia++) {
        if (dia < 1 || dia > ultimo.day) {
          celulas.add(const SizedBox(width: 36, height: 40));
          continue;
        }
        final d      = DateTime(_mes.year, _mes.month, dia);
        final sel    = _diaSel?.day == dia && _diaSel?.month == _mes.month;
        final hoje   = DateTime.now();
        final ehHoje = d.day==hoje.day && d.month==hoje.month && d.year==hoje.year;

        celulas.add(GestureDetector(
          onTap: () => setState(() => _diaSel = d),
          child: SizedBox(width: 36, height: 40,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                width: 32, height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: sel ? Colors.white : ehHoje ? Colors.white24 : Colors.transparent,
                  shape: BoxShape.circle),
                child: Text('$dia', style: TextStyle(fontSize: 13,
                    fontWeight: (sel||ehHoje) ? FontWeight.bold : FontWeight.normal,
                    color: sel ? _cor : Colors.white))),
              if (_tem(d) && !sel)
                Container(width: 4, height: 4,
                    decoration: const BoxDecoration(color: Colors.white70, shape: BoxShape.circle)),
            ])),
        ));
      }
      semanas.add(Padding(padding: const EdgeInsets.only(bottom: 2),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: celulas)));
    }
    return semanas;
  }

  // ── Lista de escalas do dia selecionado ────────────────────────────
  Widget _lista() {
    if (_diaSel == null) return _vazio(Icons.touch_app_outlined, 'Toque em um dia para ver as escalas');
    if (_doDia.isEmpty)  return _vazio(Icons.event_busy_outlined, 'Nenhuma escala para este dia');
    return ListView.separated(
      itemCount: _doDia.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _CardEscala(escala: _doDia[i]),
    );
  }

  Widget _vazio(IconData ic, String msg) => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(ic, size: 52, color: _cor.withOpacity(0.2)),
      const SizedBox(height: 12),
      Text(msg, style: TextStyle(fontSize: 14, color: _cor.withOpacity(0.4))),
    ]));
}

// ── Modelo ─────────────────────────────────────────────────────────────
class _Escala {
  final String turno, funcionario, setor, horario;
  const _Escala(this.turno, this.funcionario, this.setor, this.horario);
}

// ── Card de escala ─────────────────────────────────────────────────────
class _CardEscala extends StatelessWidget {
  final _Escala e;
  const _CardEscala({required _Escala escala}) : e = escala;

  static const _cores  = {'Manhã':Color(0xFFF57F17),'Tarde':Color(0xFF1565C0),'Noite':Color(0xFF4A148C)};
  static const _icones = {'Manhã':Icons.wb_sunny_outlined,'Tarde':Icons.wb_cloudy_outlined,'Noite':Icons.nights_stay_outlined};

  Color    get _cor => _cores[e.turno]  ?? const Color(0xFF4A148C);
  IconData get _ic  => _icones[e.turno] ?? Icons.schedule_outlined;

  @override
  Widget build(BuildContext context) {
    const azul = Color.fromARGB(255, 9, 17, 131);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFB0B5D9), width: 1.5),
        borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Container(width: 44, height: 44,
            decoration: BoxDecoration(color: _cor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(_ic, color: _cor, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(e.funcionario,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: azul)),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.domain_outlined,      size: 12, color: azul.withOpacity(0.5)), const SizedBox(width: 4),
            Text(e.setor,   style: TextStyle(fontSize: 12, color: azul.withOpacity(0.6))),
            const SizedBox(width: 10),
            Icon(Icons.access_time_outlined, size: 12, color: azul.withOpacity(0.5)), const SizedBox(width: 4),
            Text(e.horario, style: TextStyle(fontSize: 12, color: azul.withOpacity(0.6))),
          ]),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: _cor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: Text(e.turno, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _cor))),
      ]),
    );
  }
}