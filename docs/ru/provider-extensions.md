# Расширения для провайдеров и моделей

Этот документ каталогизирует расширения Pi для работы с провайдерами, моделями и переменными окружения. Каждое расширение решает конкретную задачу. Используйте его как справочник при выборе инструментов для профиля.

По базовым концепциям (синтаксис `models.json`, интерполяция `$VAR`, скрытие встроенных провайдеров) см. [Провайдеры и модели](providers-and-models.md).

## Расширения для Синхронизации Моделей

Эти расширения автоматически обнаруживают модели с API эндпойнтов и регистрируют их в Pi.

### pi-openai-api-models-sync

**Назначение**: Синхронизация моделей с любого OpenAI-совместимого `/models` эндпойнта с полными метаданными.

**Как работает**:
1. Находит все `openai-responses` и `openai-completions` провайдеры в `models.json`
2. Запрашивает `<baseUrl>/models` для каждого провайдера
3. Загружает метаданные о ценах и возможностях из настроенного источника
4. Регистрирует модели с полными метаданными

**Метаданные**: contextWindow, maxTokens, input modalities, цены, уровни reasoning

**Конфигурация**: Опциональный `~/.pi/agent/pi-openai-api-models-sync.json` для паттернов include/exclude и дефолтов

**Когда использовать**: Вы используете OpenAI-совместимый relay/шлюз с множеством моделей с разными возможностями.

```bash
pi install npm:pi-openai-api-models-sync
```

### agent-zero-model-sync

**Назначение**: Синхронизация Venice.ai моделей для Agent Zero.

**Метаданные**: Уровни reasoning-effort, проверенные первой стороной

**Когда использовать**: Вы используете Venice.ai через Agent Zero.

```bash
pi install npm:agent-zero-model-sync
```

### pi-ollama-sync / @vtstech/pi-ollama-sync

**Назначение**: Синхронизация моделей Ollama в `models.json` Pi.

**Что делают**:
- Запрашивают `/api/tags` Ollama для доступных моделей
- Записывают записи моделей в `models.json`
- Версия `@vtstech` также работает с удалёнными инстансами Ollama

**Метаданные**: Нет (API Ollama возвращает только ID моделей)

**Когда использовать**: Вы запускаете локальные модели через Ollama и хотите, чтобы они автоматически появлялись в `/model`.

```bash
pi install npm:pi-ollama-sync
# или
pi install npm:@vtstech/pi-ollama-sync
```

### @vtstech/pi-openrouter-sync

**Назначение**: Синхронизация моделей из OpenRouter.

**Что делает**: Добавляет модели из URL или ID OpenRouter с метаданными из каталога OpenRouter.

**Когда использовать**: Вы используете OpenRouter и хотите добавлять конкретные модели без ручного редактирования `models.json`.

```bash
pi install npm:@vtstech/pi-openrouter-sync
```

### homelab-model-sync

**Назначение**: Автоматическая регистрация self-hosted `llama.cpp` (или любого OpenAI-совместимого) сервера как провайдера Pi.

**Конфигурация**: Установите переменную окружения `HOMELAB_URL` на URL вашего сервера.

**Когда использовать**: Вы запускаете локальный сервер инференции и хотите его доступность в `/model` без ручной настройки.

```bash
pi install git:github.com/aktech/pi-extensions
```

## Регистрация Кастомных Провайдеров

Эти расширения регистрируют кастомные провайдеры, которые не встроены в Pi.

### @indexyz/pi-custom-provider

**Назначение**: Универсальное расширение для OpenAI-совместимых, Anthropic-совместимых, OpenAI Responses и Ollama чат эндпойнтов.

**Когда использовать**: Вам нужно универсальное расширение провайдера с поддержкой нескольких типов API.

```bash
pi install npm:@indexyz/pi-custom-provider
```

### @mx_/pi-custom-provider

**Назначение**: Автоматическая регистрация кастомных API провайдеров (new-api, one-api, любые OpenAI-совместимые прокси) с динамическим обнаружением моделей.

**Ключевые функции**:
- Динамический список моделей: загрузка при открытии `/model`
- Условные запросы: ETag/Last-Modified кэширование
- Мультипротокольная поддержка: OpenAI, Anthropic, Gemini, Mistral, Azure, Bedrock, Vertex
- Реальные метаданные: из каталога Pi или эвристического вывода
- Переопределения моделей: настройка метаданных по model id

**Конфигурация**: Стандартный `models.json` — провайдеры с `baseUrl` и `apiKey` регистрируются автоматически

**Когда использовать**: Вы используете API шлюз (new-api, one-api) с меняющимся списком моделей.

```bash
pi install npm:@mx_/pi-custom-provider
```

### @esuyo/pi-esuyo-custom-provider

**Назначение**: Регистрация OpenAI-совместимых провайдеров через выделенный JSON конфиг.

