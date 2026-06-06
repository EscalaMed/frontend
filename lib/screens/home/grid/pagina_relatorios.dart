import 'package:flutter/material.dart';
import '../../../components/card_resumo.dart';
import '../../../components/grafico.dart';
import '../../../components/lista_de_contrato.dart';
import 'relatorios/tela_detalhes_alertas.dart';
import 'relatorios/tela_detalhes_contratacao.dart';

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
              children: const [
                Expanded(
                  child: CardResumo(
                    titulo: 'Total de\nFuncionários',
                    valor: '0',
                    icone: Icons.people_alt_outlined,
                    cor: corAzulVibrante,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
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

            const Text(
              'Frequência e Assiduidade',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: corAzulEscuro),
            ),
            const SizedBox(height: 16),
            Row(
              children: const [
                Expanded(
                  child: CardResumo(
                    titulo: 'Faltas e\nAtestados',
                    valor: '0',
                    icone: Icons.warning_amber_rounded,
                    cor: Colors.redAccent,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: CardResumo(
                    titulo: 'Trocas de\nPlantão',
                    valor: '0',
                    icone: Icons.swap_horiz_rounded,
                    cor: Colors.orange,
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
                children: const [
                  Text(
                    'Horas Extras por Setor',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: corAzulEscuro),
                  ),
                  SizedBox(height: 24),

                  Grafico(label: 'Enfermagem', porcentagem: 0.0, valorTexto: '0h', cor: Colors.redAccent),
                  SizedBox(height: 16),
                  Grafico(label: 'Recepção', porcentagem: 0.0, valorTexto: '0h', cor: Colors.orange),
                  SizedBox(height: 16),
                  Grafico(label: 'Clínica Médica', porcentagem: 0.0, valorTexto: '0h', cor: corAzulVibrante),
                ],
              ),
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
                children: const [
                  Text(
                    'Ocupação por Setor',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: corAzulEscuro),
                  ),
                  SizedBox(height: 24),
                  
                  Grafico(label: 'Clínica Médica', porcentagem: 0.0, valorTexto: '0%', cor: corAzulVibrante),
                  SizedBox(height: 16),
                  Grafico(label: 'Pediatria', porcentagem: 0.0, valorTexto: '0%', cor: Colors.orange),
                  SizedBox(height: 16),
                  Grafico(label: 'Cirurgia Geral', porcentagem: 0.0, valorTexto: '0%', cor: Colors.teal),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'Alertas do Sistema',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: corAzulEscuro),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  ItemListaContrato(
                    titulo: 'Déficit na Pediatria', 
                    subtitulo: 'Faltam 0 médicos para o plantão noturno', 
                    icone: Icons.error_outline,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const TelaDetalhesAlertas()));
                    },
                  ),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  ItemListaContrato(
                    titulo: 'Limite de Horas',
                    subtitulo: '0 funcionários próximos do limite semanal',
                    icone: Icons.timer_outlined,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const TelaDetalhesAlertas()));
                    },
                  ),
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
                  ItemListaContrato(
                    titulo: 'CLT',
                    subtitulo: '0 funcionários',
                    icone: Icons.badge_outlined,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const TelaDetalhesContratacao(tipoContrato: 'CLT')));
                    },
                  ),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  ItemListaContrato(
                    titulo: 'PJ',
                    subtitulo: '0 funcionários',
                    icone: Icons.business_center_outlined,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const TelaDetalhesContratacao(tipoContrato: 'PJ')));
                    },
                  ),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  ItemListaContrato(
                    titulo: 'Cooperado',
                    subtitulo: '0 funcionários',
                    icone: Icons.handshake_outlined,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const TelaDetalhesContratacao(tipoContrato: 'Cooperado')));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}