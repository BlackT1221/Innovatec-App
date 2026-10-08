import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/constants.dart';
import '../core/session_manager.dart';
import 'scanner_screen.dart';
import 'login_email_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> _asignaciones = [];
  bool _isLoading = true;
  String _nombreEvaluador = "";
  final Dio _dio = Dio();
  final String baseUrl = "http://192.168.137.223:8000/api/v1";

  @override
  void initState() {
    super.initState();
    _cargarDatosYAsignaciones();
  }

  Future<void> _cargarDatosYAsignaciones() async {
    final nombre = await SessionManager.getEvaluadorNombre();
    final id = await SessionManager.getEvaluadorId();

    setState(() => _nombreEvaluador = nombre ?? "Instructor");

    if (id != null) {
      try {
        final response = await _dio.get(
          "$baseUrl/evaluadores/evaluador/$id/asignaciones",
        );
        setState(() {
          _asignaciones = response.data;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _cerrarSesion() async {
    await SessionManager.cerrarSesion();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginEmailScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Mis Evaluaciones",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _cerrarSesion,
            tooltip: "Cerrar Sesión",
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER CON BIENVENIDA
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.senaGreen,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bienvenido,",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                Text(
                  _nombreEvaluador,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "Proyectos en Feria:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.senaGreen,
                    ),
                  )
                : _asignaciones.isEmpty
                ? Center(
                    child: Text(
                      "No tienes grupos asignados aún.",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  )
                : RefreshIndicator(
                    color: AppColors.senaGreen,
                    onRefresh: _cargarDatosYAsignaciones,
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _asignaciones.length,
                      itemBuilder: (context, index) {
                        final item = _asignaciones[index];
                        final proyecto = item['proyecto'];
                        final estado = item['estado'];
                        final puntaje = item['puntaje_final'];
                        bool procesada = estado == "PROCESADA";

                        return Card(
                          elevation: 0,
                          margin: EdgeInsets.only(bottom: 16),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        proyecto['nombre_proyecto'],
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.senaGreenDark,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: procesada
                                            ? Colors.green.shade50
                                            : Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: procesada
                                              ? Colors.green.shade200
                                              : Colors.orange.shade200,
                                        ),
                                      ),
                                      child: Text(
                                        procesada ? "Evaluado" : "Pendiente",
                                        style: TextStyle(
                                          color: procesada
                                              ? Colors.green.shade700
                                              : Colors.orange.shade700,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Trimestre: ${proyecto['trimestre']}",
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (puntaje != null)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Nota Final",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          Text(
                                            "$puntaje",
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      )
                                    else
                                      Text(
                                        "Sin calificar",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),

                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        final recargar = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ScannerScreen(),
                                          ),
                                        );
                                        if (recargar == true)
                                          _cargarDatosYAsignaciones();
                                      },
                                      icon: Icon(
                                        Icons.qr_code_scanner,
                                        size: 18,
                                      ),
                                      label: Text(
                                        procesada
                                            ? "Re-Escanear"
                                            : "Escanear OMR",
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        backgroundColor: procesada
                                            ? Colors.white
                                            : AppColors.senaGreen,
                                        foregroundColor: procesada
                                            ? AppColors.senaGreen
                                            : Colors.white,
                                        side: procesada
                                            ? BorderSide(
                                                color: AppColors.senaGreen,
                                              )
                                            : null,
                                        elevation: procesada ? 0 : 2,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
