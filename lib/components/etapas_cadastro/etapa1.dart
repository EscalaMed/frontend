import 'package:flutter/material.dart';
import '../campo_texto.dart';

class Etapa1 extends StatelessWidget {
  final TextEditingController nomeController;
  final TextEditingController cnpjController;
  final TextEditingController crmController;
  final TextEditingController cnesController;
  final TextEditingController cepController;
  final TextEditingController enderecoController;
  final TextEditingController cidadeController;
  final TextEditingController estadoController;

  const Etapa1({
    super.key,
    required this.nomeController,
    required this.cnpjController,
    required this.crmController,
    required this.cnesController,
    required this.cepController,
    required this.enderecoController,
    required this.cidadeController,
    required this.estadoController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Cadastro Institucional',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 9, 17, 131),
            ),
          ),
          const SizedBox(height: 32),
          CampoTextoCustomizado(label: 'Nome da Instituição', keyboardType: TextInputType.name, controller: nomeController),
          const SizedBox(height: 16),
          
          CampoTextoCustomizado(label: 'CNPJ', keyboardType: TextInputType.number, controller: cnpjController),
          const SizedBox(height: 16),
          
          CampoTextoCustomizado(label: 'CRM Jurídico', keyboardType: TextInputType.text, controller: crmController),
          const SizedBox(height: 16),
          
          CampoTextoCustomizado(label: 'CNES', keyboardType: TextInputType.number, controller: cnesController),
          const SizedBox(height: 16),
          
          CampoTextoCustomizado(label: 'CEP', keyboardType: TextInputType.number, controller: cepController),
          const SizedBox(height: 16),
          
          CampoTextoCustomizado(label: 'Endereço', keyboardType: TextInputType.streetAddress, controller: enderecoController),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: CampoTextoCustomizado(label: 'Cidade', keyboardType: TextInputType.text, controller: cidadeController),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CampoTextoCustomizado(label: 'Estado (UF)', keyboardType: TextInputType.text, controller: estadoController),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}