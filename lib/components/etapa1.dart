import 'package:flutter/material.dart';
import '../components/campo_texto.dart';

class Etapa1 extends StatelessWidget {
  const Etapa1({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const CampoTextoCustomizado(label: 'Nome da Instituição', keyboardType: TextInputType.name),
          const SizedBox(height: 16),
          
          const CampoTextoCustomizado(label: 'CNPJ', keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          
          const CampoTextoCustomizado(label: 'CRM Jurídico', keyboardType: TextInputType.text),
          const SizedBox(height: 16),
          
          const CampoTextoCustomizado(label: 'CNES', keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          
          const CampoTextoCustomizado(label: 'CEP', keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          
          const CampoTextoCustomizado(label: 'Endereço', keyboardType: TextInputType.streetAddress),
          const SizedBox(height: 16),
          
          Row(
            children: const [
              Expanded(
                child: CampoTextoCustomizado(label: 'Cidade', keyboardType: TextInputType.text),
              ),
              SizedBox(width: 16),
              Expanded(
                child: CampoTextoCustomizado(label: 'Estado (UF)', keyboardType: TextInputType.text),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}