import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ruta_app/edit_cash_screen/edit_screen.dart';
import 'package:ruta_app/home/components/add_cash.dart';
import 'package:ruta_app/home/components/mapa.dart';
import 'package:ruta_app/home/components/transaction_items.dart';
import '../controllers/balance_controller.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Banner de AdMob
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    // ID de prueba para banner de AdMob
    final adUnitId = 'ca-app-pub-3940256099942544/6300978111'; // ID de prueba oficial de Google

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Error al cargar el anuncio: ${error.message}');
        },
      ),
    );

    _bannerAd?.load();
  }
  // Use GetX controller instead of local state
  final BalanceController balanceController = Get.put(BalanceController());
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final RxBool _showBackToTopButton = false.obs;
  // Store the scroll controller as a class variable
  ScrollController? _listScrollController;
  // Reference to the MapaView
  MapaView? _mapaView;

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return difference.inDays == 1 ? 'Ayer' : 'Hace ${difference.inDays} días';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1
          ? 'Hace 1 hora'
          : 'Hace ${difference.inHours} horas';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1
          ? 'Hace 1 minuto'
          : 'Hace ${difference.inMinutes} minutos';
    } else {
      return 'Justo ahora';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Mapa como fondo
          Container(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                // Mapa como fondo (primer elemento para que esté en el background)
                Positioned.fill(
                  child: Builder(builder: (context) {
                    _mapaView = const MapaView();
                    return _mapaView!;
                  }),
                ),

                // Price Display centrado pero un poco arriba (segundo elemento para que esté sobre el mapa)
                Positioned(
                  top: 70,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Obx(() =>
                        PriceDisplay(amount: balanceController.balance.value)),
                  ),
                ),

                Positioned(
                    top: 150,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.inverseSurface,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 10.0),
                          child: Obx(() {
                            final availableTrips =
                                (balanceController.balance.value / 7.5).floor();
                            final tripText = availableTrips == 1
                                ? "Viaje disponible"
                                : "Viajes disponibles";
                            final color = availableTrips > 0
                                ? Colors.green
                                : Colors.orange;

                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.directions_car,
                                    color: color, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  "$availableTrips ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text("$tripText",
                                    style: TextStyle(
                                      color: const Color.fromARGB(
                                          255, 192, 192, 192),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    )),
                                if (availableTrips == 0) ...[
                                  const SizedBox(width: 8),
                                  Tooltip(
                                    message: "Necesitas recargar tu saldo",
                                    child: Icon(Icons.info_outline,
                                        color: Colors.orange, size: 18),
                                  )
                                ]
                              ],
                            );
                          }),
                        ),
                      ),
                    ))
              ],
            ),
          ),

          // Location button
          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).size.height *
                0.31, // Just above the sheet
            child: FloatingActionButton(
              heroTag: 'locationButton',
              backgroundColor: const Color(0xFF03788D),
              mini: true,
              onPressed: () {
                // Usar el controlador para centrar el mapa en la ubicación actual
                MapaController().goToCurrentLocation();
              },
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),

          // DraggableScrollableSheet for Actions section
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.29,
            minChildSize: 0.29,
            maxChildSize: 0.9,
            snap: true,
            snapSizes: const [0.30, 0.9],
            builder: (BuildContext context, ScrollController scrollController) {
              // Store the scroll controller for later use
              _listScrollController = scrollController;
              // Add listener to the scroll controller
              scrollController.addListener(() {
                // Check if scrolled to the bottom
                if (scrollController.position.pixels >=
                        scrollController.position.maxScrollExtent - 50 &&
                    !_showBackToTopButton.value) {
                  _showBackToTopButton.value = true;
                } else if (scrollController.position.pixels <
                        scrollController.position.maxScrollExtent - 50 &&
                    _showBackToTopButton.value) {
                  _showBackToTopButton.value = false;
                }
              });

              return Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: ListView(
                  controller: scrollController,
                  children: [
                    // Handle indicator
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 1),
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade600,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // Title
                    Padding(
                      padding: EdgeInsets.only(right: 5, left: 5, top: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TransactionItem(
                                title: 'Nuevo Viaje',
                                subtitle: 'Hoy',
                                amount: -7.5,
                                icon: Icons.directions_bus,
                                isClickable: true),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: AddCash(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    Divider(
                      color: Colors.grey.shade800,
                      thickness: 2,
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Historial",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19.2,
                                fontWeight: FontWeight.bold,
                              )),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward,
                                size: 24,
                                color: Color.fromARGB(255, 134, 134, 134)),
                            onPressed: () {
                              // Add edit functionality here
                              _sheetController.animateTo(
                                0.9, // Tamaño máximo
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Transaction list - dynamically updated
                    Obx(() => balanceController.transactions.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                'No hay transacciones todavía',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount:
                                min(balanceController.transactions.length, 8),
                            itemBuilder: (context, index) {
                              // Get transaction data in reverse order (newest first)
                              final transaction =
                                  balanceController.transactions[
                                      balanceController.transactions.length -
                                          1 -
                                          index];
                              final DateTime transactionDate =
                                  DateTime.parse(transaction['date']);
                              final String timeAgo =
                                  _getTimeAgo(transactionDate);

                              // Convert icon string to IconData
                              IconData transactionIcon =
                                  Icons.account_balance_wallet;
                              if (transaction['icon'] == 'directions_bus') {
                                transactionIcon = Icons.directions_bus;
                              }

                              return TransactionItem(
                                title: transaction['type'] == 'VIAJE'
                                    ? 'Viaje'
                                    : 'Recarga',
                                subtitle: timeAgo,
                                amount: transaction['amount'],
                                icon: transactionIcon,
                                isClickable: false,
                              );
                            },
                          )),
                  ],
                ),
              );
            },
          ),

          // Back to top button
          Obx(() => Positioned(
                bottom: 20,
                right: 20,
                child: AnimatedOpacity(
                  opacity: _showBackToTopButton.value ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: _showBackToTopButton.value
                      ? FloatingActionButton(
                          mini: true,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          onPressed: () {
                            // First collapse the draggable sheet
                            _sheetController
                                .animateTo(
                              0.29, // The minChildSize value
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            )
                                .then((_) {
                              // After the sheet is collapsed, reset the internal scroll position with animation
                              // This ensures the content is fully reset to its initial state with a smooth transition
                              if (_listScrollController != null) {
                                _listScrollController!.animateTo(
                                  0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              }
                            });
                          },
                          child: const Icon(
                            Icons.arrow_upward,
                            color: Colors.white,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              )),

          // Bottom action buttons
        ],
      ),
      bottomNavigationBar: _isAdLoaded
          ? SizedBox(
              height: _bannerAd!.size.height.toDouble(),
              width: _bannerAd!.size.width.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          : null,
      // bottomNavigationBar: const BottomActionButtons(currentPage: NavigationPage.home),
    );
  }
}

// Price display component
class PriceDisplay extends StatelessWidget {
  final double amount;

  const PriceDisplay({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inverseSurface,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.attach_money,
            color: const Color.fromARGB(255, 255, 255, 255),
            size: 35,
          ),
          Text(
            '${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit,
                size: 24, color: Color.fromARGB(255, 134, 134, 134)),
            onPressed: () {
              Get.to(() => const EditScreen());
              // Add edit functionality here
            },
          ),
        ],
      ),
    );
  }
}
