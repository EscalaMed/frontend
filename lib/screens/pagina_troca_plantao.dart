// screens/pagina_troca_plantao.dart
import 'package:flutter/material.dart';
import '../components/campo_texto.dart';
import '../components/botoes_navegacao.dart';
import '../components/modal_selecao.dart';
import '../components/card_troca.dart';

class PaginaTrocaPlantao extends StatefulWidget {
  const PaginaTrocaPlantao({super.key});

  @override
  State<PaginaTrocaPlantao> createState() => _PaginaTrocaPlantaoState();
}

class _PaginaTrocaPlantaoState extends State<PaginaTrocaPlantao> {
  static const corAzulEscuro = Color.fromARGB(255, 9, 17, 131);

  final _meuPlantaoCtrl      = TextEditingController();
  final _plantaoDesejadoCtrl = TextEditingController();
  final _funcionarioCtrl     = TextEditingController();
  final _motivoCtrl          = TextEditingController();

  int _aba = 0;

  final List<Map<String, String>> _solicitacoes = [
    {'meuPlantao': '10/06 – Manhã (06h–14h)',  'plantaoDesejado': '12/06 – Tarde (14h–22h)',  'funcionario': 'Dr. Carlos Mendes', 'status': 'Pendente', 'motivo': 'Consulta médica particular'},
    {'meuPlantao': '15/06 – Noite (22h–06h)',  'plantaoDesejado': '17/06 – Manhã (06h–14h)',  'funcionario': 'Enf. Ana Paula',    'status': 'Aceita',   'motivo': 'Compromisso familiar'},
    {'meuPlantao': '20/06 – Tarde (14h–22h)',  'plantaoDesejado': '22/06 – Noite (22h–06h)',  'funcionario': 'Tec. Roberto Lima', 'status': 'Recusada', 'motivo': 'Viagem programada'},
  ];

  @override
  void dispose() {
    _meuPlantaoCtrl.dispose();
    _plantaoDesejadoCtrl.dispose();
    _funcionarioCtrl.dispose();
    _motivoCtrl.dispose();
    super.dispose();
  }

  // ── Abre modal de seleção e atualiza controller ──────────────────
  void _selecionar(String tipo, List<String> opcoes, TextEditingController ctrl) {
    mostrarModalSelecao(
      context: context,
      tipo: tipo,
      opcoes: opcoes,
      aoSelecionar: (v) => setState(() => ctrl.text = v),
    );
  }

