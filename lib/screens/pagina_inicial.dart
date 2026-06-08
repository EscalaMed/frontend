import 'package:flutter/material.dart';
import '../components/cabecalho.dart';
import '../components/rodape.dart';
import 'pagina_login.dart';

class PaginaInicial extends StatelessWidget {
  const PaginaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF00E1D9), Color(0xFF0078D7), Color(0xFF001F54)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const CabecalhoLogo(
                  corTexto: Colors.white,
                  centralizado: false,
                ),
                const SizedBox(height: 40),

                const Text(
                  'Sua escala de plantão na\npalma da mão.\nOrganizamos a\ncomplexidade do hospital\npara que você foque no\nque importa: o cuidado.',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, 
                    height: 1.3,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 2),
                        blurRadius: 4.0,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PaginaLogin()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Entrar', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 40),
                
                const RodapeSociais(corLinha: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}