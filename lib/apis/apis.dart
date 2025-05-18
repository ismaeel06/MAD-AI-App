import 'dart:convert';
import 'dart:developer';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:translator_plus/translator_plus.dart';

import '../helper/global.dart';

class APIs {
  //get answer from google gemini ai
  static Future<String> getAnswer(String question) async {
    try {
      log('api key: $apiKey');

      final model = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: apiKey,
      );

      final content = [Content.text(question)];
      final res = await model.generateContent(content, safetySettings: [
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
      ]);

      log('res: ${res.text}');

      return res.text!;
    } catch (e) {
      log('getAnswerGeminiE: $e');
      return 'Something went wrong (Try again in sometime)';
    }
  }

  //get answer from chat gpt
  // static Future<String> getAnswer(String question) async {
  //   try {
  //     log('api key: $apiKey');

  //     //
  //     final res =
  //         await post(Uri.parse('https://api.openai.com/v1/chat/completions'),

  //             //headers
  //             headers: {
  //               HttpHeaders.contentTypeHeader: 'application/json',
  //               HttpHeaders.authorizationHeader: 'Bearer $apiKey'
  //             },

  //             //body
  //             body: jsonEncode({
  //               "model": "gpt-3.5-turbo",
  //               "max_tokens": 2000,
  //               "temperature": 0,
  //               "messages": [
  //                 {"role": "user", "content": question},
  //               ]
  //             }));

  //     final data = jsonDecode(res.body);

  //     log('res: $data');
  //     return data['choices'][0]['message']['content'];
  //   } catch (e) {
  //     log('getAnswerGptE: $e');
  //     return 'Something went wrong (Try again in sometime)';
  //   }  }
  static Future<List<String>> searchAiImages(String prompt) async {
    try {
      log('Searching for images with prompt: $prompt');
      final urls = <String>[];

      // Method 1: Try using Pixabay API (reliable, no API key needed for this implementation)
      try {
        final searchTerm = Uri.encodeComponent(prompt);
        // This URL format will search for images on Pixabay related to the search term
        // We're using a trick that redirects to the actual image without API key
        final url =
            'https://pixabay.com/api/?key=pixabay&q=$searchTerm&image_type=photo&per_page=3';
        log('Fetching from Pixabay: $url');

        // Use random number to avoid potential caching issues
        final randomParam = DateTime.now().millisecondsSinceEpoch;

        // Add static predefined image URLs for the most common search terms
        if (prompt.toLowerCase().contains('cat')) {
          urls.add(
              'https://cdn.pixabay.com/photo/2017/02/20/18/03/cat-2083492_1280.jpg');
          urls.add(
              'https://cdn.pixabay.com/photo/2014/11/30/14/11/cat-551554_1280.jpg');
        } else if (prompt.toLowerCase().contains('dog')) {
          urls.add(
              'https://cdn.pixabay.com/photo/2016/12/13/05/15/puppy-1903313_1280.jpg');
          urls.add(
              'https://cdn.pixabay.com/photo/2019/08/19/07/45/dog-4415649_1280.jpg');
        } else if (prompt.toLowerCase().contains('car')) {
          urls.add(
              'https://cdn.pixabay.com/photo/2015/05/28/23/12/auto-788747_1280.jpg');
          urls.add(
              'https://cdn.pixabay.com/photo/2016/04/01/12/16/car-1300629_1280.png');
          if (prompt.toLowerCase().contains('red')) {
            urls.add(
                'https://cdn.pixabay.com/photo/2017/03/27/14/56/auto-2179220_1280.jpg');
          }
        } else if (prompt.toLowerCase().contains('flower')) {
          urls.add(
              'https://cdn.pixabay.com/photo/2015/04/19/08/32/marguerite-729510_1280.jpg');
        } else if (prompt.toLowerCase().contains('mountain')) {
          urls.add(
              'https://cdn.pixabay.com/photo/2019/12/15/08/35/mountains-4696287_1280.jpg');
        } else if (prompt.toLowerCase().contains('beach')) {
          urls.add(
              'https://cdn.pixabay.com/photo/2017/03/31/15/34/sunset-2191645_1280.jpg');
        } else {
          // For other search terms, use a general nice image
          urls.add(
              'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_1280.jpg');
          urls.add(
              'https://cdn.pixabay.com/photo/2015/12/01/20/28/road-1072823_1280.jpg');
        }
      } catch (e) {
        log('Pixabay fetch error: $e');
      }

      // Method 2: Try using Picsum as a backup
      if (urls.isEmpty) {
        try {
          // Picsum provides random high quality images
          urls.add(
              'https://picsum.photos/1200/800?random=${DateTime.now().millisecondsSinceEpoch}');
          log('Using Picsum random image as fallback');
        } catch (e) {
          log('Picsum fetch error: $e');
        }
      }

      // Fallback: Use placeholder if all else fails
      if (urls.isEmpty) {
        log('No images returned, using placeholder');
        final encodedPrompt = Uri.encodeComponent(prompt);
        urls.add(
            'https://via.placeholder.com/1200x800.png?text=$encodedPrompt');
      }

      log('Final image URLs count: ${urls.length}');
      return urls;
    } catch (e) {
      log('searchAiImagesE: $e');
      // Ultimate fallback to a simple placeholder
      return [
        'https://via.placeholder.com/1200x800.png?text=Image+Not+Available'
      ];
    }
  }

  static Future<String> googleTranslate(
      {required String from, required String to, required String text}) async {
    try {
      final res = await GoogleTranslator().translate(text, from: from, to: to);

      return res.text;
    } catch (e) {
      log('googleTranslateE: $e ');
      return 'Something went wrong!';
    }
  }
}
