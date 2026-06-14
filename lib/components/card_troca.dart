// components/card_troca.dart
import 'package:flutter/material.dart';

class CardTroca extends StatelessWidget {
  final String meuPlantao;
  final String plantaoDesejado;
  final String funcionario;
  final String status;
  final String motivo;
  final VoidCallback? aoCancelar;

  const CardTroca({
    super.key,
    required this.meuPlantao,
    required this.plantaoDesejado,
    required this.funcionario,
    required this.status,
    required this.motivo,
    this.aoCancelar,
  });

  Color get _corStatus {
    switch (status) {
      case 'Aceita':   return const Color(0xFF2E7D32);
      case 'Recusada': return const Color(0xFFC62828);
      default:         return const Color(0xFFF57F17);
    }
  }

  IconData get _iconeStatus {
    switch (status) {
      case 'Aceita':   return Icons.check_circle_outline;
      case 'Recusada': return Icons.cancel_outlined;
      default:         return Icons.hourglass_top_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    const corAzulEscuro = Color.fromARGB(255, 9, 17, 131);
    const corBorda = Color(0xFFB0B5D9);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: corBorda, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Funcionário + badge de status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                funcionario,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: corAzulEscuro,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _corStatus.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_iconeStatus, size: 14, color: _corStatus),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _corStatus),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE0E4F0)),
          const SizedBox(height: 12),

          // Plantões com ícone de troca
          _LinhaPlantao(icone: Icons.calendar_today_outlined,    label: 'Meu plantão',     valor: meuPlantao),
          Center(child: Icon(Icons.swap_vert, size: 18, color: corAzulEscuro.withValues(alpha: 0.4))),
          _LinhaPlantao(icone: Icons.event_available_outlined,   label: 'Plantão desejado', valor: plantaoDesejado),

          const SizedBox(height: 12),

          // Motivo
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.notes_outlined, size: 16, color: corAzulEscuro.withValues(alpha: 0.5)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  motivo,
                  style: TextStyle(fontSize: 13, color: corAzulEscuro.withValues(alpha: 0.7)),
                ),
              ),
            ],
          ),

          // Botão cancelar — apenas pendentes
          if (status == 'Pendente' && aoCancelar != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton.icon(
                onPressed: aoCancelar,
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Cancelar Solicitação',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFC62828),
                  side: const BorderSide(color: Color(0xFFC62828), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Widget privado auxiliar — linha de plantão dentro do card
class _LinhaPlantao extends StatelessWidget {
  final IconData icone;
  final String label;
  final String valor;

  const _LinhaPlantao({required this.icone, required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    const corAzulEscuro = Color.fromARGB(255, 9, 17, 131);
    return Row(
      children: [
        Icon(icone, size: 16, color: corAzulEscuro.withValues(alpha: 0.5)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: corAzulEscuro.withValues(alpha: 0.5))),
            Text(valor,  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: corAzulEscuro)),
          ],
        ),
      ],
    );
  }
}