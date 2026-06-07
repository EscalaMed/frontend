// screens/pagina_gerenciar_hospital.dart
import 'package:flutter/material.dart';
import '../components/campo_texto.dart';
import '../components/botoes_navegacao.dart';
import '../components/modal_selecao.dart';
import '../components/cabecalho2.dart';

class PaginaGerenciarHospital extends StatefulWidget {
  const PaginaGerenciarHospital({super.key});
  @override
  State<PaginaGerenciarHospital> createState() => _State();
}

class _State extends State<PaginaGerenciarHospital> {
  static const _cor = Color.fromARGB(255, 9, 17, 131);

  final _nomeCtrl        = TextEditingController();
  final _responsavelCtrl = TextEditingController();
  final _leitosCtrl      = TextEditingController();

  // Cada setor agora tem 'coordenador' separado de 'funcionarios'
  final _setores = <Map<String, dynamic>>[
    {'nome':'UTI',          'coordenador':'Dr. Carlos Mendes',   'leitos':10, 'funcionarios':['Enf. Ana Paula','Tec. Roberto Lima']},
    {'nome':'Emergência',   'coordenador':'Dra. Fernanda Costa', 'leitos':20, 'funcionarios':['Dr. Marcos Souza']},
    {'nome':'Clínica Geral','coordenador':'Enf. Ana Paula',      'leitos':30, 'funcionarios':<String>[]},
    {'nome':'Pediatria',    'coordenador':'Dr. Marcos Souza',    'leitos':15, 'funcionarios':['Dra. Fernanda Costa']},
  ];

  final _todosCoordenadores = ['Dr. Carlos Mendes','Dra. Fernanda Costa','Enf. Ana Paula','Dr. Marcos Souza'];
  final _todosFuncs = ['Enf. Ana Paula','Tec. Roberto Lima','Dr. Marcos Souza','Dra. Fernanda Costa','Tec. Julia Rocha'];
  int _aba = 0;

  @override
  void dispose() { _nomeCtrl.dispose(); _responsavelCtrl.dispose(); _leitosCtrl.dispose(); super.dispose(); }

