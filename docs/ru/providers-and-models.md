# Настройка провайдеров и моделей

Это руководство описывает настройку нескольких OpenAI-совместимых провайдеров, скрытие информации о провайдерах и управление ключами API в файлах `.env`.

## Обзор

Pi поддерживает три механизма настройки провайдеров:

1. **`models.json`** — встроенный нативный формат. Не требует расширений. **Рекомендуемый.**
2. **`custom-providers.json`** — альтернативный формат через расширение `@esuyo/pi-esuyo-custom-provider`.
3. **`pi.registerProvider()`** — программный подход для TypeScript-расширений.

Для большинства случаев достаточно `models.json`. Он официальный, документирован и поддерживается сторонними утилитами.

## Интерполяция переменных окружения

Pi поддерживает интерполяцию переменных окружения **только** в значениях полей:

| Поле | Поддерживает `$VAR`? |
|------|---------------------|
| `apiKey` | ✅ Да |
| `headers` values | ✅ Да |
| `baseUrl` | ❌ **Нет** |
| Ключ провайдера (`"my-provider"`) | ❌ **Нет** (JSON ключ, не значение) |
| `defaultModel` в settings.json | ❌ **Нет** |
| `defaultProvider` в settings.json | ❌ **Нет** |

Это означает, что нельзя скрыть URL корпоративного провайдера через `$VAR` в `baseUrl`.

Для управления URL эндпойнтов и других неинтерполируемых значений редактируйте `models.json` напрямую, используйте расширение Pi или внешний инструмент. См. [Расширения для провайдеров](provider-extensions.md) для доступных вариантов.

## Синтаксис API-ключей

Все файлы конфигурации провайдеров поддерживают одинаковое разрешение значений `apiKey`:

| Синтаксис | Поведение | Пример |
|-----------|-----------|--------|
| `$ENV_VAR` | Читает из переменной окружения | `"$OPENROUTER_API_KEY"` |
| `${ENV_VAR}` | Читает из переменной окружения | `"${OPENROUTER_API_KEY}"` |
| `!command` | Выполняет команду, stdout = значение | `"!op read 'op://vault/key'"` |
| `$$` | Литеральный знак доллара | `"$$literal-dollar"` |
| `$!` | Литеральный восклицательный знак | `"$!literal-exclaim"` |
| Строка без префикса | Используется как есть | `"sk-literal-key"` |

Тот же синтаксис применим к значениям `headers`.

## Подход A: Нативный `models.json` (Без Расширений)

Это простейший подход. Pi читает определения провайдеров из `~/.pi/agent/models.json` (или `models.json` профиля при использовании `PI_CODING_AGENT_DIR`).

### Конфигурация

```json
{
  "providers": {
    "my-openrouter": {
      "baseUrl": "https://openrouter.ai/api/v1",
      "api": "openai-completions",
      "apiKey": "$OPENROUTER_API_KEY",
      "models": [
        {
          "id": "anthropic/claude-sonnet-4-5",
          "name": "Claude Sonnet 4.5",
          "reasoning": true,
          "input": ["text", "image"],
          "contextWindow": 200000,
          "maxTokens": 64000,
          "cost": { "input": 3, "output": 15, "cacheRead": 0.3, "cacheWrite": 3.75 }
        }
      ]
    },
    "my-deepseek": {
      "baseUrl": "https://api.deepseek.com/v1",
      "api": "openai-completions",
      "apiKey": "$DEEPSEEK_API_KEY",
      "models": [
        {
          "id": "deepseek-chat",
          "name": "DeepSeek Chat",
          "reasoning": false,
          "input": ["text"],
          "contextWindow": 128000,
          "maxTokens": 8192,
          "cost": { "input": 0.14, "output": 0.28, "cacheRead": 0, "cacheWrite": 0 }
        }
      ]
    },
    "local-ollama": {
      "baseUrl": "http://localhost:11434/v1",
      "api": "openai-completions",
      "apiKey": "ollama",
      "models": [
        { "id": "llama3.2" },
        { "id": "qwen2.5-coder:32b" }
      ]
    }
  }
}
```

### Загрузка Переменных Окружения

Pi не загружает файлы `.env` автоматически. Есть два варианта:

**Вариант 1: Экспорт в профиле shell**

Добавьте в `~/.bashrc` или `~/.zshrc`:

```bash
export OPENROUTER_API_KEY="sk-or-v1-..."
export DEEPSEEK_API_KEY="sk-..."
```

Перезапустите терминал или выполните `source ~/.bashrc`.

**Вариант 2: pique загружает `.env` автоматически**

Скрипт `bin/pique` загружает `.env` файлы до запуска Pi:

```bash
# Из директории профиля (высший приоритет)
profiles/custom-providers/.env

# Из корня репозитория (fallback)
$PIQUE_ROOT/.env
```

Существующие переменные shell никогда не перезаписываются. Можно переопределить значения из `.env` из командной строки:

```bash
OPENROUTER_API_KEY=temp-key pique custom-providers
```

См. [Скрипт pique](pique-script.md) для деталей.

