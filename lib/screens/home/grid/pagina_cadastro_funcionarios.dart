import 'package:flutter/material.dart';
import '../../../components/campo_texto.dart';
import '../../../components/modal_selecao.dart';

class PaginaCadastroFuncionarios extends StatefulWidget {
  const PaginaCadastroFuncionarios({super.key});

  @override
  State<PaginaCadastroFuncionarios> createState() => _PaginaCadastroFuncionariosState();
}

class _PaginaCadastroFuncionariosState extends State<PaginaCadastroFuncionarios> {
  final TextEditingController _cargoController = TextEditingController();
  final TextEditingController _setorController = TextEditingController();
  final TextEditingController _contratoController = TextEditingController();
  final TextEditingController _cargaController = TextEditingController();

  @override
  void dispose() {
    _cargoController.dispose();
    _setorController.dispose();
    _contratoController.dispose();
    _cargaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const corAzulEscuro = Color.fromARGB(255, 9, 17, 131);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: corAzulEscuro),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Adicionar Funcionários',
          style: TextStyle(color: corAzulEscuro, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32.0, 38.0, 32.0, 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
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
                            tipo: 'Setores',
                            opcoes: [],
                            aoSelecionar: (escolha) {
                              setState(() {
                                _setorController.text = escolha;
                              });
                            },
                          );
                        },
                        child: AbsorbPointer(
                          child: CampoTextoCustomizado(
                            label: 'Setor',
                            controller: _setorController,
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
                            aoSelecionar: (escolha) => setState(() => _contratoController.text = escolha),
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
                      const SizedBox(height: 16),

                      GestureDetector(
                        onTap: () {
                          mostrarModalSelecao(
                            context: context,
                            tipo: 'Carga Horária',
                            opcoes: [],
                            aoSelecionar: (escolha) => setState(() => _cargaController.text = escolha),
                          );
                        },
                        child: AbsorbPointer(
                          child: CampoTextoCustomizado(
                            label: 'Carga horária',
                            controller: _cargaController,
                            iconeDireita: Icons.keyboard_arrow_down,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
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
              ),
              
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}