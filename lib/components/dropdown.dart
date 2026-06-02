import 'package:flutter/material.dart';

class CampoDropdownCustomizado extends StatelessWidget {
  final String label;
  final List<String> itens;

  const CampoDropdownCustomizado({
    super.key,
    required this.label,
    required this.itens,
  });

  @override
  Widget build(BuildContext context) {
    const corAzulEscuro = Color.fromARGB(255, 9, 17, 131);

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: corAzulEscuro, fontWeight: FontWeight.bold),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: corAzulEscuro, width: 2),
        ),
      ),
      icon: const Icon(Icons.keyboard_arrow_down, color: corAzulEscuro),
      items: itens.map((String valor) {
        return DropdownMenuItem<String>(
          value: valor,
          child: Text(valor),
        );
      }).toList(),
      onChanged: (novoValor) {
      },
    );
  }
}