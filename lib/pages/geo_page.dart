import 'package:atividade_images/componentes/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:atividade_images/services/location_service.dart';

class GeoPage extends StatefulWidget {
  const GeoPage({super.key});

  @override
  State<GeoPage> createState() => _GeoPageState();
}

class _GeoPageState extends State<GeoPage> {
  Position? _currentPosition;
  String? _locationError;
  bool _isLoading = true;

  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();

  static const fallbackLat = -23.5505;
  static const fallbackLng = -46.6333;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _isLoading = true;
      _locationError = null;
    });

    try {
      final pos = await _locationService.determinePosition();
      setState(() {
        _currentPosition = pos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _locationError = e.toString().replaceFirst("Exception: ", "");
        _isLoading = false;
      });

      _currentPosition ??= Position.fromMap({
        'latitude': fallbackLat,
        'longitude': fallbackLng,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = LatLng(
      _currentPosition?.latitude ?? fallbackLat,
      _currentPosition?.longitude ?? fallbackLng,
    );

    Widget content;

    if (_isLoading && _currentPosition == null) {
      content = const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text("Carregando localização..."),
          ],
        ),
      );
    } else if (_locationError != null) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 10),
              Text(
                "Erro: $_locationError",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchLocation,
                child: const Text("Tentar novamente"),
              ),
            ],
          ),
        ),
      );
    } else {
      content = FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: center,
          initialZoom: 15,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: "com.example.atividade_images",
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: center,
                width: 80,
                height: 80,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Scaffold(
main
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

      body: Column(
        children: [
          const Header(), // SEU COMPONENTE NO TOPO 🎯
          Expanded(
            child: content, // mapa/tela de erro/tela de loading
          ),
        ],
main
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _fetchLocation,
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.refresh),
      ),
    );
  }
}
