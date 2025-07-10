import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class AudioTranscriptionService {
  final String baseUrl;
  AudioTranscriptionService({this.baseUrl = 'http://192.168.18.5:5000'});

  Future<Map<String, dynamic>> transcribeAudio({
    required File audioFile,
    required int userId,
  }) async {
    final url = Uri.parse('$baseUrl/api/v1/transcribe/audio/$userId');
    final request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath(
        'audio',
        audioFile.path,
        contentType: MediaType('audio', 'aac'),
      ));
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'error': 'Error en la transcripción',
          'id_user': userId,
          'details': response.body
        };
      }
    } catch (e) {
      return {
        'error': e.toString(),
        'id_user': userId
      };
    }
  }
}
