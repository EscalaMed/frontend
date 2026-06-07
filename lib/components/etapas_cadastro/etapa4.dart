import 'package:flutter/material.dart';
import '../../components/barra_progresso.dart';
import '../../components/campo_texto.dart';
import '../../components/botoes_navegacao.dart';
import '../../components/modal_selecao.dart';

class TelaCoordenador extends StatefulWidget {
  final bool ehTelaIndependente;
  const TelaCoordenador({super.key, this.ehTelaIndependente = false});

  @override
  State<TelaCoordenador> createState() => _TelaCoordenadorState();
}

class _TelaCoordenadorState extends State<TelaCoordenador> {
  final TextEditingController _cargoController = TextEditingController();
  final TextEditingController _contratoController = TextEditingController();

  @override
  void dispose() {
    _cargoController.dispose();
    _contratoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const corAzulEscuro = Color.fromARGB(255, 9, 17, 131);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.ehTelaIndependente
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: corAzulEscuro),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'Adicionar Coordenador',
                style: TextStyle(color: corAzulEscuro, fontWeight: FontWeight.bold, fontSize: 20),
              ),
              centerTitle: false,
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 34.0),
          child: Column(
            children: [
              if (!widget.ehTelaIndependente) ...[
                const BarraProgressoEtapas(progresso: 0.6),
                const SizedBox(height: 24),
                
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Adicionar Coordenador',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: corAzulEscuro),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CampoTextoCustomizado(label: 'Nome Completo', keyboardType: TextInputType.name),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: const [
                          Expanded(child: CampoTextoCustomizado(label: 'CPF', keyboardType: TextInputType.number)),
                          SizedBox(width: 16),
                          Expanded(child: CampoTextoCustomizado(label: 'Telefone', keyboardType: TextInputType.phone)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      const CampoTextoCustomizado(
                        label: 'Número de Registro Profissional', 
                        hintText: 'CRM, COREN, CRP...',
                      ),
                      const SizedBox(height: 16),

                      GestureDetector(
                        onTap: () {
                          mostrarModalSelecao(
                            context: context,
                            tipo: 'Cargos',
                            opcoes: [],
                            aoSelecionar: (escolha) {
                              setState(() {
                                _cargoController.text = escolha;
                              });
                            },
                          );
                        },
                        child: AbsorbPointer(
                          child: CampoTextoCustomizado(
                            label: 'Cargo',
                            controller: _cargoController,
                            iconeDireita: Icons.keyboard_arrow_down,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      GestureDetector(
                        onTap: () {
                          mostrarModalSelecao(
                            context: context,
                            tipo: 'Contratação',
                            opcoes: [],
                            aoSelecionar: (escolha) {
                              setState(() {
                                _contratoController.text = escolha;
                              });
                            },
                          );
                        },
                        child: AbsorbPointer(
                          child: CampoTextoCustomizado(
                            label: 'Forma de Contratação',
                            controller: _contratoController,
                            iconeDireita: Icons.keyboard_arrow_down,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              if (widget.ehTelaIndependente)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: corAzulEscuro,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Concluído',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_ios, size: 18),
                      ],
                    ),
                  ),
                )
              else
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