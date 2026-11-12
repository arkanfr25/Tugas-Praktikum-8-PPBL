import 'package:flutter_bloc/flutter_bloc.dart';
import '../db/database_helper.dart';
import '../models/pembacaan_sensor.dart';

class SensorCubit extends Cubit<List<PembacaanSensor>> {
  SensorCubit() : super([]);

  // Mengambil data pembacaan dari database
  Future<void> ambilData() async {
    final data =
        await DatabaseHelper.instance.ambilSemuaPembacaan();

    emit(data);
  }

  // Menambahkan pembacaan sensor
  Future<void> tambahData(PembacaanSensor data) async {
    await DatabaseHelper.instance.tambahPembacaan(data);
    await ambilData();
  }

  // Mengubah pembacaan sensor
  Future<void> ubahData(PembacaanSensor data) async {
    await DatabaseHelper.instance.ubahPembacaan(data);
    await ambilData();
  }

  // Menghapus pembacaan sensor
  Future<void> hapusData(int id) async {
    await DatabaseHelper.instance.hapusPembacaan(id);
    await ambilData();
  }
}