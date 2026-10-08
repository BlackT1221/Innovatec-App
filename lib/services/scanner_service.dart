import 'package:dio/dio.dart';

class ScannerService {
  // Cambia esto por la IP de tu PC en la misma red WiFi (ej. 192.168.1.10) o tu URL de producción
  final String baseUrl = "http://172.25.198.15:8000/api/v1"; 
  final Dio _dio = Dio();

  Future<Map<String, dynamic>?> enviarHojaEvaluacion(String imagePath) async {
    try {
      // 1. Preparar el archivo como Multipart (exactamente como lo espera FastAPI)
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(imagePath, filename: "hoja_omr.jpg"),
      });

      // 2. Hacer la petición POST
      Response response = await _dio.post(
        "$baseUrl/evaluaciones/escanear",
        data: formData,
        options: Options(
          // Si luego agregas JWT, aquí iría el header: 'Authorization': 'Bearer $token'
          headers: {"Content-Type": "multipart/form-data"}, 
        ),
      );

      // 3. Si todo sale bien, retornamos el JSON que nos dio tu backend
      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data; // Aquí vendrá el 'puntaje_final' y el 'mensaje'
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print("Error del Backend: ${e.response?.data}");
        throw Exception(e.response?.data['detail'] ?? "Error procesando la imagen");
      } else {
        throw Exception("Error de red: No se pudo conectar al servidor");
      }
    }
    return null;
  }
}