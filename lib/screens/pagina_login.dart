import 'package:flutter/material.dart';
import '../components/cabecalho.dart';
import '../components/rodape.dart';
import '../components/campo_texto.dart';

class PaginaLogin extends StatelessWidget {
  const PaginaLogin({super.key});

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
              const Spacer(),

              const CabecalhoLogo(
                corTexto: corAzulEscuro,
                centralizado: true,
              ),
              
              const SizedBox(height: 40),
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: corAzulEscuro,
                ),
              ),
              const SizedBox(height: 24),
              
              const CampoTextoCustomizado(
                label: 'E-mail',
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

              const CampoTextoCustomizado(
                label: 'Senha',
                isPassword: true,
              ),
              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Esqueceu a senha?',
                    style: TextStyle(
                      color: corAzulEscuro,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: corAzulEscuro,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton( 
                  onPressed: () {
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: corAzulEscuro,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Entrar',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const Spacer(),
              const RodapeSociais(corLinha: corAzulEscuro),
            ],
          ),
        ),
      ),
    );
  }
}