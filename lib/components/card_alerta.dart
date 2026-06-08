import 'package:flutter/material.dart';

class CardAlerta extends StatelessWidget {
  final String titulo;
  final String descricao;
  final String horario;
  final String setor;
  final IconData icone;
  final Color corPrioridade;

  const CardAlerta({
    super.key,
    required this.titulo,
    required this.descricao,
    required this.horario,
    required this.setor,
    required this.icone,
    required this.corPrioridade,
  });

  @override
  Widget build(BuildContext context) {
    const corAzulEscuro = Color.fromARGB(255, 9, 17, 131);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: corPrioridade, width: 5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, color: corPrioridade, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: corAzulEscuro),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            descricao,
            style: const TextStyle(color: Colors.black87, fontSize: 14),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Setor: $setor', style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
              Text(horario, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}