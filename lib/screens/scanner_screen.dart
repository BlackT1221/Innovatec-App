import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/scanner_service.dart';

class ScannerScreen extends StatefulWidget {
  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  final ScannerService _scannerService = ScannerService();
  bool _isLoading = false;

  Future<void> _seleccionarImagen(ImageSource source) async {
    final XFile? imagen = await _picker.pickImage(
      source: source,
      imageQuality: 90, // Buena calidad para asegurar que el QR sea legible
    );

    if (imagen != null) {
      setState(() => _isLoading = true);

      try {
        final resultado = await _scannerService.enviarHojaEvaluacion(imagen.path);

        if (resultado != null) {
          _mostrarResultadoDialog(
            resultado['mensaje'], 
            resultado['puntaje_final'].toString()
          );
        }
      } catch (e) {
        _mostrarErrorDialog(e.toString());
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _mostrarOpciones(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.camera_alt, color: Colors.blue),
            title: Text('Tomar Foto con la Cámara'),
            onTap: () {
              Navigator.pop(ctx);
              _seleccionarImagen(ImageSource.camera);
            },
          ),
          ListTile(
            leading: Icon(Icons.photo_library, color: Colors.green),
            title: Text('Elegir de la Galería'),
            onTap: () {
              Navigator.pop(ctx);
              _seleccionarImagen(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  void _mostrarResultadoDialog(String mensaje, String nota) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("¡Evaluación Exitosa! 🎉"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mensaje),
            SizedBox(height: 20),
            Text("Nota Final:", style: TextStyle(fontSize: 18)),
            Text(nota, style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.green)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Aceptar"),
          )
        ],
      ),
    );
  }

  void _mostrarErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Error de Lectura"),
        content: Text(error),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Reintentar"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Escanear Rúbrica OMR")),
      body: Center(
        child: _isLoading 
          ? CircularProgressIndicator()
          : ElevatedButton.icon(
              onPressed: () => _mostrarOpciones(context),
              icon: Icon(Icons.qr_code_scanner, size: 30),
              label: Text("Seleccionar o Capturar Hoja", style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14)
              ),
            ),
      ),
    );
  }
}