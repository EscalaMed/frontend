import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../components/cabecalho.dart';
import '../components/rodape.dart';
import '../components/campo_texto.dart';
import 'home/adm.dart';

class PaginaLogin extends StatefulWidget {
  const PaginaLogin({super.key});

  @override
  State<PaginaLogin> createState() => _PaginaLoginState();
}

class _PaginaLoginState extends State<PaginaLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  bool _estaCarregando = false;

  // Instancia o armazenamento seguro de forma global na classe
  final _secureStorage = const FlutterSecureStorage();

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _fazerLogin() async {
    if (_emailController.text.isEmpty || _senhaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha email e senha'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _estaCarregando = true;
    });

    final url = Uri.parse('http://10.0.2.2:5000/login'); 

    try {
      final resposta = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'senha': _senhaController.text,
        }),
      );

      debugPrint("--> Status Code recebido do Flask: ${resposta.statusCode}");
      final dados = jsonDecode(resposta.body);
      debugPrint("--> Corpo da resposta do Flask: $dados");

      if (resposta.statusCode == 200) {
        debugPrint("--> Entrou no bloco de sucesso!");

        if (dados['access_token'] == null) {
          debugPrint(" ERRO CRÍTICO: A chave 'access_token' não existe no retorno do Flask!");
        } else {
          await _secureStorage.write(key: 'token_jwt', value: dados['access_token'].toString());
          debugPrint("--> Token JWT gravado com sucesso!");
        }
        
        final prefs = await SharedPreferences.getInstance();
        
        if (dados['refresh_token'] != null) {
          await prefs.setString('refresh_token', dados['refresh_token'].toString());
          debugPrint("--> Refresh Token gravado!");
        }
        
        if (dados['user_id'] != null) {
          final idConvertido = int.tryParse(dados['user_id'].toString()) ?? 0;
          await prefs.setInt('user_id', idConvertido);
          debugPrint("--> User ID gravado com sucesso: $idConvertido");
        }

        debugPrint("--> Pronto! Redirecionando para a HomeAdmin...");
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeAdmin()),
          );
        }
      } else {
        debugPrint("--> Backend retornou erro tratado (Else): ${dados['msg']}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(dados['msg'] ?? 'Erro no login'), backgroundColor: Colors.redAccent),
          );
        }
      }
    } catch (e) {
      debugPrint(" PAROU NO CATCH - ERRO REAL DO LOGIN: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha na comunicação com o servidor', textAlign: TextAlign.center,), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _estaCarregando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const corAzulEscuro = Color.fromARGB(255, 9, 17, 131);

    return Scaffold(
      backgroundColor: Colors.white, 
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),

              CabecalhoLogo(
                corTexto: corAzulEscuro,
                centralizado: true,
              ),
              
              const SizedBox(height: 40),
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: corAzulEscuro,
                ),
              ),
              const SizedBox(height: 24),
              
              CampoTextoCustomizado(
                label: 'E-mail',
                keyboardType: TextInputType.emailAddress,
                controller: _emailController, 
              ),

              const SizedBox(height: 16),

              CampoTextoCustomizado(
                label: 'Senha',
                isPassword: true,
                controller: _senhaController, 
              ),
              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Esqueceu a senha?',
                    style: TextStyle(
                      color: corAzulEscuro,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: corAzulEscuro,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton( 
                  onPressed: _estaCarregando ? null : _fazerLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: corAzulEscuro,
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _estaCarregando 
                    ? const SizedBox(
                        height: 24, 
                        width: 24, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : const Text(
                        'Entrar',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                ),
              ),
              
              const Spacer(),
              const RodapeSociais(corLinha: corAzulEscuro),
            ],
          ),
        ),
      ),
    );
  }
}