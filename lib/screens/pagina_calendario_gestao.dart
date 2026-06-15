// screens/pagina_calendario_gestao.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../components/cabecalho2.dart';
import 'home/grid/pagina_criar_plantao.dart';
import 'home/grid/pagina_listar_trocas_pendentes.dart';

// Modelo de plantão (BLINDADO)
class _PlantaoItem {
  final int    id;
  final DateTime dataInicio;
  final DateTime dataFim;
  final String funcao;
  final String status;
  final String funcionarioNome;
  final String setorNome;

  const _PlantaoItem({
    required this.id,
    required this.dataInicio,
    required this.dataFim,
    required this.funcao,
    required this.status,
    required this.funcionarioNome,
    required this.setorNome,
  });

  factory _PlantaoItem.fromJson(Map<String, dynamic> j) {
    final dataIn = DateTime.tryParse(j['data_inicio']?.toString() ?? '') ?? DateTime.now();
    final dataOut = j['data_fim'] != null 
        ? DateTime.tryParse(j['data_fim'].toString()) ?? dataIn
        : dataIn;

    return _PlantaoItem(
      id:               int.tryParse(j['id_plantao']?.toString() ?? j['id']?.toString() ?? '0') ?? 0,
      dataInicio:       dataIn,
      dataFim:          dataOut,
      funcao:           j['funcao']?.toString() ?? 'Plantão',
      status:           j['status']?.toString() ?? 'agendado',
      funcionarioNome:  j['funcionario_nome']?.toString() ?? 'Vaga em Aberto',
      setorNome:        j['setor_nome']?.toString() ?? 'Geral',
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

// Widget principal 
class PaginaCalendarioGestao extends StatefulWidget {
  final String? token;
  const PaginaCalendarioGestao({super.key, this.token});

  @override
  State<PaginaCalendarioGestao> createState() => _State();
}

class _State extends State<PaginaCalendarioGestao> {
  static const _cor      = Color.fromARGB(255, 9, 17, 131);
  static const _ciano    = Color(0xFF00C9C8);
  static const _baseUrl  = 'http://10.0.2.2:5000'; // IP para Emulador Android

  DateTime  _mes        = DateTime.now();
  DateTime? _diaSel;
  bool      _carregando = false;

  // Dados do back-end
  Map<String, List<_PlantaoItem>> _plantoesMes = {};
  List<_PlantaoItem> _plantoesDia              = [];

  // Listas para o filtro
  List<String> _setores       = [];
  List<String> _funcionarios  = []; // Resolvido: Agora é usado no modal

  // Filtros ativos
  String? _filtroSetor;
  String? _filtroFuncionario;
  String? _filtroTurno;
  String? _filtroStatus;
  bool get _temFiltroAtivo =>
      _filtroSetor != null || _filtroFuncionario != null ||
      _filtroTurno != null || _filtroStatus != null;

  // Métricas
  String get _prefMes => '${_mes.year}-${_mes.month.toString().padLeft(2,'0')}';
  int get _totalMes        => _plantoesMes.values.fold(0,(s,l) => s+l.length);
  int get _diasComPlantao  => _plantoesMes.keys.where((k) => k.startsWith(_prefMes)).length;
  int get _trocasPendentes => _plantoesMes.values.expand((l) => l)
      .where((p) => p.status == 'solicitada_troca').length;

  @override
  void initState() {
    super.initState();
    _carregarTudo();
  }

  Future<String?> _getToken() async {
    if (widget.token != null) return widget.token;
    const storage = FlutterSecureStorage();
    return storage.read(key: 'token_jwt');
  }

  Future<Map<String, String>> get _headers async {
    final t = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (t != null) 'Authorization': 'Bearer ${t.trim()}',
    };
  }

  Future<void> _carregarTudo() async {
    setState(() { _carregando = true; _plantoesMes = {}; _plantoesDia = []; _diaSel = null; });
    try {
      final h = await _headers;

      // Buscar Plantões
      final uriMes = Uri.parse('$_baseUrl/api/admin/plantoes')
          .replace(queryParameters: {'ano':'${_mes.year}','mes':'${_mes.month}'});
      final resMes = await http.get(uriMes, headers: h);

      if (resMes.statusCode == 200) {
        final body = jsonDecode(resMes.body);
        final lista = body is List ? body : [];
        final mapa = <String, List<_PlantaoItem>>{};
        
        for (final j in lista) {
          if(j is Map<String, dynamic>) {
            try {
              final item  = _PlantaoItem.fromJson(j);
              final chave = _chave(item.dataInicio);
              mapa.putIfAbsent(chave, () => []).add(item);
            } catch (e) {
              debugPrint('Erro no plantão do mes: $e');
            }
          }
        }
        _plantoesMes = mapa;
      }

      // Buscar Setores
      final resSetores = await http.get(Uri.parse('$_baseUrl/api/admin/setores'), headers: h);
      if (resSetores.statusCode == 200) {
        final lista = jsonDecode(resSetores.body) as List? ?? [];
        _setores = lista.map((s) => s['nome']?.toString() ?? '').where((n) => n.isNotEmpty).toList();
      }

      // Buscar Funcionários
      final resFuncs = await http.get(Uri.parse('$_baseUrl/api/admin/usuarios'), headers: h);
      if (resFuncs.statusCode == 200) {
        final lista = jsonDecode(resFuncs.body) as List? ?? [];
        _funcionarios = lista.map((f) => f['nome']?.toString() ?? '').where((n) => n.isNotEmpty).toList();
      }
    } catch (e) {
      debugPrint("Erro ao carregar tudo: $e");
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _carregarDia(DateTime dia) async {
    setState(() { _diaSel = dia; _plantoesDia = []; _carregando = true; });
    try {
      final h = await _headers;
      
      // Resolvido: Aviso de null-aware ('use_null_aware_elements')
      final Map<String, dynamic> params = {
        'ano':'${dia.year}',
        'mes':'${dia.month}',
        'dia':'${dia.day}'
      };
      
      if (_filtroSetor != null) params['setor'] = _filtroSetor;
      if (_filtroFuncionario != null) params['funcionario'] = _filtroFuncionario;
      if (_filtroStatus != null) params['status'] = _statusBackend(_filtroStatus!);

      final uri = Uri.parse('$_baseUrl/api/admin/plantoes').replace(queryParameters: params);
      final res = await http.get(uri, headers: h);
      
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final lista = body is List ? body : [];
        final plantoesTemp = <_PlantaoItem>[];
        for (final j in lista) {
          if(j is Map<String, dynamic>) {
            // Resolvido: Aviso empty_catches
            try { 
              plantoesTemp.add(_PlantaoItem.fromJson(j)); 
            } catch (e) {
              debugPrint('Erro ao parsear plantão do dia: $e');
            }
          }
        }
        _plantoesDia = plantoesTemp;
      } else {
        _plantoesDia = _filtrarLocal(_plantoesMes[_chave(dia)] ?? []);
      }
    } catch (_) {
      _plantoesDia = _filtrarLocal(_plantoesMes[_chave(dia)] ?? []);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  List<_PlantaoItem> _filtrarLocal(List<_PlantaoItem> lista) => lista.where((p) {
    if (_filtroSetor       != null && p.setorNome       != _filtroSetor)      return false;
    if (_filtroFuncionario != null && p.funcionarioNome != _filtroFuncionario) return false;
    if (_filtroTurno       != null && p.turno           != _filtroTurno)       return false;
    if (_filtroStatus      != null && p.status          != _statusBackend(_filtroStatus!)) return false;
    return true;
  }).toList();

  void _mudarMes(int delta) {
    _mes = DateTime(_mes.year, _mes.month + delta);
    _carregarTudo();
  }

  String _chave(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';

  bool _temPlantao(DateTime d) => _plantoesMes.containsKey(_chave(d));

  static const _meses = [
    'Janeiro','Fevereiro','Março','Abril','Maio','Junho',
    'Julho','Agosto','Setembro','Outubro','Novembro','Dezembro',
  ];
  String _nomeMes(DateTime d) => '${_meses[d.month-1]} ${d.year}';
  String _nomeMesS(int m)     => _meses[m-1].substring(0,3);

  String _statusBackend(String label) => const {
    'Agendado':           'agendado',
    'Concluído':          'concluido',
    'Troca solicitada':   'solicitada_troca',
    'Em aberto':          'em_aberto',
    'Falta justificada':  'falta_justificada',
    'Falta injustificada':'falta_injustificada',
  }[label] ?? label;

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg), backgroundColor: _cor,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))));

  void _abrirFiltro() {
    String? setor  = _filtroSetor;
    String? funcionario = _filtroFuncionario;
    String? turno  = _filtroTurno;
    String? status = _filtroStatus;

    final turnos   = ['Manhã','Tarde','Noite'];
    final statuses = ['Agendado','Concluído','Troca solicitada','Em aberto','Falta justificada','Falta injustificada'];

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, set) => Padding(
        padding: EdgeInsets.fromLTRB(24,24,24,MediaQuery.of(ctx).viewInsets.bottom+24),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Filtrar Plantões', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _cor)),
            IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close, color: _cor)),
          ]),
          const SizedBox(height: 16),

          _LabelFiltro('Setor'),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: _setores.map((s) {
            final sel = setor == s;
            return _ChipFiltro(label: s, selecionado: sel, onTap: () => set(() => setor = sel ? null : s));
          }).toList()),
          const SizedBox(height: 16),

          // Resolvido: Filtro de Funcionários (Agora usamos a variável _funcionarios)
          if (_funcionarios.isNotEmpty) ...[
            _LabelFiltro('Funcionário'),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: _funcionarios.map((f) {
              final sel = funcionario == f;
              return _ChipFiltro(label: f, selecionado: sel, onTap: () => set(() => funcionario = sel ? null : f));
            }).toList()),
            const SizedBox(height: 16),
          ],

          _LabelFiltro('Turno'),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: turnos.map((t) {
            final sel = turno == t;
            return _ChipFiltro(label: t, selecionado: sel, onTap: () => set(() => turno = sel ? null : t));
          }).toList()),
          const SizedBox(height: 16),

          _LabelFiltro('Status'),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: statuses.map((s) {
            final sel = status == s;
            return _ChipFiltro(label: s, selecionado: sel, onTap: () => set(() => status = sel ? null : s));
          }).toList()),
          const SizedBox(height: 24),

          Row(children: [
            Expanded(child: SizedBox(height: 48, child: OutlinedButton(
              onPressed: () => set(() { setor=null; funcionario=null; turno=null; status=null; }),
              style: OutlinedButton.styleFrom(foregroundColor: _cor, side: const BorderSide(color: _cor, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text('Limpar', style: TextStyle(fontWeight: FontWeight.bold))))),
            const SizedBox(width: 12),
            Expanded(child: SizedBox(height: 48, child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _filtroSetor       = setor;
                  _filtroFuncionario = funcionario;
                  _filtroTurno       = turno;
                  _filtroStatus      = status;
                });
                // Resolvido: curly_braces_in_flow_control_structures
                if (_diaSel != null) {
                  _carregarDia(_diaSel!);
                } else {
                  final todos = _plantoesMes.values.expand((l) => l).toList();
                  final filtrados = _filtrarLocal(todos);
                  setState(() {
                    _plantoesDia = filtrados;
                  });
                  if (filtrados.isEmpty) _snack('Nenhum plantão encontrado com esses filtros.');
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: _cor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text('Aplicar', style: TextStyle(fontWeight: FontWeight.bold))))),
          ]),
          const SizedBox(height: 8),
        ])),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: Column(children: [

        //Cabeçalho com calendário
        Cabecalho2(
          titulo: 'Calendário de Gestão',
          metricas: [
            Metrica('$_totalMes',       'Plantões'),
            Metrica('$_diasComPlantao', 'Dias'),
            Metrica('$_trocasPendentes','Trocas'),
          ],
          acaoDireita: _carregando
              ? const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70))
              : IconButton(
                  onPressed: _carregarTudo,
                  icon: const Icon(Icons.refresh, color: Colors.white70, size: 20),
                  padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          extras: [
            const SizedBox(height: 12),

            // Botões de ação rápida
            IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                _BotaoAcao(
                  icone: Icons.add_circle_outline,
                  label: 'Criar\nPlantão',
                  cor: _ciano,
                  onTap: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => const PaginaCriarPlantao()));
                    _carregarTudo();
                  },
                ),
                const SizedBox(width: 8),
                _BotaoAcao(
                  icone: Icons.filter_list_outlined,
                  label: 'Filtrar\nPlantões',
                  cor: _cor,
                  badge: _temFiltroAtivo ? '!' : null,
                  onTap: _abrirFiltro,
                ),
                const SizedBox(width: 8),
                _BotaoAcao(
                  icone: Icons.swap_horiz_outlined,
                  label: 'Trocas\nPendentes',
                  cor: _trocasPendentes > 0 ? const Color(0xFFF57F17) : _ciano.withValues(alpha: 0.7),
                  // Resolvido: unnecessary_brace_in_string_interps
                  badge: _trocasPendentes > 0 ? _trocasPendentes.toString() : null,
                  onTap: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => const PaginaListarTrocasPendentes()));
                    _carregarTudo();
                  },
                ),
              ]),
            ),

            const SizedBox(height: 16),

            // Navegação de mês
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              IconButton(onPressed: () => _mudarMes(-1), icon: const Icon(Icons.chevron_left, color: Colors.white)),
              Text(_nomeMes(_mes), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              IconButton(onPressed: () => _mudarMes(1),  icon: const Icon(Icons.chevron_right, color: Colors.white)),
              GestureDetector(
                onTap: () { _mes = DateTime.now(); _carregarTudo(); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.calendar_today_outlined, color: Colors.white70, size: 13),
                    SizedBox(width: 4),
                    Text('Hoje', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ]))),
            ]),

            // Cabeçalho dias da semana
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['DOM','SEG','TER','QUA','QUI','SEX','SÁB']
                  .map((d) => SizedBox(width: 38, child: Text(d, textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white60))))
                  .toList()),

            const SizedBox(height: 6),
            ..._buildGrade(),
          ],
        ),

        //Área inferior 
        Expanded(child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                _diaSel != null
                    ? '${_diaSel!.day == DateTime.now().day && _diaSel!.month == DateTime.now().month ? 'Hoje, ' : ''}${_diaSel!.day} de ${_nomeMesS(_diaSel!.month)}'
                    : _temFiltroAtivo ? 'Resultado do filtro' : 'Selecione um dia',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _cor)),
              Row(children: [
                if (_temFiltroAtivo)
                  GestureDetector(
                    onTap: () { 
                      setState(() { 
                        _filtroSetor=null; _filtroFuncionario=null; _filtroTurno=null; _filtroStatus=null; 
                      }); 
                      if (_diaSel!=null) {
                        _carregarDia(_diaSel!); 
                      } else {
                        setState(() => _plantoesDia=[]);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFC62828).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.filter_list_off, size: 13, color: Color(0xFFC62828)),
                        SizedBox(width: 4),
                        Text('Limpar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFC62828))),
                      ]))),
                if (_plantoesDia.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: _cor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(20)),
                    child: Text('${_plantoesDia.length} plantão(ões)',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _cor))),
                ],
              ]),
            ]),

            const SizedBox(height: 12),
            Expanded(child: _buildListaDia()),
          ]),
        )),
      ])),
    );
  }

  //Grade do calendário
  List<Widget> _buildGrade() {
    final primeiro = DateTime(_mes.year, _mes.month, 1);
    final ultimo   = DateTime(_mes.year, _mes.month + 1, 0);
    final semanas  = <Widget>[];
    int dia = 1 - (primeiro.weekday % 7);

    while (dia <= ultimo.day) {
      final celulas = <Widget>[];
      for (int c = 0; c < 7; c++, dia++) {
        if (dia < 1 || dia > ultimo.day) { celulas.add(const SizedBox(width: 38, height: 44)); continue; }
        final d      = DateTime(_mes.year, _mes.month, dia);
        final sel    = _diaSel?.day == dia && _diaSel?.month == _mes.month;
        final hoje   = DateTime.now();
        final ehHoje = d.day==hoje.day && d.month==hoje.month && d.year==hoje.year;
        final tem    = _temPlantao(d);

        // Conta trocas pendentes neste dia para destaque especial
        final temTroca = tem && (_plantoesMes[_chave(d)] ?? []).any((p) => p.status == 'solicitada_troca');

        celulas.add(GestureDetector(
          onTap: () => _carregarDia(d),
          child: SizedBox(width: 38, height: 44, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 34, height: 34, alignment: Alignment.center,
              decoration: BoxDecoration(
                color: sel ? Colors.white : ehHoje ? Colors.white24 : tem ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
                shape: BoxShape.circle,
                border: tem && !sel && !ehHoje ? Border.all(color: Colors.white54, width: 1.5) : null),
              child: Text('$dia', style: TextStyle(fontSize: 13,
                  fontWeight: (sel||ehHoje||tem) ? FontWeight.bold : FontWeight.normal,
                  color: sel ? _cor : Colors.white))),
            // Bolinha: laranja se tem troca pendente, ciano se tem plantão normal
            if (tem && !sel)
              Container(width: 4, height: 4,
                  decoration: BoxDecoration(color: temTroca ? const Color(0xFFF57F17) : _ciano, shape: BoxShape.circle)),
          ]))));
      }
      semanas.add(Padding(padding: const EdgeInsets.only(bottom: 2),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: celulas)));
    }
    return semanas;
  }

  //Lista de plantões do dia
  Widget _buildListaDia() {
    if (_diaSel == null && !_temFiltroAtivo) {
      return _vazio(Icons.touch_app_outlined, 'Toque em um dia para ver os plantões\nou use o filtro para buscar');
    }
    if (_carregando) return const Center(child: CircularProgressIndicator(color: _cor));
    if (_plantoesDia.isEmpty) return _vazio(Icons.event_busy_outlined, 'Nenhum plantão encontrado');
    return ListView.separated(
      itemCount: _plantoesDia.length,
      // Resolvido: unnecessary_underscores
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _CardPlantao(item: _plantoesDia[i]),
    );
  }

  Widget _vazio(IconData ic, String msg) => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(ic, size: 52, color: _cor.withValues(alpha: 0.2)), const SizedBox(height: 12),
      Text(msg, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: _cor.withValues(alpha: 0.4))),
    ]));
}

