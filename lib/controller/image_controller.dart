import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
// Temporarily disabled: import 'package:gallery_saver_updated/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../apis/apis.dart';
import '../helper/global.dart';
import '../helper/my_dialog.dart';

enum Status { none, loading, complete }

class ImageController extends GetxController {
  final textC = TextEditingController();

  final status = Status.none.obs;

  final url = ''.obs;

  final imageList = <String>[].obs;
  Future<void> createAIImage() async {
    if (textC.text.trim().isNotEmpty) {
      try {
        // Update status to loading
        status.value = Status.loading;

        // Get multiple relevant image URLs
        imageList.value = await APIs.searchAiImages(textC.text);

        if (imageList.isNotEmpty) {
          // Use the first image URL
          url.value = imageList.first;
          status.value = Status.complete;
          log("Successfully generated image URL: ${url.value}");

          // Try to validate the URL by making a HEAD request
          try {
            final response = await http.head(Uri.parse(url.value));
            if (response.statusCode != 200) {
              log("Warning: Image URL returned non-200 status: ${response.statusCode}");
            }
          } catch (validateError) {
            log("Warning: Couldn't validate image URL: $validateError");
            // Continue anyway as the image might still load
          }
        } else {
          throw Exception("No image URLs returned");
        }
      } catch (e) {
        log("Error generating image: $e");
        status.value = Status.none;
        MyDialog.error('Something went wrong (Try again in sometime)!');
      }
    } else {
      MyDialog.info('Provide some beautiful image description!');
    }
  }

  void downloadImage() async {
    try {
      // Show loading dialog
      MyDialog.showLoadingDialog();

      log('url: ${url.value}');

      final bytes = (await http.get(Uri.parse(url.value))).bodyBytes;
      final dir = await getTemporaryDirectory();

      final file = await File('${dir.path}/ai_image.png').writeAsBytes(bytes);

      log('filePath: ${file.path}');

      // Gallery saver is temporarily disabled
      // Save to downloads directly and notify user
      final downloadsDir = await getExternalStorageDirectory();
      final downloadFile = await File(
              '${downloadsDir?.path}/ai_image_${DateTime.now().millisecondsSinceEpoch}.png')
          .writeAsBytes(bytes);

      // Hide loading dialog
      Get.back();

      MyDialog.success('Image saved to: ${downloadFile.path}');
    } catch (e) {
      // Hide loading dialog
      Get.back();
      MyDialog.error('Something went wrong (Try again in sometime)!');
      log('downloadImageError: $e');
    }
  }

  void shareImage() async {
    try {
      // Show loading dialog
      MyDialog.showLoadingDialog();

      log('Sharing image URL: ${url.value}');

      final response = await http.get(Uri.parse(url.value));
      if (response.statusCode != 200) {
        throw Exception('Failed to download image: ${response.statusCode}');
      }

      final bytes = response.bodyBytes;
      final dir = await getTemporaryDirectory();
      final file = await File('${dir.path}/ai_image.png').writeAsBytes(bytes);

      log('Image saved to temporary file: ${file.path}');

      // Hide loading dialog
      Get.back();

      await Share.shareXFiles([XFile(file.path)],
          text:
              'Check out this Amazing Image created by Ai Assistant App by Harsh H. Rajpurohit');
    } catch (e) {
      // Hide loading dialog
      Get.back();
      MyDialog.error('Something went wrong (Try again in sometime)!');
      log('shareImageError: $e');
    }
  }

  Future<void> searchAiImage() async {
    // This is the main method now used for generating images
    if (textC.text.trim().isNotEmpty) {
      try {
        status.value = Status.loading;

        // Use our API to get relevant images
        imageList.value = await APIs.searchAiImages(textC.text);

        if (imageList.isEmpty) {
          log("No images returned from API");
          MyDialog.error('Something went wrong (Try again in sometime)');
          status.value = Status.none;
          return;
        }

        // Use the first image URL
        url.value = imageList.first;
        status.value = Status.complete;
        log("Successfully found images. Count: ${imageList.length}, First URL: ${url.value}");

        // Verify the URL works
        try {
          final response = await http.get(Uri.parse(url.value));
          if (response.statusCode != 200) {
            log("Warning: Image URL returned status: ${response.statusCode}");
          }
        } catch (e) {
          log("Warning: Error verifying image URL: $e");
          // Continue anyway as the image might still load
        }
      } catch (e) {
        log("Error searching for images: $e");
        status.value = Status.none;
        MyDialog.error('Something went wrong (Try again in sometime)');
      }
    } else {
      MyDialog.info('Provide some beautiful image description!');
    }
  }
}
