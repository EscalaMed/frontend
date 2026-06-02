import 'package:flutter/material.dart';
import '../campo_texto.dart';

class Etapa2 extends StatelessWidget {
  const Etapa2({super.key});

  @override
  Widget build(BuildContext context) {
    const corAzulEscuro = Color.fromARGB(255, 9, 17, 131);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const CampoTextoCustomizado(label: 'Telefone', keyboardType: TextInputType.phone),
          const SizedBox(height: 16),
          
          const CampoTextoCustomizado(label: 'E-mail', keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          
          const CampoTextoCustomizado(label: 'Descrição', maxLines: 3),
          const SizedBox(height: 16),
          
          const Text('Logotipo', style: TextStyle(color: corAzulEscuro, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 80,
            child: OutlinedButton(
              onPressed: () {
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.grey, width: 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.upload_outlined, color: corAzulEscuro),
                  SizedBox(height: 4),
                  Text('Upload', style: TextStyle(color: corAzulEscuro, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          const CampoTextoCustomizado(label: 'Senha', isPassword: true),
          const SizedBox(height: 16),
          const CampoTextoCustomizado(label: 'Confirme a Senha', isPassword: true),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}