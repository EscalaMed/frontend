import 'package:flutter/material.dart';
import '../components/botao_social.dart';

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
            colors: [
              Color(0xFF00E1D9),
              Color(0xFF0078D7),
              Color(0xFF001F54),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'EscalaM',
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    
                    Transform.translate(
                      offset: const Offset(0, 8), 
                      child: Image.asset(
                        'image/logo.png',
                        height: 90, 
                        fit: BoxFit.contain,
                      ),
                    ),
                    
                    Transform.translate(
                      offset: const Offset(-12, 0), 
                      child: const Text(
                        'd',
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                
                const Text(
                  'Um jeito simples de organizar plantões.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                
                const Text(
                  'Sua escala de plantão na\npalma da mão.\nOrganizamos a\ncomplexidade do hospital\npara que você foque no\nque importa: o cuidado.',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 40),
                
                Container(
                  height: 1,
                  width: double.infinity,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 40),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white, width: 1.5),
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
                const SizedBox(height: 24),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BotaoSocial(
                      onTap: () {},
                      conteudo: Image.asset('image/google.png', height: 20),
                    ), 
                    const SizedBox(width: 16),
                    BotaoSocial(
                      onTap: () {},
                      conteudo: Image.asset('image/facebook.png', height: 20),
                    ),
                    const SizedBox(width: 16),
                    BotaoSocial(
                      onTap: () {},
                      conteudo: Image.asset('image/linkedin.png', height: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}