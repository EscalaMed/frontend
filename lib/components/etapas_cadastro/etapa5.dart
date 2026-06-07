import 'package:flutter/material.dart';
import '../../components/barra_progresso.dart';
import '../../components/campo_texto.dart';
import '../../components/botoes_navegacao.dart';
import '../../components/modal_selecao.dart';

class TelaSetores extends StatefulWidget {
  final bool ehTelaIndependente;
  const TelaSetores({super.key, this.ehTelaIndependente = false});

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
      appBar: widget.ehTelaIndependente
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: corAzulEscuro),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'Gerenciar Hospital',
                style: TextStyle(color: corAzulEscuro, fontWeight: FontWeight.bold, fontSize: 20),
              ),
              centerTitle: false,
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(32.0, widget.ehTelaIndependente ? 38.0 : 24.0, 32.0, 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!widget.ehTelaIndependente) ...[
                const BarraProgressoEtapas(progresso: 0.6),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Adicionar Setores',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: corAzulEscuro),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],

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