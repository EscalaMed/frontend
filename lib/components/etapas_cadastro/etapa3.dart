import 'package:flutter/material.dart';
import '../cartao.dart';
import 'etapa4.dart';
import 'etapa5.dart';

class Etapa3 extends StatelessWidget {
  final bool ehTelaIndependente;
  final double progressoAtual;
  final List<Map<String, String>>? coordenadoresCadastrados;
  final List<Map<String, String>>? setoresCadastrados;
  final Function(Map<String, String>)? aoAdicionarCoordenador;
  final Function(Map<String, String>)? aoAdicionarSetor;

  const Etapa3({
    super.key,
    this.ehTelaIndependente = false,
    this.progressoAtual = 0.50,
    this.coordenadoresCadastrados,
    this.setoresCadastrados,
    this.aoAdicionarCoordenador,
    this.aoAdicionarSetor,
  });

  @override
  Widget build(BuildContext context) {
    const corAzulEscuro = Color.fromARGB(255, 9, 17, 131);
    const corFundoApp = Color(0xFFF4F6FA);

    Widget conteudoVisual = SingleChildScrollView(
      padding: EdgeInsets.only(top: ehTelaIndependente ? 30.0 : 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!ehTelaIndependente) ...[
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
          CartaoOpcao(
            icone: Icons.people_outline,
            titulo: 'Coordenador ${(coordenadoresCadastrados?.isNotEmpty ?? false) ? "(${coordenadoresCadastrados!.length})" : ""}',
            subtitulo: 'Adicione coordenadores.',
            onTap: () async {
              final resultado = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TelaCoordenador(
                    ehTelaIndependente: ehTelaIndependente,
                    progressoAtual: progressoAtual,
                  ),
                ),
              );
              if (resultado != null && aoAdicionarCoordenador != null) {
                aoAdicionarCoordenador!(resultado);
              }
            },
          ),
          const SizedBox(height: 16),
          CartaoOpcao(
            icone: Icons.grid_view_outlined,
            titulo: 'Setores ${(setoresCadastrados?.isNotEmpty ?? false) ? "(${setoresCadastrados!.length})" : ""}',
            subtitulo: 'Defina setores e atribua coordenadores.',
            onTap: () async {
              final resultado = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TelaSetores(
                    ehTelaIndependente: ehTelaIndependente,
                    progressoAtual: progressoAtual,
                  ),
                ),
              );
              if (resultado != null && aoAdicionarSetor != null) {
                aoAdicionarSetor!(resultado);
              }
            },
          ),
          const SizedBox(height: 16),
          CartaoOpcao(
            icone: Icons.person_outline,
            titulo: 'Editar Informações',
            subtitulo: 'Altere informações pessoais e atualize perfil.',
            onTap: () {},
          ),
          const SizedBox(height: 16),
          CartaoOpcao(
            icone: Icons.settings_outlined,
            titulo: 'Configurações',
            onTap: () {},
          ),
          const SizedBox(height: 24),
        ],
      ),
    );

    if (ehTelaIndependente) {
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