//Botão de ação no cabeçalho
class _BotaoAcao extends StatelessWidget {
  final IconData icone;
  final String   label;
  final Color    cor;
  final String?  badge;
  final VoidCallback onTap;
  const _BotaoAcao({required this.icone, required this.label, required this.cor, required this.onTap, this.badge});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(onTap: onTap,
      child: Stack(clipBehavior: Clip.none, children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(12)),
          child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icone, color: Colors.white, size: 22),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, height: 1.2)),
          ])),
        if (badge != null)
          Positioned(top: -4, right: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFFC62828), borderRadius: BorderRadius.circular(10)),
              child: Text(badge!, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
      ])));
}

//Label de seção no filtro 
class _LabelFiltro extends StatelessWidget {
  final String texto;
  const _LabelFiltro(this.texto);
  @override
  Widget build(BuildContext context) => Text(texto,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color.fromARGB(255,9,17,131)));
}

//Chip de filtro
class _ChipFiltro extends StatelessWidget {
  final String label; final bool selecionado; final VoidCallback onTap;
  const _ChipFiltro({required this.label, required this.selecionado, required this.onTap});
  @override
  Widget build(BuildContext context) {
    const cor = Color.fromARGB(255,9,17,131);
    return GestureDetector(onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selecionado ? cor : const Color(0xFFF4F6FA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFB0B5D9), width: 1.2)),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
            color: selecionado ? Colors.white : cor))));
  }
}

