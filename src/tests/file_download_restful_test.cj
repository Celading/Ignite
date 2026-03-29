package ignite.tests

import ignite.*
import std.collection.ArrayList
import std.fs.{File, OpenMode}

@Test
public class FileDownloadAndRestfulTestSuite {
    @TestCase
    public func testDownloadAndRangeSupportLeadingSlashRelativePath(): Unit {
        let app = App(config: Config())

        app.get("/download-readme", { ctx =>
            _ = ctx.download("/README.md", filename: "README.md")
        })
        app.get("/range-readme", { ctx =>
            _ = ctx.sendFileRange("/README.md")
        })

        let downloadResp = app.handleForTest("GET", "/download-readme")
        @Assert(downloadResp.status, UInt16(200))
        @Assert(contains(downloadResp.header("content-disposition") ?? "", "attachment; filename=\"README.md\""), true)
        @Assert(contains(downloadResp.body, "Ignite"), true)

        let rangeResp = app.handleForTest(
            "GET",
            "/range-readme",
            headers: [("range", "bytes=0-31")]
        )
        @Assert(rangeResp.status, UInt16(206))
        @Assert(contains(rangeResp.header("content-range") ?? "", "bytes 0-31/"), true)
        @Assert(rangeResp.header("content-length") ?? "", "32")
        @Assert(rangeResp.body.size, Int64(32))
    }

    @TestCase
    public func testLargeFileDownloadAndRangeStreamAcrossChunks(): Unit {
        let fixturePath = "/tmp/ignite_streaming_download_fixture.txt"
        let payload = buildLargeAsciiPayload()
        writeTextFile(fixturePath, payload)

        let app = App(config: Config())
        app.get("/large-file", { ctx =>
            _ = ctx.sendFile(fixturePath)
        })
        app.get("/large-range", { ctx =>
            _ = ctx.sendFileRange(fixturePath)
        })
        app.head("/large-file", { ctx =>
            _ = ctx.sendFile(fixturePath)
        })

        let fileResp = app.handleForTest("GET", "/large-file")
        @Assert(fileResp.status, UInt16(200))
        @Assert(fileResp.header("content-length") ?? "", payload.size.toString())
        @Assert(fileResp.header("accept-ranges") ?? "", "bytes")
        @Assert(fileResp.body, payload)

        let start: Int64 = 65520
        let end: Int64 = 65679
        let rangeResp = app.handleForTest(
            "GET",
            "/large-range",
            headers: [("range", "bytes=${start}-${end}")]
        )
        @Assert(rangeResp.status, UInt16(206))
        @Assert(rangeResp.header("content-range") ?? "", "bytes ${start}-${end}/${payload.size}")
        @Assert(rangeResp.header("content-length") ?? "", "${end - start + 1}")
        @Assert(rangeResp.header("accept-ranges") ?? "", "bytes")
        @Assert(rangeResp.body, sliceText(payload, start, end + 1))

        let headResp = app.handleForTest("HEAD", "/large-file")
        @Assert(headResp.status, UInt16(200))
        @Assert(headResp.header("content-length") ?? "", payload.size.toString())
        @Assert(headResp.header("accept-ranges") ?? "", "bytes")
        @Assert(headResp.body, "")
    }

