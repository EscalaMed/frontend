import 'package:flutter/material.dart';
import '../../../../components/card_colaborador_contrato.dart';

class TelaDetalhesContratacao extends StatelessWidget {
  final String tipoContrato;

  const TelaDetalhesContratacao({super.key, required this.tipoContrato});

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
          'Regime: $tipoContrato',
          style: const TextStyle(color: corAzulEscuro, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Text(
            'Colaboradores Ativos ($tipoContrato)',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: corAzulEscuro),
          ),
          const SizedBox(height: 16),
          
          CardColaboradorContrato(nome: 'Dra. Ana Silva', cargo: 'Médica Plantonista', regime: tipoContrato, matricula: '4821'),
          CardColaboradorContrato(nome: 'Dr. Carlos Mendes', cargo: 'Cirurgião Geral', regime: tipoContrato, matricula: '9310'),
          CardColaboradorContrato(nome: 'Enf. Juliana Costa', cargo: 'Enfermeira Chefe', regime: tipoContrato, matricula: '1104'),
        ],
      ),
    );
  }
}