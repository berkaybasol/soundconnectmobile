import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/instrument_repository.dart';
import '../../data/models/instrument.dart';

final instrumentListProvider = FutureProvider<List<Instrument>>((ref) async {
  final repo = ref.watch(instrumentRepositoryProvider);
  return repo.getAll();
});
