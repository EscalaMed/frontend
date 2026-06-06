import 'package:flutter/material.dart';
import '../../../../components/card_alerta.dart';

class TelaDetalhesAlertas extends StatelessWidget {
  const TelaDetalhesAlertas({super.key});

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
        title: const Text(
          'Alertas Ativos',
          style: TextStyle(color: corAzulEscuro, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: const [
          CardAlerta(
            titulo: 'Déficit Urgente de Plantão',
            descricao: 'O plantão noturno está sem cobertura mínima obrigatória de médicos especialistas.',
            setor: 'Pediatria',
            horario: 'Hoje • 19:00 - 07:00',
            icone: Icons.error_outline_rounded,
            corPrioridade: Colors.redAccent,
          ),
          CardAlerta(
            titulo: 'Limite de Carga Horária Próximo',
            descricao: 'Colaboradores atingiram 95% do limite máximo de horas permitidas nesta semana.',
            setor: 'Geral (Múltiplos)',
            horario: 'Atualizado há 10 min',
            icone: Icons.timer_outlined,
            corPrioridade: Colors.orange,
          ),
          CardAlerta(
            titulo: 'Troca de Turno Pendente',
            descricao: 'Solicitação de substituição aguardando aprovação da coordenação clínica.',
            setor: 'Clínica Médica',
            horario: 'Amanhã • 07:00',
            icone: Icons.swap_horiz_rounded,
            corPrioridade: Colors.blue,
          ),
        ],
      ),
    );
  }
}