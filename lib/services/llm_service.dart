import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LlmService {
  static String get apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static const String chatApiUrl = 'https://api.openai.com/v1/chat/completions';
  static const String whisperApiUrl = 'https://api.openai.com/v1/audio/transcriptions';

  static final Map<String, String> personaPrompts = {
    'Formal Email': 'Rewrite this to be a professional, formal business email. Maintain the core meaning but use corporate language.',
    'To-Do List': 'Extract all actionable tasks from this text and format it as a numbered list of to-do items.',
    'LinkedIn Post': 'Turn this content into an engaging professional LinkedIn post, using appropriate spacing and 3-5 relevant hashtags.',
    'Witty Tone': 'Rewrite this text with a humorous, clever, and witty tone. Make it fun but keep the main point clear.',
  };

  static Future<String> changeTone(String text, String tone) async {
    final systemPrompt = personaPrompts[tone] ?? 'Paraphrase this text.';
    
    final payload = {
      "model": "gpt-4o-mini",
      "messages": [
        {"role": "system", "content": systemPrompt},
        {"role": "user", "content": text}
      ],
      "temperature": 0.7,
    };

    final response = await http.post(
      Uri.parse(chatApiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'].trim() as String;
    } else {
      throw Exception('Failed to generate content: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> transcribeAudio(String path) async {
    final request = http.MultipartRequest('POST', Uri.parse(whisperApiUrl))
      ..headers['Authorization'] = 'Bearer $apiKey'
      ..fields['model'] = 'whisper-1'
      ..fields['response_format'] = 'verbose_json'
      ..fields['language'] = 'en'
      ..fields['prompt'] = 'The user is speaking Malayalam, Hindi, or English. Please transcribe/translate into English text.';

    if (kIsWeb) {
      final response = await http.get(Uri.parse(path));
      final bytes = response.bodyBytes;
      
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: 'recording.webm',
        contentType: MediaType('audio', 'webm'),
      ));
    } else {
      final file = File(path);
      
      final isWav = path.toLowerCase().endsWith('.wav');
      final filename = isWav ? 'recording.wav' : 'recording.m4a';
      final contentType = isWav ? 'audio/wav' : 'audio/mp4';

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        path,
        filename: filename,
        contentType: MediaType.parse(contentType),
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'text': data['text'] as String,
        'language': 'english', // Hardcoded as requested
      };
    } else {
      debugPrint("OpenAI Translation Error: ${response.body}");
      throw Exception('OpenAI Error: ${response.statusCode}');
    }
  }
}
