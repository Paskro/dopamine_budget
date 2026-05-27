class SessionMapper {
  static SessionEntity fromDb(SessionsTableData data) {
    return SessionEntity(
      id: data.id,
      phase: data.phase == 0 ? SessionPhase.stats : SessionPhase.control,
      // ...
    );
  }
}