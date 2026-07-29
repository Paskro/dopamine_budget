import 'package:flutter/foundation.dart';
import '../../domain/entities/pin_state.dart';
import '../../domain/repositories/crypto_repository.dart';
import '../../domain/repositories/crypto_session_service.dart';

class PinNotifier extends ChangeNotifier {
  PinNotifier({
    required CryptoRepository cryptoRepository,
    required CryptoSessionService cryptoSessionService,
  })  : _cryptoRepository = cryptoRepository,
        _cryptoSessionService = cryptoSessionService {
    _init();
  }

  final CryptoRepository _cryptoRepository;
  final CryptoSessionService _cryptoSessionService;

  PinState _state = const PinState(status: PinFlowStatus.loading);
  PinState get state => _state;

  String? _firstPin;

  Future<void> _init() async {
    final rawKey = await _cryptoRepository.loadMasterKeyRaw();
    if (rawKey != null) {
      _cryptoSessionService.setKey(rawKey);
      _state = const PinState(status: PinFlowStatus.unlocked);
      notifyListeners();
      return;
    }

    final initialized = await _cryptoRepository.isMasterKeyInitialized();
    _state = PinState(
      status: initialized ? PinFlowStatus.needsUnlock : PinFlowStatus.needsSetup,
    );
    notifyListeners();
  }
  // ── Setup flow ─────────────────────────────────────────────────────────────

  void submitFirstPin(String pin) {
    _firstPin = pin;
    _state = _state.copyWith(status: PinFlowStatus.needsConfirm, errorMessage: null);
    notifyListeners();
  }

  void cancelConfirm() {
    _firstPin = null;
    _state = const PinState(status: PinFlowStatus.needsSetup);
    notifyListeners();
  }

  Future<void> submitConfirmPin(String pin) async {
    if (pin != _firstPin) {
      _firstPin = null;
      _state = PinState(
        status: PinFlowStatus.needsSetup,
        errorMessage: 'PIN-коды не совпадают',
      );
      notifyListeners();
      return;
    }

    await _cryptoRepository.generateAndStoreMasterKey(pin);
    final key = await _cryptoRepository.unlockMasterKey(pin);
    _firstPin = null;

    if (key == null) {
      _state = const PinState(
        status: PinFlowStatus.needsSetup,
        errorMessage: 'Ошибка генерации ключа. Попробуйте снова.',
      );
      notifyListeners();
      return;
    }

    await _cryptoRepository.saveMasterKeyRaw(key.bytes);
    _cryptoSessionService.setKey(key);
    _state = const PinState(status: PinFlowStatus.unlocked);
    notifyListeners();
  }

  // ── Unlock flow ────────────────────────────────────────────────────────────

  Future<void> submitUnlockPin(String pin) async {
    final key = await _cryptoRepository.unlockMasterKey(pin);

    if (key == null) {
      _state = PinState(
        status: PinFlowStatus.needsUnlock,
        errorMessage: 'Неверный PIN',
      );
      notifyListeners();
      return;
    }

    await _cryptoRepository.saveMasterKeyRaw(key.bytes);
    _cryptoSessionService.setKey(key);
    _state = const PinState(status: PinFlowStatus.unlocked);
    notifyListeners();
  }

  // ── Lock ───────────────────────────────────────────────────────────────────

  void lock() {
    _cryptoSessionService.clear();
    _state = const PinState(status: PinFlowStatus.needsUnlock);
    notifyListeners();
  }
}