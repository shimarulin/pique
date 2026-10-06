# Добавление профилей

## Создание на основе существующего

```bash
mise run new -- my-profile development
```

Команда копирует `profiles/development/` в `profiles/my-profile/`.

## Редактирование настроек

Откройте `profiles/my-profile/settings.json`. Измените:

- `description` — короткое описание назначения.
- `defaultModel` — модель для использования.
- `defaultThinkingLevel` — глубина размышлений.
- `enabledTools` — инструменты, доступные агенту.

## Редактирование инструкций

Откройте `profiles/my-profile/AGENTS.md`. Напишите инструкции. Правила:

- Одна инструкция в одном предложении.
- Активный залог.
- Настоящее время.
- Короткие предложения.

## Добавление ресурсов

Добавьте директории по необходимости:

| Директория | Содержимое |
|-----------|-----------|
| `extensions/` | Расширения Pi |
| `skills/` | Skills агента |
| `prompts/` | Шаблоны промптов |
| `themes/` | Темы интерфейса |

## Добавление MCP-серверов

Создайте `profiles/my-profile/mcp.json`:

```json
{
  "mcpServers": {
    "example": {
      "command": "npx",
      "args": ["-y", "@example/mcp-server"]
    }
  }
}
```

## Тестирование

```bash
cd ~/test-project
pique my-profile
```

Проверьте, что Pi запускается с правильными настройками.

## Валидация

```bash
mise run validate
```

Проверяет синтаксис JSON во всех профилях.

## Создание директории сессий

```bash
mkdir -p sessions/my-profile
```

Скрипт запуска использует эту директорию для сессий Pi.

## Коммит

```bash
git add profiles/my-profile sessions/
git commit -m "Add my-profile"
```