//Card de plantão 
class _CardPlantao extends StatelessWidget {
  final _PlantaoItem item;
  const _CardPlantao({required this.item});

  static const _coresTurno  = {'Manhã':Color(0xFFF57F17),'Tarde':Color(0xFF1565C0),'Noite':Color(0xFF4A148C)};
  static const _iconesTurno = {'Manhã':Icons.wb_sunny_outlined,'Tarde':Icons.wb_cloudy_outlined,'Noite':Icons.nights_stay_outlined};

  Color    get _corTurno   => _coresTurno[item.turno]  ?? const Color(0xFF4A148C);
  IconData get _iconeTurno => _iconesTurno[item.turno] ?? Icons.schedule_outlined;

  Color _corStatus(String s) => switch (s) {
    'agendado'           => const Color(0xFF1565C0),
    'concluido'||'realizado' => const Color(0xFF2E7D32),
    'solicitada_troca'   => const Color(0xFFF57F17),
    'em_aberto'          => const Color(0xFF8A94C9),
    'falta_justificada'||'falta_injustificada' => const Color(0xFFC62828),
    _                    => const Color(0xFF8A94C9),
  };

  String _labelStatus(String s) => switch (s) {
    'agendado'            => 'Agendado',
    'concluido'           => 'Concluído',
    'realizado'           => 'Realizado',
    'solicitada_troca'    => 'Troca solicitada',
    'em_aberto'           => 'Em aberto',
    'falta_justificada'   => 'Falta justificada',
    'falta_injustificada' => 'Falta injustificada',
    _                     => s,
  };

