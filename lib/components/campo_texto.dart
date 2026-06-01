import 'package:flutter/material.dart';

class CampoTextoCustomizado extends StatefulWidget {
  final String label;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextEditingController? controller;

  const CampoTextoCustomizado({
    super.key,
    required this.label,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.controller,
  });

  @override
  State<CampoTextoCustomizado> createState() => _CampoTextoCustomizadoState();
}

class _CampoTextoCustomizadoState extends State<CampoTextoCustomizado> {
  late bool _ocultarTexto;
  final Color corAzulEscuro = const Color.fromARGB(255, 9, 17, 131);

  @override
  void initState() {
    super.initState();
    _ocultarTexto = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _ocultarTexto,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: TextStyle(color: corAzulEscuro),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: corAzulEscuro, width: 2),
        ),

        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _ocultarTexto ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: corAzulEscuro,
                ),
                onPressed: () {
                  setState(() {
                    _ocultarTexto = !_ocultarTexto;
                  });
                },
              )
            : null, 
      ),
    );
  }
}