**Ключевые функции**:
- `custom-providers.json` с `fetchModels` для автоОбнаружения
- Дефолты провайдера для `contextWindow` и `maxTokens`
- Поддержка session headers
- Флаги совместимости

**Ограничения**: Нет обогащения метаданными — обнаруженные модели получают дефолтные значения.

**Когда использовать**: Вы предпочитаете выделенный конфиг файл вместо `models.json` и нужны session headers.

```bash
pi install npm:@esuyo/pi-esuyo-custom-provider
```

### @d4rw1nz/pi-custom-provider

**Назначение**: Интерактивный мастер для управления кастомными LLM провайдерами и моделями.

**Ключевые функции**:
- Мастер `/provider-setup` для добавления провайдеров
- Обнаружение моделей с эндпойнта
- Обогащение метаданных из models.dev
- Полное редактирование `compat` JSON
- Поддержка OAuth для GitHub Copilot и OpenRouter

**Когда использовать**: Вы предпочитаете интерактивную настройку ручному редактированию JSON.

```bash
pi install npm:@d4rw1nz/pi-custom-provider
```

### better-custom-provider

**Назначение**: Интерактивный мастер для управления кастомными провайдерами с комплексным обнаружением метаданных.

**Ключевые функции**:
- Добавление из каталога models.dev (OpenRouter, DeepSeek, Groq, xAI, ...)
- Добавление любого кастомного эндпойнта (OpenAI, Anthropic, Gemini, Ollama)
- Автоматическое обнаружение метаданных из нескольких источников
- Повторное сканирование для сверки списков моделей
- Проба developer-role для совместимости
- Маппинг уровней reasoning

**Когда использовать**: Вы хотите самое полное обнаружение метаданных и интерактивный workflow.

```bash
pi install npm:better-custom-provider
```

### pi-custom-providers (angribot)

**Назначение**: Регистрация OpenAI и Anthropic-совместимых relay с официальными метаданными и ценами по relay.

**Ключевые функции**:
- Каждый relay регистрируется как настоящий провайдер Pi
- Метаданные из официального каталога Pi
- `costMultiplier` и `modelCostMultipliers` для корректировки цен
- Нет поля `apiKey` — учётные данные разрешаются через собственные механизмы Pi

**Когда использовать**: Вы используете API relay с кастомными ценами и хотите точный учёт затрат.

```bash
pi install npm:pi-custom-providers
```

### @fe-essential/pi-custom-provider-manager

**Назначение**: Управление OpenAI-совместимыми провайдерами через slash-команды.

**Команды**:
- `/provider add <name> <baseUrl> <apiKey> [label]`
- `/provider sync <name>`
- `/provider list` / `show` / `set` / `delete`

**Хранение**: Собственный `providers.json` расширения (не `models.json` Pi)

**Когда использовать**: Вы предпочитаете slash-команды и отдельное хранение от `models.json`.

```bash
pi install npm:@fe-essential/pi-custom-provider-manager
```

### @pavlenkoia/pi-custom-provider

**Назначение**: Интерактивное управление провайдерами с обнаружением моделей.

**Команды**:
- `/provider` — интерактивное меню
- `/provider-status` — показать настроенных провайдеров
- `/provider-purge` — удалить все runtime-провайдеры

**Хранение**: `~/.pi/agent/custom-provider.json`

**Особенность**: Для LiteLLM читает `/model_group/info` для метаданных vision/reasoning

**Когда использовать**: Вы используете LiteLLM или хотите интерактивное управление провайдерами.

```bash
pi install npm:@pavlenkoia/pi-custom-provider
```

### playmaker/pi-custom-openai-providers

**Назначение**: Поддержка нескольких OpenAI-совместимых провайдеров с переключением через `/model`.

**Ключевые функции**:
- `/custom-providers` с подкомандами `add`/`list`/`edit`/`remove`
- Каждый провайдер регистрируется как `custom-<name>` в `/model`
- Постоянное хранение в официальном пути `models.json` Pi
- Полная поддержка схемы models.json (headers, compat, thinkingLevelMap, cost.tiers, modelOverrides)
- Seeding через переменные окружения для CI/скриптов

**Когда использовать**: Вы хотите полную поддержку схемы models.json с управлением через slash-команды.

```bash
pi install npm:pi-custom-openai-providers
```

### pi-diy-provider

**Назначение**: Сфокусированный пакет для настройки провайдеров на основе API-ключей без редактирования JSON.

**Команды**: `/provider-add`, `/provider-model-sync`

**Что делает**: Записывает определения провайдеров и моделей в `models.json`, обновляет реестр моделей Pi.

**Когда использовать**: Вы хотите минимальный, сфокусированный инструмент для добавления провайдеров.

```bash
pi install npm:pi-diy-provider
```

## Скрытие Провайдеров

### pi-hide-providers

**Назначение**: Скрытие провайдеров и моделей из селектора `/model` через блок-лист.

**Как**: Monkey-patch аксессоров ModelRuntime Pi для фильтрации скрытых моделей.

