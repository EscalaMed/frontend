import 'package:flutter/material.dart';

class BarraProgressoEtapas extends StatelessWidget {
  final double progresso;

  const BarraProgressoEtapas({
    super.key,
    required this.progresso,
  });

  @override
  Widget build(BuildContext context) {
    const corAzulVibrante = Color(0xFF3948F5);
    const corAzulEscuro = Color.fromARGB(255, 9, 17, 131);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progresso,
            minHeight: 8,
            backgroundColor: Colors.grey[300],
            color: corAzulVibrante,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'EscalaM',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: corAzulEscuro,
              ),
            ),
            
            Transform.translate(
              offset: const Offset(0, 3),
              child: Image.asset(
                'image/logo.png',
                height: 32,
                fit: BoxFit.contain,
              ),
            ),
            
            Transform.translate(
              offset: const Offset(-4, 0),
              child: const Text(
                'd',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: corAzulEscuro,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}