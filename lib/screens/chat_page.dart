import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../services/audio_transcription_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
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

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso de micrófono denegado. No se puede grabar audio.')),
        );
      }
      throw Exception('Permiso de micrófono denegado');
    }
    await _recorder.openRecorder();
  }

  Future<void> _startRecording() async {
    // Solicita el permiso justo antes de grabar
    var status = await Permission.microphone.status;
    if (status != PermissionStatus.granted) {
      status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permiso de micrófono denegado. No se puede grabar audio.')),
          );
        }
        return;
      }
    }
    final dir = await getApplicationDocumentsDirectory();
    _recordedPath = '${dir.path}/recording.wav';
    await _recorder.startRecorder(
      toFile: _recordedPath,
      codec: Codec.pcm16WAV,
      sampleRate: 16000, // <-- Sample rate ajustado a 16000 Hz
    );
    setState(() => _isRecording = true);
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
    await _recorder.stopRecorder();
    if (!mounted) return;
    setState(() => _isRecording = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Audio grabado en: $_recordedPath')),
    );
    if (_recordedPath != null) {
      print('Ruta del archivo grabado: $_recordedPath');
      final file = File(_recordedPath!);
      print('Tamaño del archivo: \\n${await file.length()} bytes');
      // Copiar a carpeta pública
      final publicPath = await _copyRecordingToDownloads(_recordedPath!);
      if (publicPath != null) {
        print('Puedes extraer el archivo con: adb pull $publicPath <destino>');
      } else {
        print('No se pudo copiar el archivo a carpeta pública');
      }
      setState(() { _isLoading = true; });
      try {
        final result = await _transcriptionService.transcribeAudio(audioFile: file, userId: _userId);
        print('Transcripción recibida:\n${result['transcription'] ?? result['error'] ?? 'Sin respuesta'}');
        setState(() {
          _transcriptionResult = result['transcription'] ?? result['error'] ?? 'Sin respuesta';
        });
      } catch (e) {
        print('Error en la transcripción: $e');
        setState(() {
          _transcriptionResult = 'Error en la transcripción';
        });
      } finally {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Conversational Interaction")),
      body: Stack(
        children: [
          Column(
            children: [
              if (_transcriptionResult != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Transcripción:\n$_transcriptionResult'),
                ),

              // Chat messages area (currently empty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Your chat history will appear here"),
                      const SizedBox(height: 20),
                      // Recording indicator
                      if (_isRecording)
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.mic, color: Colors.red),
                            SizedBox(width: 8),
                            Text("Recording audio...",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              // Bottom input section
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
