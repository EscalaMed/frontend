import 'package:flutter/material.dart';
import '../../components/card_grid_menu.dart';
import '../pagina_troca_plantao.dart';
import '../pagina_configuracoes.dart';

class PaginaFuncionario extends StatelessWidget {
  final String token;
  final String nomeUsuario;
  final String setor;

  const PaginaFuncionario({
    super.key,
    required this.token,
    this.nomeUsuario = 'Enf. Ana Paula',
    this.setor = 'UTI',
  });

  static const _cor      = Color.fromARGB(255, 9, 17, 131);
  static const _vibrante = Color(0xFF3948F5);
  static const _fundo    = Color(0xFFF4F6FA);

  void _navegar(BuildContext context, Widget pagina) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => pagina));

  @override
  Widget build(BuildContext context) {
    final plantoesSemana = [
      _Item('Seg', '09/06', 'Folga', '–', _Turno.folga),
      _Item('Ter', '10/06', 'Manhã', setor, _Turno.manha),
      _Item('Qua', '11/06', 'Manhã', setor, _Turno.manha),
      _Item('Qui', '12/06', 'Folga', '–', _Turno.folga),
      _Item('Sex', '13/06', 'Noite', 'Emergência', _Turno.noite),
    ];

    return Scaffold(
      backgroundColor: _fundo,
      body: SafeArea(
          child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Olá, ${nomeUsuario.split(' ').last}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _cor)),
              const SizedBox(height: 4),
              Text('Setor: $setor', style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ])),
            IconButton(
                onPressed: () {},
                icon: const Badge(
                    label: Text('1'),
                    child: Icon(Icons.notifications_none_outlined, color: _cor, size: 28))),
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
                    BoxShadow(color: _vibrante.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))
                  ]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Próximo Plantão',
                    style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                const Text('Amanhã – Manhã (06h–14h)',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(children: [
                  _Chip(icone: Icons.domain_outlined, texto: setor),
                  const SizedBox(width: 16),
                  const _Chip(icone: Icons.access_time_outlined, texto: '8h'),
                  const SizedBox(width: 16),
                  const _Chip(icone: Icons.calendar_today_outlined, texto: '11/06'),
                ]),
              ])),

          const SizedBox(height: 24),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Esta Semana', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _cor)),
            GestureDetector(
                onTap: () {},
                child: const Text('Ver calendário',
                    style: TextStyle(fontSize: 13, color: _vibrante, fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: 12),

          ...plantoesSemana.map((item) => Padding(padding: const EdgeInsets.only(bottom: 8), child: _CardDia(item: item))),

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
  final IconData icone; final String texto;
  const _Chip({required this.icone, required this.texto});
  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icone, size: 13, color: Colors.white70), const SizedBox(width: 4),
        Text(texto, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ]);
}

enum _Turno { manha, tarde, noite, folga }

class _Item {
  final String dia, data, turno, setor; final _Turno tipo;
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
    final cor   = _cores[item.tipo]!;
    final icone = _icones[item.tipo]!;
    final fol   = item.tipo == _Turno.folga;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: fol ? Colors.transparent : const Color(0xFFB0B5D9), width: 1.5),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))]),
      child: Row(children: [
        SizedBox(
            width: 40,
            child: Column(children: [
              Text(item.dia, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fol ? Colors.grey : azul)),
              Text(item.data.split('/')[0],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: fol ? Colors.grey : azul)),
            ])),
        Container(
            width: 1, height: 32, color: const Color(0xFFE0E4F0), margin: const EdgeInsets.symmetric(horizontal: 12)),
        Icon(icone, color: cor, size: 20),
        const SizedBox(width: 10),
        Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.turno, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: fol ? Colors.grey : azul)),
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