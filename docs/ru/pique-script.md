# Скрипт запуска pique

Этот документ описывает работу `bin/pique`, причины принятых решений и использование его функций.

## Обзор

Команда `pique` — тонкий bash-скрипт. Он:

1. Находит корень репозитория (следуя симлинкам).
2. Загружает переменные окружения из `.env` файлов.
3. Рендерит файлы шаблонов (суффикс `.template`).
4. Устанавливает `PI_CODING_AGENT_DIR` на директорию профиля.
5. Запускает Pi со всеми переданными аргументами.

Скрипт не имеет npm-зависимостей. Требует только bash и стандартные Unix-утилиты.

## Зачем Эти Функции

### Загрузка Окружения

Pi не загружает файлы `.env`. Если вы храните API-ключи в `.env`, они должны быть экспортированы в окружение до старта Pi.

Скрипт загружает `.env` файлы в этом порядке:

1. `profiles/<name>/.env` — ключи конкретного профиля (высший приоритет).
2. `$PIQUE_ROOT/.env` — ключи всего репозитория (fallback).

Существующие переменные shell **никогда не перезаписываются**. Это позволяет переопределять значения из `.env` из командной строки:

```bash
PROVIDER_PRIMARY_API_KEY=temp-key pique private-providers
```

### Рендеринг Шаблонов

`models.json` в Pi поддерживает интерполяцию `$VAR` только в значениях `apiKey` и `headers`. Он **не** поддерживает интерполяцию в:

- `baseUrl`
- Ключах провайдеров (имена в объекте `providers`)
- `defaultModel` в `settings.json`

Это означает, что нельзя скрыть URL корпоративного эндпойнта за переменной окружения используя нативный синтаксис Pi.

Рендеринг шаблонов решает эту задачу. Скрипт генерирует реальные `models.json` и `settings.json` из `.template` файлов до старта Pi. Сгенерированные файлы содержат фактические значения, а не ссылки на переменные.

**Используйте когда:**

- Нужно скрыть URL эндпойнтов из публичного репозитория.
- Нужно динамически менять имена провайдеров (переключение основной/резервный).
- Нужно вставить числовые значения (контекстное окно, стоимость) из переменных.

**Не используйте когда:**

- Конфигурация не чувствительна. Используйте обычный `models.json` и `$VAR` только в `apiKey`.
- Не нужно динамическое переключение провайдеров.

## Синтаксис Шаблонов

Шаблоны используют shell-подобные ссылки на переменные. Работают обе формы:

```
${ИМЯ_ПЕРЕМЕННОЙ}
$ИМЯ_ПЕРЕМЕННОЙ
```

В JSON-шаблонах предпочитайте `${ИМЯ_ПЕРЕМЕННОЙ}` (с фигурными скобками). Это однозначно при следовании текста.

Пример `models.json.template`:

```json
{
  "providers": {
    "primary": {
      "baseUrl": "${PROVIDER_PRIMARY_BASE_URL}",
      "api": "openai-completions",
      "apiKey": "${PROVIDER_PRIMARY_API_KEY}",
      "models": [
        {
          "id": "${MODEL_PRIMARY_ID}",
          "contextWindow": ${MODEL_PRIMARY_CONTEXT_WINDOW},
          "maxTokens": ${MODEL_PRIMARY_MAX_TOKENS}
        }
      ]
    }
  }
}
```

Примечание: числовые значения (как `contextWindow`) не требуют кавычек. Шаблонизатор заменяет `${VAR}` на значение переменной напрямую.

## Выбор Инструмента для Рендеринга

Скрипт использует первый доступный инструмент из этого списка:

| Приоритет | Инструмент | Доступность | Примечания |
|-----------|-----------|-------------|------------|
| 1 | `envsubst` | пакет gettext | Простейший, обрабатывает `$VAR` и `${VAR}` |
| 2 | `perl` | Предустановлен на macOS, распространён на Linux | Полная поддержка regex, обрабатывает краевые случаи |
| — | `sed` | Всегда доступен | **Не используется** — не может подставлять значения переменных окружения |

### Почему не sed?

`sed` выполняет текстовую подстановку, но не может искать значения переменных окружения. Команда sed вида:

```bash
sed 's/${VAR}/значение/g' шаблон
```

требует знать `значение` заранее. Она не может прочитать из `$VAR` во время выполнения.

Мы протестировали этот подход и удалили его. Он производил файлы с именами переменных вместо значений.

