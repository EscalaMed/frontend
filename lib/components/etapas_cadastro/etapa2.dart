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
          const Center(
            child: Text(
              'Cadastro Institucional',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: corAzulEscuro,
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          const CampoTextoCustomizado(label: 'Telefone', keyboardType: TextInputType.phone),
          const SizedBox(height: 16),
          
          const CampoTextoCustomizado(label: 'E-mail', keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          
          const CampoTextoCustomizado(label: 'Descrição', maxLines: 3),
          const SizedBox(height: 16),

          GestureDetector(
            onTap: () {
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Logotipo',
                labelStyle: const TextStyle(
                  color: corAzulEscuro,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 24.0), 
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.file_upload_outlined, color: corAzulEscuro),
                  SizedBox(height: 4),
                  Text(
                    'Upload', 
                    style: TextStyle(color: corAzulEscuro, fontWeight: FontWeight.bold),
                  ),
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