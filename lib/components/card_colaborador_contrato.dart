import 'package:flutter/material.dart';

class CardColaboradorContrato extends StatelessWidget {
  final String nome;
  final String cargo;
  final String regime;
  final String matricula;

  const CardColaboradorContrato({
    super.key,
    required this.nome,
    required this.cargo,
    required this.regime,
    required this.matricula,
  });

  @override
  Widget build(BuildContext context) {
    const corAzulEscuro = Color.fromARGB(255, 9, 17, 131);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nome,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: corAzulEscuro),
              ),
              const SizedBox(height: 4),
              Text(
                cargo,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: corAzulEscuro.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  regime,
                  style: const TextStyle(color: corAzulEscuro, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'ID: $matricula',
                style: const TextStyle(color: Colors.black38, fontSize: 11),
              ),
            ],
          )
        ],
      ),
    );
  }
}