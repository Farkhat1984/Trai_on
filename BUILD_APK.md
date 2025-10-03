# 📱 Инструкция по сборке APK

## Название приложения: **Trai on**
## Иконка: `assets/icons/Trai_icon.png`

---

## ✅ Что уже настроено:

### 1. **Название приложения**
- ✅ Android: `Trai on` (в `AndroidManifest.xml`)
- ✅ iOS: `Trai on` (в `Info.plist`)

### 2. **Иконка приложения**
- ✅ Путь к иконке: `assets/icons/Trai_icon.png`
- ✅ Иконки сгенерированы для всех размеров Android
- ✅ Иконки сгенерированы для iOS
- ✅ Adaptive icon для Android с белым фоном

---

## 🚀 Команды для сборки APK

### 1. **Сборка Release APK (рекомендуется)**
```powershell
flutter build apk --release
```

**Результат:** 
- Файл: `build\app\outputs\flutter-apk\app-release.apk`
- Размер: ~50-60 MB (оптимизированный)
- Название при установке: **Trai on**
- Иконка: Ваша кастомная иконка из `Trai_icon.png`

---

### 2. **Сборка APK для разных архитектур (меньший размер)**

#### Для всех архитектур (3 файла):
```powershell
flutter build apk --split-per-abi
```

**Результат:**
- `app-arm64-v8a-release.apk` - для современных Android устройств (64-bit)
- `app-armeabi-v7a-release.apk` - для старых Android устройств (32-bit)
- `app-x86_64-release.apk` - для эмуляторов

**Преимущества:**
- ✅ Размер каждого APK: ~20-25 MB (меньше в 2-3 раза!)
- ✅ Пользователи скачивают только нужную версию
- ✅ Быстрее установка

**Недостатки:**
- ⚠️ Нужно выбрать правильную версию для устройства
- ⚠️ Большинство современных устройств - `arm64-v8a`

---

### 3. **Сборка App Bundle (для Google Play Store)**
```powershell
flutter build appbundle --release
```

**Результат:**
- Файл: `build\app\outputs\bundle\release\app-release.aab`
- Google Play автоматически создаст оптимизированные APK для каждого устройства

---

## 📋 Пошаговая инструкция

### Шаг 1: Очистка предыдущих сборок (опционально)
```powershell
flutter clean
```

### Шаг 2: Обновление зависимостей
```powershell
flutter pub get
```

### Шаг 3: Сборка APK
```powershell
flutter build apk --release
```

### Шаг 4: Найти готовый APK
Файл будет находиться в:
```
c:\Users\faragj\Desktop\flutter\build\app\outputs\flutter-apk\app-release.apk
```

### Шаг 5: Установка на устройство
```powershell
# Если устройство подключено по USB:
flutter install --release

# Или вручную:
# Скопируйте app-release.apk на телефон и установите
```

---

## 🔧 Дополнительные настройки (опционально)

### Изменить Package Name (для публикации в Play Store)
Отредактируйте файл: `android\app\build.gradle.kts`

Найдите:
```kotlin
namespace = "com.example.virtual_try_on"
```

Измените на уникальное имя (например):
```kotlin
namespace = "com.traion.app"
```

---

### Изменить версию приложения
Отредактируйте файл: `pubspec.yaml`

Найдите:
```yaml
version: 1.0.0+1
```

Формат: `ВЕРСИЯ+НОМЕР_СБОРКИ`
- `1.0.0` - версия для пользователей
- `+1` - внутренний номер сборки (каждая сборка должна быть больше предыдущей)

Примеры:
```yaml
version: 1.0.1+2  # Первое обновление
version: 1.1.0+3  # Новые функции
version: 2.0.0+4  # Мажорное обновление
```

---

### Подписать APK (для публикации)

#### 1. Создать ключ подписи:
```powershell
keytool -genkey -v -keystore c:\Users\faragj\Desktop\flutter\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

#### 2. Создать файл `key.properties`:
```
storePassword=ваш_пароль
keyPassword=ваш_пароль
keyAlias=upload
storeFile=c:/Users/faragj/Desktop/flutter/upload-keystore.jks
```

#### 3. Настроить подпись в `android/app/build.gradle.kts`:
```kotlin
android {
    signingConfigs {
        create("release") {
            storeFile = file(keystoreProperties["storeFile"] ?: "")
            storePassword = keystoreProperties["storePassword"] as String
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

---

## 📊 Проверка APK

### Размер APK
```powershell
# Показать размер всех выходных файлов
Get-ChildItem -Path ".\build\app\outputs\flutter-apk\" | Select-Object Name, @{Name="Size(MB)";Expression={[math]::Round($_.Length/1MB,2)}}
```

### Информация об APK
```powershell
# Требует Android SDK
aapt dump badging .\build\app\outputs\flutter-apk\app-release.apk
```

---

## 🎯 Рекомендации

### Для тестирования:
✅ Используйте: `flutter build apk --release`
- Быстро собирается
- Работает на всех устройствах
- Легко отправить для тестирования

### Для публикации в Play Store:
✅ Используйте: `flutter build appbundle --release`
- Меньший размер для пользователей
- Google Play оптимизирует под каждое устройство
- Обязательно для новых приложений в Play Store

### Для прямого распространения (не через магазин):
✅ Используйте: `flutter build apk --split-per-abi`
- Дайте пользователям выбрать их версию
- Или соберите только `arm64-v8a` (95% устройств)

---

## ⚠️ Важные моменты

1. **Название "Trai on"** - убедитесь, что это правильное написание
   - Возможно имелось в виду: "Try On" или "Trai On"?
   - Можно изменить в `AndroidManifest.xml` и `Info.plist`

2. **Иконка** - проверьте, что `Trai_icon.png`:
   - Размер: минимум 512x512 пикселей
   - Формат: PNG с прозрачностью
   - Квадратная форма
   - Качественное изображение

3. **Тестирование**:
   - Установите APK на реальное устройство
   - Проверьте название в списке приложений
   - Проверьте иконку на разных лаунчерах
   - Проверьте все функции приложения

---

## 📱 Текущая конфигурация

```
Название: Trai on
Package: com.example.virtual_try_on
Версия: 1.0.0+1
Иконка: assets/icons/Trai_icon.png
Минимальный Android: API 21 (Android 5.0)
Целевой Android: API 34 (Android 14)
```

---

## 🔄 Быстрые команды

```powershell
# Очистка + Сборка
flutter clean; flutter pub get; flutter build apk --release

# Сборка + Установка на устройство
flutter build apk --release; flutter install

# Проверка размера
Get-ChildItem ".\build\app\outputs\flutter-apk\app-release.apk" | Select-Object Name, @{Name="Size(MB)";Expression={[math]::Round($_.Length/1MB,2)}}
```

---

**Готово! Теперь можете собрать APK с новым названием "Trai on" и вашей иконкой! 🚀**
