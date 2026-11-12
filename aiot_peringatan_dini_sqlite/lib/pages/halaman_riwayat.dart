import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/pembacaan_sensor.dart';

class HalamanRiwayat extends StatefulWidget {
  const HalamanRiwayat({super.key});

  @override
  State<HalamanRiwayat> createState() => _HalamanRiwayatState();
}

class _HalamanRiwayatState extends State<HalamanRiwayat> {
  late Future<List<PembacaanSensor>> _riwayat;

  @override
  void initState() {
    super.initState();
    muatRiwayat();
  }

  void muatRiwayat() {
    _riwayat = DatabaseHelper.instance.ambilSemuaPembacaan();
  }

  Future<void> ubahData(PembacaanSensor data) async {
    final controller = TextEditingController(
      text: data.nilai.toString(),
    );

    final nilaiBaru = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Pembacaan'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          decoration: const InputDecoration(
            labelText: 'Nilai sensor',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final nilai = double.tryParse(
                controller.text.replaceAll(',', '.'),
              );

              if (nilai != null && nilai >= 0) {
                Navigator.pop(context, nilai);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (nilaiBaru == null) return;

    await DatabaseHelper.instance.ubahPembacaan(
      PembacaanSensor(
        id: data.id,
        jenisSensor: data.jenisSensor,
        nilai: nilaiBaru,
        lokasiPos: data.lokasiPos,
        waktu: data.waktu,
      ),
    );

    if (!mounted) return;

    setState(muatRiwayat);
  }

  Future<void> hapusData(int id) async {
    await DatabaseHelper.instance.hapusPembacaan(id);

    if (!mounted) return;

    setState(muatRiwayat);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data berhasil dihapus'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pembacaan Sensor'),
      ),
      body: FutureBuilder<List<PembacaanSensor>>(
        future: _riwayat,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(
              child: Text('Belum ada riwayat pembacaan sensor'),
            );
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];

              return Dismissible(
                key: ValueKey(item.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (_) => hapusData(item.id!),
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(item.jenisSensor),
                    subtitle: Text(
                      'Lokasi: ${item.lokasiPos}\n'
                      'Waktu: ${item.waktu}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.nilai.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => ubahData(item),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}