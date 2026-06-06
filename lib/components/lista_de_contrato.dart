import 'package:flutter/material.dart';

class ItemListaContrato extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final IconData icone;

  const ItemListaContrato({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    const corAzulEscuro = Color.fromARGB(255, 9, 17, 131);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: corAzulEscuro.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(icone, color: corAzulEscuro, size: 20),
      ),
      title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, color: corAzulEscuro)),
      subtitle: Text(subtitulo),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
    );
  }
}