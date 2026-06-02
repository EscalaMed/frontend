import 'package:flutter/material.dart';
import '../../components/barra_progresso.dart';
import '../../components/campo_texto.dart';
import '../../components/dropdown.dart';
import '../../components/botoes_navegacao.dart';

class TelaCoordenador extends StatelessWidget {
  const TelaCoordenador({super.key});

  @override
  Widget build(BuildContext context) {
    const corAzulEscuro = Color.fromARGB(255, 9, 17, 131);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BarraProgressoEtapas(progresso: 0.6), 
              
              const SizedBox(height: 32),

              const Text(
                'Adicionar Coordenador',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: corAzulEscuro),
              ),
              const SizedBox(height: 32),

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

                      const CampoDropdownCustomizado(
                        label: 'Cargo', 
                        itens: ['Médico Chefe', 'Enfermeiro Chefe', 'Diretor Clínico'],
                      ),
                      const SizedBox(height: 16),

                      const CampoDropdownCustomizado(
                        label: 'Forma de Contratação', 
                        itens: ['CLT', 'PJ', 'Cooperado'],
                      ),
                    ],
                  ),
                ),
              ),

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