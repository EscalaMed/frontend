import 'package:flutter/material.dart';

class CampoTextoCustomizado extends StatefulWidget {
  final String label;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final int maxLines;
  final double fontSizeTexto;
  final double fontSizeLabel;

  const CampoTextoCustomizado({
    super.key,
    required this.label,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.maxLines = 1,
    this.fontSizeTexto = 16.0,
    this.fontSizeLabel = 20.0,
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
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      style: TextStyle(
        fontSize: widget.fontSizeTexto, 
        color: corAzulEscuro,
      ),
      
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: TextStyle(
          color: corAzulEscuro, 
          fontWeight: FontWeight.bold,
          fontSize: widget.fontSizeLabel,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always, 
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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