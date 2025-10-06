# Временные Звуковые Файлы

Эта папка должна содержать звуковые файлы:
- click.wav (звук клика кнопки)
- whoosh.wav (звук полёта)

Пока файлы отсутствуют, приложение будет работать нормально, просто без звуков.

## Быстрое Решение - Создание Простых Звуков в Python

Если у вас установлен Python и библиотека pydub, вы можете создать простые звуки:

```python
from pydub import AudioSegment
from pydub.generators import Sine

# Создаём короткий клик (100ms)
click = Sine(800).to_audio_segment(duration=100).fade_in(10).fade_out(10)
click.export("click.wav", format="wav")

# Создаём свуш (800ms) с затуханием
whoosh = Sine(300).to_audio_segment(duration=800)
whoosh = whoosh.fade_in(50).fade_out(400) - 10  # Уменьшаем громкость
whoosh.export("whoosh.wav", format="wav")
```

## Или скачайте готовые звуки:

### Рекомендуемые бесплатные источники:
1. **Freesound.org** - огромная библиотека бесплатных звуков
2. **Mixkit.co** - качественные UI звуки
3. **Zapsplat.com** - бесплатный tier с хорошими звуками

### Поисковые запросы:
- Для клика: "ui button click", "soft tap", "pop sound"
- Для свуша: "whoosh", "swipe transition", "swoosh fade"

После скачивания:
1. Переименуйте файлы в `click.wav` и `whoosh.wav`
2. Поместите их в эту папку
3. Если файлы в MP3, конвертируйте их в WAV (можно онлайн на cloudconvert.com)
4. Перезапустите приложение
