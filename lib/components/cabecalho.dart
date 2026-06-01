import 'package:flutter/material.dart';

class CabecalhoLogo extends StatelessWidget {
  final Color corTexto;
  final bool centralizado;

  const CabecalhoLogo({
    super.key, 
    required this.corTexto,
    this.centralizado = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: centralizado ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: centralizado ? MainAxisAlignment.center : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'EscalaM',
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: corTexto,
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
              child: Text(
                'd',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: corTexto,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          centralizado 
              ? 'Um jeito simples de organizar\nplantões.' 
              : 'Um jeito simples de organizar plantões.',
          textAlign: centralizado ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: corTexto,
          ),
        ),
      ],
    );
  }
}