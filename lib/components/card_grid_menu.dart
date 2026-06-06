import 'package:flutter/material.dart';

class CardGridMenu extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final VoidCallback onTap;

  const CardGridMenu({
    super.key,
    required this.icone,
    required this.titulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const corAzulEscuro = Color.fromARGB(255, 9, 17, 131);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: corAzulEscuro.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icone, color: corAzulEscuro, size: 28),
            ),
            Text(
              titulo,
              style: const TextStyle(
                color: corAzulEscuro,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}