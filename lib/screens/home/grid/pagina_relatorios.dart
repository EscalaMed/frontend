import 'package:flutter/material.dart';
import '../../../components/card_resumo.dart';

class TelaRelatorios extends StatelessWidget {
  const TelaRelatorios({super.key});

  @override
  Widget build(BuildContext context) {
    const corAzulEscuro = Color.fromARGB(255, 9, 17, 131);
    const corFundoApp = Color(0xFFF4F6FA);
    const corAzulVibrante = Color(0xFF3948F5);

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
          'Relatórios',
          style: TextStyle(color: corAzulEscuro, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Visão Geral do Mês',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: corAzulEscuro),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                const Expanded(
                  child: CardResumo(
                    titulo: 'Total de\nFuncionários',
                    valor: '0',
                    icone: Icons.people_alt_outlined,
                    cor: corAzulVibrante,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: CardResumo(
                    titulo: 'Plantões\nRealizados',
                    valor: '0',
                    icone: Icons.check_circle_outline,
                    cor: Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ocupação por Setor',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: corAzulEscuro),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'Forma de Contratação',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: corAzulEscuro),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}