# 📥 Руководство по установке Flutter

## ⚠️ Flutter не установлен

Вам нужно сначала установить Flutter SDK. Вот несколько вариантов:

---

## 🎯 Вариант 1: Установка через официальный сайт (Рекомендуется)

### Шаг 1: Скачать Flutter SDK

1. Перейдите на https://flutter.dev/docs/get-started/install/windows
2. Нажмите "Download Flutter SDK"
3. Скачайте последнюю стабильную версию (flutter_windows_x.x.x-stable.zip)

### Шаг 2: Распаковать Flutter

1. Создайте папку `C:\src\flutter`
2. Распакуйте скачанный архив в эту папку
3. Путь должен быть: `C:\src\flutter\bin`

### Шаг 3: Добавить Flutter в PATH

1. Откройте "Переменные среды":
   - Нажмите `Win + X`
   - Выберите "Система"
   - Нажмите "Дополнительные параметры системы"
   - Нажмите "Переменные среды"

2. В разделе "Системные переменные" найдите `Path`
3. Нажмите "Изменить"
4. Добавьте новую строку: `C:\src\flutter\bin`
5. Нажмите "ОК" во всех окнах

### Шаг 4: Перезапустить PowerShell

Закройте и откройте PowerShell заново

### Шаг 5: Проверить установку

```powershell
flutter --version
flutter doctor
```

---

## 🚀 Вариант 2: Быстрая установка через Git

Если у вас установлен Git:

```powershell
# Перейти в папку для установки
cd C:\src

# Клонировать Flutter
git clone https://github.com/flutter/flutter.git -b stable

# Добавить в PATH (временно для текущей сессии)
$env:Path += ";C:\src\flutter\bin"

# Проверить установку
flutter doctor
```

Затем добавьте `C:\src\flutter\bin` в PATH постоянно (см. Вариант 1, Шаг 3)

---

## 📦 Вариант 3: Альтернатива - Запустить проект на Flutter Online

Если не хотите устанавливать Flutter локально, можно использовать:

1. **DartPad** (для небольших виджетов): https://dartpad.dev
2. **FlutLab** (полноценный проект): https://flutlab.io
3. **Zapp** (онлайн IDE): https://zapp.run

---

## ✅ После установки Flutter

### 1. Проверить систему

```powershell
flutter doctor
```

Эта команда покажет, что нужно установить дополнительно:
- Android Studio (для Android разработки)
- Visual Studio (для Windows разработки)
- Chrome (для веб-разработки)

### 2. Установить зависимости проекта

```powershell
cd C:\Users\faragj\Desktop\flutter
flutter pub get
```

### 3. Запустить проект

```powershell
# На эмуляторе или подключенном устройстве
flutter run

# В браузере Chrome
flutter run -d chrome

# На Windows
flutter run -d windows
```

---

## 🔧 Установка дополнительных инструментов

### Для Android разработки:

1. **Android Studio**: https://developer.android.com/studio
2. После установки:
   ```powershell
   flutter doctor --android-licenses
   ```

### Для iOS разработки (только на Mac):

1. Установите Xcode из App Store
2. ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   ```

### Для Windows разработки:

1. **Visual Studio 2022**: https://visualstudio.microsoft.com/downloads/
2. При установке выберите "Разработка классических приложений на C++"

---

## 🎨 Рекомендуемые редакторы

### VS Code (легкий)
1. Скачать: https://code.visualstudio.com/
2. Установить расширения:
   - Flutter
   - Dart
   - Flutter Widget Snippets

### Android Studio (полнофункциональный)
1. Скачать: https://developer.android.com/studio
2. Установить плагины Flutter и Dart через Settings → Plugins

---

## 📱 Запуск на реальном устройстве

### Android:
1. Включите "Режим разработчика" на устройстве
2. Включите "Отладку по USB"
3. Подключите устройство к компьютеру
4. Выполните: `flutter devices`
5. Запустите: `flutter run`

### iOS (только Mac):
1. Подключите iPhone/iPad
2. Доверьте компьютеру на устройстве
3. В Xcode настройте подписание
4. Выполните: `flutter run`

---

## ⚡ Быстрая команда для проверки

После установки Flutter выполните:

```powershell
flutter doctor -v
```

Это покажет детальную информацию о вашей установке.

---

## 🐛 Решение проблем

### "flutter: команда не найдена" после установки

1. Проверьте PATH:
   ```powershell
   $env:Path
   ```

2. Добавьте временно:
   ```powershell
   $env:Path += ";C:\src\flutter\bin"
   ```

3. Перезапустите PowerShell

### "Doctor found issues"

Это нормально! Установите только то, что вам нужно:
- Android Studio - для Android
- Chrome - для веб
- Visual Studio - для Windows

---

## 📚 Полезные ссылки

- 📖 Официальная документация: https://flutter.dev/docs
- 🎓 Туториалы: https://flutter.dev/learn
- 💬 Сообщество: https://flutter.dev/community
- 🐛 Issue tracker: https://github.com/flutter/flutter/issues

---

## 🎯 Минимальная установка для этого проекта

Для запуска Virtual Try-On приложения минимально нужно:

1. ✅ Flutter SDK
2. ✅ Chrome (для веб-версии) ИЛИ
3. ✅ Android Studio + эмулятор (для Android версии)

**Рекомендуемый путь:**
1. Установить Flutter SDK
2. Установить Chrome
3. Запустить: `flutter run -d chrome`

Это позволит быстро запустить приложение без установки Android Studio!

---

**После установки Flutter вернитесь к файлу [QUICK_START.md](QUICK_START.md)**
