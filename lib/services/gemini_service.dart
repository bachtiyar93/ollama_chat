import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  Future<String> generateResponse(String prompt, String apiKey, String model) async {
    // Use the correct Gemini API endpoint with proper model naming
    final url = 'https://generativelanguage.googleapis.com/v1/models/$model:generateContent?key=$apiKey';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ]
      }),
    ).timeout(const Duration(seconds: 60)); // Add 60 second timeout

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      // Provide more detailed error information
      final errorData = jsonDecode(response.body);
      final errorMessage = errorData['error']?['message'] ?? 'Unknown error';
      throw Exception('Failed to generate response from Gemini: $errorMessage\nStatus: ${response.statusCode}\nModel: $model');
    }
  }

  // Method to list available models with their supported methods
  Future<List<Map<String, dynamic>>> listAvailableModels(String apiKey) async {
    final url = 'https://generativelanguage.googleapis.com/v1/models?key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final models = data['models'] as List;
      return models.map((model) => {
        'name': model['name'].toString().split('/').last,
        'displayName': model['displayName'] ?? model['name'].toString().split('/').last,
        'supportedMethods': model['supportedGenerationMethods'] ?? [],
        'description': model['description'] ?? '',
      }).toList();
    } else {
      throw Exception('Failed to list models: ${response.body}');
    }
  }

  // Get models that support generateContent method
  Future<List<String>> getModelsSupportingGenerateContent(String apiKey) async {
    final models = await listAvailableModels(apiKey);
    return models
        .where((model) => (model['supportedMethods'] as List).contains('generateContent'))
        .map((model) => model['name'] as String)
        .toList();
  }
}
