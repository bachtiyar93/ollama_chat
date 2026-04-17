import 'dart:convert';
import 'package:http/http.dart' as http;

class OllamaService {
  Future<String> generateResponse(String prompt, String baseUrl, String model) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/generate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'model': model,
        'prompt': prompt,
        'stream': false,
      }),
    ).timeout(const Duration(seconds: 120)); // Add 2 minute timeout for local Ollama

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['response'];
    } else {
      throw Exception('Failed to connect to Ollama: ${response.body}');
    }
  }

  Future<void> generateStreamingResponse(
    String prompt,
    String baseUrl,
    String model,
    Function(String) onChunk,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/generate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'model': model,
        'prompt': prompt,
        'stream': true,
      }),
    ).timeout(const Duration(seconds: 120));

    if (response.statusCode == 200) {
      final stream = response.body.split('\n');
      for (final line in stream) {
        if (line.trim().isNotEmpty) {
          try {
            final data = jsonDecode(line);
            final chunk = data['response'] as String?;
            if (chunk != null) {
              onChunk(chunk);
            }
            // Check if this is the final chunk
            if (data['done'] == true) {
              break;
            }
          } catch (e) {
            // Skip malformed JSON lines
            continue;
          }
        }
      }
    } else {
      throw Exception('Failed to connect to Ollama: ${response.body}');
    }
  }
}
