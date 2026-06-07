// screens/pagina_coordenador.dart
import 'package:flutter/material.dart';
import '../components/card_grid_menu.dart';

class PaginaCoordenador extends StatefulWidget {
  final String nomeUsuario;
  final String setor;

  const PaginaCoordenador({
    super.key,
    this.nomeUsuario = 'Dr. Carlos Mendes',
    this.setor = 'UTI',
  });

  @override
  State<PaginaCoordenador> createState() => _PaginaCoordenadorState();
}

class _PaginaCoordenadorState extends State<PaginaCoordenador> {
  static const _cor      = Color.fromARGB(255, 9, 17, 131);
  static const _vibrante = Color(0xFF3948F5);
  static const _fundo    = Color(0xFFF4F6FA);

  // Trocas pendentes de aprovação do coordenador
  final _trocas = <Map<String, String>>[
    {'nome':'Enf. Ana Paula',    'de':'10/06 Manhã',  'para':'12/06 Tarde',  'motivo':'Consulta médica', 'tempo':'há 2h'},
    {'nome':'Tec. Roberto Lima', 'de':'15/06 Noite',  'para':'17/06 Manhã',  'motivo':'Compromisso familiar', 'tempo':'há 5h'},
    {'nome':'Enf. Julia Rocha',  'de':'18/06 Tarde',  'para':'20/06 Manhã',  'motivo':'Viagem programada', 'tempo':'há 1d'},
  ];

  // Equipe do setor
  final _equipe = <Map<String, String>>[
    {'nome':'Enf. Ana Paula',    'cargo':'Enfermeira',   'turno':'Manhã'},
    {'nome':'Tec. Roberto Lima', 'cargo':'Técnico',      'turno':'Noite'},
    {'nome':'Enf. Julia Rocha',  'cargo':'Enfermeira',   'turno':'Tarde'},
    {'nome':'Tec. Paulo Neto',   'cargo':'Técnico',      'turno':'Manhã'},
  ];

  void _responderTroca(int i, bool aceitar) {
    setState(() => _trocas.removeAt(i));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(aceitar ? 'Troca aprovada!' : 'Troca recusada.'),
      backgroundColor: aceitar ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fundo,
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Cabeçalho 
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Olá, ${widget.nomeUsuario.split(' ').first}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _cor)),
              const SizedBox(height: 4),
              Text('Coordenador – ${widget.setor}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ])),
            Stack(children: [
              IconButton(onPressed: () {},
                  icon: const Icon(Icons.notifications_none_outlined, color: _cor, size: 28)),
              if (_trocas.isNotEmpty)
                Positioned(top: 8, right: 8, child: Container(
                  width: 16, height: 16,
                  decoration: const BoxDecoration(color: Color(0xFFC62828), shape: BoxShape.circle),
                  child: Center(child: Text('${_trocas.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))))),
            ]),
          ]),

          const SizedBox(height: 24),

          // ── Card do setor 
          Container(width: double.infinity, padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_cor, _vibrante],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: _vibrante.withOpacity(0.3), blurRadius: 12, offset: const Offset(0,6))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Meu Setor – ${widget.setor}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              const Text('3 Plantões Hoje',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                _Mini('${_equipe.length}', 'Funcionários'),
                _Mini('10',               'Leitos'),
                _Mini('${_trocas.length}','Pendentes'),
              ]),
            ])),

          const SizedBox(height: 24),

          // ── Solicitações de troca 
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Trocas Pendentes (${_trocas.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _cor)),
            if (_trocas.isEmpty)
              const Icon(Icons.check_circle_outline, color: Color(0xFF2E7D32), size: 20),
          ]),
          const SizedBox(height: 12),

          if (_trocas.isEmpty)
            Container(width: double.infinity, padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white,
                  border: Border.all(color: const Color(0xFFB0B5D9), width: 1.5),
                  borderRadius: BorderRadius.circular(12)),
              child: const Center(child: Text('Nenhuma solicitação pendente.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF8A94C9)))))
          else
            ...List.generate(_trocas.length, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CardTroca(
                troca: _trocas[i],
                onAceitar: () => _responderTroca(i, true),
                onRecusar: () => _responderTroca(i, false),
              ))),

          const SizedBox(height: 24),

          // ── Minha Equipe 
          const Text('Minha Equipe',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _cor)),
          const SizedBox(height: 12),

          ...List.generate(_equipe.length, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _CardFuncionario(func: _equipe[i]))),

          const SizedBox(height: 24),

          // ── Ações Rápidas 
          const Text('Ações Rápidas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _cor)),
          const SizedBox(height: 16),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 1.1,
            children: [
              CardGridMenu(icone: Icons.calendar_month_outlined, titulo: 'Escalas e\nTurnos',  onTap: () {}),
              CardGridMenu(icone: Icons.swap_horiz_outlined,     titulo: 'Trocas de\nPlantão', onTap: () {}),
              CardGridMenu(icone: Icons.people_outline,          titulo: 'Minha\nEquipe',       onTap: () {}),
              CardGridMenu(icone: Icons.settings_outlined,       titulo: 'Configurações',       onTap: () {}),
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
    Text(valor, style: const TextStyle(color: Colors.white,   fontSize: 16, fontWeight: FontWeight.bold)),
    Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
  ]);
}

