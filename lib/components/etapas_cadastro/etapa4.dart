import 'package:flutter/material.dart';
import '../../components/barra_progresso.dart';
import '../../components/campo_texto.dart';
import '../../components/modal_selecao.dart';

class TelaCoordenador extends StatefulWidget {
  final bool ehTelaIndependente;
  final double progressoAtual;
  const TelaCoordenador({
    super.key,
    this.ehTelaIndependente = false,
    this.progressoAtual = 0.50,
  });

  @override
  State<TelaCoordenador> createState() => _TelaCoordenadorState();
}

class _TelaCoordenadorState extends State<TelaCoordenador> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _registroController = TextEditingController();
  final TextEditingController _cargoController = TextEditingController();
  final TextEditingController _contratoController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _registroController.dispose();
    _cargoController.dispose();
    _contratoController.dispose();
    super.dispose();
  }

  void _concluirEVoltar() {
    if (_nomeController.text.trim().isEmpty ||
        _cpfController.text.trim().isEmpty ||
        _telefoneController.text.trim().isEmpty ||
        _registroController.text.trim().isEmpty ||
        _cargoController.text.trim().isEmpty ||
        _contratoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Preencha todos os campos do coordenador!',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final dados = {
      'nome': _nomeController.text.trim(),
      'cpf': _cpfController.text.trim(),
      'telefone': _telefoneController.text.trim(),
      'registro': _registroController.text.trim(),
      'cargo': _cargoController.text.trim(),
      'contrato': _contratoController.text.trim(),
    };

    Navigator.pop(context, dados);
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
          icon: const Icon(Icons.arrow_back_ios_new, color: Color.fromARGB(255, 9, 17, 131)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Adicionar Coordenador',
          style: TextStyle(color: Color.fromARGB(255, 9, 17, 131), fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 34.0),
          child: Column(
            children: [
              if (!widget.ehTelaIndependente) ...[
                BarraProgressoEtapas(progresso: widget.progressoAtual),
                const SizedBox(height: 32),
              ],
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      CampoTextoCustomizado(
                        label: 'Nome Completo',
                        keyboardType: TextInputType.name,
                        controller: _nomeController,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CampoTextoCustomizado(
                              label: 'CPF',
                              keyboardType: TextInputType.number,
                              controller: _cpfController,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CampoTextoCustomizado(
                              label: 'Telefone',
                              keyboardType: TextInputType.phone,
                              controller: _telefoneController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CampoTextoCustomizado(
                        label: 'Registro Profissional',
                        hintText: 'CRM, COREN...',
                        controller: _registroController,
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => mostrarModalSelecao(
                          context: context,
                          tipo: 'Cargos',
                          opcoes: [],
                          aoSelecionar: (val) =>
                              setState(() => _cargoController.text = val),
                        ),
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
                        onTap: () => mostrarModalSelecao(
                          context: context,
                          tipo: 'Contratação',
                          opcoes: [],
                          aoSelecionar: (val) =>
                              setState(() => _contratoController.text = val),
                        ),
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
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _concluirEVoltar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: corAzulEscuro,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Concluído',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
