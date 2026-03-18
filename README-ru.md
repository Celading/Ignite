<p align="center">
  <img src="https://img.shields.io/badge/Cangjie-Ignite-ff6b35?style=for-the-badge&labelColor=1a1a2e" alt="Ignite" />
  <img src="https://img.shields.io/badge/version-0.4.51-blue?style=for-the-badge&labelColor=1a1a2e" alt="Version" />
  <img src="https://img.shields.io/badge/license-Apache%202.0-green?style=for-the-badge&labelColor=1a1a2e" alt="License" />
</p>
<div align="center">
<pre style="background:#00000000">
┌───────────────────────────────────────────────────────┐
│                <span style="color:#88C0D0;">Ignite HttpServer v0.4.51</span>              │
│                  <span style="color:#6EB186;">http://127.0.0.1:8080</span>                │
│          <span style="color:#AAAAAA;">(bound on host 0.0.0.0 and port 8080)</span>        │
│                                                       │
│    Handlers <span style="color:#555;">...........</span> 16  Processes <span style="color:#555;">...........</span> 1   │
│    Prefork <span style="color:#555;">......</span> Disabled  PID <span style="color:#555;">.............</span> 67271   │
└───────────────────────────────────────────────────────┘
</pre>
</div>

<h1 align="center">Ignite (叶燧)</h1>

<p align="center">
  <strong>Высокопроизводительный веб-фреймворк для языка Cangjie</strong><br>
  <sub>Гибкость · Минимальный API · Маршрутизация Trie · WebSocket · SSE · Swagger · TLS/HTTP2</sub>
</p>

<p align="center">
  <a href="#быстрый-старт">Быстрый старт</a> ·
  <a href="#основные-возможности">Возможности</a> ·
  <a href="#обзор-api">Обзор API</a> ·
  <a href="#промежуточное-по-middleware">Промежуточное ПО</a> ·
  <a href="#расширенное-использование">Расширенное использование</a> ·
  <a href="#проекты">Проекты</a> ·
  <a href="#лицензия">Лицензия</a>
</p>

<p align="center">
  <a href="https://atomgit.com/Cinexus/ignite-cangjie">Репозиторий</a> ·
  <a href="https://pkg.cangjie-lang.cn/package/ignite">Реестр пакетов</a>
</p>

---

## Почему Ignite?

> **«Зажги первый огонь веб-разработки на Cangjie.»**