  @override
  Widget build(BuildContext context) {
    const azul = Color.fromARGB(255,9,17,131);
    final corS = _corStatus(item.status);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFB0B5D9), width: 1.5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0,2))]),
      child: Row(children: [
        // Ícone de turno
        Container(width: 48, height: 48,
            decoration: BoxDecoration(color: _corTurno.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(_iconeTurno, color: _corTurno, size: 22)),
        const SizedBox(width: 12),

        // Informações
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.funcionarioNome,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: azul)),
          const SizedBox(height: 3),
          Row(children: [
            Icon(Icons.domain_outlined, size: 12, color: azul.withValues(alpha: 0.5)),
            const SizedBox(width: 4),
            Text(item.setorNome, style: TextStyle(fontSize: 12, color: azul.withValues(alpha: 0.6))),
            const SizedBox(width: 8),
            Icon(Icons.access_time_outlined, size: 12, color: azul.withValues(alpha: 0.5)),
            const SizedBox(width: 4),
            Text(item.horario, style: TextStyle(fontSize: 12, color: azul.withValues(alpha: 0.6))),
          ]),
          const SizedBox(height: 2),
          Text(item.funcao, style: TextStyle(fontSize: 11, color: azul.withValues(alpha: 0.4))),
        ])),

        // Badge de status
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(color: corS.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
          child: Text(_labelStatus(item.status),
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: corS))),
      ]));
  }
}