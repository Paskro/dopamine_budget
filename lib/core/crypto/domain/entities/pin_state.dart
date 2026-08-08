enum PinFlowStatus {
  loading,
  needsSetup,      // первый запуск — нет MasterKey
  needsConfirm,    // PIN введён, ждём повтор
  needsUnlock,     // MasterKey есть, ждём PIN
  unlocked,        // MasterKey в CryptoSessionService
  error,           // неверный PIN или несовпадение при подтверждении
}

class PinState {
  final PinFlowStatus status;
  final String? errorMessage;

  const PinState({required this.status, this.errorMessage});

  PinState copyWith({PinFlowStatus? status, String? errorMessage}) => PinState(
    status: status ?? this.status,
    errorMessage: errorMessage,
  );
}