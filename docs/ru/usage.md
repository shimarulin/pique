# Использование

## Запуск Pi с профилем

```bash
cd ~/my-project
pique development
```

Команда устанавливает `PI_CODING_AGENT_DIR` и запускает Pi в текущей директории.

## Передача аргументов

```bash
pique development --version
pique research --print "Проанализируй код"
pique minimal
```

Все аргументы после имени профиля передаются в Pi напрямую.

## Список профилей

```bash
pique --list
```

## Сравнение профилей

```bash
pique --diff minimal development
```

Вывод показывает файлы, существующие только в одном профиле, и различия в содержимом общих файлов.

## Использование в проекте

### Разовый запуск

Запустите Pi из любой директории с профилем:

```bash
cd ~/any-project
pique development
```

### Автоматический

Добавьте в `mise.toml` проекта:

```toml
[env]
PI_CODING_AGENT_DIR = "~/.config/pique/profiles/development"
```

Запускайте `pi` из директории проекта с активированным mise. Pi автоматически использует профиль development.

### Проектные переопределения

Pi читает `.pi/settings.json` из директории проекта. Эти настройки переопределяют настройки профиля.

Пример `.pi/settings.json`:

```json
{
  "defaultModel": "claude-opus-4-1",
  "defaultThinkingLevel": "high"
}
```

Это меняет модель только для этого проекта. Профиль остаётся без изменений.

## Задачи управления

Запуск из корня репозитория pique:

```bash
mise run list                 # Список профилей
mise run validate             # Валидация всех профилей
mise run diff -- a b          # Сравнение профилей
mise run new -- name [base]   # Создание нового профиля
mise run sync-shared          # Копирование общих skills
```

## Workflow

### Развитие профиля

1. Редактируйте файлы в `profiles/<name>/`.
2. Тестируйте: `pique <name>` из любой директории.
3. Коммитьте изменения.

### Создание нового профиля

```bash
mise run new -- my-profile development
```

Редактируйте `profiles/my-profile/`. Тестируйте через `pique my-profile`.

### Сравнение профилей

```bash
mise run diff -- minimal development
```

Просмотрите различия. Копируйте полезные изменения между профилями.

### Обновление общих skills

1. Редактируйте файлы в `shared/skills/`.
2. Запустите `mise run sync-shared`.
3. Закоммитьте изменения в профилях.
