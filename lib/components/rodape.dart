import 'package:flutter/material.dart';
import 'botao_social.dart';
import '../screens/pagina_cadastro.dart';

class RodapeSociais extends StatelessWidget {
  final Color corLinha;

  const RodapeSociais({super.key, required this.corLinha});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: corLinha.withValues(alpha: 0.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaginaCadastro(),
                    ),
                  );
                },
                child: Text(
                  'Ou cadastra-se',
                  style: TextStyle(
                    color: corLinha,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                    decorationColor: corLinha,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            Expanded(
              child: Container(
                height: 1,
                color: corLinha.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BotaoSocial(
              onTap: () {},
              corBorda: corLinha.withValues(alpha: 0.4),
              conteudo: Image.asset('image/google.png', height: 20),
            ),
            const SizedBox(width: 16),
            BotaoSocial(
              onTap: () {},
              corBorda: corLinha.withValues(alpha: 0.4),
              conteudo: Image.asset('image/facebook.png', height: 20),
            ),
            const SizedBox(width: 16),
            BotaoSocial(
              onTap: () {},
              corBorda: corLinha.withValues(alpha: 0.4),
              conteudo: Image.asset('image/linkedin.png', height: 20),
            ),
          ],
        ),
        const SizedBox(height: 114),
      ],
    );
  }
}