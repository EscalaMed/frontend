// screens/pagina_configuracoes.dart
import 'package:flutter/material.dart';
import '../components/campo_texto.dart';
import '../components/botoes_navegacao.dart';

class PaginaConfiguracoes extends StatefulWidget {
  const PaginaConfiguracoes({super.key});

  @override
  State<PaginaConfiguracoes> createState() => _PaginaConfiguracoesState();
}

class _PaginaConfiguracoesState extends State<PaginaConfiguracoes> {
  static const corAzulEscuro = Color.fromARGB(255, 9, 17, 131);
  static const corFundoApp   = Color(0xFFF4F6FA);

  final _nomeCtrl     = TextEditingController(text: 'Administrador');
  final _emailCtrl    = TextEditingController(text: 'admin@hospital.com');
  final _telefoneCtrl = TextEditingController(text: '(71) 99999-0000');
  final _senhaCtrl    = TextEditingController();
  final _confirmaCtrl = TextEditingController();

  bool _notifTrocas    = true;
  bool _notifEscalas   = true;
  bool _notifSistema   = false;

  int _aba = 0;

  @override
  void dispose() {
    _nomeCtrl.dispose(); _emailCtrl.dispose(); _telefoneCtrl.dispose();
    _senhaCtrl.dispose(); _confirmaCtrl.dispose();
    super.dispose();
  }

  void _salvar() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Informações salvas com sucesso!'),
      backgroundColor: corAzulEscuro,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
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
                    padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  const Text('Configurações',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: corAzulEscuro)),
                ],
              ),

              const SizedBox(height: 24),

              // Avatar
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: corAzulEscuro.withValues(alpha: 0.1),
                      child: const Icon(Icons.person, size: 52, color: corAzulEscuro),
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: corAzulEscuro, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt_outlined, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Abas
              Container(
                decoration: BoxDecoration(color: corFundoApp, borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  _Aba(label: 'Meus Dados',     ativa: _aba == 0, onTap: () => setState(() => _aba = 0)),
                  _Aba(label: 'Segurança',      ativa: _aba == 1, onTap: () => setState(() => _aba = 1)),
                  _Aba(label: 'Notificações',   ativa: _aba == 2, onTap: () => setState(() => _aba = 2)),
                ]),
              ),

              const SizedBox(height: 24),

              Expanded(child: SingleChildScrollView(child: _conteudoAba())),

              const SizedBox(height: 16),

              if (_aba != 2)
                BotoesNavegacao(
                  textoContinuar: 'Salvar',
                  aoVoltar: () => Navigator.pop(context),
                  aoContinuar: _salvar,
                ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _conteudoAba() {
    switch (_aba) {
      case 1:  return _SecaoSeguranca(senhaCtrl: _senhaCtrl, confirmaCtrl: _confirmaCtrl);
      case 2:  return _SecaoNotificacoes(
        notifTrocas: _notifTrocas, notifEscalas: _notifEscalas, notifSistema: _notifSistema,
        onChange: (campo, val) => setState(() {
          if (campo == 0) _notifTrocas  = val;
          if (campo == 1) _notifEscalas = val;
          if (campo == 2) _notifSistema = val;
        }),
      );
      default: return _SecaoDados(nomeCtrl: _nomeCtrl, emailCtrl: _emailCtrl, telefoneCtrl: _telefoneCtrl);
    }
  }
}

// ── Aba ──────────────────────────────────────────────────────────────
class _Aba extends StatelessWidget {
  final String label; final bool ativa; final VoidCallback onTap;
  const _Aba({required this.label, required this.ativa, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const cor = Color.fromARGB(255, 9, 17, 131);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: ativa ? cor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                  color: ativa ? Colors.white : cor)),
        ),
      ),
    );
  }
}

