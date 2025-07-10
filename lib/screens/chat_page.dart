import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import '../services/audio_transcription_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isAudio;
  final Map<String, dynamic>? expenseData;
  ChatMessage({required this.text, this.isUser = false, this.isAudio = false, this.expenseData});
}

class _ChatPageState extends State<ChatPage> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String? _recordedPath;
  final TextEditingController _messageController = TextEditingController();
  String? _transcriptionResult;
  final int _userId = 1; // Cambia esto según tu lógica de usuario
  final AudioTranscriptionService _transcriptionService = AudioTranscriptionService();
  bool _isLoading = false;
  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    // Solicita el permiso de micrófono al iniciar
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso de micrófono denegado. No se puede grabar audio.')),
        );
        return;
      }
    }
    await _recorder.openRecorder();
  }

  Future<void> _startRecording() async {
    try {
      var status = await Permission.microphone.status;
      if (!status.isGranted) {
        status = await Permission.microphone.request();
        if (!status.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permiso de micrófono denegado. No se puede grabar audio.')),
            );
          }
          return;
        }
      }
      await _recorder.openRecorder(); // Asegura que esté abierto
      final dir = await getApplicationDocumentsDirectory();
      _recordedPath = '${dir.path}/recording.aac';
      await _recorder.startRecorder(
        toFile: _recordedPath,
        codec: Codec.aacADTS, // Graba en AAC para máxima compatibilidad
      );
      setState(() => _isRecording = true);
      print('Grabando en formato AAC...');
    } catch (e) {
      print('Error al iniciar la grabación: $e');
      setState(() => _isRecording = false);
    }
  }

  Future<String?> _copyRecordingToDownloads(String privatePath) async {
    try {
      // Ruta pública real de descargas
      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      final fileName = privatePath.split('/').last;
      final newPath = "${downloadsDir.path}/$fileName";
      final newFile = await File(privatePath).copy(newPath);
      print('Archivo copiado a carpeta pública: ${newFile.path}');
      return newFile.path;
    } catch (e) {
      print('Error copiando a carpeta pública: $e');
      return null;
    }
  }

  Future<void> _stopRecording() async {
    try {
      // Forzar al menos 2 segundos de grabación para pruebas
      await Future.delayed(const Duration(seconds: 2));
      await _recorder.stopRecorder();
      setState(() => _isRecording = false);
      if (_recordedPath != null) {
        print('Ruta del archivo grabado: $_recordedPath');
        final file = File(_recordedPath!);
        final length = await file.length();
        print('Tamaño del archivo: $length bytes');
        if (length <= 44) {
          print('Advertencia: El archivo está vacío. Verifica el micrófono y los permisos.');
        }
        // Copiar a carpeta pública
        final publicPath = await _copyRecordingToDownloads(_recordedPath!);
        if (publicPath != null) {
          print('Puedes extraer el archivo con: adb pull $publicPath <destino>');
        } else {
          print('No se pudo copiar el archivo a carpeta pública');
        }
        setState(() { _isLoading = true; });
        // Agrega mensaje de audio enviado
        setState(() {
          _messages.add(ChatMessage(
            text: 'Audio enviado',
            isUser: true,
            isAudio: true,
          ));
        });
        try {
          final result = await _transcriptionService.transcribeAudio(audioFile: file, userId: _userId);
          final transcription = result['transcription'];
          print('Transcripción recibida:\n${transcription ?? result['error'] ?? 'Sin respuesta'}');
          // Si es gasto, muestra bonito
          if (transcription is Map<String, dynamic> || (transcription is Map)) {
            setState(() {
              _messages.add(ChatMessage(
                text: '',
                isUser: false,
                expenseData: Map<String, dynamic>.from(transcription),
              ));
            });
          } else {
            setState(() {
              _messages.add(ChatMessage(
                text: transcription is String ? transcription : jsonEncode(transcription ?? result['error'] ?? 'Sin respuesta'),
                isUser: false,
              ));
            });
          }
        } catch (e) {
          print('Error en la transcripción: $e');
          setState(() {
            _messages.add(ChatMessage(
              text: 'Error en la transcripción',
              isUser: false,
            ));
          });
        } finally {
          setState(() { _isLoading = false; });
        }
      }
    } catch (e) {
      print('Error al detener la grabación: $e');
      setState(() => _isRecording = false);
    }
  }

  Widget _buildChatBubble(ChatMessage message) {
    if (message.isAudio && message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.mic, color: Colors.blue),
              SizedBox(width: 8),
              Text('Audio enviado', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    } else if (message.expenseData != null) {
      final data = message.expenseData!;
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('✅ Gasto añadido', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              const SizedBox(height: 4),
              Text('Descripción: ${data['description'] ?? '-'}'),
              Text('Cantidad: ${data['amount'] ?? '-'}'),
              Text('Método de pago: ${data['paymentMethod'] ?? '-'}'),
            ],
          ),
        ),
      );
    } else {
      return Align(
        alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            color: message.isUser ? Colors.blue.shade100 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(message.text),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Conversational Interaction")),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  reverse: false,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return _buildChatBubble(_messages[index]);
                  },
                ),
              ),
              _buildInputSection(),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text field with microphone button
          TextField(
            controller: _messageController,
            decoration: InputDecoration(
              hintText: 'Write your message or send a voice note',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24.0),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24.0),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24.0),
                borderSide: const BorderSide(color: Colors.blue),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  color: _isRecording ? Colors.red : Colors.blue,
                ),
                onPressed: _isRecording ? _stopRecording : _startRecording,
              ),
            ),
          ),

          // Helper text
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 4.0, bottom: 16.0),
            child: Text(
              'Microphone button for voice input',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),

          // Suggestion buttons
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              _messageController.text = 'Check my expenses';
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text('Check my expenses'),
          ),

          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              _messageController.text = 'Set a savings goal';
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text('Set a savings goal'),
          ),

          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              _messageController.text = 'What is a budget?';
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text('What is a budget?'),
          ),

          // Send button
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Send functionality to be implemented later
              if (_messageController.text.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Message sent: ${_messageController.text}')),
                );
                _messageController.clear();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: const Text(
              'Send',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
