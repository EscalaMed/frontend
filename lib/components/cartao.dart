import 'package:flutter/material.dart';

class CartaoOpcao extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String? subtitulo;
  final VoidCallback onTap;

  const CartaoOpcao({
    super.key,
    required this.icone,
    required this.titulo,
    this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const corAzulEscuro = Color.fromARGB(255, 9, 17, 131);
    const corBorda = Color(0xFFB0B5D9);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(color: corBorda, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icone, size: 32, color: corAzulEscuro),
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: corAzulEscuro,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  
                  if (subtitulo != null && subtitulo!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitulo!,
                      style: const TextStyle(
                        color: Color(0xFF8A94C9),
                        fontSize: 12,
                      ),
                    ),
                  ]
                ],
              ),
            ),
            
            const Icon(Icons.add_circle_outline, color: Colors.black87),
          ],
        ),
      ),
    );
  }
}