**Команды**: `/hide-models` с подкомандами `add`/`remove`/`status`/`reset`

**Конфиг**: `~/.pi/agent/hide-providers.json` или `.pi/hide-providers.json`

**Когда использовать**: У вас настроено много провайдеров, но вы используете только несколько. См. [Провайдеры и модели](providers-and-models.md) для деталей.

```bash
pi install npm:pi-hide-providers
```

### pi-provider-allowlist

**Назначение**: Ограничение Pi одним allowlist или blocklist провайдеров моделей.

**Команды**: `/providers-allowlist` с 3-страничным мастером

**Когда использовать**: Вы предпочитаете подход allowlist (перечислить нужное, скрыть остальное).

```bash
pi install npm:pi-provider-allowlist
```

### @mcowger/pi-suppress-providers

**Назначение**: Ограничение провайдеров в селекторе моделей на основе `enabledProviders` в `settings.json`.

**Как**: Удаляет переменные окружения с API-ключами для не-включённых провайдеров до загрузки реестра моделей Pi, затем восстанавливает их.

**Когда использовать**: Вы хотите подавление провайдеров, не влияющее на другие инструменты, использующие те же переменные окружения.

```bash
pi install npm:@mcowger/pi-suppress-providers
```

## Загрузка Переменных Окружения

### @pi-lab/env

**Назначение**: Загрузка env vars для Pi из `settings.json` и `~/.pi/agent/.env`.

**Источники**: Блок `env` в `settings.json` и файл `.env`; `settings.json` имеет приоритет.

**Когда использовать**: Вы хотите декларативные env vars в настройках плюс файл `.env`.

```bash
pi install npm:@pi-lab/env
```

### pi-dotenv

**Назначение**: Загрузка `~/.pi/agent/.env` в `process.env` при старте Pi.

**Когда использовать**: Вы хотите простой загрузчик `.env`. См. [Провайдеры и модели](providers-and-models.md) для деталей.

```bash
pi install npm:pi-dotenv
```

## Расширения Дашборда / Менеджера

### @fanchaozz/provider-manager

**Назначение**: Управление кастомными провайдерами и моделями в `models.json` через TUI дашборд и команду `/providers`.

**Скоуп**: Только `models.json` — не управляет встроенными провайдерами, не переключает модели, не предоставляет UI для логина.

**Когда использовать**: Вы хотите визуальный обзор и управление вашими кастомными провайдерами.

```bash
pi install npm:@fanchaozz/provider-manager
```

## Выбор Расширения

| Ваша Потребность | Рекомендуемое Расширение |
|-------------------|--------------------------|
| Синхронизация моделей с метаданными с OpenAI-совместимого API | `pi-openai-api-models-sync` |
| Синхронизация моделей Ollama | `pi-ollama-sync` или `@vtstech/pi-ollama-sync` |
| Синхронизация моделей OpenRouter | `@vtstech/pi-openrouter-sync` |
| Регистрация API шлюза с динамическими моделями | `@mx_/pi-custom-provider` |
| Универсальный мульти-API провайдер | `@indexyz/pi-custom-provider` |
| Интерактивный мастер настройки | `better-custom-provider` или `@d4rw1nz/pi-custom-provider` |
| Управление через slash-команды | `@fe-essential/pi-custom-provider-manager` или `playmaker/pi-custom-openai-providers` |
| Relay с кастомными ценами | `pi-custom-providers` (angribot) |
| Скрытие неиспользуемых провайдеров | `pi-hide-providers` |
| Allowlist провайдеров | `pi-provider-allowlist` или `@mcowger/pi-suppress-providers` |
| Загрузка `.env` при старте | `pi-dotenv` или `@pi-lab/env` |
| TUI дашборд для провайдеров | `@fanchaozz/provider-manager` |

## Комбинирование с pique

Эти расширения работают внутри Pi. pique работает вне Pi (запуск Pi с профилем). Они комплементарны:

1. pique устанавливает `PI_CODING_AGENT_DIR` на директорию вашего профиля.
2. Pi загружает расширения из директории `extensions/` профиля или пакетов из `settings.json`.
3. Расширения видят `models.json` и `.env` профиля.

Пример структуры профиля с расширениями:

```
profiles/custom-providers/
├── settings.json          # Содержит "packages": ["npm:pi-openai-api-models-sync"]
├── models.json            # Определения провайдеров (или .template)
├── .env                   # API ключи (gitignored)
└── extensions/            # Или положите расширения здесь
```

## Замечания по Безопасности

- Все эти расширения — сторонний код, работающий внутри процесса Pi.
- Проверяйте исходный код перед установкой.
- Расширения могут инспектировать учётные данные, промпты и определения инструментов.
- Предпочитайте расширения с большим количеством загрузок и активной поддержкой.
- Скрипт pique (`bin/pique`) обеспечивает загрузку `.env` без каких-либо расширений — рассмотрите, нужно ли вам расширение вообще.