  // ── Modal de confirmação de envio ────────────────────────────────
  void _confirmar() {
    if (_meuPlantaoCtrl.text.isEmpty || _plantaoDesejadoCtrl.text.isEmpty || _funcionarioCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Preencha todos os campos obrigatórios.'),
        backgroundColor: corAzulEscuro,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: corAzulEscuro,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 40),
            const SizedBox(height: 16),
            const Text('Confirmar Solicitação',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Trocar "${_meuPlantaoCtrl.text}" por "${_plantaoDesejadoCtrl.text}" com ${_funcionarioCtrl.text}.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            BotoesNavegacao(
              textoContinuar: 'Confirmar',
              aoVoltar: () => Navigator.pop(ctx),
              aoContinuar: () {
                Navigator.pop(ctx);
                setState(() {
                  _solicitacoes.insert(0, {
                    'meuPlantao':      _meuPlantaoCtrl.text,
                    'plantaoDesejado': _plantaoDesejadoCtrl.text,
                    'funcionario':     _funcionarioCtrl.text,
                    'status':          'Pendente',
                    'motivo':          _motivoCtrl.text.isEmpty ? 'Sem motivo informado' : _motivoCtrl.text,
                  });
                  _meuPlantaoCtrl.clear();
                  _plantaoDesejadoCtrl.clear();
                  _funcionarioCtrl.clear();
                  _motivoCtrl.clear();
                  _aba = 1;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, color: corAzulEscuro, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  const Text('Troca de Plantão',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: corAzulEscuro)),
                ],
              ),

              const SizedBox(height: 24),

              // Abas
              Container(
                decoration: BoxDecoration(color: const Color(0xFFF4F6FA), borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  _Aba(label: 'Solicitar Troca',      ativa: _aba == 0, onTap: () => setState(() => _aba = 0)),
                  _Aba(label: 'Minhas Solicitações',  ativa: _aba == 1, onTap: () => setState(() => _aba = 1)),
                ]),
              ),

              const SizedBox(height: 24),

              // Conteúdo
              Expanded(child: _aba == 0 ? _Formulario(this) : _ListaSolicitacoes(this)),

              // Botões só no formulário
              if (_aba == 0) ...[
                const SizedBox(height: 16),
                BotoesNavegacao(
                  textoContinuar: 'Enviar Solicitação',
                  aoVoltar: () => Navigator.pop(context),
                  aoContinuar: _confirmar,
                ),
              ],

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Aba do seletor ───────────────────────────────────────────────────
class _Aba extends StatelessWidget {
  final String label;
  final bool ativa;
  final VoidCallback onTap;

  const _Aba({required this.label, required this.ativa, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const corAzulEscuro = Color.fromARGB(255, 9, 17, 131);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: ativa ? corAzulEscuro : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: ativa ? Colors.white : corAzulEscuro,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Formulário de solicitação ────────────────────────────────────────
class _Formulario extends StatelessWidget {
  final _PaginaTrocaPlantaoState s;
  const _Formulario(this.s);

  @override
  Widget build(BuildContext context) {
    const cor = Color.fromARGB(255, 9, 17, 131);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Banner informativo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cor.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: cor, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Selecione seu plantão e o desejado. O colega será notificado para aceitar ou recusar.',
                    style: TextStyle(fontSize: 13, color: cor, height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Meu plantão
          GestureDetector(
            onTap: () => s._selecionar('Plantão', ['10/06 – Manhã (06h–14h)', '11/06 – Tarde (14h–22h)', '12/06 – Noite (22h–06h)', '13/06 – Manhã (06h–14h)'], s._meuPlantaoCtrl),
            child: AbsorbPointer(child: CampoTextoCustomizado(label: 'Meu Plantão', hintText: 'Selecione o plantão que deseja ceder', controller: s._meuPlantaoCtrl, iconeDireita: Icons.keyboard_arrow_down)),
          ),

          const SizedBox(height: 16),

          // Ícone de troca
          Center(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: cor.withOpacity(0.08), shape: BoxShape.circle),
              child: const Icon(Icons.swap_vert_rounded, color: cor, size: 28),
            ),
          ),

          const SizedBox(height: 16),

          // Plantão desejado
          GestureDetector(
            onTap: () => s._selecionar('Plantão Desejado', ['14/06 – Tarde (14h–22h)', '15/06 – Noite (22h–06h)', '16/06 – Manhã (06h–14h)', '17/06 – Tarde (14h–22h)'], s._plantaoDesejadoCtrl),
            child: AbsorbPointer(child: CampoTextoCustomizado(label: 'Plantão Desejado', hintText: 'Selecione o plantão que deseja receber', controller: s._plantaoDesejadoCtrl, iconeDireita: Icons.keyboard_arrow_down)),
          ),

          const SizedBox(height: 16),

          // Trocar com
          GestureDetector(
            onTap: () => s._selecionar('Funcionário', ['Dr. Carlos Mendes', 'Enf. Ana Paula', 'Tec. Roberto Lima', 'Dra. Fernanda Costa'], s._funcionarioCtrl),
            child: AbsorbPointer(child: CampoTextoCustomizado(label: 'Trocar com', hintText: 'Selecione o colega de trabalho', controller: s._funcionarioCtrl, iconeDireita: Icons.keyboard_arrow_down)),
          ),

          const SizedBox(height: 16),

          CampoTextoCustomizado(label: 'Motivo da Troca', hintText: 'Descreva brevemente o motivo...', controller: s._motivoCtrl, maxLines: 3, fontSizeLabel: 18),
        ],
      ),
    );
  }
}

// ── Lista de solicitações ────────────────────────────────────────────
class _ListaSolicitacoes extends StatelessWidget {
  final _PaginaTrocaPlantaoState s;
  const _ListaSolicitacoes(this.s);

  @override
  Widget build(BuildContext context) {
    const cor = Color.fromARGB(255, 9, 17, 131);

    if (s._solicitacoes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swap_horiz_outlined, size: 64, color: cor.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text('Nenhuma solicitação encontrada',
                style: TextStyle(fontSize: 16, color: cor.withOpacity(0.5), fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: s._solicitacoes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, i) {
        final item = s._solicitacoes[i];
        return CardTroca(
          meuPlantao:      item['meuPlantao']!,
          plantaoDesejado: item['plantaoDesejado']!,
          funcionario:     item['funcionario']!,
          status:          item['status']!,
          motivo:          item['motivo']!,
          aoCancelar: item['status'] == 'Pendente'
              ? () => s.setState(() => s._solicitacoes.removeAt(i))
              : null,
        );
      },
    );
  }
}