  int get _totalLeitos => _setores.fold(0,(s,e) => s+(e['leitos'] as int));
  int get _totalFuncs  {
    final t=<String>{};
    for (final s in _setores) { t.addAll((s['funcionarios'] as List).cast<String>()); }
    return t.length;
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(m), backgroundColor: _cor, behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))));

  void _adicionar() {
    if (_nomeCtrl.text.isEmpty) { _snack('Informe o nome do setor.'); return; }
    setState(() {
      _setores.add({'nome':_nomeCtrl.text,
        'coordenador': _responsavelCtrl.text.isEmpty ? 'Não definido' : _responsavelCtrl.text,
        'leitos': int.tryParse(_leitosCtrl.text) ?? 0,
        'funcionarios': <String>[]});
      _nomeCtrl.clear(); _responsavelCtrl.clear(); _leitosCtrl.clear(); _aba = 0;
    });
    _snack('Setor adicionado!');
  }

  // ── Modal editar leitos ─────────────────────────────────────────────
  void _editarLeitos(int i) {
    final c = TextEditingController(text: '${_setores[i]['leitos']}');
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: _cor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 32, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.bed_outlined, color: Colors.white, size: 36),
          const SizedBox(height: 12),
          Text('Leitos – ${_setores[i]['nome']}',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          // Campo com padding suficiente para o label não ser cortado
          TextField(controller: c, keyboardType: TextInputType.number,
            style: const TextStyle(color: _cor, fontWeight: FontWeight.bold, fontSize: 18),
            decoration: InputDecoration(
              labelText: 'Quantidade de leitos',
              labelStyle: const TextStyle(color: _cor, fontWeight: FontWeight.w600, fontSize: 14),
              filled: true, fillColor: Colors.white,
              contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            )),
          const SizedBox(height: 20),
          BotoesNavegacao(
            aoVoltar: () => Navigator.pop(ctx), textoContinuar: 'Salvar',
            aoContinuar: () {
              setState(() => _setores[i]['leitos'] = int.tryParse(c.text) ?? _setores[i]['leitos']);
              Navigator.pop(ctx); _snack('Leitos atualizados!');
            }),
        ])));
  }

  // ── Modal vincular coordenador ──────────────────────────────────────
  void _vincularCoordenador(int i) {
    mostrarModalSelecao(context: context, tipo: 'Coordenador', opcoes: _todosCoordenadores,
        aoSelecionar: (f) => setState(() => _setores[i]['coordenador'] = f));
  }

  // ── Modal vincular funcionário ──────────────────────────────────────
  void _vincularFunc(int i) {
    final vinc = (_setores[i]['funcionarios'] as List).cast<String>();
    final disp = _todosFuncs.where((f) => !vinc.contains(f)).toList();
    if (disp.isEmpty) { _snack('Todos os funcionários já vinculados.'); return; }
    mostrarModalSelecao(context: context, tipo: 'Funcionário', opcoes: disp,
        aoSelecionar: (f) => setState(() => (_setores[i]['funcionarios'] as List).add(f)));
  }

  // ── Modal excluir setor ─────────────────────────────────────────────
  void _excluir(int i) => showModalBottomSheet(
    context: context, backgroundColor: _cor,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.delete_outline, color: Colors.white, size: 36),
        const SizedBox(height: 12),
        Text('Remover "${_setores[i]['nome']}"?',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        BotoesNavegacao(aoVoltar: () => Navigator.pop(ctx), textoContinuar: 'Remover',
            aoContinuar: () { Navigator.pop(ctx); setState(() => _setores.removeAt(i)); }),
      ])));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: Column(children: [
        Cabecalho2(titulo: 'Gerenciar Hospital', metricas: [
          Metrica('${_setores.length}', 'Setores'),
          Metrica('$_totalLeitos',      'Leitos'),
          Metrica('$_totalFuncs',       'Funcionários'),
        ]),

        const SizedBox(height: 16),

        Padding(padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _Abas(aba: _aba, rotulos: const ['Setores','Adicionar Setor'],
              onMudar: (v) => setState(() => _aba = v))),

        const SizedBox(height: 16),

        Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _aba == 0 ? _buildLista() : SingleChildScrollView(child: _buildForm()),
        )),

        if (_aba == 1) Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: BotoesNavegacao(textoContinuar: 'Adicionar',
              aoVoltar: () => setState(() => _aba = 0), aoContinuar: _adicionar)),
      ])),
    );
  }

  Widget _buildLista() {
    if (_setores.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.local_hospital_outlined, size: 56, color: _cor.withOpacity(0.2)),
      const SizedBox(height: 12),
      Text('Nenhum setor cadastrado', style: TextStyle(fontSize: 14, color: _cor.withOpacity(0.4))),
    ]));
    return ListView.separated(
      itemCount: _setores.length, separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _CardSetor(
        setor: _setores[i],
        onLeitos:     () => _editarLeitos(i),
        onCoordenador: () => _vincularCoordenador(i),
        onVincular:   () => _vincularFunc(i),
        onDesvincular: (f) => setState(() => (_setores[i]['funcionarios'] as List).remove(f)),
        onExcluir:    () => _excluir(i)));
  }

  Widget _buildForm() => Column(children: [
    CampoTextoCustomizado(label: 'Nome do Setor',        hintText: 'Ex: UTI, Emergência...', controller: _nomeCtrl),
    const SizedBox(height: 16),
    CampoTextoCustomizado(label: 'Coordenador',          hintText: 'Nome do coordenador',   controller: _responsavelCtrl, keyboardType: TextInputType.name),
    const SizedBox(height: 16),
    CampoTextoCustomizado(label: 'Capacidade de Leitos', hintText: 'Número de leitos',       controller: _leitosCtrl, keyboardType: TextInputType.number),
  ]);
}

// ── Card de setor expandível ───────────────────────────────────────────
class _CardSetor extends StatefulWidget {
  final Map<String,dynamic> setor;
  final VoidCallback onLeitos, onCoordenador, onVincular, onExcluir;
  final void Function(String) onDesvincular;
  const _CardSetor({required this.setor, required this.onLeitos, required this.onCoordenador,
      required this.onVincular, required this.onDesvincular, required this.onExcluir});
  @override State<_CardSetor> createState() => _CardSetorState();
}

class _CardSetorState extends State<_CardSetor> {
  bool _exp = false;

