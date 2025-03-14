#!/usr/bin/env bash

set -e

d:
  npm run dev

f:
  npx prettier --write .

s:
  npx astro sync

b:
  npx astro build

p:
  npx astro preview

bot:
  TELEGRAM_BOT_TOKEN=$(cat ~/Sync/tg-web-inputs/telegram-token) \
    node --env-file=bot/.env.local bot/bot.mjs

t:
  export BOT_TOKEN=$(cat ~/Sync/tg-web-inputs/telegram-token)
  export CHAT_ID=$(cat ~/Sync/tg-web-inputs/chat-id)
  export HANDLER_URL="https://your-bot.com/handler"
  export URL="https://x0k.github.io/telegram-web-inputs/calendar?$(python3 -c "
  import urllib.parse
  import json
  from datetime import date
  now = date.today().isoformat()
  params = {
    'r': json.dumps({
      'url': '${HANDLER_URL}'
    }),
    'v': json.dumps({
      'type': 'object',
      'properties': {
        'selectedDates': {
          'type': 'array',
          'minItems': 1
        }
      },
      'required': ['selectedDates']
    }),
    'w': json.dumps({
      'date': {
        'min': now,
      },
      'settings': {
        'selected': {
          'dates': [now]
        }
      }
    })
  }
  print(urllib.parse.urlencode(params))
  ")"
  curl -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --argjson chat_id $CHAT_ID --arg url "$URL" '{
    chat_id: $chat_id,
    text: "Pick a date",
    reply_markup: {
      inline_keyboard: [[
        {
          text: "📅",
          web_app: { url: $url }
        }
      ]]
    }
  }')"
