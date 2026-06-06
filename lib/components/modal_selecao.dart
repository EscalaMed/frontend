import 'package:flutter/material.dart';

void mostrarModalSelecao({
  required BuildContext context,
  required String tipo,
  required List<String> opcoes,
  required Function(String) aoSelecionar,
}) {
  const corAzulEscuro = Color.fromARGB(255, 9, 17, 131);

  showModalBottomSheet(
    context: context,
    backgroundColor: corAzulEscuro,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...opcoes.map((opcao) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    opcao,
                    style: const TextStyle(color: corAzulEscuro, fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.check_circle_outline, color: corAzulEscuro),
                  onTap: () {
                    aoSelecionar(opcao);
                    Navigator.pop(context);
                  },
                ),
              ),
            )),
            
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_circle_left_outlined, color: Colors.white),
                  label: const Text('Voltar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                TextButton.icon(
                  onPressed: () {
                  },
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                  label: Text('Adicionar $tipo', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}