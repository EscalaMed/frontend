import 'package:flutter/material.dart';
import '../../components/barra_progresso.dart';
import '../../components/campo_texto.dart';
import '../../components/modal_selecao.dart';

class TelaSetores extends StatefulWidget {
  final bool ehTelaIndependente;
  final double progressoAtual;
  const TelaSetores({super.key, this.ehTelaIndependente = false, this.progressoAtual = 0.50});

  @override
  State<TelaSetores> createState() => _TelaSetoresState();
}

class _TelaSetoresState extends State<TelaSetores> {
  final TextEditingController _nomeSetorController = TextEditingController();
  final TextEditingController _coordenadorController = TextEditingController();

  List<String> _listaCoordenadores = ['Dr. Carlos Alberto', 'Dra. Mariana Souza'];

  @override
  void dispose() {
    _nomeSetorController.dispose();
    _coordenadorController.dispose();
    super.dispose();
  }

  void _concluirEVoltar() {
    if (_nomeSetorController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O nome do setor é obrigatório!', textAlign: TextAlign.center), backgroundColor: Colors.redAccent),
      );
      return;
    }
    Navigator.pop(context, {
      'nome': _nomeSetorController.text.trim(),
      'coordenador_responsavel': _coordenadorController.text.trim(),
    });
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
          'Adicionar Setor',
          style: TextStyle(color: corAzulEscuro, fontWeight: FontWeight.bold),
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
                child: Column(
                  children: [
                    CampoTextoCustomizado(label: 'Nome do Setor', hintText: 'Ex: UTI Geral, Pediatria...', controller: _nomeSetorController),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => mostrarModalSelecao(
                        context: context,
                        tipo: 'Coordenadores',
                        opcoes: _listaCoordenadores,
                        aoSelecionar: (val) => setState(() => _coordenadorController.text = val),
                        aoCriarNovaOpcao: (novoCoord) {
                          setState(() {
                            _listaCoordenadores.add(novoCoord);
                            _coordenadorController.text = novoCoord;
                          });
                        },
                      ),
                      child: AbsorbPointer(
                        child: CampoTextoCustomizado(label: 'Coordenador Responsável (Opcional)', controller: _coordenadorController, iconeDireita: Icons.keyboard_arrow_down),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: _concluirEVoltar,
                  style: ElevatedButton.styleFrom(backgroundColor: corAzulEscuro, foregroundColor: Colors.white),
                  child: const Text('Concluído', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}