import 'package:flutter/material.dart';
import '../../components/card_destaque.dart';
import '../../components/card_grid_menu.dart';
import '../../components/etapas_cadastro/etapa3.dart';
import 'grid/pagina_cadastro_funcionarios.dart';
import 'grid/pagina_relatorios.dart';

class HomeAdmin extends StatelessWidget {
  const HomeAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    const corAzulEscuro = Color.fromARGB(255, 9, 17, 131);
    const corFundoApp = Color(0xFFF4F6FA);

    return Scaffold(
      backgroundColor: corFundoApp,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Olá, Administrador',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: corAzulEscuro),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Painel Geral de Controle',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Badge(
                      label: Text('0'),
                      child: Icon(Icons.notifications_none_outlined, color: corAzulEscuro, size: 28),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const CardDestaque(),

              const SizedBox(height: 32),

              const Text(
                'Ações Rápidas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: corAzulEscuro),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    CardGridMenu(
                      icone: Icons.local_hospital_outlined,
                      titulo: 'Gerenciar\nHospital',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Etapa3(ehTelaIndependente: true), 
                          ),
                        );
                      },
                    ),
                    CardGridMenu(
                      icone: Icons.person_add_alt_1_outlined,
                      titulo: 'Adicionar\nFuncionários',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PaginaCadastroFuncionarios(),
                          ),
                        );
                      },
                    ),
                    CardGridMenu(
                      icone: Icons.calendar_month_outlined,
                      titulo: 'Escalas e\nTurnos',
                      onTap: () {},
                    ),
                    CardGridMenu(
                      icone: Icons.bar_chart_outlined,
                      titulo: 'Relatórios\nEstatísticos',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TelaRelatorios(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}