Cangjie — язык программирования от Huawei. **Ignite** — веб-фреймворк для экосистемы Cangjie, вдохновлённый минималистичной философией [Fiber](https://gofiber.io/): **минимальный API, высокая производительность и низкое потребление ресурсов**. Идеи Fiber перенесены в систему типов Cangjie — вы можете строить высокопроизводительные HTTP-сервисы минимумом кода.

Мы считаем, что хороший фреймворк должен быть лёгким, как лист, и высекать искру, как кремень. **«叶» (лист)** — за подвижность, **«燧» (кремень)** — за воспламенение; так родилось имя **叶燧 (Ignite)**.

```
                ┌─────────────────────────────────────────┐
                │            Ignite Architecture          │
                │                                         │
                │   Request ──► Router (Trie) ──► Match   │
                │                                   │     │
                │              Middleware Chain ◄───┘     │
                │              │     │     │              │
                │              ▼     ▼     ▼              │
                │          Logger   CORS   Recover         │
                │            │                            │
                │            ▼                            │
                │       Handler ──► Ctx ──► Response      │
                │                    │                    │
                │           ┌────────┼────────┐           │
                │           ▼        ▼        ▼           │
                │         JSON     SSE    WebSocket       │
                └─────────────────────────────────────────┘
```

## Быстрый старт

### Требования

- Cangjie SDK [`cangjie-sdk`](https://cangjie-lang.cn/download) v1.1.0+
- Стандартная библиотека расширений [`cangjie-stdx`](https://gitcode.com/Cangjie/cangjie_stdx/releases/v1.0.5.1)
  - При необходимости: [Cangjie nightly (со stdx)](https://gitcode.com/Cangjie/nightly_build)
- Платформы: macOS (arm64/x86_64), Linux (arm64/x86_64), Windows (x86_64), HarmonyOS

### Подключение зависимостей

#### Добавление зависимости в `cangjie.toml`

```toml
[package]
..... # В группе зависимостей в [package] добавьте:
[dependencies]
    Ignite = "https://gitcode.com/Cinyu/Ignite-cangjie"
```

#### Использование реестра пакетов

Создайте и настройте локально `cangjie-repo.toml` по образцу `cangjie-repo.toml.example`.

> **Важно:** При использовании приватного или защищённого реестра **не коммитьте `cangjie-repo.toml`** в репозиторий (файл в .gitignore).

### Hello, Ignite!

```cangjie
import ignite.*

main() {
    let app = App()

    app.get("/", { ctx =>
        ctx.json(#"{"message": "Hello, Ignite!"}"#)
    })

    app.listen("0.0.0.0", 3000)
}
```

Всего **6 строк кода** — и HTTP-сервер запущен.

## Основные возможности

| Возможность | Описание |
|:---|:---|
| **Маршрутизация Trie** | Эффективный префиксный роутинг с параметрами пути `:id` и маской `*` |
| **Цепочка API** | Удобные вызовы: `app.get(...).post(...).use(...)` |
| **Промежуточное ПО** | Глобальное и групповое; поток задаётся через `ctx.next()` |
| **Группы маршрутов** | `app.group("/api")` с вложенными группами и авто-префиксом |
| **WebSocket** | Апгрейд до WebSocket в одну строку |
| **SSE** | Встроенная поддержка Server-Sent Events |
| **Потоковая отдача** | Chunked Transfer Encoding |
| **Swagger** | OpenAPI 3.0 и Swagger UI с кэшем (`enableSwaggerCache`), `?refresh=1` для принудительного обновления |
| **TLS/HTTP2** | Нативный TLS и HTTP/2 по ALPN |
| **HTTP-клиент** | Встроенный `RestClient` в стиле builder |
| **JSON** | `ctx.jsonSerialize` / `ctx.jsonEncode`, опционально `Config.jsonEncoder`; `ignite.serializeJson` / `deserializeJson` |
| **Файлы и Range** | `ctx.sendFile`, `ctx.download` (имя вложения), `ctx.sendFileRange` (HTTP Range 206/416) |
| **static / staticSpa** | `app.static(prefix, root)` — только статика; `app.staticSpa(prefix, root, indexFile)` — статика + откат на index для SPA |
| **Корректное завершение** | Хук `onShutdown` для освобождения ресурсов |

## Обзор API

### Регистрация маршрутов

```cangjie
let app = App()

// Базовые маршруты
app.get("/users", listUsers)
app.post("/users", createUser)
app.put("/users/:id", updateUser)
app.delete("/users/:id", deleteUser)

// Все HTTP-методы
app.all("/health", healthCheck)
```

### Параметры пути и запроса

```cangjie
app.get("/users/:id", { ctx =>
    let userId = ctx.params("id")
    let fields = ctx.queryDefault("fields", "all")
    ctx.json(#"{"id": "${userId}", "fields": "${fields}"}"#)
})
```

### Контекст запроса (Ctx)

`Ctx` — основной объект жизненного цикла запроса:

```cangjie
app.post("/upload", { ctx =>
    // Информация о запросе
    let method   = ctx.method       // "POST"
    let path     = ctx.path         // "/upload"
    let clientIp = ctx.ip           // "127.0.0.1"
    let token    = ctx.header("Authorization")

    // Тело запроса
    let body = ctx.bodyString()

    // Ответ
    ctx.status(201).json(#"{"status": "created"}"#)
})
```

**Методы ответа:**

```cangjie
ctx.json(body)                   // application/json
ctx.jsonSerialize(obj)           // сериализация при реализации StdxJsonSerializable
ctx.jsonEncode(obj)              // JsonEncodable или Config.jsonEncoder
ctx.sendString(body)             // text/plain
ctx.html(body)                   // text/html
ctx.send(byteArray)              // сырые байты
ctx.sendStatus(404)              // код + сообщение по умолчанию
ctx.redirect("/login")           // редирект 302
ctx.noContent()                  // 204 No Content
ctx.sendFile(path)               // отдача файла по пути
ctx.download(path, filename)     // вложение (filename опционален)
ctx.sendFileRange(path)          // HTTP Range → 206/416
ctx.setCookie("token", value,    // Set-Cookie
    maxAge: 3600,
    httpOnly: true,
    secure: true
)
```

### Группы маршрутов

```cangjie
let api = app.group("/api/v1")

api.use(authMiddleware)

api.get("/users", listUsers)
api.post("/users", createUser)

// Вложенная группа
let admin = api.group("/admin")
admin.use(adminOnlyMiddleware)
admin.get("/stats", getStats)
// Путь: GET /api/v1/admin/stats
```

### Конфигурация

```cangjie
let app = App(config: Config(
    appName:             "MyService",
    appVersion:          "1.0.0",   // опционально; в заголовке баннера; пусто = версия фреймворка
    serverHeader:        "Ignite/0.4",
    bodyLimit:           10 * 1024 * 1024,   // 10MB
    readTimeout:         std.time.Duration.second * 30,
    writeTimeout:        std.time.Duration.second * 30,
    enableSwagger:       true,
    enableSwaggerCache:  true,   // кэш Swagger JSON/UI; ?refresh=1 для обновления
    enablePrintRoutes:   false,  // при true — печать таблицы маршрутов при старте; баннер всегда показывается
    kmode:               false,  // при true — режим отладки: баннер с версией Ignite; используется с kmodeMiddleware
    jsonEncoder:         None   // опционально: свой энкодер JsonEncodable
))
```

#### KeyMode (kMode) Суперпользователь
- Зарезервировано для определений компонентов, доступных только разработчикам

## Промежуточное ПО (Middleware)

### Встроенное промежуточное ПО

Подключение: `import ignite.middleware.*`:

| Категория | Middleware | Описание |
|------|--------|------|
| **Безопасность** | `securityMiddleware` | Заголовки X-Content-Type-Options, X-Frame-Options, HSTS, CSP и др. |
| | `corsMiddleware` | CORS |
| | `csrfMiddleware` | CSRF, двойная отправка cookie |
| | `basicAuthMiddleware` | HTTP Basic-аутентификация |
| | `keyAuthMiddleware` | API Key (Header/Query/Cookie) |
| | `encryptCookieMiddleware` | Шифрование/расшифровка cookie (XOR + Base64) |
| **Логирование** | `loggerMiddleware` | Метод, путь, длительность; интерфейс Logger, DefaultLogger, своя реализация; `enableEntityLog` для структурированных логов |
| | `accessLogMiddleware` | IP, задержка, User-Agent |
| | `requestIdMiddleware` | X-Request-ID |
| | `recoverMiddleware` | Восстановление после panic |
| **Поток** | `rateLimitMiddleware` | Ограничение по IP или своему ключу |
| | `bodyLimitMiddleware` | Ограничение размера тела запроса |
| | `timeoutMiddleware` | Таймаут запроса |
| **Кэш** | `cacheMiddleware` | Кэш GET-ответов в памяти |
| | `etagMiddleware` | ETag + If-None-Match 304 |
| **Сессии** | `sessionMiddleware` | Cookie с ID сессии + SessionStore |
| **Прочее** | `redirectMiddleware` | Правила редиректа URL |
| | `rewriteMiddleware` | Перезапись URL (ctx locals) |
| | `staticFileMiddleware` | Статические файлы |
| | `faviconMiddleware` | favicon.ico |
| | `healthCheckMiddleware` | Эндпоинт проверки здоровья |
| | `idempotencyMiddleware` | X-Idempotency-Key |
| | `proxyMiddleware` | Обратный прокси |
| **Отладка** | `kmodeMiddleware` | Режим kmode: устанавливает ctx local `kmode`; с `Config.kmode`; баннер всегда выводит версию Ignite при kmode |

Пример:

```cangjie
import ignite.middleware.*

// Режим отладки (при Config.kmode = true при старте выводится версия Ignite и URL Swagger)
app.use(kmodeMiddleware(app.config.kmode))

// Логирование
app.use(loggerMiddleware())

// CORS
app.use(corsMiddleware(config: CorsConfig(
    allowOrigins: "https://example.com",
    allowCredentials: true,
    maxAge: 86400
)))

// Заголовки безопасности
app.use(securityMiddleware(config: SecurityConfig(hstsMaxAge: 31536000)))

// Request ID
app.use(requestIdMiddleware())
```

### Своё промежуточное ПО

```cangjie
let authMiddleware: Handler = { ctx =>
    let token = ctx.header("Authorization")
    if (let Some(t) <- token) {
        ctx.setLocal("user", "authenticated")
        ctx.next()
    } else {
        ctx.status(401).json(#"{"error": "Unauthorized"}"#)
    }
}

app.use(authMiddleware)
```

Промежуточное ПО выполняется по принципу «луковицы»; `ctx.next()` передаёт управление:

```
Request ──► Logger ──► CORS ──► Auth ──► Handler
                                          │
Response ◄── Logger ◄── CORS ◄── Auth ◄───┘
```

## Расширенное использование

### Переопределение поведения

Использование middleware с опциональной конфигурацией (например LoggerConfig: свой logger, enableEntityLog для структурированных логов):

```cangjie
app.use(loggerMiddleware())
app.use(recoverMiddleware())
```

**Своя реализация Logger:** реализуйте интерфейс `Logger` (`log(msg: String): Unit`) для управления форматом и местом вывода (файл, удалённый сервис и т.д.). Подключение через `LoggerConfig(logger: ...)`:

```cangjie
public class MyLogger: Logger {
    public func log(msg: String) {
        println("[MyLogger] " + msg)
    }
}
let loggerConfig = LoggerConfig(logger: MyLogger())
app.use(loggerMiddleware(config: loggerConfig))
```

Либо настройка вывода через `LoggerConfig.output`:

```cangjie
app.use(loggerMiddleware(config: LoggerConfig(output: { msg => 
    writeFile("/var/log/myapp.log", msg + "\n", append: true)
})))
```

### WebSocket

```cangjie
app.ws("/chat", { conn =>
    while (true) {
        let msg = conn.readMessage()
        if (msg.isClose) { break }
        if (msg.isText) {
            conn.writeText("Echo: ${msg.text()}")
        }
    }
    conn.close()
})
```

### Server-Sent Events (SSE)

```cangjie
app.get("/events", { ctx =>
    let sse = ctx.sse()
    sse.sendRetry(3000)
    for (i in 0..10) {
        sse.sendEvent(
            #"{"count": ${i}}"#,
            event: "counter",
            id: "${i}"
        )
    }
})
```

### Потоковый ответ

```cangjie
app.get("/stream", { ctx =>
    let writer = ctx.writer()
    writer.writeString("chunk 1\n")
    writer.writeString("chunk 2\n")
    writer.writeString("chunk 3\n")
})
```

### Статические файлы и откат для SPA (static / staticSpa)

**Только статика:** `app.static(prefix, root)` сопоставляет URL с файлами в `root`; ответ отдаётся только при существовании файла, иначе запрос уходит дальше по маршрутам или в 404.

**Статика в приоритете + откат для SPA:** для Next.js static export, Vite/React и других SPA часто нужно «отдать файл, если есть, иначе вернуть index.html для клиентского роутинга». Используйте `app.staticSpa(prefix, root, indexFile)`:

```cangjie
// Для /: сначала файл из frontend/out; при отсутствии — frontend/out/index.html
app.staticSpa("/", "frontend/out", "index.html")
```

- `prefix`: префикс URL (например `"/"`); для корня регистрируются GET/HEAD `/` и `/*`.
- `root`: корень статики (например `out` у Next.js, `dist` у Vite).
- `indexFile`: файл по умолчанию при отсутствии совпадения; по умолчанию `"index.html"`.
- Безопасность пути: запросы с `..` отклоняются и откатываются к index-файлу.

Сначала регистрируйте API-маршруты, затем в конце — `staticSpa`, чтобы API не перекрывалось общим обработчиком.

#### Нужна только SPA?

Маршруты в Ignite обрабатываются **сверху вниз**. Из соображений **безопасности** при необходимости «жадной» статики **регистрируйте её последней**:

```cangjie
app.static("/app", "frontend/out")
app.static("/", "frontend/out")
app.static("/*", "frontend/out")
```

### Swagger / OpenAPI

```cangjie
let app = App(config: Config(
    enableSwagger: true,
    swaggerPath: "/docs"
))

app.swagger(SwaggerInfo(
    title: "My API",
    version: "1.0.0",
    description: "Powered by Ignite"
))

app.get("/users/:id", getUser, option: RouteOption()
    .withSummary("Get user")
    .withDescription("Get user by ID")
    .withTags(["Users"])
    .withParams([ParamSpec(
        name: "id",
        location: ParamLocation.Path,
        required: true,
        description: "User ID"
    )])
    .withResponses([
        ResponseSpec(status: 200, description: "Success"),
        ResponseSpec(status: 404, description: "Not found")
    ])
)

// /docs — Swagger UI, /docs/json — OpenAPI JSON
```

### TLS / HTTPS

```cangjie
let app = App(config: Config(
    tlsCertFile: "./cert.pem",
    tlsKeyFile:  "./key.pem"
))

// TLS + HTTP/2 ALPN (h2, http/1.1)
app.listen("0.0.0.0", 443)
```

**HTTP/2:** при включённом TLS сервер согласует `h2`. Проверка: `curl -sI --http2 https://localhost:3443/`.

### HTTP-клиент

```cangjie
import ignite.client.*

let client = RestClient()

let resp = client.get("https://api.example.com/users")
println(resp.body())
resp.discard()

// POST JSON
let resp2 = client.postJson(
    "https://api.example.com/users",
    #"{"name": "Ignite"}"#
)
println(resp2.status)
resp2.discard()

client.close()
```

**API клиента:**

| Возможность | API |
|------|-----|
| Методы | `get`, `post`, `put`, `patch`, `delete`, `head`, `options` |
| JSON | `postJson(url, json)` |
| Форма | `postForm(url, ArrayList<(String,String)>)` |
| Multipart | `postMultipart(url, fields, files)`, `MultipartFile(name, filename, contentType, data)` |
| Builder | `request().method().url().query(k,v).header()/addHeader().basicAuth().bearerToken().form()/multipart().send()` |
| Base URL | `baseUrl("https://api.example.com")` |
| Заголовки по умолчанию | `defaultHeader(name, value)` |
| Cookie | `useCookies()` или `useCookies(store)` |
| Ответ | `status`, `body()`/`bodyBytes()`/`bodyStream()`, `json()`, `header(name)`, `headerValues(name)`, `isOk()`/`isSuccess()`, `discard()` |

### Обработка ошибок и корректное завершение

```cangjie
app.onError({ ctx, err =>
    println("[Error] ${err.message}")
    ctx.status(500).json(#"{"error": "${err.message}"}"#)
})

app.onShutdown({
    println("Releasing resources...")
    // Закрытие БД, очистка кэшей и т.д.
})
```

## Структура проекта

```
ignite/
├── src/
│   ├── app.cj            # Ядро приложения: создание, маршруты, запуск, жизненный цикл
│   ├── config.cj         # Конфигурация: таймауты, лимиты, TLS, Swagger и т.д.
│   ├── ctx.cj            # Контекст запроса: API запроса/ответа
│   ├── route.cj          # Метаданные маршрута и результат сопоставления
│   ├── router.cj        # Маршрутизатор Trie
│   ├── handler.cj       # Типы Handler / ErrorHandler
│   ├── group.cj          # Группы маршрутов: префикс и групповое middleware
│   ├── stream.cj         # ResponseWriter / SseWriter
│   ├── websocket.cj      # Подключение WebSocket
│   ├── swagger.cj        # Генератор OpenAPI 3.0
│   ├── middleware/
│   │   ├── logger.cj, cors.cj, recover.cj   # Базовые
│   │   ├── security.cj, csrf.cj, basic_auth.cj, key_auth.cj, encrypt_cookie.cj
│   │   ├── access_log.cj, request_id.cj, rate_limit.cj, body_limit.cj, timeout.cj
│   │   ├── cache.cj, etag.cj, session.cj
│   │   ├── proxy.cj, redirect.cj, rewrite.cj, static_file.cj, favicon.cj
│   │   ├── health_check.cj, idempotency.cj, utils.cj
│   └── client/
│       └── client.cj     # HTTP-клиент (RestClient)
└── cjpm.toml             # Конфигурация пакета
```

## Поддерживаемые платформы

| Платформа | Архитектура | Статус |
|:---|:---|:---:|
| macOS | aarch64 (Apple Silicon) | ✅ |
| macOS | x86_64 (Intel) | ✅ |
| Linux | x86_64 | ✅ |
| Linux | aarch64 | ✅ |
| Windows | x86_64 | ✅ |

## Проекты (叶燧星火)

> Командам, которые двигаются со скоростью света.

<a href="https://gitcode.com/copur/lanlu">兰鹿 (Lanlu)</a> — Система управления архивом манги на Cangjie

### Примеры Ignite

- <a href="https://atomgit.com/cinyu/ignite-benchmark">Ignite-Benchmark</a> — Рекомендуемые практики
- <a href="https://gitcode.com/cinyu/easyTODO-core">easyTODO-core</a> — Бэкенд TODO на чистом Cangjie + HTML
- <a href="https://atomgit.com/cinyu/igMessanging">igMessanging</a> — Бэкенд чата на чистом Cangjie + HTML

## Документация API

- В разработке.

## Заметка для сопровождающих

- **Версия:** Единственный источник истины — `[package].version` в `cjpm.toml`. После изменения запустите `./scripts/gen_version.sh`, чтобы синхронизировать `src/version.cj` (версия фреймворка в баннере и т.д.).

## Лицензия

Открытый код под [Apache License 2.0](LICENSE).

---

<p align="center">
  <sub>Собери на Cangjie. Зажги возможное.</sub><br>
  <strong>Built with Cangjie. Ignited by passion.</strong>
</p>