### Преимущества

- Не требует расширений.
- Работает с профилями pique из коробки.
- Полный контроль над определениями провайдеров и моделей.
- Перезагружается при `/model` — не нужен рестарт.

### Недостатки

- Нет автоматического обнаружения моделей (нужно перечислять все).
- Встроенные провайдеры всё равно появляются, если их env vars установлены.

## Подход B: `models.json` + Расширение `pi-dotenv`

Расширение `pi-dotenv` загружает `~/.pi/agent/.env` в `process.env` при старте Pi. Полезно, если вы запускаете Pi без pique.

### Установка

```bash
pi install npm:pi-dotenv
```

Или добавьте в `settings.json`:

```json
{
  "packages": ["npm:pi-dotenv"]
}
```

**Важно:** Для расширений, которые читают `process.env` во время загрузки (не в обработчиках событий), `pi-dotenv` должен загружаться первым. Поставьте его первым в массиве `packages`.

### Создайте `.env`

```env
# ~/.pi/agent/.env (или .env профиля)
OPENROUTER_API_KEY=sk-or-v1-...
DEEPSEEK_API_KEY=sk-...
OLLAMA_API_KEY=ollama
```

### Как Это Работает

- Загружает файл `.env`, когда Pi загружает расширение.
- Никогда не перезаписывает переменные окружения, уже установленные в shell.
- Использует `@dotenvx/dotenvx` внутри.
- Перезагружается при каждом `session_start` (подхватывает изменения между `/new`, `/resume`, `/fork`).

### Преимущества

- Автоматическая загрузка `.env`.
- Не нужен ручной `export`.
- Существующие переменные shell имеют приоритет.

### Недостатки

- Требует одно расширение.
- Расположение `.env` фиксировано (`~/.pi/agent/.env` или `.env` профиля).

## Подход C: `models.json` + Расширение `@pi-lab/env`

Похоже на `pi-dotenv`, но также поддерживает переменные окружения в `settings.json`.

### Установка

```bash
pi install npm:@pi-lab/env
```

### Конфигурация

**В `settings.json`:**

```json
{
  "env": {
    "HTTP_PROXY": "http://127.0.0.1:7890",
    "OPENAI_API_KEY": "...",
    "INTERNAL_TOKEN": "..."
  }
}
```

**Или в `~/.pi/agent/.env`:**

```env
HTTP_PROXY=http://127.0.0.1:7890
OPENAI_API_KEY=...
INTERNAL_TOKEN=...
```

### Преимущества

- Два источника конфигурации (`settings.json` и `.env`).
- Значения env из `settings.json` имеют приоритет над значениями из `.env`.
- Доверенные проекты могут переопределять в `.pi/settings.json`.

### Недостатки

- Требует одно расширение.
- То же фиксированное расположение `.env`.

## Подход D: `custom-providers.json` + `@esuyo/pi-esuyo-custom-provider`

Это расширение предоставляет альтернативный JSON-формат с дополнительными функциями.

### Установка

```bash
pi install npm:@esuyo/pi-esuyo-custom-provider
```

### Конфигурация

Создайте `~/.pi/agent/custom-providers.json`:

```json
{
  "providers": [
    {
      "name": "my-openrouter",
      "label": "OpenRouter",
      "baseUrl": "https://openrouter.ai/api/v1",
      "apiKey": "$OPENROUTER_API_KEY",
      "fetchModels": true
    },
    {
      "name": "my-gateway",
      "label": "Корпоративный Шлюз",
      "baseUrl": "https://api.my-gateway.com/v1",
      "apiKey": "$GATEWAY_API_KEY",
      "models": [
        { "id": "gpt-4o", "name": "GPT-4o" },
        { "id": "claude-3-5-sonnet", "name": "Claude 3.5 Sonnet" }
      ]
    }
  ]
}
```

### Ключевые Функции

| Функция | Описание |
|---------|----------|
| `fetchModels` | Автоматически обнаруживает модели через `{baseUrl}/models` |
| Дефолты на уровне провайдера | Установите `contextWindow` и `maxTokens` один раз для всех моделей |
| `sendSessionHeaders` | Отправлять заголовки для каждой сессии |
| `compat` | Те же флаги совместимости, что в `models.json` |

**Ограничение:** обнаруженные модели получают дефолтные метаданные (нули для cost, false для reasoning). Эндпойнт `/models` возвращает только ID моделей, а не возможности.

### Преимущества

- Автоматическое обнаружение моделей (`fetchModels: true`).
- Более чистый формат для нескольких провайдеров (массив вместо объекта).
- Дефолты провайдера уменьшают повторение.

### Недостатки

- Требует одно расширение.
- Дополнительный слой абстракции над нативным форматом Pi.
- Нет обогащения метаданными для обнаруженных моделей.
- Те же ограничения `.env`, что в Подходе A.

## Скрытие Встроенных Провайдеров

Pi показывает модели встроенных провайдеров, когда настроена аутентификация (через `/login` или переменные окружения). Чтобы скрыть их:

