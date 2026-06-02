import 'package:flutter/material.dart';
import '../cartao.dart';

class Etapa3 extends StatelessWidget {
  const Etapa3({super.key});

  @override
  Widget build(BuildContext context) {
    const corAzulEscuro = Color.fromARGB(255, 9, 17, 131);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, 
        children: [
          const Text(
            'Gerenciar Hospital',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: corAzulEscuro,
            ),
          ),
          const SizedBox(height: 32),

          CartaoOpcao(
            icone: Icons.people_outline,
            titulo: 'Coordenador',
            subtitulo: 'Adicione coordenadores.',
            onTap: () {
            },
          ),
          const SizedBox(height: 16),

          CartaoOpcao(
            icone: Icons.grid_view_outlined,
            titulo: 'Setores',
            subtitulo: 'Defina setores e atribua coordenadores.',
            onTap: () {
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
  }
}