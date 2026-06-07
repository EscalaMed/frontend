import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../components/barra_progresso.dart';
import '../components/botoes_navegacao.dart';
import '../components/etapas_cadastro/etapa1.dart';
import '../components/etapas_cadastro/etapa2.dart';
import '../components/etapas_cadastro/etapa3.dart';

class PaginaCadastro extends StatefulWidget {
  const PaginaCadastro({super.key});

  @override
  State<PaginaCadastro> createState() => _PaginaCadastroState();
}

class _PaginaCadastroState extends State<PaginaCadastro> {
  final PageController _controladorPagina = PageController();
  int _etapaAtual = 0;
  final int _totalEtapas = 3; 
  bool _estaCarregando = false;

  final _nomeController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _crmController = TextEditingController();
  final _cnesController = TextEditingController();
  final _cepController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();

  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmaSenhaController = TextEditingController();

  final List<Map<String, String>> _coordenadores = [];
  final List<Map<String, String>> _setores = [];

  void adicionarCoordenador(Map<String, String> novoCoordenador) {
    setState(() {
      _coordenadores.add(novoCoordenador);
    });
  }

  void adicionarSetor(Map<String, String> novoSetor) {
    setState(() {
      _setores.add(novoSetor);
    });
  }

  @override
  void dispose() {
    _controladorPagina.dispose();
    _nomeController.dispose();
    _cnpjController.dispose();
    _crmController.dispose();
    _cnesController.dispose();
    _cepController.dispose();
    _enderecoController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _descricaoController.dispose();
    _senhaController.dispose();
    _confirmaSenhaController.dispose();
    super.dispose();
  }

  double _calcularProgresso() {
    if (_etapaAtual == 0) return 0.25;
    if (_etapaAtual == 1) return 0.50;
    if (_etapaAtual == 2) {
      double progresso = 0.50;
      if (_coordenadores.isNotEmpty) progresso += 0.25;
      if (_setores.isNotEmpty) progresso += 0.25;
      return progresso;
    }
    return 1.0;
  }

  bool _validarEtapaAtual() {
    if (_etapaAtual == 0) {
      return _nomeController.text.trim().isNotEmpty &&
          _cnpjController.text.trim().isNotEmpty &&
          _crmController.text.trim().isNotEmpty &&
          _cnesController.text.trim().isNotEmpty &&
          _cepController.text.trim().isNotEmpty &&
          _enderecoController.text.trim().isNotEmpty &&
          _cidadeController.text.trim().isNotEmpty &&
          _estadoController.text.trim().isNotEmpty;
    } else if (_etapaAtual == 1) {
      return _telefoneController.text.trim().isNotEmpty &&
          _emailController.text.trim().isNotEmpty &&
          _descricaoController.text.trim().isNotEmpty &&
          _senhaController.text.trim().isNotEmpty &&
          _confirmaSenhaController.text.trim().isNotEmpty;
    } else if (_etapaAtual == 2) {
      return _coordenadores.isNotEmpty && _setores.isNotEmpty;
    }
    return true;
  }

  Future<void> _finalizarCadastro() async {
    if (_senhaController.text != _confirmaSenhaController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('As senhas não coincidem!', textAlign: TextAlign.center),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _estaCarregando = true;
    });

    final url = Uri.parse('http://10.0.2.2:5000/cadastro_institucional');

    try {
      final resposta = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "nome": _nomeController.text.trim(),
          "cnpj": _cnpjController.text.trim(),
          "crm_juridico": _crmController.text.trim(),
          "cnes": _cnesController.text.trim(),
          "cep": _cepController.text.trim(),
          "endereco": _enderecoController.text.trim(),
          "cidade": _cidadeController.text.trim(),
          "estado_UF": _estadoController.text.trim(),
          "telefone": _telefoneController.text.trim(),
          "email": _emailController.text.trim(),
          "descricao": _descricaoController.text.trim(),
          "logotipo": "",
          "senha": _senhaController.text,
          "coordenadores": _coordenadores,
          "setores": _setores,
        }),
      );
      if (!mounted) return;

      final dadosJson = jsonDecode(resposta.body);

      if (resposta.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(dadosJson['msg'] ?? 'Cadastro realizado com sucesso!', textAlign: TextAlign.center),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(dadosJson['msg'] ?? 'Erro no cadastro', textAlign: TextAlign.center),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falha na comunicação com o servidor', textAlign: TextAlign.center),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _estaCarregando = false;
        });
      }
    }
  }

  void _avancarEtapa() {
    if (!_validarEtapaAtual()) {
      String msgErro = _etapaAtual == 2
          ? 'Cadastre pelo menos 1 Coordenador e 1 Setor para continuar.'
          : 'Preencha todos os campos para continuar.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msgErro, textAlign: TextAlign.center),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_etapaAtual < _totalEtapas - 1) {
      _controladorPagina.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finalizarCadastro();
    }
  }

  void _voltarEtapa() {
    if (_etapaAtual > 0) {
      _controladorPagina.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AbsorbPointer(
        absorbing: _estaCarregando,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BarraProgressoEtapas(progresso: _calcularProgresso()),
                const SizedBox(height: 24),
                Expanded(
                  child: PageView(
                    controller: _controladorPagina,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _etapaAtual = index;
                      });
                    },
                    children: [
                      Etapa1(
                        nomeController: _nomeController,
                        cnpjController: _cnpjController,
                        crmController: _crmController,
                        cnesController: _cnesController,
                        cepController: _cepController,
                        enderecoController: _enderecoController,
                        cidadeController: _cidadeController,
                        estadoController: _estadoController,
                      ),
                      Etapa2(
                        telefoneController: _telefoneController,
                        emailController: _emailController,
                        descricaoController: _descricaoController,
                        senhaController: _senhaController,
                        confirmaSenhaController: _confirmaSenhaController,
                      ),
                      Etapa3(
                        progressoAtual: _calcularProgresso(),
                        coordenadoresCadastrados: _coordenadores,
                        setoresCadastrados: _setores,
                        aoAdicionarCoordenador: adicionarCoordenador,
                        aoAdicionarSetor: adicionarSetor,
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _estaCarregando
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color.fromARGB(255, 9, 17, 131),
                        ),
                      )
                    : BotoesNavegacao(
                        aoVoltar: _voltarEtapa,
                        textoContinuar: _etapaAtual == _totalEtapas - 1
                            ? 'Cadastrar'
                            : 'Continuar',
                        aoContinuar: _avancarEtapa,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}