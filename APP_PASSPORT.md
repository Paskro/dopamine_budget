# Dopamine Budget — Паспорт приложения v3.0
_Составлен: 08.08.2026. Источник: анализ кодовой базы Claude Code._

---

## 1. Архитектура

**Паттерн:** Feature-First + Clean Architecture  
**Слои внутри фичи:** `presentation/` → `domain/` → `data/`  
**Стейт:** Riverpod Notifier'ы  
**БД:** Drift/SQLite (`dopamine.db`, schemaVersion 16)  
**Бэкенд:** Supabase (Auth + PostgreSQL + Realtime)  
**Шифрование:** PBKDF2 + AES-GCM (title/titleNonce привычек)  

**Критические правила:**
- Время: ТОЛЬКО через `TimeProvider.now` — `DateTime.now()` в бизнес-логике запрещён
- Баланс: считается "на лету" SQL-запросом, хранение в стейте запрещено
- Push в Supabase: fire-and-forget через `_sync?.push...().catchError((_) {})`

---

## 2. Таблицы Drift (schemaVersion 16)

| Таблица | Ключевые колонки | Назначение |
|---|---|---|
| `SessionsTable` | phase, calibrationDays, avgScore, isDeleted, shrinking-поля, updatedAt | Ядро сессии |
| `HabitsTable` | title (шифр.), titleNonce, scoreValue, isArchived, userId | Справочник привычек |
| `SessionHabitsTable` | sessionId, habitId (UNIQUE pair) | Many-to-many сессия↔привычка |
| `HabitLogsTable` | habitId, sessionId, scoreCost, timestamp | Лог кликов по привычкам |
| `DaysTable` | date (PK, 'yyyy-MM-dd'), isBrokenClicked, isGoodBoyClicked, dayStatus | Запись дня |
| `ShrinkingPeriodsTable` | sessionId, startDate, targetPercent | Периоды сужения лимита |
| `ShrinkingReportsLogTable` | sessionId, weekNumber, reportDate | Лог еженедельных отчётов |
| `StreakTable` | currentStreak, currentMultiplier, previousMultiplier | Серии активности |

---

## 3. Use Cases (25 шт.)

### Habits
| Use Case | Назначение |
|---|---|
| `AddHabitUseCase` | Создать привычку + push habits/session_habits |
| `UpdateHabitUseCase` | Обновить привычку |
| `DeleteHabitUseCase` | Удалить привычку |
| `GetHabitsUseCase` | Получить список привычек |

### Scoring
| Use Case | Назначение |
|---|---|
| `GetCurrentDopamineBalanceUseCase` | Текущий баланс (с обнулением при срыве) |
| `GetDailyLimitUseCase` | Дневной лимит (avgScore - decreasePercentage) |
| `GetWeeklyHabitsReportUseCase` | Недельный отчёт по привычкам |
| `ToggleShrinkingModeUseCase` | Вкл/выкл режим усыхания + push shrinking_periods |

### Sessions
| Use Case | Назначение |
|---|---|
| `InitializeSessionUseCase` | Создать новую калибровочную сессию + push |
| `StartControlSessionUseCase` | Перевести сессию в фазу контроля + push |
| `StartControlSessionWithHabitsUseCase` | То же + привязка привычек |
| `VerifyCalibrationExpiryUseCase` | Проверить завершение калибровки + push |
| `ArchiveSessionUseCase` | Архивировать сессию + push |
| `DeleteSessionUseCase` | Soft-delete сессии (isDeleted=true) + push |
| `RecordActionUseCase` | Зафиксировать клик по привычке |
| `CheckAndGenerateWeeklyReportUseCase` | Генерация недельного отчёта |
| `CheckAndGenerateShrinkingReportUseCase` | Генерация отчёта усыхания |

### Auth
| Use Case | Назначение |
|---|---|
| `SendMagicLinkUseCase` | Отправить magic link |
| `SyncMasterKeyUseCase` | Синхронизировать мастер-ключ шифрования |
| `UploadMasterKeyUseCase` | Загрузить мастер-ключ (новый юзер) |

### Streak
| Use Case | Назначение |
|---|---|
| `SyncStreakUseCase` | Синхронизировать серию активности |

---

## 4. Presentation Layer

### Gates (маршрутизация верхнего уровня)
```
AppGate → OnboardingGate → RootGate
```
- **AppGate:** авторизация → синк → PIN-разблокировка. Вызывает `ActiveSessionService.activate()` после auth.
- **OnboardingGate:** проверяет `SyncPrefs.isOnboardingDone`. Первый запуск → онбординг.
- **RootGate:** роутер по `SessionsNotifier.phase`:
  - `null` → `SessionOnboardingScreen`
  - `phase=0` → `HomePage` (калибровка)
  - `phase=1` → `ControlScreen` (контроль)
  - Промежуточные: `CalibrationResultPage`, `ShrinkingReportPage`, `WeeklyReportPage`

