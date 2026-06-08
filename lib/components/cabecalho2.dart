// components/cabecalho2.dart
import 'package:flutter/material.dart';
class Cabecalho2 extends StatelessWidget {
  final String titulo;
  final List<_Metrica> metricas;
  final List<Widget>? extras; //
  final Widget? acaoDireita;

  const Cabecalho2({
    super.key,
    required this.titulo,
    this.metricas = const [],
    this.extras,
    this.acaoDireita,
  });

  @override
  Widget build(BuildContext context) {
    const corAzulEscuro  = Color.fromARGB(255, 9, 17, 131);
    const corAzulVibrante = Color(0xFF3948F5);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [corAzulEscuro, corAzulVibrante],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Linha de título
          Row(children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              padding: EdgeInsets.zero, constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(titulo,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white))),
            if (acaoDireita != null) acaoDireita!,
          ]),

          // Métricas
          if (metricas.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: metricas.expand((m) sync* {
                if (metricas.indexOf(m) > 0)
                  yield Container(width: 1, height: 28, color: Colors.white30);
                yield _MetricaWidget(metrica: m);
              }).toList(),
            ),
          ],

          // Conteúdo extra (calendário, etc.)
          if (extras != null) ...extras!,
        ],
      ),
    );
  }
}

class _Metrica {
  final String valor, label;
  const _Metrica(this.valor, this.label);
}

class _MetricaWidget extends StatelessWidget {
  final _Metrica metrica;
  const _MetricaWidget({required this.metrica});

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(metrica.valor,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
    Text(metrica.label, style: const TextStyle(fontSize: 11, color: Colors.white60)),
  ]);
}

typedef Metrica = _Metrica;