import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MinhaVisitaApp());
}

class MinhaVisitaApp extends StatelessWidget {
  const MinhaVisitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minha Visita',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF1D3557)),
      home: const LoginScreen(),
    );
  }
}

class ApiClient {
  ApiClient(this.baseUrl);

  final String baseUrl;

  Future<Map<String, dynamic>> login(String email, String senha) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': senha}),
    );
    if (response.statusCode >= 400) {
      throw Exception('Login falhou: ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> checkin({
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
      }),
    );
    if (response.statusCode >= 400) {
      throw Exception('Check-in falhou: ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> checkout({
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
      }),
    );
    if (response.statusCode >= 400) {
      throw Exception('Check-out falhou: ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
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

  final _api = ApiClient('http://10.0.2.2:8080');

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _erro = null;
    });
    try {
      final data = await _api.login(_emailController.text, _senhaController.text);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomeScreen(api: _api, loginData: data),
        ),
      );
    } catch (e) {
      setState(() {
        _erro = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              const Text('Minha Visita', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Entre com seu email e senha para continuar.'),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _senhaController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              if (_erro != null)
                Text(_erro!, style: const TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading ? const CircularProgressIndicator() : const Text('Entrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.api, required this.loginData});

  final ApiClient api;
  final Map<String, dynamic> loginData;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _visitaIdController = TextEditingController();
  final _checkinIdController = TextEditingController();
  Position? _position;
  String? _status;
  bool _loading = false;

  Future<void> _atualizarLocalizacao() async {
    setState(() {
      _loading = true;
      _status = null;
    });
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final request = await Geolocator.requestPermission();
        if (request == LocationPermission.denied) {
          throw Exception('Permissao de localizacao negada');
        }
      }
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _position = pos;
        _status = 'Localizacao atualizada';
      });
    } catch (e) {
      setState(() {
        _status = e.toString();
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _checkin() async {
    if (_position == null) {
      setState(() => _status = 'Atualize a localizacao antes do check-in');
      return;
    }
    final visitaId = int.tryParse(_visitaIdController.text);
    if (visitaId == null) {
      setState(() => _status = 'Informe um visitaId valido');
      return;
    }
    setState(() => _loading = true);
    try {
      final response = await widget.api.checkin(
        visitaId: visitaId,
        latitude: _position!.latitude,
        longitude: _position!.longitude,
      );
      setState(() {
        _status = 'Check-in realizado. ID: ${response['id']}';
        _checkinIdController.text = '${response['id']}';
      });
    } catch (e) {
      setState(() => _status = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _checkout() async {
    if (_position == null) {
      setState(() => _status = 'Atualize a localizacao antes do check-out');
      return;
    }
    final checkinId = int.tryParse(_checkinIdController.text);
    if (checkinId == null) {
      setState(() => _status = 'Informe um checkinId valido');
      return;
    }
    setState(() => _loading = true);
    try {
      final response = await widget.api.checkout(
        checkinId: checkinId,
        latitude: _position!.latitude,
        longitude: _position!.longitude,
      );
      setState(() {
        _status = 'Check-out realizado. Duracao: ${response['duracaoSegundos']}s';
      });
    } catch (e) {
      setState(() => _status = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = widget.loginData['usuario'] as Map<String, dynamic>?;
    return Scaffold(
      appBar: AppBar(title: const Text('Minha Visita')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Ola, ${usuario?['nome'] ?? 'Usuario'}', style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 16),
              TextField(
                controller: _visitaIdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Visita ID'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _checkinIdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Check-in ID'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _loading ? null : _atualizarLocalizacao,
                child: const Text('Atualizar localizacao'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loading ? null : _checkin,
                child: const Text('Check-in'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loading ? null : _checkout,
                child: const Text('Check-out'),
              ),
              const SizedBox(height: 16),
              if (_position != null)
                Text('Lat: ${_position!.latitude}, Lng: ${_position!.longitude}'),
              if (_status != null) ...[
                const SizedBox(height: 12),
                Text(_status!, style: const TextStyle(color: Colors.black87)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
