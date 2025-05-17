import 'dart:developer';
import 'package:flutter/material.dart';

// Temporarily disabled Facebook Audience Network due to compatibility issues
// import 'package:easy_audience_network/easy_audience_network.dart';
// import 'package:get/get.dart';
// import 'my_dialog.dart';

class AdHelper {
  // Temporarily disabled initialization
  static void init() {
    // Removed EasyAudienceNetwork.init() call due to dependency issues
    log('Ad initialization disabled');
  }

  // Temporarily disabled interstitial ads
  static void showInterstitialAd(VoidCallback onComplete) {
    // Just call the completion callback immediately
    log('Interstitial ad disabled');
    onComplete();
  }

  // Temporarily disabled native ads
  static Widget nativeAd() {
    // Return an empty container instead of the ad
    return const SizedBox.shrink();
  }

  // Temporarily disabled native banner ads
  static Widget nativeBannerAd() {
    // Return an empty container instead of the ad
    return const SizedBox.shrink();
  }
}