// ── Seção: Meus Dados ─────────────────────────────────────────────────
class _SecaoDados extends StatelessWidget {
  final TextEditingController nomeCtrl, emailCtrl, telefoneCtrl;
  const _SecaoDados({required this.nomeCtrl, required this.emailCtrl, required this.telefoneCtrl});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      CampoTextoCustomizado(label: 'Nome Completo',  controller: nomeCtrl,     keyboardType: TextInputType.name),
      const SizedBox(height: 16),
      CampoTextoCustomizado(label: 'E-mail',         controller: emailCtrl,    keyboardType: TextInputType.emailAddress),
      const SizedBox(height: 16),
      CampoTextoCustomizado(label: 'Telefone',       controller: telefoneCtrl, keyboardType: TextInputType.phone),
    ],
  );
}

// ── Seção: Segurança ──────────────────────────────────────────────────
class _SecaoSeguranca extends StatelessWidget {
  final TextEditingController senhaCtrl, confirmaCtrl;
  const _SecaoSeguranca({required this.senhaCtrl, required this.confirmaCtrl});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      CampoTextoCustomizado(label: 'Nova Senha',         controller: senhaCtrl,    isPassword: true),
      const SizedBox(height: 16),
      CampoTextoCustomizado(label: 'Confirmar Senha',    controller: confirmaCtrl, isPassword: true),
      const SizedBox(height: 24),
      // Dicas de segurança
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 9, 17, 131).withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color.fromARGB(255, 9, 17, 131).withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Dicas para uma senha segura:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13,
                    color: Color.fromARGB(255, 9, 17, 131))),
            SizedBox(height: 8),
            _DicaSenha(texto: 'Mínimo de 8 caracteres'),
            _DicaSenha(texto: 'Letras maiúsculas e minúsculas'),
            _DicaSenha(texto: 'Pelo menos um número'),
            _DicaSenha(texto: 'Pelo menos um caractere especial'),
          ],
        ),
      ),
    ],
  );
}

class _DicaSenha extends StatelessWidget {
  final String texto;
  const _DicaSenha({required this.texto});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(
      children: [
        const Icon(Icons.check_circle_outline, size: 14, color: Color.fromARGB(255, 9, 17, 131)),
        const SizedBox(width: 6),
        Text(texto, style: const TextStyle(fontSize: 12, color: Color.fromARGB(255, 9, 17, 131))),
      ],
    ),
  );
}

// ── Seção: Notificações ───────────────────────────────────────────────
class _SecaoNotificacoes extends StatelessWidget {
  final bool notifTrocas, notifEscalas, notifSistema;
  final void Function(int, bool) onChange;

  const _SecaoNotificacoes({
    required this.notifTrocas, required this.notifEscalas,
    required this.notifSistema, required this.onChange,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _ItemNotificacao(
        icone: Icons.swap_horiz_outlined,
        titulo: 'Trocas de Plantão',
        subtitulo: 'Receba alertas de solicitações de troca',
        valor: notifTrocas, onChanged: (v) => onChange(0, v),
      ),
      _ItemNotificacao(
        icone: Icons.calendar_month_outlined,
        titulo: 'Escalas e Turnos',
        subtitulo: 'Notificações sobre alterações na escala',
        valor: notifEscalas, onChanged: (v) => onChange(1, v),
      ),
      _ItemNotificacao(
        icone: Icons.notifications_outlined,
        titulo: 'Avisos do Sistema',
        subtitulo: 'Atualizações e comunicados gerais',
        valor: notifSistema, onChanged: (v) => onChange(2, v),
      ),
    ],
  );
}

class _ItemNotificacao extends StatelessWidget {
  final IconData icone;
  final String titulo, subtitulo;
  final bool valor;
  final ValueChanged<bool> onChanged;

  const _ItemNotificacao({
    required this.icone, required this.titulo, required this.subtitulo,
    required this.valor, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const cor = Color.fromARGB(255, 9, 17, 131);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFB0B5D9), width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icone, size: 28, color: cor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: cor)),
              const SizedBox(height: 2),
              Text(subtitulo, style: const TextStyle(fontSize: 12, color: Color(0xFF8A94C9))),
            ]),
          ),
          Switch(value: valor, onChanged: onChanged, activeThumbColor: cor),
        ],
      ),
    );
  }
}