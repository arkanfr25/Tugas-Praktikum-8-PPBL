import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/theme_cubit.dart';
import '../db/database_helper.dart';
import '../models/pembacaan_sensor.dart';
import '../models/sensor.dart';
import '../widgets/sensor_card.dart';
import '../widgets/theme_toggle_button.dart';
import 'halaman_riwayat.dart';

class HalamanSensor extends StatefulWidget {
  const HalamanSensor({super.key});

  @override
  State<HalamanSensor> createState() => _HalamanSensorState();
}

class _HalamanSensorState extends State<HalamanSensor> {
  late Future<List<PembacaanSensor>> _dataSensor;

  final List<Sensor> daftarSensor = const [
    Sensor(
      id: '1',
      jenis: 'Ketinggian Air',
      lokasi: 'Pos Sungai A',
      nilai: 0,
      satuan: 'cm',
    ),
    Sensor(
      id: '2',
      jenis: 'Pergeseran Tanah',
      lokasi: 'Pos Pemantauan B',
      nilai: 0,
      satuan: 'mm',
    ),
    Sensor(
      id: '3',
      jenis: 'Curah Hujan',
      lokasi: 'Pos Hujan C',
      nilai: 0,
      satuan: 'mm',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _dataSensor = DatabaseHelper.instance.ambilSemuaPembacaan();
  }

  void muatUlang() {
    setState(() {
      _dataSensor = DatabaseHelper.instance.ambilSemuaPembacaan();
    });
  }

  // Menentukan status berdasarkan nilai sensor.
  String statusSensor(String jenis, double nilai) {
    if (jenis == 'Ketinggian Air') {
      if (nilai >= 150) return 'Siaga';
      if (nilai >= 100) return 'Waspada';
    } else if (jenis == 'Pergeseran Tanah') {
      if (nilai >= 10) return 'Siaga';
      if (nilai >= 5) return 'Waspada';
    } else if (jenis == 'Curah Hujan') {
      if (nilai >= 50) return 'Siaga';
      if (nilai >= 20) return 'Waspada';
    }

    return 'Aman';
  }

  // Mengambil status tertinggi dari pembacaan terbaru setiap sensor.
  String statusKeseluruhan(List<PembacaanSensor> data) {
    final Map<String, PembacaanSensor> terbaru = {};

    for (final item in data) {
      if (!terbaru.containsKey(item.jenisSensor)) {
        terbaru[item.jenisSensor] = item;
      }
    }

    int tingkat = 0;

    for (final item in terbaru.values) {
      final status = statusSensor(item.jenisSensor, item.nilai);

      if (status == 'Waspada' && tingkat < 1) {
        tingkat = 1;
      } else if (status == 'Siaga') {
        tingkat = 2;
      }
    }

    if (tingkat == 2) return 'Siaga';
    if (tingkat == 1) return 'Waspada';
    return 'Aman';
  }

  Color warnaStatus(String status) {
    if (status == 'Siaga') return Colors.red;
    if (status == 'Waspada') return Colors.orange;
    return Colors.green;
  }

  // Menampilkan dialog untuk memasukkan nilai sensor.
  Future<void> inputPembacaan(Sensor sensor) async {
    final controller = TextEditingController();

    final nilai = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Input ${sensor.jenis}'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: InputDecoration(
              labelText: 'Nilai (${sensor.satuan})',
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final hasil = double.tryParse(
                  controller.text.replaceAll(',', '.'),
                );

                if (hasil != null && hasil >= 0) {
                  Navigator.pop(dialogContext, hasil);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (nilai == null) return;

    final pembacaan = PembacaanSensor(
      jenisSensor: sensor.jenis,
      nilai: nilai,
      lokasiPos: sensor.lokasi,
      waktu: DateTime.now().toIso8601String(),
    );

    await DatabaseHelper.instance.tambahPembacaan(pembacaan);

    if (!mounted) return;

    muatUlang();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pembacaan sensor berhasil disimpan'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        context.watch<ThemeCubit>().state == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AIoT Peringatan Dini'),
        actions: [
          ThemeToggleButton(
            isDark: isDark,
            onPressed: () {
              context.read<ThemeCubit>().ubahTema();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<PembacaanSensor>>(
        future: _dataSensor,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Terjadi kesalahan: ${snapshot.error}'),
            );
          }

          final data = snapshot.data ?? [];
          final status = statusKeseluruhan(data);

          return RefreshIndicator(
            onRefresh: () async => muatUlang(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: warnaStatus(status).withValues(alpha: 0.15),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        const Text(
                          'STATUS PERINGATAN',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: warnaStatus(status),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Berdasarkan pembacaan terbaru di database',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Daftar Sensor',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                ...daftarSensor.map((sensor) {
                  final pembacaan = data.firstWhere(
                    (item) => item.jenisSensor == sensor.jenis,
                    orElse: () => PembacaanSensor(
                      jenisSensor: sensor.jenis,
                      nilai: sensor.nilai,
                      lokasiPos: sensor.lokasi,
                      waktu: '-',
                    ),
                  );

                  final sensorTampil = Sensor(
                    id: sensor.id,
                    jenis: sensor.jenis,
                    lokasi: sensor.lokasi,
                    nilai: pembacaan.nilai,
                    satuan: sensor.satuan,
                  );

                  return Column(
                    children: [
                      SensorCard(sensor: sensorTampil),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => inputPembacaan(sensor),
                          icon: const Icon(Icons.save),
                          label: const Text('Input Pembacaan Sensor'),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }),

                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HalamanRiwayat(),
                      ),
                    ).then((_) => muatUlang());
                  },
                  icon: const Icon(Icons.history),
                  label: const Text('Lihat Riwayat Pembacaan'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}