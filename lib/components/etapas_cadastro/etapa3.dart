import 'package:flutter/material.dart';
import '../cartao.dart';
import '../etapas_cadastro/etapa4.dart';
import '../etapas_cadastro/etapa5.dart';

class Etapa3 extends StatelessWidget {
  final bool ehTelaIndependente;
  const Etapa3({super.key, this.ehTelaIndependente = false});

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
            titulo: 'Coordenador',
            subtitulo: 'Adicione coordenadores.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TelaCoordenador(
                    ehTelaIndependente: ehTelaIndependente,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          CartaoOpcao(
            icone: Icons.grid_view_outlined,
            titulo: 'Setores',
            subtitulo: 'Defina setores e atribua coordenadores.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TelaSetores(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          CartaoOpcao(
            icone: Icons.person_outline,
            titulo: 'Editar Informações',
            subtitulo: 'Altere informações pessoais e atualize perfil.',
            onTap: () {
            },
          ),
          const SizedBox(height: 16),

          CartaoOpcao(
            icone: Icons.settings_outlined,
            titulo: 'Configurações',
            onTap: () {
            },
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