// ── Card de solicitação de troca 
class _CardTroca extends StatelessWidget {
  final Map<String, String> troca;
  final VoidCallback onAceitar, onRecusar;
  const _CardTroca({required this.troca, required this.onAceitar, required this.onRecusar});

  @override
  Widget build(BuildContext context) {
    const cor = Color.fromARGB(255, 9, 17, 131);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white,
          border: Border.all(color: const Color(0xFFB0B5D9), width: 1.5),
          borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const CircleAvatar(radius: 18, backgroundColor: Color(0xFFF4F6FA),
              child: Icon(Icons.person_outline, color: cor, size: 18)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(troca['nome']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: cor)),
            Text(troca['tempo']!, style: TextStyle(fontSize: 11, color: cor.withOpacity(0.4))),
          ])),
        ]),
        const SizedBox(height: 10),
        // Detalhe da troca
        Container(width: double.infinity, padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFFF4F6FA), borderRadius: BorderRadius.circular(8)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _LinhaTroca(icone: Icons.arrow_upward_outlined,   cor: const Color(0xFFC62828), label: 'Cede',    valor: troca['de']!),
            const SizedBox(height: 4),
            _LinhaTroca(icone: Icons.arrow_downward_outlined, cor: const Color(0xFF2E7D32), label: 'Recebe',  valor: troca['para']!),
            const SizedBox(height: 4),
            _LinhaTroca(icone: Icons.notes_outlined,          cor: cor,                    label: 'Motivo',  valor: troca['motivo']!),
          ])),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: SizedBox(height: 36,
            child: OutlinedButton.icon(onPressed: onRecusar,
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Recusar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFC62828),
                  side: const BorderSide(color: Color(0xFFC62828), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))))),
          const SizedBox(width: 10),
          Expanded(child: SizedBox(height: 36,
            child: ElevatedButton.icon(onPressed: onAceitar,
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Aprovar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32),
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
    Text(valor, style: const TextStyle(fontSize: 12, color: Color.fromARGB(255, 9, 17, 131))),
  ]);
}

// ── Card de funcionário da equipe 
class _CardFuncionario extends StatelessWidget {
  final Map<String, String> func;
  const _CardFuncionario({required this.func});

  @override
  Widget build(BuildContext context) {
    const cor = Color.fromARGB(255, 9, 17, 131);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: Colors.white,
          border: Border.all(color: const Color(0xFFB0B5D9), width: 1.5),
          borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        const CircleAvatar(radius: 20, backgroundColor: Color(0xFFF4F6FA),
            child: Icon(Icons.person_outline, color: cor, size: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(func['nome']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: cor)),
          Text(func['cargo']!, style: const TextStyle(fontSize: 12, color: Color(0xFF8A94C9))),
        ])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: cor.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
          child: Text(func['turno']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: cor))),
      ]),
    );
  }
}