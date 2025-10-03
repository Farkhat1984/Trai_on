# 🚀 Быстрая сборка APK

## Команда для сборки:
```powershell
flutter build apk --release
```

## Где найти готовый APK:
```
build\app\outputs\flutter-apk\app-release.apk
```

## Название приложения: 
**Trai on**

## Иконка:
`assets/icons/Trai_icon.png`

---

## ✅ Что изменено:

1. **AndroidManifest.xml** - название "Trai on"
2. **Info.plist (iOS)** - название "Trai on"  
3. **pubspec.yaml** - путь к иконке `Trai_icon.png`
4. **Иконки сгенерированы** - для всех размеров Android и iOS

---

## 📱 После сборки:

APK будет иметь:
- ✅ Название: **Trai on**
- ✅ Иконку из файла `Trai_icon.png`
- ✅ Размер: ~50-60 MB
- ✅ Готов к установке на Android устройства

## Установка на телефон:
```powershell
# Если телефон подключен:
flutter install --release

# Или скопируйте app-release.apk на телефон вручную
```

---

**Подробная инструкция в файле BUILD_APK.md**