### Ключевые Notifier'ы
| Notifier | Отвечает за |
|---|---|
| `SessionsNotifier` | Активная сессия, запуск калибровки/контроля |
| `ScoringNotifier` | Баланс/усыхание, защита от гонок (`_executionCounter`) |
| `ControlScreenNotifier` | Баланс/лимит/статус дня в фазе контроля, `errorEvents`-стрим |
| `HabitsNotifier` | CRUD привычек + привязка к сессии |
| `PinNotifier` | Флоу PIN: setup/confirm/unlock/unlocked |
| `AuthNotifier` | Логин, pull при входе, координация auth-флоу |

### Экраны
| Экран | Фаза | Размер/Особенности |
|---|---|---|
| `SessionOnboardingScreen` | — | Визард старта сессии |
| `HomePage` | Калибровка (phase=0) | Точки прогресса, список привычек |
| `ControlScreen` | Контроль (phase=1) | ~1430 строк: gauge, hold-кнопки, конфетти, блокировка при срыве |
| `CalibrationResultPage` | Переход 0→1 | Итоги калибровки |
| `SessionSettingsSheet` | — | Настройки усыхания + управление привычками |
| `ShrinkingReportPage` | Контроль | Отчёт по усыханию |
| `WeeklyReportPage` | Контроль | Недельный отчёт |
| `WeeklyDetailBottomSheet` | Контроль | Донат-чарт трат по привычкам |
| `PastSessionsScreen` | — | История сессий |
| `SessionSummaryScreen` | — | Итоги сессии |
| `ProfileScreen` | — | Профиль пользователя |
| `HabitManagementPage` | — | CRUD привычек (+ embedded-режим) |

---

## 5. Core модули

| Модуль | Назначение |
|---|---|
| `TimeProvider` | Виртуальное время для тестов/debug. Геттер `.now` — единственный источник времени |
| `SyncService` | Push/pull всех таблиц в Supabase (last-write-wins по `updated_at`) |
| `ActiveSessionService` | Supabase Realtime: детект входа с другого устройства |
| `CryptoRepository` | PBKDF2+AES-GCM шифрование title привычек |
| `HapticService` | Вибрация (пакет `vibration`) |
| `NotificationScheduler` | Планирование push-уведомлений |
| `NotificationPrefs` | Время уведомлений в SharedPreferences |
| `AppTheme` | Дизайн-система: цвета, типографика, 8pt grid |
| `DeveloperOverlay` | Debug-панель (сдвиг времени, экспорт БД) — закомментирована в RootGate |

---

## 6. Supabase таблицы

| Supabase таблица | Push | Pull | Статус |
|---|---|---|---|
| `sessions` | ✅ (после мутаций) | ✅ | OK после sprint fix |
| `habits` | ✅ | ✅ | OK |
| `session_habits` | ✅ | ✅ | OK |
| `habit_logs` | ✅ | ✅ | OK |
| `days` | ✅ | ✅ | OK |
| `shrinking_periods` | ✅ (после sprint fix) | ✅ | OK после sprint fix |
| `shrinking_reports_log` | ⚠️ нигде не вызывается | ✅ | Баг (e) |
| `streak` | ✅ | ✅ (после sprint fix) | OK после sprint fix |
| `user_profiles` | ⚠️ нигде не вызывается | ✅ | Баг (e) |
| `profiles` | через ProfilesRepositoryImpl | — | Отдельный механизм |
| `active_sessions` | через ActiveSessionService | — | Realtime, отдельный механизм |

---

## 7. Известные баги и технический долг

### Открытые баги
| # | Файл | Описание | Приоритет |
|---|---|---|---|
| f | `app_database.dart:181-197` | `watchActiveSession()`/`getActiveSessionId()` не фильтруют `isDeleted` — soft-deleted сессия может всплыть как активная | High |
| g | `sync_service.dart` | `pushShrinkingReportsLog()` определён, но нигде не вызывается | Medium |
| h | `sync_service.dart` | `pushUserProfile()` определён, но нигде не вызывается | Low |

### Закрытые баги (sprint 08.08.2026)
| # | Описание |
|---|---|
| a | ~~streak не пуллился~~ — добавлен `_pullStreak()` в `pullAll()` |
| b | ~~pushShrinkingPeriods не вызывался~~ — добавлен в `ToggleShrinkingModeUseCase` |
| c | ~~deleteSession жёсткий DELETE~~ — заменён на soft-delete + push |
| d | ~~pushSessions не вызывался после мутаций~~ — добавлен в 3 use case'а |

### Технический долг
| Файл | Проблема |
|---|---|
| `ControlScreen` | ~1430 строк — кандидат на декомпозицию |
| `session_mapper.dart` | `decrease_percentage`: в БД `double` (0.02=2%), в Entity `int` (2) — маппер не исправлен |
| `DeveloperOverlay` | Закомментирован в `RootGate:190-198` — решить: удалить или восстановить |

---

## 8. Pull вызывается только при логине

`auth_notifier.dart:64-73` — единственная точка входа `pullAll()`.  
Нет pull при: resume приложения, по таймеру, pull-to-refresh.  
Это архитектурное решение (намеренное или нет) — стоит обсудить.

