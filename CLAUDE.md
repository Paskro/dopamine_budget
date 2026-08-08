# Dopamine Budget — контекст для Claude Code

## Архитектура
- Feature-First + Clean Architecture: `lib/features/<фича>/data|domain|presentation`
- Время: ТОЛЬКО через `TimeProvider.now` — `DateTime.now()` в бизнес-логике запрещён
- Баланс: считается "на лету" SQL-запросом, хранение в стейте запрещено

## База данных (Drift, schemaVersion 16)
| Таблица | Назначение |
|---|---|
| SessionsTable | ядро сессии: phase, calibrationDays, shrinking-поля, isDeleted |
| HabitsTable | привычки (title шифруется) |
| SessionHabitsTable | many-to-many сессия↔привычка |
| HabitLogsTable | лог кликов по привычкам |
| DaysTable | запись дня: isBrokenClicked, isGoodBoyClicked, dayStatus |
| ShrinkingPeriodsTable | периоды сужения лимита |
| ShrinkingReportsLogTable | лог еженедельных shrinking-отчётов |
| StreakTable | серии активности и множители |

## Supabase sync (lib/core/sync/sync_service.dart)
- Push: читает всю таблицу целиком и upsert'ит (нет диффа)
- Pull (pullAll): last-write-wins по updated_at, параллельно
- Pull вызывается ТОЛЬКО при логине (auth_notifier.dart:64-73)
- Push разбросан по use case'ам как fire-and-forget

## Статус после cleanup (коммит от 08.08.2026)
Удалены как dead code:
- `features/scoring/domain/usecases/calculate_score_usecase.dart`
- `features/sessions/domain/usecases/calculate_score_usecase.dart`
- `data/db/actions_table.dart`
- `features/scoring/data/tables/daily_entries_table.dart`
- `flutter analyze` чист: No issues found

## Известные баги синхронизации (приоритет текущего спринта)

### КРИТИЧЕСКИЕ
**a) streak не пуллится** — `_pullStreak()` отсутствует, в `pullAll()` не входит.
После смены устройства/переустановки streak обнуляется локально.

**b) pushShrinkingPeriods() / pushShrinkingReportsLog() не вызываются нигде**
Методы определены в SyncService, но grep по lib/ не находит ни одного вызова.
`ToggleShrinkingModeUseCase` пишет в таблицы напрямую без push.

**c) deleteSession() — жёсткий DELETE вместо soft-delete**
`session_repository_impl.dart:472-476` делает `_db.delete()` напрямую.
Колонка `isDeleted` есть в схеме и в push/pull логике — но не используется при удалении.
Результат: удалённая сессия "воскресает" после pullAll() на другом устройстве.

### НЕКРИТИЧЕСКИЕ
**d) pushSessions() вызывается только в StartControlSessionUseCase**
Не пушатся: переход калибровка→контроль (VerifyCalibrationExpiryUseCase),
создание сессии (InitializeSessionUseCase), архивирование (ArchiveSessionUseCase),
изменение shrinking (ToggleShrinkingModeUseCase).

**e) pushUserProfile() определён, но нигде не вызывается**
display_name пуллится, но загрузить наверх нельзя.

## Правила работы
- Локальный рефакторинг: возвращай только изменённый метод, не весь класс
- Не выдумывай структуры которых не видел — запроси файл
- После каждого изменения: `flutter analyze`
- Коммит после каждой завершённой задачи
