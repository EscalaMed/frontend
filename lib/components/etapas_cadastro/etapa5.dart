import 'package:flutter/material.dart';
import '../../components/barra_progresso.dart';
import '../../components/campo_texto.dart';
import '../../components/botoes_navegacao.dart';
import '../../components/modal_selecao.dart';

class TelaSetores extends StatefulWidget {
  const TelaSetores({super.key});

  @override
  State<TelaSetores> createState() => _TelaSetoresState();
}

class _TelaSetoresState extends State<TelaSetores> {
  final TextEditingController _coordenadorController = TextEditingController();

  @override
  void dispose() {
    _coordenadorController.dispose();
    super.dispose();
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
              const BarraProgressoEtapas(progresso: 0.6),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Adicionar Setores',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: corAzulEscuro),
                  ),
                  Icon(Icons.add_circle_outline, color: corAzulEscuro, size: 28),
                ],
              ),
              const SizedBox(height: 32),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const CampoTextoCustomizado(label: 'Nome do Setor', keyboardType: TextInputType.name),
                      const SizedBox(height: 16),
                      
                      GestureDetector(
                        onTap: () {
                          mostrarModalSelecao(
                            context: context,
                            tipo: 'Coordenador',
                            opcoes: [],
                            aoSelecionar: (escolha) {
                              setState(() {
                                _coordenadorController.text = escolha;
                              });
                            },
                          );
                        },
                        child: AbsorbPointer(
                          child: CampoTextoCustomizado(
                            label: 'Coordenador',
                            controller: _coordenadorController,
                            iconeDireita: Icons.keyboard_arrow_down, 
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              BotoesNavegacao(
                textoContinuar: 'Concluído',
                aoVoltar: () => Navigator.pop(context),
                aoContinuar: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}