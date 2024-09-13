import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  // Rewarded Ad variables
  static RewardedAd? _rewardedAd;
  static bool _isRewardedAdLoaded = false;

  // Interstitial Ad variables
  static InterstitialAd? _interstitialAd;
  static bool _isInterstitialAdLoaded = false;

  //========================================== Rewarded Ad =========================================================

  // Method to load a rewarded ad
  static Future<void> loadRewardedAd() async {
    final adUnitId = _getRewardedAdUnitId();

    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdLoaded = false;
          _rewardedAd = null;
        },
      ),
    );
  }

  // Method to show a rewarded ad
  static void showRewardedAd(BuildContext context, VoidCallback onAdClosed) {
    if (_isRewardedAdLoaded && _rewardedAd != null) {
      _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
      }).then((_) {
        _rewardedAd!.dispose();
        _rewardedAd = null;
        _isRewardedAdLoaded = false;
        onAdClosed();
      }).catchError((error) {
        _rewardedAd!.dispose();
        _rewardedAd = null;
        _isRewardedAdLoaded = false;
        onAdClosed();
      });
    } else {
      onAdClosed();
    }
  }

  // Method to get a rewarded ad unit ID
  static String _getRewardedAdUnitId() {
    final adUnitIds = [
      'ca-app-pub-1594064189441475/3366915506',
      'ca-app-pub-1594064189441475/9381649773',
      'ca-app-pub-1594064189441475/7530346201',
    ];
    final adUnitId = (adUnitIds..shuffle()).first;
    return adUnitId;
  }

  //========================================== Interstitial Ad =========================================================

  // Method to load an interstitial ad
  static Future<void> loadInterstitialAd() async {
    final adUnitId = _getInterstitialAdUnitId();

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdLoaded = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  // Method to show an interstitial ad
  static void showInterstitialAd(BuildContext context, VoidCallback onAdClosed) {
    if (_isInterstitialAdLoaded && _interstitialAd != null) {
      _interstitialAd!.show().then((_) {
        _interstitialAd!.dispose();
        _interstitialAd = null;
        _isInterstitialAdLoaded = false;
        onAdClosed();
      }).catchError((error) {
        _interstitialAd!.dispose();
        _interstitialAd = null;
        _isInterstitialAdLoaded = false;
        onAdClosed();
      });
    } else {
      onAdClosed();
    }
  }

  // Method to get an interstitial ad unit ID
  static String _getInterstitialAdUnitId() {
    final adUnitIds = [
      'ca-app-pub-1594064189441475/4375992841',
      'ca-app-pub-1594064189441475/5244029994',
      'ca-app-pub-1594064189441475/5497502824',
      'ca-app-pub-1594064189441475/3363972114',
      'ca-app-pub-1594064189441475/2955099966',
    ];
    final adUnitId = (adUnitIds..shuffle()).first;
    return adUnitId;
  }
}
