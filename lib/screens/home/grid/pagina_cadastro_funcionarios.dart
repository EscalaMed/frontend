import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../components/campo_texto.dart';
import '../../../components/modal_selecao.dart';

class PaginaCadastroFuncionarios extends StatefulWidget {
  final bool ehTelaIndependente;
  const PaginaCadastroFuncionarios({super.key, this.ehTelaIndependente = false});

  @override
  State<PaginaCadastroFuncionarios> createState() => _PaginaCadastroFuncionariosState();
}

class _PaginaCadastroFuncionariosState extends State<PaginaCadastroFuncionarios> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _registroController = TextEditingController();

  final TextEditingController _cargoController = TextEditingController();
  final TextEditingController _setorController = TextEditingController();
  final TextEditingController _contratoController = TextEditingController();
  final TextEditingController _cargaController = TextEditingController();

  List<String> _listaCargos = ['Enfermeiro(a)', 'Médico(a)', 'Recepcionista', 'Técnico(a) em Enfermagem'];
  List<String> _listaSetores = ['Pronto Socorro', 'Pediatria', 'UTI Geral', 'Ambulatório'];
  List<String> _listaContratos = ['CLT', 'PJ', 'Estágio', 'Temporário'];
  List<String> _listaCargasHorarias = ['20h semanais', '30h semanais', '40h semanais', 'Escala 12x36'];

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _registroController.dispose();
    _cargoController.dispose();
    _setorController.dispose();
    _contratoController.dispose();
    _cargaController.dispose();
    super.dispose();
  }

  Future<int?> _garantirSetorNoServidor(String nomeSetor, String token) async {
    final urlSetor = Uri.parse('http://10.0.2.2:5000/admin/setor');
    try {
      final resposta = await http.post(
        urlSetor,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'nome': nomeSetor}),
      );

      if (resposta.statusCode == 201 || resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);
        return dados['setor_id'];
      }
    } catch (e) {
      print("Erro ao garantir setor: $e");
    }
    return null;
  }

  Future<void> _concluirCadastro() async {
    if (_nomeController.text.trim().isEmpty || 
        _emailController.text.trim().isEmpty ||
        _cpfController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha o nome, e-mail e CPF.'), backgroundColor: Colors.redAccent),
      );
      return;
    }
    
    if (_cargoController.text.isEmpty || 
        _setorController.text.isEmpty || 
        _contratoController.text.isEmpty || 
        _cargaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todas as opções antes de concluir.'), backgroundColor: Colors.orangeAccent),
      );
      return;
    }

    final cpfLimpo = _cpfController.text.replaceAll(RegExp(r'[^0-9]'), '').trim();
    
    if (widget.ehTelaIndependente) {
      const storage = FlutterSecureStorage();
      String? tokenJWT = await storage.read(key: 'token_jwt');

      if (tokenJWT == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sessão expirada. Faça login novamente.'), backgroundColor: Colors.orangeAccent),
        );
        return;
      }

      final tokenLimpo = tokenJWT.trim();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      int? idDoSetor = await _garantirSetorNoServidor(_setorController.text.trim(), tokenLimpo);

      if (idDoSetor == null) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro: Setor não encontrado ou inválido no banco.'), backgroundColor: Colors.redAccent),
        );
        return;
      }

      final dadosFuncionario = {
        'nome': _nomeController.text.trim(),
        'email': _emailController.text.trim(),
        'cpf': cpfLimpo,
        'telefone': _telefoneController.text.trim(),
        'registro_profissional': _registroController.text.trim(),
        'tipo': 'funcionario',
        'forma_contratacao': _contratoController.text.trim(),
        'carga_horaria': _cargaController.text.trim(), 
        'regra_escala': _cargaController.text.trim(),
        'funcao': _cargoController.text.trim(),
        'setor_id': idDoSetor,
        'senha': 'Mudar@123',
      };

      final url = Uri.parse('http://10.0.2.2:5000/admin/usuarios');

      try {
        final resposta = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $tokenLimpo',
          },
          body: jsonEncode(dadosFuncionario),
        );

        if (!mounted) return;
        Navigator.pop(context);

        if (resposta.statusCode == 201 || resposta.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Funcionário cadastrado com sucesso!', textAlign: TextAlign.center),
              backgroundColor: Colors.green
            ),
          );
          Navigator.pop(context, dadosFuncionario);
        } else {
          final erro = jsonDecode(resposta.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(erro['msg'] ?? 'Erro ao cadastrar funcionário'), backgroundColor: Colors.redAccent),
          );
        }
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha de conexão com o servidor'), backgroundColor: Colors.red),
        );
      }
    } else {
      Navigator.pop(context, {
        'nome': _nomeController.text.trim(),
        'email': _emailController.text.trim(),
        'cpf': cpfLimpo,
        'telefone': _telefoneController.text.trim(),
        'registro_profissional': _registroController.text.trim(),
        'forma_contratacao': _contratoController.text.trim(),
        'carga_horaria': _cargaController.text.trim(),
        'regra_escala': _cargaController.text.trim(),
        'funcao': _cargoController.text.trim(),
        'setor_nome': _setorController.text.trim(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const corAzulEscuro = Color.fromARGB(255, 9, 17, 131);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: corAzulEscuro),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Adicionar Funcionários',
          style: TextStyle(color: corAzulEscuro, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32.0, 38.0, 32.0, 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      CampoTextoCustomizado(label: 'Nome Completo', keyboardType: TextInputType.name, controller: _nomeController),
                      const SizedBox(height: 16),
                      
                      CampoTextoCustomizado(
                        label: 'E-mail institucional/pessoal', 
                        keyboardType: TextInputType.emailAddress, 
                        controller: _emailController,
                        hintText: 'exemplo@hospital.com',
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(child: CampoTextoCustomizado(label: 'CPF', keyboardType: TextInputType.number, controller: _cpfController)),
                          const SizedBox(width: 16),
                          Expanded(child: CampoTextoCustomizado(label: 'Telefone', keyboardType: TextInputType.phone, controller: _telefoneController)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      CampoTextoCustomizado(
                        label: 'Número de Registro Profissional', 
                        hintText: 'CRM, COREN, CRP...',
                        controller: _registroController,
                      ),
                      const SizedBox(height: 16),

                      GestureDetector(
                        onTap: () {
                          mostrarModalSelecao(
                            context: context,
                            tipo: 'Cargos',
                            opcoes: _listaCargos,
                            aoSelecionar: (escolha) => setState(() => _cargoController.text = escolha),
                            aoCriarNovaOpcao: (novaOpcao) {
                              setState(() {
                                _listaCargos.add(novaOpcao);
                                _cargoController.text = novaOpcao;
                              });
                            },
                          );
                        },
                        child: AbsorbPointer(
                          child: CampoTextoCustomizado(
                            label: 'Cargo',
                            controller: _cargoController,
                            iconeDireita: Icons.keyboard_arrow_down,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      GestureDetector(
                        onTap: () {
                          mostrarModalSelecao(
                            context: context,
                            tipo: 'Setores',
                            opcoes: _listaSetores,
                            aoSelecionar: (escolha) => setState(() => _setorController.text = escolha),
                            aoCriarNovaOpcao: (novaOpcao) {
                              setState(() {
                                _listaSetores.add(novaOpcao);
                                _setorController.text = novaOpcao;
                              });
                            },
                          );
                        },
                        child: AbsorbPointer(
                          child: CampoTextoCustomizado(
                            label: 'Setor',
                            controller: _setorController,
                            iconeDireita: Icons.keyboard_arrow_down,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      GestureDetector(
                        onTap: () {
                          mostrarModalSelecao(
                            context: context,
                            tipo: 'Contratação',
                            opcoes: _listaContratos,
                            aoSelecionar: (escolha) => setState(() => _contratoController.text = escolha),
                            aoCriarNovaOpcao: (novaOpcao) {
                              setState(() {
                                _listaContratos.add(novaOpcao);
                                _contratoController.text = novaOpcao;
                              });
                            },
                          );
                        },
                        child: AbsorbPointer(
                          child: CampoTextoCustomizado(
                            label: 'Forma de Contratação',
                            controller: _contratoController,
                            iconeDireita: Icons.keyboard_arrow_down,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      GestureDetector(
                        onTap: () {
                          mostrarModalSelecao(
                            context: context,
                            tipo: 'Carga Horária',
                            opcoes: _listaCargasHorarias,
                            aoSelecionar: (escolha) => setState(() => _cargaController.text = escolha),
                            aoCriarNovaOpcao: (novaOpcao) {
                              setState(() {
                                _listaCargasHorarias.add(novaOpcao);
                                _cargaController.text = novaOpcao;
                              });
                            },
                          );
                        },
                        child: AbsorbPointer(
                          child: CampoTextoCustomizado(
                            label: 'Carga horária',
                            controller: _cargaController,
                            iconeDireita: Icons.keyboard_arrow_down,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _concluirCadastro,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: corAzulEscuro,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Concluído',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_ios, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}