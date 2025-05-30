import '../models/settings.dart';
import '../repositories/settings_repository.dart';

class SettingsService {
  static SettingsService? _instance;
  late final SettingsRepository _settingsRepository;

  SettingsService._internal();

  static Future<SettingsService> getInstance() async {
    if (_instance == null) {
      final service = SettingsService._internal();
      service._settingsRepository = await SettingsRepository.getInstance();
      _instance = service;
    }
    return _instance!;
  }

  Future<void> updateSettings(Settings settings) async {
    await _settingsRepository.updateSettings(settings);
  }

  Future<Settings?> getSettingsForGame(int gameId) async {
    return await _settingsRepository.getSettings(gameId);
  }
}
