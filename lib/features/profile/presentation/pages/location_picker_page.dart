import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/shared/widgets/custom_button.dart';

class LocationResult {
  final LatLng coordinates;
  final String address;
  final String city;

  LocationResult(
      {required this.coordinates, required this.address, required this.city});
}

// --- PERUBAHAN DI SINI ---
class LocationPickerPage extends StatefulWidget {
  // Tambahkan parameter opsional untuk lokasi awal
  final LatLng? initialLocation;

  // Ubah constructor untuk menerima parameter
  const LocationPickerPage({super.key, this.initialLocation});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}
// --- AKHIR PERUBAHAN ---

class _LocationPickerPageState extends State<LocationPickerPage> {
  final MapController _mapController = MapController();
  LatLng? _selectedLocation;
  String _selectedAddress =
      'Ketuk peta untuk memilih lokasi atau gunakan lokasi saat ini.';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Gunakan lokasi awal dari widget.initialLocation jika ada
    _selectedLocation =
        widget.initialLocation ?? const LatLng(-6.2088, 106.8456);
    if (widget.initialLocation != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _getAddressFromLatLng(_selectedLocation!);
      });
    }
  }

  Future<void> _handleTap(TapPosition tapPosition, LatLng point) async {
    setState(() {
      _selectedLocation = point;
      _isLoading = true;
      _selectedAddress = 'Mencari alamat...';
    });
    await _getAddressFromLatLng(point);
  }

  Future<void> _getAddressFromLatLng(LatLng point) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(point.latitude, point.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final addressLine =
            '${p.street}, ${p.subLocality}, ${p.locality}, ${p.subAdministrativeArea}, ${p.administrativeArea} ${p.postalCode}'
                .replaceAll(' ,', '')
                .replaceAll(', ,', ',');
        setState(() {
          _selectedAddress = addressLine;
        });
      }
    } catch (e) {
      setState(() {
        _selectedAddress = 'Gagal mendapatkan alamat. Coba lagi.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Layanan lokasi tidak aktif.')));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Izin lokasi ditolak.')));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Izin lokasi ditolak permanen, harap aktifkan di pengaturan.')));
      return;
    }

    setState(() => _isLoading = true);
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final currentLatLng = LatLng(position.latitude, position.longitude);

    _mapController.move(currentLatLng, 15.0);
    setState(() {
      _selectedLocation = currentLatLng;
      _selectedAddress = 'Mencari alamat...';
    });
    await _getAddressFromLatLng(currentLatLng);
  }

  void _confirmLocation() {
    if (_selectedLocation != null && !_isLoading) {
      placemarkFromCoordinates(
              _selectedLocation!.latitude, _selectedLocation!.longitude)
          .then((placemarks) {
        String city = placemarks.isNotEmpty
            ? (placemarks.first.subAdministrativeArea ??
                placemarks.first.locality ??
                '')
            : '';
        final result = LocationResult(
          coordinates: _selectedLocation!,
          address: _selectedAddress,
          city: city,
        );
        Navigator.of(context).pop(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation!,
              initialZoom: 15.0,
              onTap: _handleTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.satulemari',
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 80,
                      height: 80,
                      child: const Icon(Icons.location_pin,
                          color: AppColors.premium, size: 50),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16)
                  .copyWith(bottom: MediaQuery.of(context).padding.bottom + 16),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(blurRadius: 10, color: Colors.black12)
                  ]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ))
                      : Text(_selectedAddress,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Konfirmasi Lokasi Ini',
                    onPressed: (_selectedLocation == null || _isLoading)
                        ? null
                        : _confirmLocation,
                  )
                ],
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              backgroundColor: AppColors.surface,
              heroTag: 'currentLocationFab',
              child: const Icon(Icons.my_location, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
