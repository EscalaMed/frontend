import 'package:flutter/material.dart';
import '../cartao.dart';
import 'etapa4.dart';
import 'etapa5.dart';
import '../../screens/home/grid/pagina_listar_funcionarios.dart';
import '../../screens/home/grid/pagina_criar_plantao.dart';
import '../../screens/home/grid/pagina_listar_plantoes.dart';
import '../../screens/home/grid/pagina_listar_trocas_pendentes.dart';

class Etapa3 extends StatefulWidget {
  final bool ehTelaIndependente;
  final double progressoAtual;
  final List<Map<String, String>>? coordenadoresCadastrados;
  final List<Map<String, String>>? setoresCadastrados;
  final Function(Map<String, String>)? aoAdicionarCoordenador;
  final Function(Map<String, String>)? aoAdicionarSetor;
  final String? role;

  const Etapa3({
    super.key,
    this.ehTelaIndependente = false,
    this.progressoAtual = 0.50,
    this.coordenadoresCadastrados,
    this.setoresCadastrados,
    this.aoAdicionarCoordenador,
    this.aoAdicionarSetor,
    this.role,
  });

  @override
  State<Etapa3> createState() => _Etapa3State();
}

class _Etapa3State extends State<Etapa3> {
  final List<Map<String, String>> _coordenadoresLocais = [];
  final List<Map<String, String>> _setoresLocais = [];

  List<Map<String, String>> get _coordenadores => 
      widget.ehTelaIndependente ? _coordenadoresLocais : (widget.coordenadoresCadastrados ?? []);

  List<Map<String, String>> get _setores => 
      widget.ehTelaIndependente ? _setoresLocais : (widget.setoresCadastrados ?? []);

  @override
  Widget build(BuildContext context) {
    const corAzulEscuro = Color.fromARGB(255, 9, 17, 131);
    const corFundoApp = Color(0xFFF4F6FA);

    final faturamentoRole = widget.role?.toLowerCase() ?? '';
    
    final ehAdmin = faturamentoRole == 'administrador';
    final ehCoordenador = faturamentoRole == 'coordenador';
    final ehCoordenadorOuAdmin = ehCoordenador || ehAdmin;

    Widget conteudoVisual = SingleChildScrollView(
      padding: EdgeInsets.only(top: widget.ehTelaIndependente ? 30.0 : 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!widget.ehTelaIndependente) ...[
            const Text(
              'Gerenciar Hospital',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: corAzulEscuro,
              ),
            ),
            const SizedBox(height: 32),
          ],

          if (ehCoordenadorOuAdmin) ...[
            CartaoOpcao(
              icone: Icons.badge_outlined,
              titulo: 'Listar Funcionários',
              subtitulo: 'Visualize e gerencie a equipe de saúde.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PaginaListarFuncionarios(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            CartaoOpcao(
              icone: Icons.calendar_month_outlined,
              titulo: 'Listar Plantões Agendados',
              subtitulo: 'Confira a escala completa dos próximos turnos.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PaginaListarPlantoes(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            CartaoOpcao(
              icone: Icons.swap_horizontal_circle_outlined,
              titulo: 'Listar Trocas Pendentes',
              subtitulo: 'Aprove ou recuse as solicitações de mudança.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PaginaListarTrocasPendentes(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            CartaoOpcao(
              icone: Icons.add_box_outlined,
              titulo: 'Criar Plantões',
              subtitulo: 'Monte novas escalas e atribua horários.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PaginaCriarPlantao(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
          if (ehAdmin || !ehCoordenadorOuAdmin) ...[
            CartaoOpcao(
              icone: Icons.people_outline,
              titulo: 'Coordenador ${_coordenadores.isNotEmpty ? "(${_coordenadores.length})" : ""}',
              subtitulo: 'Adicione coordenadores.',
              onTap: () async {
                final resultado = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TelaCoordenador(
                      ehTelaIndependente: widget.ehTelaIndependente,
                      progressoAtual: widget.progressoAtual,
                    ),
                  ),
                );

                if (resultado != null && resultado is Map<String, String>) {
                  if (widget.ehTelaIndependente) {
                    setState(() {
                      _coordenadoresLocais.add(resultado);
                    });
                  } else {
                    widget.aoAdicionarCoordenador?.call(resultado);
                  }
                }
              },
            ),
            const SizedBox(height: 16),
            CartaoOpcao(
              icone: Icons.grid_view_outlined,
              titulo: 'Setores ${_setores.isNotEmpty ? "(${_setores.length})" : ""}',
              subtitulo: 'Defina setores e atribua coordenadores.',
              onTap: () async {
                final resultado = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TelaSetores(
                      ehTelaIndependente: widget.ehTelaIndependente,
                      progressoAtual: widget.progressoAtual,
                    ),
                  ),
                );

                if (resultado != null && resultado is Map<String, String>) {
                  if (widget.ehTelaIndependente) {
                    setState(() {
                      _setoresLocais.add(resultado);
                    });
                  } else {
                    widget.aoAdicionarSetor?.call(resultado);
                  }
                }
              },
            ),
            const SizedBox(height: 16),
          ],

          CartaoOpcao(
            icone: Icons.person_outline,
            titulo: 'Editar Informações',
            subtitulo: 'Altere informações pessoais e atualize perfil.',
            onTap: () {},
          ),
          const SizedBox(height: 24),

          if (widget.ehTelaIndependente)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: corAzulEscuro,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (!ehCoordenadorOuAdmin && _coordenadoresLocais.isEmpty && _setoresLocais.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nenhuma alteração detectada para salvar.', textAlign: TextAlign.center),
                        backgroundColor: Colors.orangeAccent,
                      ),
                    );
                    return;
                  }
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Configurações salvas com sucesso!', textAlign: TextAlign.center),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text(
                  'Salvar Alterações',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );

    if (widget.ehTelaIndependente) {
      return Scaffold(
        backgroundColor: corFundoApp,
        appBar: AppBar(
          backgroundColor: corFundoApp,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: corAzulEscuro),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Gerenciar Hospital',
            style: TextStyle(color: corAzulEscuro, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: conteudoVisual,
          ),
        ),
      );
    }
    return conteudoVisual;
  }
}