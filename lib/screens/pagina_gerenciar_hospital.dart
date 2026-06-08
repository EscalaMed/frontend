// screens/pagina_gerenciar_hospital.dart
import 'package:flutter/material.dart';
import '../components/botoes_navegacao.dart';
import '../components/cabecalho2.dart';
import '../components/modal_selecao.dart';
import '../components/etapas_cadastro/etapa4.dart';
import '../components/etapas_cadastro/etapa5.dart';
import 'home/grid/pagina_cadastro_funcionarios.dart';

class PaginaGerenciarHospital extends StatefulWidget {
  const PaginaGerenciarHospital({super.key});
  @override
  State<PaginaGerenciarHospital> createState() => _State();
}

class _State extends State<PaginaGerenciarHospital> {
  static const _cor = Color.fromARGB(255, 9, 17, 131);

  // ── Listas de pessoas já cadastradas no sistema 
  final _coordenadores = [
    'Dr. Carlos Mendes',
    'Dra. Fernanda Costa',
    'Enf. Ana Paula',
    'Dr. Marcos Souza',
    'Dra. Juliana Ramos',
  ];

  final _funcionariosCadastrados = [
    'Enf. Ana Paula',
    'Tec. Roberto Lima',
    'Dr. Marcos Souza',
    'Dra. Fernanda Costa',
    'Tec. Julia Rocha',
    'Enf. Paulo Neto',
    'Tec. Maria Silva',
  ];

  final _setores = <Map<String, dynamic>>[
    {'nome':'UTI',          'coordenador':'Dr. Carlos Mendes',   'leitos':10, 'funcionarios':['Enf. Ana Paula','Tec. Roberto Lima']},
    {'nome':'Emergência',   'coordenador':'Dra. Fernanda Costa', 'leitos':20, 'funcionarios':['Dr. Marcos Souza']},
    {'nome':'Clínica Geral','coordenador':'Enf. Ana Paula',      'leitos':30, 'funcionarios':<String>[]},
    {'nome':'Pediatria',    'coordenador':'Dr. Marcos Souza',    'leitos':15, 'funcionarios':['Dra. Fernanda Costa']},
  ];

  int get _totalLeitos => _setores.fold(0,(s,e) => s+(e['leitos'] as int));
  int get _totalFuncs  {
    final t=<String>{};
    for (final s in _setores) { t.addAll((s['funcionarios'] as List).cast<String>()); }
    return t.length;
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(m), backgroundColor: _cor, behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))));

  void _navegar(Widget pagina) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => pagina));

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
          const Align(alignment: Alignment.centerLeft,
            child: Text('Quantidade de leitos',
                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600))),
          const SizedBox(height: 8),
          TextField(controller: c, keyboardType: TextInputType.number,
            style: const TextStyle(color: _cor, fontWeight: FontWeight.bold, fontSize: 22),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              filled: true, fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none))),
          const SizedBox(height: 20),
          BotoesNavegacao(
            aoVoltar: () => Navigator.pop(ctx), textoContinuar: 'Salvar',
            aoContinuar: () {
              setState(() => _setores[i]['leitos'] = int.tryParse(c.text) ?? _setores[i]['leitos']);
              Navigator.pop(ctx); _snack('Leitos atualizados!');
            }),
        ])));
  }

  // ── Alterar coordenador: mostra lista dos já cadastrados ────────────
  void _alterarCoordenador(int i) {
    mostrarModalSelecao(
      context: context,
      tipo: 'Coordenador',
      opcoes: _coordenadores,
      aoSelecionar: (escolha) => setState(() => _setores[i]['coordenador'] = escolha),
    );
  }

  // ── Vincular funcionário: mostra apenas os não vinculados ───────────
  void _vincularFuncionario(int i) {
    final vinculados = (_setores[i]['funcionarios'] as List).cast<String>();
    final disponiveis = _funcionariosCadastrados.where((f) => !vinculados.contains(f)).toList();
    if (disponiveis.isEmpty) { _snack('Todos os funcionários já estão vinculados.'); return; }
    mostrarModalSelecao(
      context: context,
      tipo: 'Funcionário',
      opcoes: disponiveis,
      aoSelecionar: (escolha) => setState(() => (_setores[i]['funcionarios'] as List).add(escolha)),
    );
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

        // ── Botões de ação rápida ──────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(children: [
            Expanded(child: _BotaoAcao(
              icone: Icons.person_add_alt_1_outlined,
              label: 'Add Funcionário',
              onTap: () => _navegar(const PaginaCadastroFuncionarios()),
            )),
            const SizedBox(width: 12),
            Expanded(child: _BotaoAcao(
              icone: Icons.manage_accounts_outlined,
              label: 'Add Coordenador',
              onTap: () => _navegar(const TelaCoordenador()),
            )),
            const SizedBox(width: 12),
            Expanded(child: _BotaoAcao(
              icone: Icons.add_business_outlined,
              label: 'Add Setor',
              onTap: () => _navegar(const TelaSetores()),
            )),
          ]),
        ),

        const SizedBox(height: 16),

        Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _buildLista(),
        )),
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
        onLeitos:      () => _editarLeitos(i),
        onCoordenador: () => _alterarCoordenador(i),
        onVincular:    () => _vincularFuncionario(i),
        onDesvincular: (f) => setState(() => (_setores[i]['funcionarios'] as List).remove(f)),
        onExcluir:     () => _excluir(i)));
  }
}

// ── Botão de ação rápida ───────────────────────────────────────────────
class _BotaoAcao extends StatelessWidget {
  final IconData icone;
  final String label;
  final VoidCallback onTap;
  const _BotaoAcao({required this.icone, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const cor = Color.fromARGB(255, 9, 17, 131);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(10)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icone, color: Colors.white, size: 22),
          const SizedBox(height: 6),
          Text(label, textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
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

        if (_exp) ...[
          const Divider(height: 1, color: Color(0xFFE0E4F0)),
          Padding(padding: const EdgeInsets.fromLTRB(14, 12, 14, 14), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [

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