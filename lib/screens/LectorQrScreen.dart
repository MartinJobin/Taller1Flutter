import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class LectorQrScreen extends StatefulWidget {
  const LectorQrScreen({super.key});

  @override
  State<LectorQrScreen> createState() => _LectorQrScreenState();
}

class _LectorQrScreenState extends State<LectorQrScreen> {
  final MobileScannerController _scannerController =
      MobileScannerController();

  String _resultado = 'Todavía no se ha escaneado ningún código';
  bool _codigoDetectado = false;

  void _procesarCodigo(BarcodeCapture capture) {
    if (_codigoDetectado) {
      return;
    }

    final List<Barcode> codigos = capture.barcodes;

    if (codigos.isEmpty) {
      return;
    }

    final String? valor = codigos.first.rawValue;

    if (valor == null || valor.isEmpty) {
      return;
    }

    setState(() {
      _codigoDetectado = true;
      _resultado = valor;
    });

    _scannerController.stop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Código QR detectado'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _escanearNuevamente() {
    setState(() {
      _codigoDetectado = false;
      _resultado = 'Buscando código QR...';
    });

    _scannerController.start();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Lector QR',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              alignment: Alignment.center,
              children: [
                MobileScanner(
                  controller: _scannerController,
                  onDetect: _procesarCodigo,
                ),

                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.red,
                      width: 4,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const Positioned(
                  bottom: 25,
                  child: Text(
                    'Coloca el código QR dentro del recuadro',
                    style: TextStyle(
                      color: Colors.white,
                      backgroundColor: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: const Color(0xFF1A1A2E),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Resultado',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),

                  SelectableText(
                    _resultado,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 25),

                  ElevatedButton.icon(
                    onPressed: _escanearNuevamente,
                    icon: const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'ESCANEAR NUEVAMENTE',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}