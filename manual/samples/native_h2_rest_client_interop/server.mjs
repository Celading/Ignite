import http2 from "node:http2";

const port = Number.parseInt(process.env.IGNITE_H2_INTEROP_PORT ?? "18882", 10);
const server = http2.createServer();
let sessionCount = 0;
let retryCount = 0;

server.on("session", (session) => {
  session.__igniteSessionId = String(++sessionCount);
  session.on("error", () => {});
});

server.on("stream", (stream, headers) => {
  const path = headers[":path"];
  const sessionId = stream.session.__igniteSessionId;
  stream.on("error", () => {});

  if (path === "/patch") {
    const chunks = [];
    stream.on("data", (chunk) => chunks.push(chunk));
    stream.on("end", () => {
      const body = Buffer.concat(chunks).toString("utf8");
      stream.respond({ ":status": 202, "x-node-session": sessionId });
      stream.end(`node:${body}`);
    });
    return;
  }

  if (path === "/retry") {
    retryCount += 1;
    if (retryCount === 1) {
      stream.respond({ ":status": 503, "x-node-session": sessionId });
      stream.end("retry");
    } else {
      stream.respond({ ":status": 200, "x-node-session": sessionId });
      stream.end("recovered");
    }
    return;
  }

  if (path === "/cancel") {
    stream.respond({ ":status": 200, "x-node-session": sessionId });
    stream.write("first");
    const timer = setInterval(() => stream.write("-later"), 25);
    stream.on("close", () => clearInterval(timer));
    return;
  }

  if (path === "/after") {
    stream.respond({ ":status": 200, "x-node-session": sessionId });
    stream.end("fresh");
    return;
  }

  stream.respond({ ":status": 404 });
  stream.end("missing");
});

server.listen(port, "127.0.0.1", () => {
  process.stdout.write(`ready:${port}\n`);
});

const shutdown = () => server.close(() => process.exit(0));
process.on("SIGTERM", shutdown);
process.on("SIGINT", shutdown);