  @override
  Widget build(BuildContext context) {
    const cor = Color.fromARGB(255, 9, 17, 131);
    final funcs = (widget.setor['funcionarios'] as List).cast<String>();

    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFB0B5D9), width: 1.5),
          borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        // Linha principal
        InkWell(onTap: () => setState(() => _exp = !_exp), borderRadius: BorderRadius.circular(12),
          child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
            Container(padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: cor.withOpacity(0.08), shape: BoxShape.circle),
                child: const Icon(Icons.domain_outlined, color: cor, size: 22)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.setor['nome'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: cor)),
              Text(widget.setor['coordenador'],
                  style: const TextStyle(fontSize: 12, color: Color(0xFF8A94C9))),
            ])),
            // Badge de leitos — clique abre edição
            GestureDetector(onTap: widget.onLeitos,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: cor.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.bed_outlined,  size: 14, color: cor), const SizedBox(width: 4),
                  Text('${widget.setor['leitos']}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: cor)),
                  const SizedBox(width: 4),
                  const Icon(Icons.edit_outlined, size: 12, color: cor),
                ]))),
            const SizedBox(width: 8),
            Icon(_exp ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: cor, size: 20),
          ]))),

        // Área expandida
        if (_exp) ...[
          const Divider(height: 1, color: Color(0xFFE0E4F0)),
          Padding(padding: const EdgeInsets.fromLTRB(14, 12, 14, 14), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [

              // ── Coordenador ─────────────────────────────────────
              _SecaoTitulo(titulo: 'Coordenador', botaoLabel: 'Alterar',
                  icone: Icons.manage_accounts_outlined, onTap: widget.onCoordenador),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.manage_accounts_outlined, size: 16, color: Color(0xFF8A94C9)),
                const SizedBox(width: 8),
                Text(widget.setor['coordenador'],
                    style: const TextStyle(fontSize: 13, color: cor, fontWeight: FontWeight.w500)),
              ]),

              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0xFFE0E4F0)),
              const SizedBox(height: 14),

              // ── Funcionários ─────────────────────────────────────
              _SecaoTitulo(titulo: 'Funcionários (${funcs.length})',
                  botaoLabel: 'Vincular', icone: Icons.person_add_alt_1_outlined,
                  onTap: widget.onVincular),
              const SizedBox(height: 8),
              if (funcs.isEmpty)
                Text('Nenhum funcionário vinculado.',
                    style: TextStyle(fontSize: 13, color: cor.withOpacity(0.4)))
              else
                ...funcs.map((f) => Padding(padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [
                    const Icon(Icons.person_outline, size: 16, color: Color(0xFF8A94C9)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(f, style: const TextStyle(fontSize: 13, color: cor))),
                    GestureDetector(onTap: () => widget.onDesvincular(f),
                        child: const Icon(Icons.remove_circle_outline, size: 16, color: Color(0xFFC62828))),
                  ]))),

              const SizedBox(height: 10),
              SizedBox(width: double.infinity, height: 38,
                child: OutlinedButton.icon(onPressed: widget.onExcluir,
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Remover setor',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFC62828),
                    side: const BorderSide(color: Color(0xFFC62828), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
            ])),
        ],
      ]),
    );
  }
}

// ── Cabeçalho de seção com botão de ação ──────────────────────────────
class _SecaoTitulo extends StatelessWidget {
  final String titulo, botaoLabel;
  final IconData icone;
  final VoidCallback onTap;
  const _SecaoTitulo({required this.titulo, required this.botaoLabel, required this.icone, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const cor = Color.fromARGB(255, 9, 17, 131);
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(titulo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: cor)),
      GestureDetector(onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(8)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icone, size: 14, color: Colors.white), const SizedBox(width: 4),
            Text(botaoLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          ]))),
    ]);
  }
}

// ── Abas ──────────────────────────────────────────────────────────────
class _Abas extends StatelessWidget {
  final int aba; final List<String> rotulos; final void Function(int) onMudar;
  const _Abas({required this.aba, required this.rotulos, required this.onMudar});

  @override
  Widget build(BuildContext context) {
    const cor = Color.fromARGB(255, 9, 17, 131);
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF4F6FA), borderRadius: BorderRadius.circular(10)),
      child: Row(children: List.generate(rotulos.length, (i) => Expanded(
        child: GestureDetector(onTap: () => onMudar(i),
          child: AnimatedContainer(duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
                color: aba==i ? cor : Colors.transparent, borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.center,
            child: Text(rotulos[i], style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                color: aba==i ? Colors.white : cor))))))),
    );
  }
}