import 'package:flutter/material.dart';

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EscalaMed',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
      ),
      home: const TelaInicial(),
    );
  }
}

class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'EscalaM',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    
                    Transform.translate(
                      offset: const Offset(0, 5), 
                      child: Image.asset(
                        'image/logo.png',
                        height: 70, 
                        fit: BoxFit.contain,
                      ),
                    ),
                    
                    Transform.translate(
                      offset: const Offset(-8, 0), 
                      child: const Text(
                        'd',
                        style: TextStyle(
                          fontSize: 48,
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
                    onPressed: () {
                    },
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
                      onTap: () {
                      },
                      conteudo: Image.asset('image/google.png', height: 20),
                    ), 
                    const SizedBox(width: 16),
                    BotaoSocial(
                      onTap: () {
                      },
                      conteudo: Image.asset('image/facebook.png', height: 20),
                    ),
                    const SizedBox(width: 16),
                    BotaoSocial(
                      onTap: () {
                      },
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

class BotaoSocial extends StatefulWidget {
  final Widget conteudo;
  final VoidCallback onTap;

  const BotaoSocial({
    super.key, 
    required this.conteudo, 
    required this.onTap,
  });

  @override
  State<BotaoSocial> createState() => _BotaoSocialState();
}

class _BotaoSocialState extends State<BotaoSocial> {
  bool _estaComMousePorCima = false;
  bool _estaSendoPressionado = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _estaComMousePorCima = true),
      onExit: (_) => setState(() => _estaComMousePorCima = false),
      cursor: SystemMouseCursors.click, 
      
      child: GestureDetector(
        onTapDown: (_) => setState(() => _estaSendoPressionado = true),
        onTapUp: (_) => setState(() => _estaSendoPressionado = false),
        onTapCancel: () => setState(() => _estaSendoPressionado = false),
        onTap: widget.onTap,
        
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: _estaComMousePorCima && !_estaSendoPressionado ? 0.7 : 1.0, 
          
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 50,
            height: 35,
            decoration: BoxDecoration(
              color: _estaSendoPressionado ? Colors.grey[300] : Colors.white,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                if (_estaComMousePorCima && !_estaSendoPressionado)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
              ],
            ),
            child: Center(
              child: widget.conteudo,
            ),
          ),
        ),
      ),
    );
  }
}