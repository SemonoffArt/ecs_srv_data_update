# 🔄 ECS03 Data Update

**Скрипт для синхронизации данных ECS03 с основным сервером ECS**

[![PowerShell](https://img.shields.io/badge/PowerShell-1.0%2B-blue.svg)](https://docs.microsoft.com/en-us/powershell/)
[![Windows](https://img.shields.io/badge/Platform-Windows-lightgrey.svg)](https://www.microsoft.com/windows/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📋 Описание

PowerShell скрипт для автоматизации процесса синхронизации данных на ECS03 с основным сервером ECS.

## ✨ Основные возможности

- 🔧 **Управление службами Windows** (опционально)
- 📁 **Копирование файлов базы данных** (.mdb файлы)
- 🗂️ **Синхронизация директорий** с рекурсивным копированием
- 💾 **Автоматическое создание резервных копий** перед заменой
- 🔄 **Перезагрузка системы** с подтверждением пользователя
- 🎨 **Цветной вывод** для лучшей читаемости
- ⚡ **Совместимость с PowerShell 1.0+**

## 📂 Структура проекта

```
ecs_srv_data_update/
├── 📄 ecs_srv_pnt_&_scr_upt.ps1    # Основной скрипт с полной функциональностью
├── 📄 .gitignore                   # Исключения для Git
├── 📄 LICENSE                      # Лицензия MIT
└── 📄 README.md                    # Этот файл
```

## 🚀 Быстрый старт

### Предварительные требования

- ✅ Windows OS (Windows 7/Server 2008 или новее)
- ✅ PowerShell 1.0 или выше
- ✅ Права администратора (для управления службами)

### Установка

1. **Клонируйте репозиторий:**
   ```bash
   git clone https://github.com/your-username/ecs_srv_data_update.git
   cd ecs_srv_data_update
   ```

2. **Настройте политику выполнения PowerShell:**
   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. **Создайте необходимые директории:**
   ```powershell
   # Создайте исходные и целевые папки согласно конфигурации
   New-Item -Path "C:\tmp\source\FlsaProDb" -ItemType Directory -Force
   New-Item -Path "C:\tmp\source\FlsaGmsPic\ECS2261" -ItemType Directory -Force
   New-Item -Path "C:\tmp\dest\FlsaDev\ProDb" -ItemType Directory -Force
   ```

### Использование

#### Запуск основного скрипта:

```powershell
# Запуск от имени администратора
powershell -File "ecs_srv_pnt_&_scr_upt.ps1"
```

#### Выбор версии скрипта:

| Скрипт | PowerShell версия | Функциональность |
|--------|-------------------|------------------|
| `ecs_srv_pnt_&_scr_upt.ps1` | 1.0+ | Полная (службы закомментированы) |


## ⚙️ Конфигурация

### Пути по умолчанию:

```powershell
# MDB файлы
$MdbSourceFolder = "C:\tmp\source\FlsaProDb"
$MdbDestinationFolder = "C:\tmp\dest\FlsaDev\ProDb"

# Директория изображений
$PicSourceFolder = "C:\tmp\source\FlsaGmsPic\ECS2261"
$PicDestinationFolder = "C:\tmp\dest\FlsaDev\GMSPic\Ops\ECS2261"
```

### Службы Windows (закомментированы):

```powershell
# $ServicesToManage = @(
#     "SdrOpcHdaSvr30",
#     "SdrPLCParamsSvr30", 
#     "SdrPointSvr30",
#     "SdrRepScheduleSvr30",
#     "SdrStartHelperRpc30",
#     "SdrSAAMServer.3",
#     "SdrSimS5Svr30",
#     "SdrLogSvr30"
# )
```

### Копируемые файлы:

```powershell
$FilesToCopy = @(
    "SdrApAlg30.mdb",
    "SdrBlkAlg30.mdb", 
    "SdrBpAlg30.mdb",
    "SdrPoint30.mdb",
    "SdrSimS5Config30.mdb"
)
```

## 🔧 Функциональность

### 1. Проверка прав доступа
- Автоматическая проверка прав администратора
- Валидация существования директорий
- Создание отсутствующих папок назначения

### 2. Резервное копирование
- Создание timestamped бэкапов перед заменой
- Формат: `filename.backup.yyyyMMdd_HHmmss`
- Сохранение структуры директорий

### 3. Операции копирования

#### MDB файлы:
- Индивидуальное копирование файлов базы данных
- Проверка успешности операций
- Детальная отчетность по каждому файлу

#### Директории:
- Рекурсивное копирование всего содержимого
- Полная замена целевой директории
- Сохранение прав доступа и атрибутов

### 4. Управление службами (опционально)
- Graceful остановка служб Windows
- Автоматический перезапуск после операций
- Проверка статуса служб

### 5. Перезагрузка системы
- Интерактивный запрос подтверждения
- 10-секундный таймаут с возможностью отмены
- Только при успешном выполнении всех операций

## 📊 Пример вывода

```
ECS File Copy Script Starting...
MDB Source: C:\tmp\source\FlsaProDb
MDB Destination: C:\tmp\dest\FlsaDev\ProDb
Picture Source: C:\tmp\source\FlsaGmsPic\ECS2261
Picture Destination: C:\tmp\dest\FlsaDev\GMSPic\Ops\ECS2261

Step 1: Copying MDB files...
Copying: SdrApAlg30.mdb
  Backup created: SdrApAlg30.mdb.backup.20250906_123456
  File copied successfully
...

Step 2: Copying directory and all contents...
Copying from: C:\tmp\source\FlsaGmsPic\ECS2261
Copying to: C:\tmp\dest\FlsaDev\GMSPic\Ops\ECS2261
  Directory GMSPic copied successfully

==================================================
ECS FILE COPY COMPLETE
==================================================
MDB Files copied: 5
MDB Files failed: 0
GMSPic Directory copy: Success

Operation completed successfully!

Do you want to restart Windows now? (Y/N):
```

## 🛡️ Безопасность

- ✅ Проверка прав администратора
- ✅ Валидация путей перед операциями
- ✅ Создание резервных копий
- ✅ Подтверждение перезагрузки системы
- ✅ Обработка ошибок и откат операций

## 🔍 Устранение неполадок

### Ошибка "Execution Policy"
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Ошибка "Access Denied"
- Запустите PowerShell от имени администратора
- Проверьте права доступа к целевым директориям

### Службы не найдены
- Убедитесь, что службы установлены в системе
- Проверьте точность названий служб

## 🤝 Участие в разработке

1. Форкните репозиторий
2. Создайте ветку для новой функции (`git checkout -b feature/amazing-feature`)
3. Зафиксируйте изменения (`git commit -m 'Add amazing feature'`)
4. Отправьте в ветку (`git push origin feature/amazing-feature`)
5. Откройте Pull Request

## 📝 Лицензия

Этот проект распространяется под лицензией MIT. Подробности см. в файле [LICENSE](LICENSE).

## 👨‍💻 Автор

- **Разработчик**: Артемий Семёнов
- **Email**: semonoff@gmail.com
- **GitHub**: [SemonoffArt](https://github.com/SemonoffArt)

## 🙏 Благодарности

- LLM за вайб кодинг


---
