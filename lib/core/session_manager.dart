import "package:shared_preferences/shared_preferences.dart";

class SessionManager {
  static Future<void> guardarEvaluador(String id, String nombre, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('evaluador_id', id);
    await prefs.setString('evaluador_nombre', nombre);
    await prefs.setString('evaluador_email', email);
  }

  static Future<String?> getEvaluadorId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('evaluador_id');
  }

  static Future<String?> getEvaluadorNombre() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('evaluador_nombre');
  }

  static Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}