### Что происходит без perl или envsubst?

Скрипт выводит ошибку и завершается:

```
Error: Cannot render template profiles/private-providers/models.json.template
Neither perl nor envsubst is available.
Install one of them, or create profiles/private-providers/models.json manually.
```

Pi не запускается со сломанной конфигурацией. Это намеренно — тихий отказ хуже громкого.

**Для исправления:**

```bash
# macOS (perl предустановлен, этого не должно происходить)
# Linux: установите один из:
sudo apt-get install gettext     # предоставляет envsubst
sudo dnf install perl            # предоставляет perl
```

## Файлы Шаблонов vs Сгенерированные Файлы

| Тип файла | Коммитить в Git? | Почему |
|-----------|-------------------|--------|
| `*.template` | ✅ Да | Содержит структуру, без секретов |
| Сгенерированные (`models.json`, `settings.json`) | ❌ Нет (в `.gitignore`) | Содержат реальные значения, могут содержать секреты |

`.gitignore` в каждой директории профиля исключает:

```
.env
models.json
settings.json
sessions/
auth.json
```

## Переключение Провайдеров

### Паттерн Основной/Резервный

Определите обоих провайдеров в шаблоне с одинаковыми моделями:

```json
{
  "providers": {
    "primary": {
      "baseUrl": "${PROVIDER_PRIMARY_BASE_URL}",
      "apiKey": "${PROVIDER_PRIMARY_API_KEY}",
      "models": [
        { "id": "${MODEL_ID}", "contextWindow": 200000 }
      ]
    },
    "fallback": {
      "baseUrl": "${PROVIDER_FALLBACK_BASE_URL}",
      "apiKey": "${PROVIDER_FALLBACK_API_KEY}",
      "models": [
        { "id": "${MODEL_ID}", "contextWindow": 200000 }
      ]
    }
  }
}
```

В `.env`:

```env
PROVIDER_PRIMARY_BASE_URL=https://gateway-a.corp.com/v1
PROVIDER_PRIMARY_API_KEY=sk-key-a
PROVIDER_FALLBACK_BASE_URL=https://gateway-b.corp.com/v1
PROVIDER_FALLBACK_API_KEY=sk-key-b
```

Чтобы поменять местами:

1. Отредактируйте `.env` — поменяйте URL и ключи местами.
2. Запустите `pique private-providers` снова.

Сгенерированный `models.json` обновится с новыми значениями.

### Модели для Отдельных Провайдеров

Добавьте больше провайдеров в шаблон с их собственными моделями:

```json
{
  "providers": {
    "primary": {
      "baseUrl": "${PROVIDER_PRIMARY_BASE_URL}",
      "apiKey": "${PROVIDER_PRIMARY_API_KEY}",
      "models": [
        { "id": "claude-sonnet-4-5", "contextWindow": 200000 }
      ]
    },
    "image-provider": {
      "baseUrl": "${PROVIDER_IMAGE_BASE_URL}",
      "apiKey": "${PROVIDER_IMAGE_API_KEY}",
      "models": [
        { "id": "flux-pro", "input": ["text", "image"] }
      ]
    }
  }
}
```

Каждый провайдер имеет свои модели. Переключайтесь между ними через `/model` внутри Pi.

## Порядок Операций

Когда вы запускаете `pique <profile>`:

```
1. Определение корня репозитория
   ├─ Следование симлинкам для поиска реального пути скрипта
   ├─ Проверка переменной окружения PIQUE_ROOT
   └─ Раскрытие тильды (~) при наличии

2. Валидация директорий
   ├─ Проверка существования PIQUE_ROOT
   └─ Проверка существования поддиректории profiles/

3. Разбор аргументов
   ├─ --help, --list, --diff, --version → выполнить и выйти
   └─ <profile> → продолжить

4. Валидация профиля
   └─ Проверка существования директории profiles/<name>/

5. Загрузка окружения
   ├─ Загрузка profiles/<name>/.env (если существует)
   └─ Загрузка $PIQUE_ROOT/.env (если у профиля нет своего)

6. Рендеринг шаблонов
   ├─ Поиск всех *.template файлов в директории профиля
   ├─ Для каждого: рендер в то же имя без .template
   └─ Запись только при изменении контента

7. Установка окружения Pi
   ├─ export PI_CODING_AGENT_DIR=<директория-профиля>
   └─ export PI_CODING_AGENT_SESSION_DIR (если sessions/ существует)

8. Определение бинарника Pi
   ├─ Попытка: mise which pi (из PIQUE_ROOT)
   └─ Fallback: command -v pi (системный PATH)

9. Запуск
   └─ exec $PI_BIN "$@"
```

