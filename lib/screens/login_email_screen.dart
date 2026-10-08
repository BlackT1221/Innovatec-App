import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/constants.dart';
import 'login_otp_screen.dart';

class LoginEmailScreen extends StatefulWidget {
  @override
  _LoginEmailScreenState createState() => _LoginEmailScreenState();
}

class _LoginEmailScreenState extends State<LoginEmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  final Dio _dio = Dio();
  final String baseUrl = "http://192.168.137.223:8000/api/v1";

  Future<void> _solicitarCodigo() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await _dio.post("$baseUrl/auth/request-otp", data: {"email": email});
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginOtpScreen(email: email)),
      );
    } on DioException catch (e) {
      final msg = e.response?.data['detail'] ?? "Error al enviar el código";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LOGO DEL SENA
                Image.asset('assets/images/logo_sena.png', height: 120, errorBuilder: (context, error, stackTrace) => Icon(Icons.school, size: 100, color: AppColors.senaGreen)),
                SizedBox(height: 30),
                Text("Innovatec CBA", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.senaGreenDark)),
                Text("Evaluación de Proyectos Formativos", style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                SizedBox(height: 40),
                
                // TARJETA DE INGRESO
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: Offset(0, 10))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text("Acceso para Instructores", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      SizedBox(height: 20),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Correo Electrónico",
                          prefixIcon: Icon(Icons.email_outlined, color: AppColors.senaGreen),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.senaGreen, width: 2)),
                        ),
                      ),
                      SizedBox(height: 24),
                      _isLoading
                          ? Center(child: CircularProgressIndicator(color: AppColors.senaGreen))
                          : ElevatedButton(
                              onPressed: _solicitarCodigo,
                              child: Text("Solicitar Acceso"),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}