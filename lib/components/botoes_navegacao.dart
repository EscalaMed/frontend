import 'package:flutter/material.dart';

class BotoesNavegacao extends StatelessWidget {
  final VoidCallback aoVoltar;
  final VoidCallback aoContinuar;

  const BotoesNavegacao({
    super.key,
    required this.aoVoltar,
    required this.aoContinuar,
  });

  @override
  Widget build(BuildContext context) {
    const corAzulEscuro = Color.fromARGB(255, 9, 17, 131);

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              onPressed: aoVoltar,
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              label: const Text(
                'Voltar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: corAzulEscuro,
                side: const BorderSide(color: corAzulEscuro, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        Expanded(
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: aoContinuar,
              style: ElevatedButton.styleFrom(
                backgroundColor: corAzulEscuro,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Continuar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios, size: 18),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}