import 'package:flutter/material.dart';
import '../components/barra_progresso.dart';
import '../components/botoes_navegacao.dart';
import '../components/etapas_cadastro/etapa1.dart';
import '../components/etapas_cadastro/etapa2.dart';
import '../components/etapas_cadastro/etapa3.dart';

class PaginaCadastro extends StatefulWidget {
  const PaginaCadastro({super.key});

  @override
  State<PaginaCadastro> createState() => _PaginaCadastroState();
}

class _PaginaCadastroState extends State<PaginaCadastro> {
  final PageController _controladorPagina = PageController();
  int _etapaAtual = 0;
  final int _totalEtapas = 5;

  void _avancarEtapa() {
    if (_etapaAtual < _totalEtapas - 1) {
      _controladorPagina.nextPage(
        duration: const Duration(milliseconds: 300), 
        curve: Curves.easeInOut,
      );
    } else {
    }
  }

  void _voltarEtapa() {
    if (_etapaAtual > 0) {
      _controladorPagina.previousPage(
        duration: const Duration(milliseconds: 300), 
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    const corAzulEscuro = Color.fromARGB(255, 9, 17, 131);

    return Scaffold(
      backgroundColor: Colors.white, 
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BarraProgressoEtapas(progresso: (_etapaAtual + 1) / _totalEtapas),
              const SizedBox(height: 24),

              const Center(
                child: Text(
                  'Cadastro Institucional',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: corAzulEscuro,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Expanded(
                child: PageView(
                  controller: _controladorPagina,
                  physics: const NeverScrollableScrollPhysics(), 
                  onPageChanged: (index) {
                    setState(() {
                      _etapaAtual = index;
                    });
                  },
                  children: const [
                    Etapa1(),
                    Etapa2(),
                    Etapa3(),
                  ],
                ),
              ),
              
              BotoesNavegacao(
                aoVoltar: _voltarEtapa,
                aoContinuar: _avancarEtapa,
              ),
            ],
          ),
        ),
      ),
    );
  }
}