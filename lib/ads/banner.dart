import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  @override
  _BannerAdWidgetState createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test ad unit ID
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('Banner ad loaded');
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Banner ad failed to load: ${error.message}');
          ad.dispose();
        },
        onAdOpened: (Ad ad) {
          print('Banner ad opened');
        },
        onAdClosed: (Ad ad) {
          print('Banner ad closed');
        },
      ),
    );

    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: _bannerAd == null
          ? SizedBox()
          : AdWidget(ad: _bannerAd!),
    );
  }
}