    @TestCase
    public func testRestfulCrudEndToEnd(): Unit {
        let app = App(config: Config())
        let store = TodoStore()

        app.get("/todos", { ctx =>
            let doneFilterRaw = (ctx.queryFromUrl("done") ?? "").trimAscii().toAsciiLower()
            if (doneFilterRaw == "true") {
                _ = ctx.json(todoListJson(store.listByDone(true)))
                return
            }
            if (doneFilterRaw == "false") {
                _ = ctx.json(todoListJson(store.listByDone(false)))
                return
            }
            if (doneFilterRaw.size > 0) {
                _ = ctx.status(400).json(errorJson("done must be true or false"))
                return
            }
            _ = ctx.json(todoListJson(store.listAll()))
        })

        app.post("/todos", { ctx =>
            let title = (ctx.queryFromUrl("title") ?? "").trimAscii()
            if (title.size == 0) {
                _ = ctx.status(400).json(errorJson("missing title query parameter"))
                return
            }
            _ = ctx.status(201).json(todoJson(store.create(title)))
        })

        app.get("/todos/:id", { ctx =>
            if (let Some(id) <- parseInt64Strict(ctx.params("id"))) {
                if (let Some(todo) <- store.find(id)) {
                    _ = ctx.json(todoJson(todo))
                } else {
                    _ = ctx.status(404).json(errorJson("todo not found"))
                }
                return
            }
            _ = ctx.status(400).json(errorJson("invalid id"))
        })

        app.patch("/todos/:id", { ctx =>
            if (let Some(id) <- parseInt64Strict(ctx.params("id"))) {
                let doneRaw = (ctx.queryFromUrl("done") ?? "").trimAscii().toAsciiLower()
                if (doneRaw != "true" && doneRaw != "false") {
                    _ = ctx.status(400).json(errorJson("done must be true or false"))
                    return
                }
                if (let Some(todo) <- store.setDone(id, doneRaw == "true")) {
                    _ = ctx.json(todoJson(todo))
                } else {
                    _ = ctx.status(404).json(errorJson("todo not found"))
                }
                return
            }
            _ = ctx.status(400).json(errorJson("invalid id"))
        })

        app.delete("/todos/:id", { ctx =>
            if (let Some(id) <- parseInt64Strict(ctx.params("id"))) {
                if (store.remove(id)) {
                    _ = ctx.sendStatus(204)
                } else {
                    _ = ctx.status(404).json(errorJson("todo not found"))
                }
                return
            }
            _ = ctx.status(400).json(errorJson("invalid id"))
        })

        let list0 = app.handleForTest("GET", "/todos")
        @Assert(list0.status, UInt16(200))
        @Assert(contains(list0.body, #""items":[]"#), true)

        let created = app.handleForTest("POST", "/todos?title=learn-ignite")
        @Assert(created.status, UInt16(201))
        @Assert(contains(created.body, #""id":1"#), true)
        @Assert(contains(created.body, #""title":"learn-ignite""#), true)
        @Assert(contains(created.body, #""done":false"#), true)

        let detail = app.handleForTest("GET", "/todos/1")
        @Assert(detail.status, UInt16(200))
        @Assert(contains(detail.body, #""id":1"#), true)

        let patched = app.handleForTest("PATCH", "/todos/1?done=true")
        @Assert(patched.status, UInt16(200))
        @Assert(contains(patched.body, #""done":true"#), true)

        let filtered = app.handleForTest("GET", "/todos?done=true")
        @Assert(filtered.status, UInt16(200))
        @Assert(contains(filtered.body, #""id":1"#), true)

        let removed = app.handleForTest("DELETE", "/todos/1")
        @Assert(removed.status, UInt16(204))

        let detailMissing = app.handleForTest("GET", "/todos/1")
        @Assert(detailMissing.status, UInt16(404))
        @Assert(contains(detailMissing.body, "todo not found"), true)
    }

    func contains(text: String, sub: String): Bool {
        let t = text.toRuneArray()
        let p = sub.toRuneArray()
        if (p.size == 0) { return true }
        if (t.size < p.size) { return false }
        var i: Int64 = 0
        while (i <= t.size - p.size) {
            var ok = true
            var j: Int64 = 0
            while (j < p.size) {
                if (t[i + j] != p[j]) {
                    ok = false
                    break
                }
                j += 1
            }
            if (ok) { return true }
            i += 1
        }
        false
    }

    func buildLargeAsciiPayload(): String {
        let line = "ignite-streaming-regression-0123456789-ABCDEFGHIJKLMNOPQRSTUVWXYZ\n"
        var out = ""
        var i: Int64 = 0
        while (i < 4096) {
            out += line
            i += 1
        }
        out
    }

    func writeTextFile(path: String, body: String): Unit {
        let file = File(path, OpenMode.Write)
        file.write(body.toArray())
        file.close()
    }

    func sliceText(text: String, start: Int64, endExclusive: Int64): String {
        let runes = text.toRuneArray()
        var out = ""
        var i = start
        while (i < endExclusive && i < runes.size) {
            out += runes[i].toString()
            i += 1
        }
        out
    }

    func errorJson(message: String): String {
        #"{"error":"bad_request","message":""# + escapeJson(message) + #""}"#
    }

    func todoListJson(items: Array<TodoItem>): String {
        var out = #"{"items":["#
        for (i in 0..items.size) {
            if (i > 0) {
                out += ","
            }
            out += todoJson(items[i])
        }
        out += "]}"
        out
    }

    func todoJson(todo: TodoItem): String {
        #"{"id":"# + todo.id.toString() +
            #","title":""# + escapeJson(todo.title) +
            #"","done":"# + boolToJson(todo.done) + #"}"#
    }

    func boolToJson(v: Bool): String {
        if (v) { "true" } else { "false" }
    }

    func parseInt64Strict(text: String): ?Int64 {
        let raw = text.trimAscii()
        if (raw.size == 0) {
            return None
        }
        let chars = raw.toRuneArray()
        var i: Int64 = 0
        var sign: Int64 = 1
        if (chars[0] == r'-') {
            sign = -1
            i = 1
        } else if (chars[0] == r'+') {
            i = 1
        }
        if (i >= chars.size) {
            return None
        }
        var out: Int64 = 0
        while (i < chars.size) {
            let ch = chars[i]
            if (ch < r'0' || ch > r'9') {
                return None
            }
            out = out * 10 + (Int64(UInt32(ch)) - Int64(UInt32(r'0')))
            i += 1
        }
        Some(out * sign)
    }

    func escapeJson(input: String): String {
        var out = ""
        for (r in input.toRuneArray()) {
            if (r == r'\\') {
                out += "\\\\"
            } else if (r == r'"') {
                out += "\\\""
            } else if (r == r'\n') {
                out += "\\n"
            } else if (r == r'\r') {
                out += "\\r"
            } else if (r == r'\t') {
                out += "\\t"
            } else {
                out += r.toString()
            }
        }
        out
    }
}

public class TodoItem {
    public let id: Int64
    public let title: String
    public var done: Bool

    public init(id: Int64, title: String, done: Bool) {
        this.id = id
        this.title = title
        this.done = done
    }
}

public class TodoStore {
    var items: ArrayList<TodoItem> = ArrayList<TodoItem>()
    var nextId: Int64 = 1

    public func create(title: String): TodoItem {
        let item = TodoItem(nextId, title, false)
        items.add(item)
        nextId += 1
        item
    }

    public func listAll(): Array<TodoItem> {
        items.toArray()
    }

    public func listByDone(done: Bool): Array<TodoItem> {
        let out = ArrayList<TodoItem>()
        for (item in items) {
            if (item.done == done) {
                out.add(item)
            }
        }
        out.toArray()
    }

    public func find(id: Int64): ?TodoItem {
        for (item in items) {
            if (item.id == id) {
                return Some(item)
            }
        }
        None
    }

    public func setDone(id: Int64, done: Bool): ?TodoItem {
        for (item in items) {
            if (item.id == id) {
                item.done = done
                return Some(item)
            }
        }
        None
    }

    public func remove(id: Int64): Bool {
        let kept = ArrayList<TodoItem>()
        var removed = false
        for (item in items) {
            if (item.id == id) {
                removed = true
            } else {
                kept.add(item)
            }
        }
        items = kept
        removed
    }
}
