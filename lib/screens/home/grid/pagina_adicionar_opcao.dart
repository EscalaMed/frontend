import 'package:flutter/material.dart';
import '../../../components/campo_texto.dart'; 
import 'package:http/http.dart' as http;
import 'dart:convert';

class TelaAdicionarOpcao extends StatefulWidget {
  final String tipo;

  const TelaAdicionarOpcao({super.key, required this.tipo});

  @override
  State<TelaAdicionarOpcao> createState() => _TelaAdicionarOpcaoState();
}

class _TelaAdicionarOpcaoState extends State<TelaAdicionarOpcao> {
  final TextEditingController _nomeController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_nomeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Digite o nome do(a) ${widget.tipo}')),
      );
      return;
    }
    final url = Uri.parse('http://10.0.2.2:5000/adicionar_opcao');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "tipo": widget.tipo,
          "valor": _nomeController.text.trim(),
        }),
      );

      if (response.statusCode == 201) {
        Navigator.pop(context, _nomeController.text.trim());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao salvar no servidor', textAlign: TextAlign.center)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro de conexão', textAlign: TextAlign.center)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const corAzulEscuro = Color.fromARGB(255, 9, 17, 131);
    const corFundoApp = Color(0xFFF4F6FA);

    return Scaffold(
      backgroundColor: corFundoApp,
      appBar: AppBar(
        backgroundColor: corFundoApp,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: corAzulEscuro),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Novo ${widget.tipo}',
          style: const TextStyle(color: corAzulEscuro, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Adicionar ${widget.tipo.toLowerCase()}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: corAzulEscuro),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Preencha o nome abaixo para disponibilizar esta opção no sistema.',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 32),
                      
                      CampoTextoCustomizado(
                        label: 'Nome do(a) ${widget.tipo}',
                        controller: _nomeController,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _salvar,
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
                        'Salvar',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.check, size: 18),
                    ],
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