### Метод 1: Не Настраивать Аутентификацию

Если вы не выполняете `/login` для встроенных провайдеров и не имеете их API-ключей в окружении, их модели не появятся.

**Ограничение:** Если у вас установлен `OPENAI_API_KEY` для других целей (например, локальная инференция), Pi покажет модели OpenAI.

### Метод 2: Расширение `pi-hide-providers`

Расширение `pi-hide-providers` предоставляет механизм блок-листа, который полностью удаляет провайдеров и моделей из всех списков.

#### Установка

```bash
pi install npm:pi-hide-providers
```

#### Конфигурация

Создайте `~/.pi/agent/hide-providers.json`:

```json
{
  "hide": [
    { "provider": "anthropic" },
    { "provider": "openai" },
    { "provider": "google" },
    { "provider": "github-copilot" }
  ]
}
```

#### Интерактивные Команды

| Команда | Эффект |
|---------|--------|
| `/hide-models` | Открыть интерактивный TUI |
| `/hide-models add ollama` | Скрыть весь провайдер `ollama` |
| `/hide-models add openrouter/cheap-model` | Скрыть конкретную модель |
| `/hide-models add openrouter/*` | Скрыть весь провайдер (wildcard) |
| `/hide-models remove ollama` | Убрать правило скрытия |
| `/hide-models reset` | Снять патч — все модели возвращаются |
| `/hide-models status` | Показать текущие правила |

#### Как Это Работает

Расширение monkey-patch'ит внутренние аксессоры `ModelRuntime` Pi, чтобы отфильтровать скрытые модели. Это не официальный механизм SDK, но работает надёжно и переживает обновления каталога моделей.

**Примечание:** Конфигурация проекта (`.pi/hide-providers.json`) имеет приоритет над глобальной (`~/.pi/agent/hide-providers.json`).

### Метод 3: Расширение `@mcowger/pi-suppress-providers`

Это расширение читает `enabledProviders` из `settings.json` и временно удаляет учётные данные для не-включённых провайдеров до загрузки реестра моделей Pi.

#### Установка

```bash
pi install npm:@mcowger/pi-suppress-providers
```

#### Конфигурация

Добавьте `enabledProviders` в `settings.json`:

```json
{
  "enabledProviders": ["my-openrouter", "my-deepseek", "local-ollama"]
}
```

Будут доступны только перечисленные провайдеры; все остальные будут подавлены.

#### Как Это Работает

Расширение удаляет переменные окружения с API-ключами для не-включённых провайдеров до загрузки реестра моделей Pi. После разрешения реестра переменные окружения восстанавливаются, поэтому они остаются доступными для bash-команд и других инструментов.

### Метод 4: Расширение `pi-provider-allowlist`

Ограничивает Pi allowlist или blocklist провайдеров через мастер `/providers-allowlist`.

```bash
pi install npm:pi-provider-allowlist
```

### Сравнение Методов Скрытия

| Метод | Плюсы | Минусы |
|-------|-------|--------|
| Не настроен auth | Не нужно расширение | Не работает, если env vars установлены |
| `pi-hide-providers` | Полное удаление; блок-лист; glob-паттерны; мгновенный эффект | Monkey-patch'ит внутренности |
| `@mcowger/pi-suppress-providers` | Подавляет env vars; восстанавливает после загрузки | Allowlist (нужно перечислять нужных) |
| `pi-provider-allowlist` | Allowlist/blocklist; мастер UI | Требует расширение |
| `enabledModels` в settings.json | Встроено; не нужно расширение | Allowlist; громоздко для многих моделей |

## Комбинированный Подход

Для максимальной функциональности объедините несколько расширений:

```bash
pi install npm:pi-dotenv
pi install npm:@esuyo/pi-esuyo-custom-provider
pi install npm:pi-hide-providers
```

Затем:

1. `pi-dotenv` автоматически загружает `.env`.
2. `@esuyo` обнаруживает модели через `fetchModels`.
3. `pi-hide-providers` скрывает встроенных провайдеров.

### Порядок Загрузки

Поставьте `pi-dotenv` первым в `packages`:

```json
{
  "packages": [
    "npm:pi-dotenv",
    "npm:@esuyo/pi-esuyo-custom-provider",
    "npm:pi-hide-providers"
  ]
}
```

## Рекомендация

| Ваш Приоритет | Рекомендуемый Подход |
|----------------|---------------------|
| Минимум зависимостей | A: Только `models.json` + загрузка `.env` через pique |
| Автозагрузка `.env` без pique | B: `models.json` + `pi-dotenv` |
| Автообнаружение моделей | D: `custom-providers.json` + `@esuyo` или см. [Расширения для провайдеров](provider-extensions.md) |
| Скрыть встроенных | A/B/C/D + `pi-hide-providers` |
| Всё сразу | Комбинированный подход выше |

Для профилей pique достаточен Подход A (`models.json` + встроенная загрузка `.env` через pique). Скрипт загружает `.env` до запуска Pi, поэтому расширение для базового управления ключами не требуется.
