import 'package:flutter/material.dart';
import '../models/sensor.dart';

class SensorCard extends StatelessWidget {
  final Sensor sensor;

  const SensorCard({
    super.key,
    required this.sensor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sensor.jenis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Lokasi: ${sensor.lokasi}'),
            Text(
              '${sensor.nilai} ${sensor.satuan}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}