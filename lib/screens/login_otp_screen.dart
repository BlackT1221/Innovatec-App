import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/constants.dart';
import '../core/session_manager.dart';
import 'dashboard_screen.dart';

class LoginOtpScreen extends StatefulWidget {
  final String email;
  LoginOtpScreen({required this.email});

  @override
  _LoginOtpScreenState createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends State<LoginOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  final Dio _dio = Dio();
  final String baseUrl = "http://192.168.137.223:8000/api/v1";

  Future<void> _verificarCodigo() async {
    final code = _otpController.text.trim();
    if (code.length != 6) return;

    setState(() => _isLoading = true);
    try {
      final response = await _dio.post("$baseUrl/auth/verify-otp", data: {"email": widget.email, "code": code});
      final evaluador = response.data['evaluador'];
      
      await SessionManager.guardarEvaluador(evaluador['id'], evaluador['nombre_completo'], evaluador['email']);
      
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => DashboardScreen()), (route) => false);
    } on DioException catch (e) {
      final msg = e.response?.data['detail'] ?? "Código incorrecto o expirado";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verificación de Seguridad")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.mark_email_read_outlined, size: 80, color: AppColors.senaGreen),
              SizedBox(height: 20),
              Text("Revisa tu bandeja de entrada", textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              SizedBox(height: 10),
              Text("Hemos enviado un código seguro de 6 dígitos a:\n${widget.email}", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
              SizedBox(height: 40),
              
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, letterSpacing: 15, fontWeight: FontWeight.bold, color: AppColors.senaGreenDark),
                decoration: InputDecoration(
                  counterText: "",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: AppColors.senaGreen, width: 2)),
                ),
              ),
              SizedBox(height: 30),
              _isLoading
                  ? Center(child: CircularProgressIndicator(color: AppColors.senaGreen))
                  : ElevatedButton(
                      onPressed: _verificarCodigo,
                      child: Text("Verificar y Entrar"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}