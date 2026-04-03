import ignite.*

let FILE_SAMPLE_GUIDE = "samples/files/assets/guide.txt"

main() {
    let app = App(config: Config(appName: "ignite-sample-files"))

    app.get("/", { ctx =>
        _ = ctx.json(
            "{\"routes\":[\"/view\",\"/download\",\"/range\"],\"asset\":\"guide.txt\"}"
        )
    })

    app.get("/view", { ctx =>
        _ = ctx.sendFile(FILE_SAMPLE_GUIDE)
    })

    app.get("/download", { ctx =>
        _ = ctx.download(FILE_SAMPLE_GUIDE, filename: "ignite-guide.txt")
    })

    app.get("/range", { ctx =>
        _ = ctx.sendFileRange(FILE_SAMPLE_GUIDE)
    })

    println("[sample/files] listening on http://127.0.0.1:18812")
    println("[sample/files] try: curl -i http://127.0.0.1:18812/view")
    println("[sample/files] try: curl -i http://127.0.0.1:18812/download")
    println("[sample/files] try: curl -i -H 'Range: bytes=0-63' http://127.0.0.1:18812/range")
    app.listen("127.0.0.1", 18812)
}
