import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

const LatLng kSaoLuisCenter = LatLng(-2.52972, -44.30278);

bool _isCompactWidth(double width) => width < 480;

int _adaptiveColumns(double width) {
  if (width >= 1180) return 4;
  if (width >= 900) return 3;
  if (width >= 620) return 2;
  return 1;
}

void main() {
  runApp(const MinhaVisitaApp());
}

String resolveApiBaseUrl() {
  // Para desenvolvimento local com emulator Android: 10.0.2.2:8080
  // Para GCP/produção: 34.95.224.29:8080
  // Para mudar, edite a constante abaixo:
  
  const String GCP_IP = '34.95.224.29'; // Mude aqui para usar outro IP
  
  if (kIsWeb) {
    return 'http://localhost:8080';
  }
  if (defaultTargetPlatform == TargetPlatform.android) {
    // Use o IP do GCP para device físico, ou 10.0.2.2 para emulator
    return 'http://$GCP_IP:8080';
  }
  return 'http://localhost:8080';
}

class MinhaVisitaApp extends StatelessWidget {
  const MinhaVisitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minha Visita',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0B1020),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF10162A),
          foregroundColor: Colors.white,
          centerTitle: false,
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: Color(0xFF121A31),
          surfaceTintColor: Color(0xFF121A31),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            side: BorderSide(color: Color(0xFF25314F)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF11192F),
          labelStyle: const TextStyle(color: Color(0xFFB7C2E1)),
          hintStyle: const TextStyle(color: Color(0xFF7C89AD)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF27314A)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF27314A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF7C7FFF), width: 1.4),
          ),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Color(0xFF10162A),
          indicatorColor: Color(0xFF5B5DF6),
          labelTextStyle: WidgetStatePropertyAll(
            TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

class AppUser {
  AppUser({
    required this.id,
    required this.nome,
    required this.email,
    required this.perfil,
  });

  final int id;
  final String nome;
  final String email;
  final String perfil;

  bool get isAdmin => perfil.toUpperCase() == 'ADMIN';

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: (json['id'] as num).toInt(),
      nome: (json['nome'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      perfil: (json['perfil'] ?? 'OPERADOR') as String,
    );
  }
}

class VisitPlan {
  VisitPlan({
    required this.id,
    required this.usuarioId,
    required this.clienteNome,
    required this.endereco,
    required this.latitude,
    required this.longitude,
    required this.dataAgendada,
    required this.raioMetros,
    required this.status,
  });

  final int id;
  final int usuarioId;
  final String clienteNome;
  final String endereco;
  final double latitude;
  final double longitude;
  final DateTime dataAgendada;
  final int raioMetros;
  final String status;

  factory VisitPlan.fromJson(Map<String, dynamic> json) {
    return VisitPlan(
      id: (json['id'] as num).toInt(),
      usuarioId: (json['usuarioId'] as num).toInt(),
      clienteNome: (json['clienteNome'] ?? '') as String,
      endereco: (json['endereco'] ?? '') as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      dataAgendada: DateTime.parse(json['dataAgendada'] as String).toLocal(),
      raioMetros: (json['raioMetros'] as num).toInt(),
      status: (json['status'] ?? 'AGENDADA') as String,
    );
  }
}

class CheckinEvent {
  CheckinEvent({
    required this.id,
    required this.dataCheckin,
    required this.dataCheckout,
    required this.duracaoSegundos,
  });

  final int id;
  final DateTime dataCheckin;
  final DateTime? dataCheckout;
  final int? duracaoSegundos;

  factory CheckinEvent.fromJson(Map<String, dynamic> json) {
    return CheckinEvent(
      id: (json['id'] as num).toInt(),
      dataCheckin: DateTime.parse(json['dataCheckin'] as String).toLocal(),
      dataCheckout: json['dataCheckout'] != null
          ? DateTime.parse(json['dataCheckout'] as String).toLocal()
          : null,
      duracaoSegundos: (json['duracaoSegundos'] as num?)?.toInt(),
    );
  }
}

class JourneySummary {
  JourneySummary({
    required this.usuarioId,
    required this.nome,
    required this.email,
    required this.latitudeAtual,
    required this.longitudeAtual,
    required this.kmPercorridos,
    required this.atualizacaoEm,
    required this.locaisVisitados,
    required this.totalLocaisVisitados,
  });

  final int usuarioId;
  final String nome;
  final String email;
  final double? latitudeAtual;
  final double? longitudeAtual;
  final double kmPercorridos;
  final DateTime? atualizacaoEm;
  final List<String> locaisVisitados;
  final int totalLocaisVisitados;

  bool get iniciouRota => latitudeAtual != null && longitudeAtual != null;

  factory JourneySummary.fromJson(Map<String, dynamic> json) {
    return JourneySummary(
      usuarioId: (json['usuarioId'] as num).toInt(),
      nome: (json['nome'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      latitudeAtual: (json['latitudeAtual'] as num?)?.toDouble(),
      longitudeAtual: (json['longitudeAtual'] as num?)?.toDouble(),
      kmPercorridos: ((json['kmPercorridos'] as num?) ?? 0).toDouble(),
      atualizacaoEm: json['atualizacaoEm'] != null
          ? DateTime.parse(json['atualizacaoEm'] as String).toLocal()
          : null,
      locaisVisitados: ((json['locaisVisitados'] as List<dynamic>?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      totalLocaisVisitados:
          ((json['totalLocaisVisitados'] as num?) ?? 0).toInt(),
    );
  }
}

class ApiClient {
  ApiClient(this.baseUrl);

  final String baseUrl;

  Future<AppUser> login(String email, String senha) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': senha}),
    );
    if (response.statusCode >= 400) {
      throw Exception('Login falhou: ${response.body}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return AppUser.fromJson(body['usuario'] as Map<String, dynamic>);
  }

  Future<List<AppUser>> listarUsuarios() async {
    final response = await http.get(Uri.parse('$baseUrl/api/usuarios'));
    if (response.statusCode >= 400) {
      throw Exception('Falha ao listar usuarios: ${response.body}');
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => AppUser.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<VisitPlan>> listarAgenda({
    required int usuarioId,
    required DateTime data,
  }) async {
    final dataParam = _formatDate(data);
    final response = await http.get(
      Uri.parse('$baseUrl/api/visitas?usuarioId=$usuarioId&data=$dataParam'),
    );
    if (response.statusCode >= 400) {
      throw Exception('Falha ao listar agenda: ${response.body}');
    }
    final dataList = jsonDecode(response.body) as List<dynamic>;
    return dataList
        .map((item) => VisitPlan.fromJson(item as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.dataAgendada.compareTo(b.dataAgendada));
  }

  Future<VisitPlan> criarVisita({
    required int usuarioId,
    required String clienteNome,
    required String endereco,
    required double latitude,
    required double longitude,
    required DateTime dataAgendada,
    required int raioMetros,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/visitas'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'usuarioId': usuarioId,
        'clienteNome': clienteNome,
        'endereco': endereco,
        'latitude': latitude,
        'longitude': longitude,
        'dataAgendada': dataAgendada.toUtc().toIso8601String(),
        'raioMetros': raioMetros,
      }),
    );
    if (response.statusCode >= 400) {
      throw Exception('Falha ao criar visita: ${response.body}');
    }
    return VisitPlan.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<CheckinEvent> checkin({
    required int visitaId,
    required double latitude,
    required double longitude,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/checkins'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'visitaId': visitaId,
        'latitude': latitude,
        'longitude': longitude,
        'dataHora': DateTime.now().toUtc().toIso8601String(),
      }),
    );
    if (response.statusCode >= 400) {
      throw Exception('Check-in falhou: ${response.body}');
    }
    return CheckinEvent.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<CheckinEvent> checkout({
    required int checkinId,
    required double latitude,
    required double longitude,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/checkins/$checkinId/checkout'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'latitude': latitude,
        'longitude': longitude,
        'dataHora': DateTime.now().toUtc().toIso8601String(),
      }),
    );
    if (response.statusCode >= 400) {
      throw Exception('Check-out falhou: ${response.body}');
    }
    return CheckinEvent.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> pingJornada({
    required int usuarioId,
    required double latitude,
    required double longitude,
  }) async {
    await http.post(
      Uri.parse('$baseUrl/api/jornadas/ping'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'usuarioId': usuarioId,
        'latitude': latitude,
        'longitude': longitude,
        'dataHora': DateTime.now().toUtc().toIso8601String(),
      }),
    );
  }

  Future<List<JourneySummary>> resumoJornada(DateTime data) async {
    final dataParam = _formatDate(data);
    final response = await http
        .get(Uri.parse('$baseUrl/api/jornadas/resumo?data=$dataParam'));
    if (response.statusCode >= 400) {
      throw Exception('Falha ao carregar painel de jornada: ${response.body}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((item) => JourneySummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _loading = false;
  String? _erro;

  final _api = ApiClient(resolveApiBaseUrl());

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _erro = null;
    });
    try {
      final user =
          await _api.login(_emailController.text.trim(), _senhaController.text);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (_) => ShellScreen(api: _api, currentUser: user)),
      );
    } catch (e) {
      setState(() => _erro = e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B1020), Color(0xFF11172C), Color(0xFF171C34)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth < 460
                ? constraints.maxWidth * 0.94
                : 420.0;
            final isCompact = _isCompactWidth(constraints.maxWidth);

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Stack(
                  children: [
                Positioned(
                  top: 22,
                  right: 16,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF5B5DF6).withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(isCompact ? 16 : 22),
                        child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: EdgeInsets.all(isCompact ? 12 : 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF5B5DF6), Color(0xFF22C1C3)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.16),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.badge,
                                        color: Colors.white, size: 28),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text('Minha Visita',
                                        style: TextStyle(
                                            fontSize: isCompact ? 24 : 30,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Operação de campo em tempo real para equipes externas.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.84),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isCompact ? 14 : 18),
                        TextField(
                            controller: _emailController,
                            decoration:
                                const InputDecoration(labelText: 'Email')),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _senhaController,
                          decoration: const InputDecoration(labelText: 'Senha'),
                          obscureText: true,
                        ),
                        if (_erro != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B1D2A),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF7F1D1D)),
                            ),
                            child: Text(_erro!,
                                style: const TextStyle(color: Colors.white)),
                          ),
                        ],
                        SizedBox(height: isCompact ? 12 : 16),
                        FilledButton(
                          onPressed: _loading ? null : _login,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2))
                              : const Text('Entrar'),
                        ),
                      ],
                    ),
                  ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key, required this.api, required this.currentUser});

  final ApiClient api;
  final AppUser currentUser;

  @override
  Widget build(BuildContext context) {
    return currentUser.isAdmin
        ? AdminHome(api: api, currentUser: currentUser)
        : OperatorHome(api: api, currentUser: currentUser);
  }
}

