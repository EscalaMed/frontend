import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaginaCriarPlantao extends StatefulWidget {
  const PaginaCriarPlantao({super.key});

  @override
  State<PaginaCriarPlantao> createState() => _PaginaCriarPlantaoState();
}

class _PaginaCriarPlantaoState extends State<PaginaCriarPlantao> {
  final TextEditingController _funcaoController = TextEditingController(text: 'Plantão Médico');
  
  List<dynamic> _setores = [];
  List<dynamic> _funcionarios = [];
  
  dynamic _setorSelecionado;
  dynamic _funcionarioSelecionado;
  
  DateTime? _dataInicio;
  TimeOfDay? _horaInicio;
  DateTime? _dataFim;
  TimeOfDay? _horaFim;

  bool _carregandoSetores = true;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _carregarSetores();
  }

  @override
  void dispose() {
    _funcaoController.dispose();
    super.dispose();
  }

  Future<void> _carregarSetores() async {
    const storage = FlutterSecureStorage();
    String? tokenJWT = await storage.read(key: 'token_jwt');

    if (tokenJWT == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/admin/setores'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${tokenJWT.trim()}',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _setores = json.decode(response.body);
          _carregandoSetores = false;
        });
      } else {
        setState(() => _carregandoSetores = false);
      }
    } catch (e) {
      setState(() => _carregandoSetores = false);
    }
  }

  Future<void> _carregarFuncionarios(int setorId) async {
    const storage = FlutterSecureStorage();
    String? tokenJWT = await storage.read(key: 'token_jwt');

    if (tokenJWT == null) return;

    setState(() {
      _funcionarios = [];
      _funcionarioSelecionado = null;
    });

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/admin/usuarios?setor_id=$setorId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${tokenJWT.trim()}',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _funcionarios = json.decode(response.body);
        });
      }
    } catch (e) {
      // ignorar em caso de erro temporário
    }
  }

  Future<void> _selecionarData(BuildContext context, bool isInicio) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isInicio) {
          _dataInicio = picked;
        } else {
          _dataFim = picked;
        }
      });
    }
  }

  Future<void> _selecionarHora(BuildContext context, bool isInicio) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isInicio) {
          _horaInicio = picked;
        } else {
          _horaFim = picked;
        }
      });
    }
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  Future<void> _salvarPlantao() async {
    if (_setorSelecionado == null || _dataInicio == null || _horaInicio == null || _dataFim == null || _horaFim == null || _funcaoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _salvando = true);

    const storage = FlutterSecureStorage();
    String? tokenJWT = await storage.read(key: 'token_jwt');

    final dataInicioFinal = DateTime(_dataInicio!.year, _dataInicio!.month, _dataInicio!.day, _horaInicio!.hour, _horaInicio!.minute);
    final dataFimFinal = DateTime(_dataFim!.year, _dataFim!.month, _dataFim!.day, _horaFim!.hour, _horaFim!.minute);

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/plantoes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${tokenJWT!.trim()}',
        },
        body: json.encode({
          'setor_id': _setorSelecionado['id'],
          'medico_titular_id': _funcionarioSelecionado?['id'],
          'data_inicio': dataInicioFinal.toIso8601String(),
          'data_fim': dataFimFinal.toIso8601String(),
          'funcao': _funcaoController.text.trim(),
        }),
      );

      if (response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plantão criado com sucesso!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        final erro = json.decode(response.body);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(erro['msg'] ?? 'Erro ao criar plantão'), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao conectar com o servidor'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const corAzulEscuro = Color.fromARGB(255, 9, 17, 131);
    const corFundoApp = Color(0xFFF4F6FA);

    return Scaffold(
      backgroundColor: corFundoApp,
      appBar: AppBar(
        backgroundColor: corFundoApp,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: corAzulEscuro),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Criar Plantão',
          style: TextStyle(color: corAzulEscuro, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _carregandoSetores 
          ? const Center(child: CircularProgressIndicator(color: corAzulEscuro))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Setor (Obrigatório)', style: TextStyle(fontWeight: FontWeight.bold, color: corAzulEscuro)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<dynamic>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFB0B5D9))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFB0B5D9))),
                    ),
                    value: _setorSelecionado,
                    hint: const Text('Selecione o setor'),
                    items: _setores.map((s) {
                      return DropdownMenuItem<dynamic>(value: s, child: Text(s['nome']));
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _setorSelecionado = val;
                        _carregarFuncionarios(val['id']);
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  const Text('Funcionário Titular (Opcional)', style: TextStyle(fontWeight: FontWeight.bold, color: corAzulEscuro)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<dynamic>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFB0B5D9))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFB0B5D9))),
                    ),
                    value: _funcionarioSelecionado,
                    hint: const Text('Selecione um funcionário'),
                    items: _funcionarios.map((f) {
                      return DropdownMenuItem<dynamic>(value: f, child: Text(f['nome']));
                    }).toList(),
                    onChanged: (val) => setState(() => _funcionarioSelecionado = val),
                  ),
                  const SizedBox(height: 16),

                  _construirLinhaDataHora(context, 'Início', true),
                  const SizedBox(height: 16),
                  _construirLinhaDataHora(context, 'Fim', false),
                  const SizedBox(height: 16),

                  const Text('Função do Plantão', style: TextStyle(fontWeight: FontWeight.bold, color: corAzulEscuro)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _funcaoController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFB0B5D9))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFB0B5D9))),
                    ),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _salvando ? null : _salvarPlantao,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: corAzulEscuro,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _salvando
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Salvar Plantão', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _construirLinhaDataHora(BuildContext context, String label, bool isInicio) {
    const corAzulEscuro = Color.fromARGB(255, 9, 17, 131);
    final data = isInicio ? _dataInicio : _dataFim;
    final hora = isInicio ? _horaInicio : _horaFim;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$label (Data)', style: const TextStyle(fontWeight: FontWeight.bold, color: corAzulEscuro)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selecionarData(context, isInicio),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFB0B5D9)), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(data != null ? _formatarData(data) : 'DD/MM/AAAA', style: TextStyle(color: data != null ? Colors.black87 : Colors.grey)),
                      const Icon(Icons.calendar_today, color: corAzulEscuro, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$label (Hora)', style: const TextStyle(fontWeight: FontWeight.bold, color: corAzulEscuro)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selecionarHora(context, isInicio),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFB0B5D9)), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(hora != null ? hora.format(context) : '--:--', style: TextStyle(color: hora != null ? Colors.black87 : Colors.grey)),
                      const Icon(Icons.access_time, color: corAzulEscuro, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}