## Обработка Ошибок

| Ошибка | Причина | Исправление |
|--------|---------|-------------|
| `PIQUE_ROOT does not exist` | Переменная окружения указывает на неверный путь | Проверьте переменную или уберите её |
| `profiles directory not found` | Структура репозитория нарушена | Пере-клонируйте или проверьте PIQUE_ROOT |
| `profile 'X' not found` | Опечатка или профиль отсутствует | Выполните `pique --list` |
| `Cannot render template` | Нет perl или envsubst | Установите gettext (envsubst) или perl |
| `'pi' binary not found` | Pi не установлен или mise не настроен | Выполните `cd $PIQUE_ROOT && mise install` |

## Тест-кейсы

Выполните их для проверки работы скрипта:

```bash
# Тест 1: Базовый запуск
pique minimal
# Ожидание: Pi запускается, .env не загружается, шаблоны не рендерятся

# Тест 2: Загрузка окружения
echo "TEST_VAR=hello" > profiles/minimal/.env
pique minimal
# Внутри Pi выполните: ! echo $TEST_VAR
# Ожидание: hello

# Тест 3: Рендеринг шаблона
cat > profiles/minimal/settings.json.template << 'EOF'
{
  "description": "Test: ${TEST_VAR}"
}
EOF
pique minimal
# Ожидание: settings.json содержит "Test: hello"
# Очистка: rm profiles/minimal/settings.json.template profiles/minimal/settings.json

# Тест 4: Неустановленная переменная
unset TEST_VAR
pique minimal
# Ожидание: settings.json содержит "Test: " (пустое значение)

# Тест 5: Кавычки в .env
echo 'QUOTED="with quotes"' > profiles/minimal/.env
pique minimal
# Внутри Pi выполните: ! echo $QUOTED
# Ожидание: with quotes (кавычки убраны)
# Очистка: rm profiles/minimal/.env

# Тест 6: Приоритет переменной shell
export TEST_VAR="from-shell"
echo "TEST_VAR=from-env-file" > profiles/minimal/.env
pique minimal
# Внутри Pi выполните: ! echo $TEST_VAR
# Ожидание: from-shell (shell побеждает)
# Очистка: unset TEST_VAR; rm profiles/minimal/.env

# Тест 7: Разрешение симлинков
ln -sf /real/path/to/pique ~/.local/bin/pique
pique --list
# Ожидание: работает, PIQUE_ROOT это /real/path/to/pique

# Тест 8: Отсутствие инструмента рендеринга
# (симулируйте, скрыв perl и envsubst)
PATH=/usr/bin:/bin pique private-providers
# Ожидание: понятное сообщение об ошибке, код выхода 1

# Тест 9: Diff исключает сгенерированные файлы
pique --diff minimal development
# Ожидание: показывает .template файлы, не сгенерированные .json

# Тест 10: Версия
pique --version
# Ожидание: выводит расположение pique и версию Pi
```

## Связь с Документацией Pi

Этот скрипт добавляет функциональность поверх Pi. Собственное поведение Pi документировано на:

- [Конфигурация моделей](https://pi.dev/docs/latest/models) — синтаксис `models.json`, ограничения интерполяции `$VAR`
- [Переменные окружения](https://pi.dev/docs/latest/environment-variables) — что Pi устанавливает и читает
- [Провайдеры](https://pi.dev/docs/latest/providers) — методы аутентификации

По вопросам, связанным с Pi (ID моделей, флаги совместимости API, управление сессиями), обращайтесь к документации Pi. Этот документ покрывает только то, что добавляет `bin/pique`.

## Замечания по Безопасности

- Файлы `.env` в .gitignore. Никогда не коммитьте их.
- Сгенерированные `models.json` и `settings.json` в .gitignore в профилях, использующих шаблоны.
- Скрипт не логирует и не выводит значения переменных окружения.
- `render_template` пишет только в директорию профиля. Он не трогает файлы вне `PIQUE_ROOT`.
- Если шаблон ссылается на неопределённую переменную, она становится пустой строкой. Это может создать некорректный JSON. Проверяйте `.env` перед запуском.
