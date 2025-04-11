import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class NativeAdWidget extends StatefulWidget {
  final String adUnitId;
  final double height;

  const NativeAdWidget({
    super.key,
    required this.adUnitId,
    this.height = 200.0,
  });

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    print('Intentando cargar anuncio nativo con ID: ${widget.adUnitId}');
    _nativeAd = NativeAd(
      adUnitId: widget.adUnitId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          print('Anuncio nativo cargado correctamente');
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          // Dispose the ad here to free resources
          ad.dispose();
          print(
              'Error al cargar el anuncio: ${error.message}, código: ${error.code}');
          // Intentar cargar un anuncio de prueba si falla
          _loadTestAd();
        },
        onAdOpened: (ad) => print('Anuncio abierto'),
        onAdClosed: (ad) => print('Anuncio cerrado'),
        onAdImpression: (ad) => print('Impresión de anuncio registrada'),
      ),
      request: const AdRequest(),
      // Factoryid para anuncios nativos en Android
      factoryId: 'listTile',
    );

    _nativeAd!.load();
  }

  // Cargar un anuncio de prueba si el anuncio real falla
  void _loadTestAd() {
    print('Intentando cargar anuncio de prueba');
    // ID de anuncio de prueba para anuncios nativos
    const String testAdUnitId = 'ca-app-pub-3940256099942544/2247696110';

    _nativeAd = NativeAd(
      adUnitId: testAdUnitId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          print('Anuncio de prueba cargado correctamente');
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print(
              'Error al cargar el anuncio de prueba: ${error.message}, código: ${error.code}');
        },
      ),
      request: const AdRequest(),
      // Factoryid para anuncios nativos en Android
      factoryId: 'listTile',
    );

    _nativeAd!.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded) {
      return Container(
        height: widget.height * 0.8, // Altura reducida para el estado de carga
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    return Container(
      height: widget.height,
      alignment: Alignment.center,
      child: AdWidget(ad: _nativeAd!),
    );
  }
}
