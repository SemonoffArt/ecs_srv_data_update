# 🔄 ECS Service Data Update

**Автоматизированный скрипт для обновления данных ECS сервисов с сетевого сервера**

[![PowerShell](https://img.shields.io/badge/PowerShell-1.0%2B-blue.svg)](https://docs.microsoft.com/en-us/powershell/)
[![Windows](https://img.shields.io/badge/Platform-Windows-lightgrey.svg)](https://www.microsoft.com/windows/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📋 Описание

Этот проект представляет собой PowerShell скрипт для автоматизации процесса обновления данных в системах ECS (Elastic Compute Service). Скрипт копирует файлы базы данных и директории с сетевого сервера `ECS2261SVR02` на локальную машину, создавая резервные копии существующих данных перед заменой.

Скрипт предназначен для системных администраторов и DevOps инженеров, которым необходимо выполнять регулярные операции обновления данных и файлов конфигурации из централизованного источника.

## ✨ Основные возможности

- 🌐 **Работа с сетевыми папками** - доступ к централизованному серверу ECS2261SVR02
- 🔧 **Управление службами Windows** (закомментировано)
- 📁 **Копирование файлов базы данных** (.mdb файлы)
- 🗂️ **Синхронизация директорий** с рекурсивным копированием
- 💾 **Автоматическое создание резервных копий** перед заменой
- 🔄 **Перезагрузка системы** с подтверждением пользователя
- 🎨 **Цветной вывод** для лучшей читаемости
- ⚡ **Совместимость с PowerShell 1.0+**
- 🔒 **Проверка сетевых прав доступа** и подключений

## 📂 Структура проекта

```
ecs_srv_data_update/
├── 📄 ecs_srv_pnt_scr_upt.ps1       # Основной скрипт с сетевой функциональностью
├── 📄 .gitignore                   # Исключения для Git
├── 📄 LICENSE                      # Лицензия MIT
└── 📄 README.md                    # Этот файл
```

## 🚀 Быстрый старт

### Предварительные требования

- ✅ Windows OS (Windows 7/Server 2008 или новее)
- ✅ PowerShell 1.0 или выше
- ✅ Права администратора (опционально)
- 🌐 **Сетевое подключение** к серверу `ECS2261SVR02`
- 🔒 **Права доступа** к сетевым папкам:
  - `\\ECS2261SVR02\FlsaProDb`
  - `\\ECS2261SVR02\FlsaGmsPic\ECS2261`

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

3. **Проверьте доступ к сетевым папкам:**
   ```powershell
   # Проверьте доступ к сетевым ресурсам
   Test-Path "\\ECS2261SVR02\FlsaProDb"
   Test-Path "\\ECS2261SVR02\FlsaGmsPic\ECS2261"
   ```

4. **Создайте локальные целевые директории:**
   ```powershell
   # Создайте локальные папки назначения
   New-Item -Path "C:\tmp\dest\FlsaDev\ProDb" -ItemType Directory -Force
   New-Item -Path "C:\tmp\dest\FlsaDev\GMSPic\Ops\ECS2261" -ItemType Directory -Force
   ```

### Использование

#### Запуск основного скрипта:

```powershell
# Запуск от имени администратора
powershell -Command "ecs_srv_pnt_scr_upt.ps1"
```

#### Описание скрипта:

| Компонент | Описание |
|-----------|-------------|
| **Сетевые источники** | `\\ECS2261SVR02\FlsaProDb` и `\\ECS2261SVR02\FlsaGmsPic\ECS2261` |
| **Локальное назначение** | `C:\tmp\dest\FlsaDev\` |
| **Управление службами** | Закомментировано (можно активировать) |
| **Перезагрузка** | Автоматический запрос после успешного копирования |


## ⚙️ Конфигурация

### Пути по умолчанию:

```powershell
# Сетевые источники (ECS2261SVR02)
$MdbSourceFolder = "\\ECS2261SVR02\FlsaProDb"
$PicSourceFolder = "\\ECS2261SVR02\FlsaGmsPic\ECS2261"

# Локальные назначения
$MdbDestinationFolder = "C:\tmp\dest\FlsaDev\ProDb"
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

### 1. Проверка сетевого доступа
- Проверка доступности сетевых папок `\\ECS2261SVR02`
- Валидация прав доступа к сетевым ресурсам
- Автоматические подсказки по устранению сетевых проблем
- Создание отсутствующих локальных папок назначения

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
MDB Source: \\ECS2261SVR02\FlsaProDb
MDB Destination: C:\tmp\dest\FlsaDev\ProDb
Picture Source: \\ECS2261SVR02\FlsaGmsPic\ECS2261
Picture Destination: C:\tmp\dest\FlsaDev\GMSPic\Ops\ECS2261

Step 1: Copying MDB files...
Copying: SdrApAlg30.mdb
  Backup created: SdrApAlg30.mdb.backup.20250906_123456
  File copied successfully
...

Step 2: Copying directory and all contents...
Copying from: \\ECS2261SVR02\FlsaGmsPic\ECS2261
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

### Ошибка "Access Denied" или сетевые проблемы
- Проверьте сетевое подключение к `ECS2261SVR02`
- Убедитесь в наличии прав доступа к сетевым папкам
- Проверьте авторизацию в домене/рабочей группе
- Попробуйте подключиться вручную: `\\ECS2261SVR02`

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