class AdminHome extends StatefulWidget {
  const AdminHome({super.key, required this.api, required this.currentUser});

  final ApiClient api;
  final AppUser currentUser;

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _tabIndex = 0;
  DateTime _selectedDate = DateTime.now();
  List<JourneySummary> _resumo = [];
  Map<int, List<VisitPlan>> _agendaPorOperador = {};
  List<AppUser> _usuarios = [];
  AppUser? _selectedOperador;
  bool _loading = false;
  String? _status;

  final _clienteController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _raioController = TextEditingController(text: '120');
  final _horaController = TextEditingController(text: '09:00');
  LatLng _selectedMapPoint = kSaoLuisCenter;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() => _loading = true);
    try {
      _usuarios = await widget.api.listarUsuarios();
      final operadores = _usuarios.where((u) => !u.isAdmin).toList();
      _selectedOperador = operadores.isNotEmpty ? operadores.first : null;
      await _refreshDashboard();
    } catch (e) {
      setState(() => _status = e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _refreshDashboard() async {
    final resumo = await widget.api.resumoJornada(_selectedDate);
    final agendas = await Future.wait(
      resumo
          .map(
            (item) async => MapEntry(
              item.usuarioId,
              await widget.api.listarAgenda(
                usuarioId: item.usuarioId,
                data: _selectedDate,
              ),
            ),
          )
          .toList(),
    );

    if (!mounted) return;
    setState(() {
      _resumo = resumo;
      _agendaPorOperador = Map<int, List<VisitPlan>>.fromEntries(agendas);
    });
  }

  Future<void> _refreshResumo() async {
    await _refreshDashboard();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );
    if (picked == null) return;
    setState(() => _selectedDate = picked);
    await _refreshResumo();
  }

  List<VisitPlan> _agendaDoOperador(int usuarioId) {
    return _agendaPorOperador[usuarioId] ?? const [];
  }

  VisitPlan? _visitaAtiva(JourneySummary resumo) {
    if (!resumo.iniciouRota) return null;
    final visitas = _agendaDoOperador(resumo.usuarioId);
    for (final visita in visitas) {
      final distancia = Geolocator.distanceBetween(
        resumo.latitudeAtual!,
        resumo.longitudeAtual!,
        visita.latitude,
        visita.longitude,
      );
      if (distancia <= visita.raioMetros) {
        return visita;
      }
    }
    return null;
  }

  String _resumoOperador(JourneySummary resumo) {
    if (!resumo.iniciouRota) {
      return 'Ainda nao iniciou a rota';
    }
    final visitaAtiva = _visitaAtiva(resumo);
    if (visitaAtiva != null) {
      return 'Em visita em ${visitaAtiva.clienteNome}';
    }
    return 'Rota iniciada, aguardando ponto de visita';
  }

  Color _statusColor(JourneySummary resumo) {
    if (!resumo.iniciouRota) return const Color(0xFF9CA3AF);
    return _visitaAtiva(resumo) != null ? const Color(0xFF16A34A) : const Color(0xFF0F766E);
  }

  IconData _statusIcon(JourneySummary resumo) {
    if (!resumo.iniciouRota) return Icons.pause_circle_outline;
    return _visitaAtiva(resumo) != null ? Icons.location_on : Icons.route;
  }

  Future<void> _pickHour() async {
    final picked = await showTimePicker(
        context: context, initialTime: const TimeOfDay(hour: 9, minute: 0));
    if (picked == null) return;
    setState(() => _horaController.text =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
  }

  Future<void> _criarVisita() async {
    if (_selectedOperador == null) {
      setState(() => _status = 'Selecione um operador');
      return;
    }
    if (_clienteController.text.trim().isEmpty ||
        _enderecoController.text.trim().isEmpty) {
      setState(() => _status = 'Cliente e endereco sao obrigatorios');
      return;
    }
    final raio = int.tryParse(_raioController.text);
    if (raio == null || raio <= 0) {
      setState(() => _status = 'Raio invalido');
      return;
    }
    final parts = _horaController.text.split(':');
    if (parts.length != 2) {
      setState(() => _status = 'Horario invalido');
      return;
    }
    final hour = int.tryParse(parts[0]) ?? 9;
    final minute = int.tryParse(parts[1]) ?? 0;

    setState(() {
      _loading = true;
      _status = null;
    });
    try {
      final agendada = DateTime(_selectedDate.year, _selectedDate.month,
          _selectedDate.day, hour, minute);
      await widget.api.criarVisita(
        usuarioId: _selectedOperador!.id,
        clienteNome: _clienteController.text.trim(),
        endereco: _enderecoController.text.trim(),
        latitude: _selectedMapPoint.latitude,
        longitude: _selectedMapPoint.longitude,
        dataAgendada: agendada,
        raioMetros: raio,
      );
      _clienteController.clear();
      _enderecoController.clear();
      setState(() => _status = 'Visita criada com ponto selecionado no mapa');
    } catch (e) {
      setState(() => _status = e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Widget _buildTopBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = _isCompactWidth(constraints.maxWidth);
        final profileCard = Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF0F766E), Color(0xFF0891B2)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Painel Admin', style: TextStyle(color: Colors.white70)),
              Text(widget.currentUser.nome,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        );
        final dateButton = OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today),
            label: Text(_fmtDate(_selectedDate)));

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              profileCard,
              const SizedBox(height: 8),
              Align(alignment: Alignment.centerLeft, child: dateButton),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: profileCard),
            const SizedBox(width: 10),
            dateButton,
          ],
        );
      },
    );
  }

  Widget _buildKpiGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _adaptiveColumns(constraints.maxWidth);
        final width = constraints.maxWidth;
        final spacing = 10.0;
        final cardWidth = (width - (spacing * (columns - 1))) / columns;

        final cards = [
          _MetricCard(
            label: 'Rotas iniciadas',
            value: '${_resumo.where((item) => item.iniciouRota).length}',
            icon: Icons.route,
            accent: const Color(0xFF5B5DF6),
          ),
          _MetricCard(
            label: 'No ponto',
            value: '${_resumo.where((item) => _visitaAtiva(item) != null).length}',
            icon: Icons.location_on,
            accent: const Color(0xFF22C55E),
          ),
          _MetricCard(
            label: 'Km hoje',
            value: _resumo
                .fold<double>(0, (sum, item) => sum + item.kmPercorridos)
                .toStringAsFixed(1),
            icon: Icons.timeline,
            accent: const Color(0xFF22C1C3),
          ),
          _MetricCard(
            label: 'Locais visitados',
            value: _resumo
                .fold<int>(0, (sum, item) => sum + item.totalLocaisVisitados)
                .toString(),
            icon: Icons.place,
            accent: const Color(0xFFF59E0B),
          ),
        ];

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards
              .map((card) => SizedBox(width: cardWidth, child: card))
              .toList(),
        );
      },
    );
  }

  Widget _buildOperatorCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _adaptiveColumns(constraints.maxWidth);
        final width = constraints.maxWidth;
        final spacing = 12.0;
        final cardWidth = (width - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: _resumo.map((item) {
            final visitaAtiva = _visitaAtiva(item);
            return SizedBox(
              width: cardWidth,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(item.nome,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                          Chip(
                            avatar: Icon(_statusIcon(item),
                                size: 16, color: Colors.white),
                            label: Text(
                              item.iniciouRota ? 'Em rota' : 'Offline',
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: _statusColor(item),
                            side: BorderSide.none,
                          ),
                        ],
                      ),
                      Text(item.email,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.white60)),
                      const SizedBox(height: 8),
                      Text('${item.kmPercorridos.toStringAsFixed(2)} km hoje'),
                      Text('${item.totalLocaisVisitados} locais visitados'),
                      Text(_resumoOperador(item)),
                      if (item.atualizacaoEm != null)
                        Text('Atualizado ${_fmtDateTime(item.atualizacaoEm!)}'),
                      if (visitaAtiva != null)
                        Text(
                          'No ponto: ${visitaAtiva.clienteNome}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget _buildOverviewModule() {
    final center = _resumo.firstWhere(
      (r) => r.latitudeAtual != null && r.longitudeAtual != null,
      orElse: () => JourneySummary(
        usuarioId: 0,
        nome: 'Mapa',
        email: '',
        latitudeAtual: kSaoLuisCenter.latitude,
        longitudeAtual: kSaoLuisCenter.longitude,
        kmPercorridos: 0,
        atualizacaoEm: null,
        locaisVisitados: const [],
        totalLocaisVisitados: 0,
      ),
    );

    return Column(
      children: [
        _buildKpiGrid(),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Rotas iniciadas hoje: ${_resumo.where((item) => item.iniciouRota).length}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ),
        const SizedBox(height: 10),
        _buildOperatorCards(),
        const SizedBox(height: 12),
        SizedBox(
          height: 320,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: FlutterMap(
                  options: MapOptions(
                      initialCenter: LatLng(center.latitudeAtual!, center.longitudeAtual!),
                      initialZoom: 11),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'br.com.minhavisita.mobile',
                ),
                MarkerLayer(
                  markers: _resumo
                      .where((item) =>
                          item.latitudeAtual != null &&
                          item.longitudeAtual != null)
                      .map((item) => Marker(
                            point: LatLng(
                                item.latitudeAtual!, item.longitudeAtual!),
                            width: 140,
                            height: 70,
                            child: Column(
                              children: [
                                const Icon(Icons.location_on,
                                    color: Colors.red, size: 34),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Text(item.nome,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamModule() {
    return Column(
      children: _resumo.map((item) {
        final visitas = _agendaDoOperador(item.usuarioId);
        final visitaAtiva = _visitaAtiva(item);

        return Card(
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: _statusColor(item).withValues(alpha: 0.12),
              foregroundColor: _statusColor(item),
              child: Icon(_statusIcon(item)),
            ),
            title: Text(item.nome),
            subtitle: Text(
                '${item.kmPercorridos.toStringAsFixed(2)} km • ${item.totalLocaisVisitados} locais • ${_resumoOperador(item)}'),
            children: [
              if (visitas.isEmpty)
                const ListTile(title: Text('Sem visitas agendadas hoje.'))
              else
                ...visitas.map((visita) {
                  final estaNoPonto = visitaAtiva?.id == visita.id;
                  final distancia = item.iniciouRota
                      ? Geolocator.distanceBetween(
                          item.latitudeAtual!,
                          item.longitudeAtual!,
                          visita.latitude,
                          visita.longitude,
                        )
                      : null;

                  return ListTile(
                    leading: Icon(
                      estaNoPonto
                          ? Icons.verified
                          : visita.status.toUpperCase() == 'CONCLUIDA'
                              ? Icons.check_circle_outline
                              : Icons.place_outlined,
                      color: estaNoPonto
                          ? const Color(0xFF16A34A)
                          : visita.status.toUpperCase() == 'CONCLUIDA'
                              ? const Color(0xFF0F766E)
                              : Colors.black45,
                    ),
                    title: Text(visita.clienteNome),
                    subtitle: Text(
                      '${visita.endereco}\n${visita.status} • Raio ${visita.raioMetros}m${distancia == null ? '' : ' • ${distancia.toStringAsFixed(0)}m da posicao atual'}',
                    ),
                    isThreeLine: true,
                    trailing: estaNoPonto
                        ? const Chip(
                            label: Text('NO PONTO'),
                            visualDensity: VisualDensity.compact,
                          )
                        : null,
                  );
                }),
              if (item.locaisVisitados.isNotEmpty) ...[
                const Divider(height: 1),
                const ListTile(
                  title: Text('Locais visitados concluídos'),
                ),
                ...item.locaisVisitados.map(
                  (local) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.check_circle, color: Color(0xFF16A34A)),
                    title: Text(local),
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlannerModule() {
    final operadores = _usuarios.where((u) => !u.isAdmin).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                DropdownButtonFormField<AppUser>(
                  initialValue: _selectedOperador,
                  decoration: const InputDecoration(labelText: 'Operador'),
                  items: operadores
                      .map((u) => DropdownMenuItem(
                          value: u, child: Text('${u.nome} (${u.email})')))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedOperador = value),
                ),
                const SizedBox(height: 10),
                TextField(
                    controller: _clienteController,
                    decoration: const InputDecoration(labelText: 'Cliente')),
                const SizedBox(height: 10),
                TextField(
                    controller: _enderecoController,
                    decoration: const InputDecoration(labelText: 'Endereco')),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = _isCompactWidth(constraints.maxWidth);
                    final raioField = TextField(
                      controller: _raioController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Raio (m)'),
                    );
                    final horaField = TextField(
                      controller: _horaController,
                      readOnly: true,
                      onTap: _pickHour,
                      decoration: const InputDecoration(labelText: 'Horario'),
                    );

                    if (compact) {
                      return Column(
                        children: [
                          raioField,
                          const SizedBox(height: 8),
                          horaField,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: raioField),
                        const SizedBox(width: 8),
                        Expanded(child: horaField),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: _loading ? null : _criarVisita,
                  icon: const Icon(Icons.add_task),
                  label: const Text('Salvar visita'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 350,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _selectedMapPoint,
                initialZoom: 13,
                onTap: (_, point) {
                  setState(() {
                    _selectedMapPoint = point;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'br.com.minhavisita.mobile',
                ),
                MarkerLayer(markers: [
                  Marker(
                    point: _selectedMapPoint,
                    width: 70,
                    height: 70,
                    child: const Icon(Icons.location_pin,
                        size: 44, color: Colors.red),
                  ),
                ]),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
            'Ponto selecionado: ${_selectedMapPoint.latitude.toStringAsFixed(5)}, ${_selectedMapPoint.longitude.toStringAsFixed(5)}'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final modules = [
      _buildOverviewModule(),
      _buildTeamModule(),
      _buildPlannerModule(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Admin'),
        actions: [
          IconButton(onPressed: _refreshResumo, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B1020), Color(0xFF12192E), Color(0xFF0B1020)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 14),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(
                            value: 0,
                            icon: Icon(Icons.analytics),
                            label: Text('Visao geral')),
                        ButtonSegment(
                            value: 1,
                            icon: Icon(Icons.group),
                            label: Text('Equipe')),
                        ButtonSegment(
                            value: 2,
                            icon: Icon(Icons.map),
                            label: Text('Planejar')),
                      ],
                      selected: {_tabIndex},
                      onSelectionChanged: (value) =>
                          setState(() => _tabIndex = value.first),
                    ),
                    const SizedBox(height: 12),
                    modules[_tabIndex],
                    if (_status != null) ...[
                      const SizedBox(height: 10),
                      Card(
                        color: const Color(0xFF3B1D2A),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(_status!,
                              style: const TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d/$m/$y';
  }

  String _fmtDateTime(DateTime dateTime) {
    final date = _fmtDate(dateTime);
    final h = dateTime.hour.toString().padLeft(2, '0');
    final m = dateTime.minute.toString().padLeft(2, '0');
    return '$date às $h:$m';
  }
}

class OperatorHome extends StatefulWidget {
  const OperatorHome({super.key, required this.api, required this.currentUser});

  final ApiClient api;
  final AppUser currentUser;

  @override
  State<OperatorHome> createState() => _OperatorHomeState();
}

class _OperatorHomeState extends State<OperatorHome> {
  int _tabIndex = 0;
  DateTime _selectedDate = DateTime.now();
  List<VisitPlan> _agenda = [];
  bool _loading = false;
  bool _operacaoAtiva = false;
  String? _status;

  Position? _currentPosition;
  JourneySummary? _ownSummary;
  StreamSubscription<Position>? _positionSub;
  StreamSubscription<ServiceStatus>? _serviceStatusSub;
  Timer? _summaryTimer;
  final MapController _mapController = MapController();
  bool _followMyPosition = true;
  bool _locationLocked = false;
  String _locationLockReason =
      'Ative a localizacao para continuar usando o app.';

  VisitPlan? _monitoringVisit;
  int? _activeCheckinId;
  DateTime? _activeCheckinStart;
  Timer? _clockTimer;
  Duration _elapsed = Duration.zero;
  double? _distanceToTarget;
  bool _autoActionInFlight = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _serviceStatusSub?.cancel();
    _summaryTimer?.cancel();
    _clockTimer?.cancel();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() => _loading = true);
    try {
      _startServiceStatusWatch();
      await _loadAgenda();
      await _refreshOwnSummary();
      if (_ownSummary?.iniciouRota == true) {
        _operacaoAtiva = true;
        await _startLocationTracking();
      }
      _summaryTimer = Timer.periodic(const Duration(seconds: 20), (_) async {
        await _refreshOwnSummary();
      });
    } catch (e) {
      setState(() => _status = e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadAgenda() async {
    final agenda = await widget.api
        .listarAgenda(usuarioId: widget.currentUser.id, data: _selectedDate);
    if (!mounted) return;
    setState(() => _agenda = agenda);
  }

  Future<void> _startLocationTracking() async {
    await _ensureLocationReady();
    if (mounted) {
      setState(() {
        _locationLocked = false;
      });
    }

    _positionSub?.cancel();
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best, distanceFilter: 10),
    ).listen((position) async {
      _currentPosition = position;
      if (_followMyPosition) {
        _centerOnCurrentPosition();
      }
      await widget.api.pingJornada(
        usuarioId: widget.currentUser.id,
        latitude: position.latitude,
        longitude: position.longitude,
      );
      await _avaliarGeofence(position);
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _iniciarOperacao() async {
    setState(() {
      _loading = true;
      _status = 'Iniciando operacao e ativando rastreamento GPS...';
    });
    try {
      await _startLocationTracking();
      await _refreshOwnSummary();
      if (!mounted) return;
      setState(() {
        _operacaoAtiva = true;
        _status =
            'Operacao iniciada. GPS obrigatorio ativo durante toda a jornada.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _encerrarOperacao() async {
    if (_activeCheckinId != null) {
      setState(() {
        _status =
            'Existe um check-in ativo. Saia do local para checkout automatico antes de encerrar a operacao.';
      });
      return;
    }

    await _pararMonitoramento();
    _positionSub?.cancel();
    if (!mounted) return;
    setState(() {
      _operacaoAtiva = false;
      _followMyPosition = true;
      _status = 'Operacao encerrada. Bater ponto novamente para retomar.';
    });
  }

  void _startServiceStatusWatch() {
    _serviceStatusSub?.cancel();
    _serviceStatusSub = Geolocator.getServiceStatusStream().listen((status) {
      if (!mounted) return;
      if (status == ServiceStatus.disabled) {
        _positionSub?.cancel();
        setState(() {
          _locationLocked = true;
          _locationLockReason =
              'O localizador foi desligado. Para usar o app, mantenha a localizacao ativa o tempo todo.';
        });
      } else if (_locationLocked && _operacaoAtiva) {
        _startLocationTracking();
      }
    });
  }

  Future<void> _refreshOwnSummary() async {
    final resumo = await widget.api.resumoJornada(_selectedDate);
    if (!mounted) return;
    setState(() {
      _ownSummary = resumo.firstWhere(
        (r) => r.usuarioId == widget.currentUser.id,
        orElse: () => JourneySummary(
          usuarioId: widget.currentUser.id,
          nome: widget.currentUser.nome,
          email: widget.currentUser.email,
          latitudeAtual: _currentPosition?.latitude,
          longitudeAtual: _currentPosition?.longitude,
          kmPercorridos: 0,
          atualizacaoEm: null,
          locaisVisitados: const [],
          totalLocaisVisitados: 0,
        ),
      );
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );
    if (picked == null) return;
    setState(() => _selectedDate = picked);
    await _loadAgenda();
    await _refreshOwnSummary();
  }

  Future<void> _iniciarVisita(VisitPlan visita) async {
    if (!_operacaoAtiva) {
      setState(() {
        _status =
            'Bata o ponto em "Iniciar operacao" antes de comecar uma visita.';
      });
      return;
    }

    setState(() {
      _monitoringVisit = visita;
      _status = 'Monitorando geofence da visita ${visita.clienteNome}';
    });
    if (_currentPosition != null) {
      await _avaliarGeofence(_currentPosition!);
    }
  }

  Future<void> _pararMonitoramento() async {
    _clockTimer?.cancel();
    setState(() {
      _monitoringVisit = null;
      _activeCheckinId = null;
      _activeCheckinStart = null;
      _distanceToTarget = null;
      _elapsed = Duration.zero;
      _status = 'Monitoramento pausado';
    });
  }

  Future<void> _avaliarGeofence(Position position) async {
    final visita = _monitoringVisit;
    if (visita == null) return;

    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      visita.latitude,
      visita.longitude,
    );
    setState(() => _distanceToTarget = distance);

    if (_autoActionInFlight) return;

    if (_activeCheckinId == null && distance <= visita.raioMetros) {
      _autoActionInFlight = true;
      try {
        final response = await widget.api.checkin(
          visitaId: visita.id,
          latitude: position.latitude,
          longitude: position.longitude,
        );
        _activeCheckinId = response.id;
        _activeCheckinStart = response.dataCheckin;
        _clockTimer?.cancel();
        _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (!mounted || _activeCheckinStart == null) return;
          setState(
              () => _elapsed = DateTime.now().difference(_activeCheckinStart!));
        });
        if (mounted) {
          setState(() => _status = 'Check-in automatico iniciado');
        }
      } catch (e) {
        if (mounted) setState(() => _status = e.toString());
      } finally {
        _autoActionInFlight = false;
      }
      return;
    }

    if (_activeCheckinId != null && distance > visita.raioMetros) {
      _autoActionInFlight = true;
      try {
        final response = await widget.api.checkout(
          checkinId: _activeCheckinId!,
          latitude: position.latitude,
          longitude: position.longitude,
        );
        _clockTimer?.cancel();
        if (mounted) {
          setState(() {
            _status =
                'Checkout automatico realizado. Duracao: ${response.duracaoSegundos ?? 0}s';
            _activeCheckinId = null;
            _activeCheckinStart = null;
            _elapsed = Duration.zero;
          });
        }
        await _loadAgenda();
        await _refreshOwnSummary();
      } catch (e) {
        if (mounted) setState(() => _status = e.toString());
      } finally {
        _autoActionInFlight = false;
      }
    }
  }

  Future<void> _ensureLocationReady() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      _locationLocked = true;
      _locationLockReason =
          'Ative a localizacao do dispositivo para operar no campo.';
      throw Exception('Localizacao desativada');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _locationLocked = true;
        _locationLockReason =
            'Permissao de localizacao negada. Sem ela nao e possivel usar o app.';
        throw Exception('Permissao de localizacao negada');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _locationLocked = true;
      _locationLockReason =
          'Permissao negada para sempre. Abra configuracoes do app para liberar a localizacao.';
      throw Exception('Permissao de localizacao negada para sempre');
    }
  }

  Widget _buildOperacaoCard() {
    final badgeColor = _operacaoAtiva
        ? const Color(0xFF22C55E).withValues(alpha: 0.2)
        : const Color(0xFFF59E0B).withValues(alpha: 0.2);
    final badgeText = _operacaoAtiva ? 'Operacao ativa' : 'Operacao parada';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.badge, color: Color(0xFF5B5DF6)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Bater ponto da operacao',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFF2B385A)),
                  ),
                  child: Text(badgeText,
                      style: const TextStyle(fontSize: 12, color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _operacaoAtiva
                  ? 'Operacao em andamento. O GPS deve permanecer ligado o tempo todo para monitorar jornada e visitas.'
                  : 'Inicie a operacao para habilitar visitas e rastreamento da jornada.',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: _loading || _operacaoAtiva ? null : _iniciarOperacao,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Iniciar operacao'),
                ),
                OutlinedButton.icon(
                  onPressed: _loading || !_operacaoAtiva ? null : _encerrarOperacao,
                  icon: const Icon(Icons.stop),
                  label: const Text('Encerrar operacao'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _centerOnCurrentPosition() {
    final pos = _currentPosition;
    if (pos == null) return;
    try {
      _mapController.move(LatLng(pos.latitude, pos.longitude), 16.2);
    } catch (_) {
      // The map may not be attached yet.
    }
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget _buildLocationLockOverlay() {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.45),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.gps_off, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Localizacao obrigatoria',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(_locationLockReason),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: Geolocator.openLocationSettings,
                          icon: const Icon(Icons.location_on),
                          label: const Text('Ativar localizador'),
                        ),
                        OutlinedButton.icon(
                          onPressed: Geolocator.openAppSettings,
                          icon: const Icon(Icons.settings),
                          label: const Text('Permissao do app'),
                        ),
                        TextButton(
                          onPressed: () async {
                            try {
                              await _startLocationTracking();
                            } catch (_) {}
                          },
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
            colors: [Color(0xFF171C34), Color(0xFF262D4E)]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bom dia', style: TextStyle(color: Colors.white70)),
          Row(
            children: [
              Expanded(
                child: Text(widget.currentUser.nome,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
              ),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF5B5DF6),
                  borderRadius: BorderRadius.circular(21),
                ),
                child: Center(
                  child: Text(
                    widget.currentUser.nome
                        .split(' ')
                        .where((e) => e.isNotEmpty)
                        .map((e) => e[0])
                        .take(2)
                        .join(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Visitas de hoje e jornada em campo',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.72))),
        ],
      ),
    );
  }

  Widget _buildAgendaModule() {
    if (!_operacaoAtiva) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Operacao ainda nao iniciada',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'Bata o ponto em "Iniciar operacao" para liberar as visitas do dia.',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: _loading ? null : _iniciarOperacao,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Iniciar operacao agora'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _agenda.map((visita) {
        final selected = _monitoringVisit?.id == visita.id;
        return Card(
          color: selected ? const Color(0xFFE0F2FE) : null,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFF22C1C3) : const Color(0xFF6366F1),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(visita.clienteNome,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 17)),
                    ),
                    Chip(
                      label: Text(visita.status,
                          style: const TextStyle(color: Colors.white, fontSize: 11)),
                      backgroundColor: _statusVisitColor(visita.status),
                      side: BorderSide.none,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(visita.endereco, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 6),
                Text(
                    'Horario: ${_fmtTime(visita.dataAgendada)} • Raio: ${visita.raioMetros}m',
                    style: const TextStyle(color: Colors.white60)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    FilledButton.tonal(
                        onPressed: _locationLocked
                            ? null
                            : () => _iniciarVisita(visita),
                        child: const Text('Iniciar visita')),
                    const SizedBox(width: 8),
                    if (selected)
                      OutlinedButton(
                          onPressed: _pararMonitoramento,
                          child: const Text('Parar')),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMapModule() {
    final baseCenter = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : kSaoLuisCenter;

    final markers = <Marker>[
      if (_currentPosition != null)
        Marker(
          point:
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          width: 130,
          height: 70,
          child: Column(
            children: [
              const Icon(Icons.my_location, color: Colors.blue, size: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8)),
                child: const Text('Minha posicao'),
              ),
            ],
          ),
        ),
      ..._agenda.map((visita) => Marker(
            point: LatLng(visita.latitude, visita.longitude),
            width: 120,
            height: 60,
            child: Column(
              children: [
                const Icon(Icons.place, color: Colors.red, size: 30),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8)),
                  child:
                      Text(visita.clienteNome, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          )),
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _followMyPosition
                    ? 'Mapa fixado na sua posicao atual (GPS)'
                    : 'Mapa livre. Toque em Recentrar para voltar ao GPS',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              onPressed: _centerOnCurrentPosition,
              icon: const Icon(Icons.my_location),
              label: const Text('Recentrar'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 420,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options:
                      MapOptions(initialCenter: baseCenter, initialZoom: 15.2),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'br.com.minhavisita.mobile',
                    ),
                    MarkerLayer(markers: markers),
                  ],
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Fixar GPS'),
                          Switch(
                            value: _followMyPosition,
                            onChanged: (value) {
                              setState(() => _followMyPosition = value);
                              if (value) {
                                _centerOnCurrentPosition();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJourneyModule() {
    final summary = _ownSummary;
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = _isCompactWidth(constraints.maxWidth);
            if (compact) {
              return Column(
                children: [
                  _MetricCard(
                    label: 'Km percorridos',
                    value: '${(summary?.kmPercorridos ?? 0).toStringAsFixed(2)}',
                    icon: Icons.route,
                    accent: const Color(0xFF22C1C3),
                  ),
                  const SizedBox(height: 10),
                  _MetricCard(
                    label: 'Locais visitados',
                    value: '${summary?.totalLocaisVisitados ?? 0}',
                    icon: Icons.place_outlined,
                    accent: const Color(0xFF5B5DF6),
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'Km percorridos',
                    value:
                        '${(summary?.kmPercorridos ?? 0).toStringAsFixed(2)}',
                    icon: Icons.route,
                    accent: const Color(0xFF22C1C3),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    label: 'Locais visitados',
                    value: '${summary?.totalLocaisVisitados ?? 0}',
                    icon: Icons.place_outlined,
                    accent: const Color(0xFF5B5DF6),
                  ),
                ),
              ],
            );
          },
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Status da jornada',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (_activeCheckinId != null)
                  Text(
                      'Check-in ativo #$_activeCheckinId • ${_fmtDuration(_elapsed)}')
                else
                  const Text('Sem check-in ativo no momento'),
                if (_distanceToTarget != null)
                  Text(
                      'Distancia do alvo: ${_distanceToTarget!.toStringAsFixed(1)} m'),
                const SizedBox(height: 8),
                if ((summary?.locaisVisitados ?? const []).isEmpty)
                  const Text('Nenhum local visitado ainda.'),
                ...(summary?.locaisVisitados ?? const []).map((local) =>
                    ListTile(
                        dense: true,
                        leading:
                            const Icon(Icons.check_circle, color: Colors.green),
                        title: Text(local))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final modules = [
      _buildAgendaModule(),
      _buildMapModule(),
      _buildJourneyModule(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel do Vendedor'),
        actions: [
          IconButton(
              onPressed: _pickDate, icon: const Icon(Icons.calendar_month)),
          IconButton(
              onPressed: () async {
                await _loadAgenda();
                await _refreshOwnSummary();
              },
              icon: const Icon(Icons.refresh)),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient:
              LinearGradient(colors: [Color(0xFF0B1020), Color(0xFF12192E)]),
        ),
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 12),
                        _buildOperacaoCard(),
                        const SizedBox(height: 12),
                        modules[_tabIndex],
                        if (_status != null) ...[
                          const SizedBox(height: 10),
                          Card(
                            color: const Color(0xFF3B1D2A),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(_status!,
                                  style: const TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                        if (_loading) ...[
                          const SizedBox(height: 10),
                          const Center(child: CircularProgressIndicator()),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_locationLocked) _buildLocationLockOverlay(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (value) => setState(() => _tabIndex = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Rota'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Histórico'),
        ],
      ),
    );
  }

  String _fmtTime(DateTime date) {
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _fmtDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  Color _statusVisitColor(String status) {
    switch (status.toUpperCase()) {
      case 'CONCLUIDA':
        return const Color(0xFF22C55E);
      case 'EM_ANDAMENTO':
        return const Color(0xFF5B5DF6);
      case 'CANCELADA':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF59E0B);
    }
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  Text(label, style: const TextStyle(color: Colors.white60)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
