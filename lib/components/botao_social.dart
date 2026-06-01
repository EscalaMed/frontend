import 'package:flutter/material.dart';

class BotaoSocial extends StatefulWidget {
  final Widget conteudo;
  final VoidCallback onTap;
  final Color? corBorda;

  const BotaoSocial({
    super.key, 
    required this.conteudo, 
    required this.onTap,
    this.corBorda,
  });

  @override
  State<BotaoSocial> createState() => _BotaoSocialState();
}

class _BotaoSocialState extends State<BotaoSocial> {
  bool _estaComMousePorCima = false;
  bool _estaSendoPressionado = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _estaComMousePorCima = true),
      onExit: (_) => setState(() => _estaComMousePorCima = false),
      cursor: SystemMouseCursors.click, 
      
      child: GestureDetector(
        onTapDown: (_) => setState(() => _estaSendoPressionado = true),
        onTapUp: (_) => setState(() => _estaSendoPressionado = false),
        onTapCancel: () => setState(() => _estaSendoPressionado = false),
        onTap: widget.onTap,
        
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150), 
          opacity: _estaComMousePorCima && !_estaSendoPressionado ? 0.7 : 1.0, 
          
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 50,
            height: 35,
            decoration: BoxDecoration(
              color: _estaSendoPressionado ? Colors.grey[300] : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: widget.corBorda ?? Colors.transparent,
                width: 1,
              ),
              
              boxShadow: [
                if (_estaComMousePorCima && !_estaSendoPressionado)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
              ],
            ),
            child: Center(
              child: widget.conteudo,
            ),
          ),
        ),
      ),
    );
  }
}