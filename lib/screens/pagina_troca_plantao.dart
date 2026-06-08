import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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
  final _motivoCtrl          = TextEditingController();

  int _aba = 0;
  bool _enviando = false;
  List<dynamic> _meusPlantoes = [];
  List<dynamic> _outrosPlantoes = [];
  List<dynamic> _minhasSolicitacoesBackend = [];

  @override
  void initState() {
    super.initState();
    _buscarMeusPlantoes();
    _buscarOutrosPlantoes();
    _buscarMinhasSolicitacoes();
  }

  String _formatarDataPlantao(String? iso) {
    if (iso == null) return '';
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} às ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _buscarMeusPlantoes() async {
    const storage = FlutterSecureStorage();
    String? tokenJWT = await storage.read(key: 'token_jwt');
    if (tokenJWT == null) return;

    try {
      final now = DateTime.now();
      final url1 = Uri.parse('http://10.0.2.2:5000/api/calendario/mes?ano=${now.year}&mes=${now.month}');
      final res1 = await http.get(url1, headers: {'Authorization': 'Bearer $tokenJWT'});

      List<dynamic> plantoes = [];
      if (res1.statusCode == 200) {
        plantoes.addAll(jsonDecode(res1.body)['plantoes_mes'] ?? []);
      }

      int nextMonth = now.month == 12 ? 1 : now.month + 1;
      int nextYear = now.month == 12 ? now.year + 1 : now.year;
      final url2 = Uri.parse('http://10.0.2.2:5000/api/calendario/mes?ano=$nextYear&mes=$nextMonth');
      final res2 = await http.get(url2, headers: {'Authorization': 'Bearer $tokenJWT'});

      if (res2.statusCode == 200) {
        plantoes.addAll(jsonDecode(res2.body)['plantoes_mes'] ?? []);
      }

      setState(() {
        _meusPlantoes = plantoes.where((p) => p['status']?.toString().toLowerCase() == 'agendado').toList();
      });
    } catch (_) {}
  }

  Future<void> _buscarOutrosPlantoes() async {
    const storage = FlutterSecureStorage();
    String? tokenJWT = await storage.read(key: 'token_jwt');
    if (tokenJWT == null) return;

    try {
      final res = await http.get(Uri.parse('http://10.0.2.2:5000/plantoes'), headers: {'Authorization': 'Bearer $tokenJWT'});
      if (res.statusCode == 200) {
        final todos = jsonDecode(res.body) as List<dynamic>;
        
        final prefs = await SharedPreferences.getInstance();
        final meuId = prefs.getInt('user_id');

        setState(() {
          _outrosPlantoes = todos.where((p) => 
            p['status']?.toString().toLowerCase() == 'agendado' &&
            p['medico_titular_id'] != meuId
          ).toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _buscarMinhasSolicitacoes() async {
    const storage = FlutterSecureStorage();
    String? tokenJWT = await storage.read(key: 'token_jwt');
    if (tokenJWT == null) return;

    try {
      final res = await http.get(Uri.parse('http://10.0.2.2:5000/pedidos_troca/meus_pedidos'), headers: {'Authorization': 'Bearer $tokenJWT'});
      if (res.statusCode == 200) {
        setState(() => _minhasSolicitacoesBackend = jsonDecode(res.body));
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _meuPlantaoCtrl.dispose();
    _plantaoDesejadoCtrl.dispose();
    _motivoCtrl.dispose();
    super.dispose();
  }

  void _selecionar(String tipo, List<String> opcoes, TextEditingController ctrl) {
    mostrarModalSelecao(
      context: context,
      tipo: tipo,
      opcoes: opcoes,
      aoSelecionar: (v) => setState(() => ctrl.text = v),
      aoCriarNovaOpcao: (novaOpcao) => setState(() => ctrl.text = novaOpcao), 
    );
  }

  Future<void> _enviarSolicitacaoBackend(int idPlantaoCedido, int idPlantaoDesejado) async {
    setState(() => _enviando = true);
    const storage = FlutterSecureStorage();
    String? tokenJWT = await storage.read(key: 'token_jwt');

    String motivoFinal = _motivoCtrl.text.isNotEmpty ? _motivoCtrl.text : "Sem motivo informado";

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/plantoes/$idPlantaoCedido/solicitar_troca'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${tokenJWT!.trim()}',
        },
        body: jsonEncode({
          'motivo': motivoFinal,
          'legitimado': false,
          'plantao_desejado_id': idPlantaoDesejado,
        })
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitação enviada com sucesso!'), backgroundColor: Colors.green));
        _meuPlantaoCtrl.clear();
        _plantaoDesejadoCtrl.clear();
        _motivoCtrl.clear();
        setState(() => _aba = 1);
        _buscarMinhasSolicitacoes();
      } else {
        final erro = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro['msg'] ?? 'Erro ao solicitar.'), backgroundColor: Colors.red));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Falha de conexão com o servidor.'), backgroundColor: Colors.red));
    } finally {
      setState(() => _enviando = false);
    }
  }

  void _confirmar() {
    if (_meuPlantaoCtrl.text.isEmpty || _plantaoDesejadoCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Selecione "Meu Plantão" e "Plantão Desejado".'),
        backgroundColor: corAzulEscuro,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
      return;
    }

    final plantaoCedido = _meusPlantoes.firstWhere(
      (p) => "${_formatarDataPlantao(p['data_inicio'])} - ${p['funcao']}" == _meuPlantaoCtrl.text,
      orElse: () => null
    );

    final plantaoDesejado = _outrosPlantoes.firstWhere(
      (p) => "${_formatarDataPlantao(p['data_inicio'])} - ${p['funcao']}" == _plantaoDesejadoCtrl.text,
      orElse: () => null
    );

    if (plantaoCedido == null || plantaoDesejado == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plantão inválido. Escolha uma das opções.'), backgroundColor: Colors.redAccent));
      return;
    }

    int idPlantaoCedido = plantaoCedido['id_plantao']; 
    int idPlantaoDesejado = plantaoDesejado['id'];

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
              'Deseja ceder "${_meuPlantaoCtrl.text}" e assumir "${_plantaoDesejadoCtrl.text}"?',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            BotoesNavegacao(
              textoContinuar: _enviando ? 'Enviando...' : 'Confirmar',
              aoVoltar: () => Navigator.pop(ctx),
              aoContinuar: _enviando ? () {} : () async {
                Navigator.pop(ctx);
                await _enviarSolicitacaoBackend(idPlantaoCedido, idPlantaoDesejado);
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

              Container(
                decoration: BoxDecoration(color: const Color(0xFFF4F6FA), borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  _Aba(label: 'Solicitar Troca',      ativa: _aba == 0, onTap: () => setState(() => _aba = 0)),
                  _Aba(label: 'Minhas Solicitações',  ativa: _aba == 1, onTap: () => setState(() => _aba = 1)),
                ]),
              ),

              const SizedBox(height: 24),

              Expanded(child: _aba == 0 ? _Formulario(this) : _ListaSolicitacoes(this)),

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

class _Formulario extends StatelessWidget {
  final _PaginaTrocaPlantaoState s;
  const _Formulario(this.s);

  @override
  Widget build(BuildContext context) {
    const cor = Color.fromARGB(255, 9, 17, 131);

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cor.withValues(alpha: 0.15)),
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

          GestureDetector(
            onTap: () {
              List<String> opcoes = s._meusPlantoes.map((p) => "${s._formatarDataPlantao(p['data_inicio'])} - ${p['funcao']}").toList();
              if (opcoes.isEmpty) opcoes = ['Nenhum plantão agendado'];
              s._selecionar('Meu Plantão', opcoes, s._meuPlantaoCtrl);
            },
            child: AbsorbPointer(child: CampoTextoCustomizado(label: 'Meu Plantão (Obrigatório)', hintText: 'Selecione o plantão que deseja ceder', controller: s._meuPlantaoCtrl, iconeDireita: Icons.keyboard_arrow_down)),
          ),

          const SizedBox(height: 16),

          Center(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: cor.withValues(alpha: 0.08), shape: BoxShape.circle),
              child: const Icon(Icons.swap_vert_rounded, color: cor, size: 28),
            ),
          ),

          const SizedBox(height: 16),

          GestureDetector(
            onTap: () {
              List<String> opcoes = s._outrosPlantoes.map((p) => "${s._formatarDataPlantao(p['data_inicio'])} - ${p['funcao']}").toList();
              if (opcoes.isEmpty) opcoes = ['Nenhum plantão disponível no setor'];
              s._selecionar('Plantão Desejado', opcoes, s._plantaoDesejadoCtrl);
            },
            child: AbsorbPointer(child: CampoTextoCustomizado(label: 'Plantão Desejado (Obrigatório)', hintText: 'Selecione o plantão para troca', controller: s._plantaoDesejadoCtrl, iconeDireita: Icons.keyboard_arrow_down)),
          ),

          const SizedBox(height: 16),

          CampoTextoCustomizado(label: 'Motivo da Troca', hintText: 'Descreva brevemente o motivo...', controller: s._motivoCtrl, maxLines: 3, fontSizeLabel: 18),
        ],
      ),
    );
  }
}
class _ListaSolicitacoes extends StatelessWidget {
  final _PaginaTrocaPlantaoState s;
  const _ListaSolicitacoes(this.s);

  @override
  Widget build(BuildContext context) {
    const cor = Color.fromARGB(255, 9, 17, 131);

    if (s._minhasSolicitacoesBackend.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swap_horiz_outlined, size: 64, color: cor.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('Nenhuma solicitação encontrada',
                style: TextStyle(fontSize: 16, color: cor.withValues(alpha: 0.5), fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: s._minhasSolicitacoesBackend.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, i) {
        final item = s._minhasSolicitacoesBackend[i];
        return CardTroca(
          meuPlantao:      item['meuPlantao'] ?? 'Sem data',
          plantaoDesejado: item['plantaoDesejado'] ?? 'Aguardando',
          funcionario:     item['funcionario'] ?? 'Pendente',
          status:          item['status']?.toString() ?? 'Pendente',
          motivo:          item['motivo'] ?? 'Sem motivo',
          aoCancelar: null,
        );
      },
    );
  }
}