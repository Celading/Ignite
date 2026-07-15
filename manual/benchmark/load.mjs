import http from "node:http";
import http2 from "node:http2";
import { appendFileSync } from "node:fs";

const target = new URL(process.env.IGNITE_BENCH_URL ?? "http://127.0.0.1:18880/plaintext");
const concurrency = positiveInt("IGNITE_BENCH_CONCURRENCY", 32);
const durationSeconds = positiveNumber("IGNITE_BENCH_DURATION", 10);
const warmupSeconds = positiveNumber("IGNITE_BENCH_WARMUP", 2);
const output = process.env.IGNITE_BENCH_OUTPUT ?? "";
const label = process.env.IGNITE_BENCH_LABEL ?? "ignite-benchmark";
const version = process.env.IGNITE_BENCH_VERSION ?? "unknown";
const backend = process.env.IGNITE_BENCH_BACKEND ?? "unknown";
const track = process.env.IGNITE_BENCH_TRACK ?? "public";
const benchmarkProfile = process.env.IGNITE_BENCH_PROFILE ?? "balanced";
const implementation = process.env.IGNITE_BENCH_IMPLEMENTATION ?? backend;
const scenario = process.env.IGNITE_BENCH_SCENARIO ?? target.pathname.replace(/^\//, "");
const protocol = process.env.IGNITE_BENCH_PROTOCOL ?? `${target.protocol === "https:" ? "https" : "http"}/h1`;
const useH2 = protocol === "http/h2" || protocol === "https/h2";
const caveats = (process.env.IGNITE_BENCH_CAVEATS ?? "")
  .split("|")
  .map(item => item.trim())
  .filter(Boolean);
const expectedResponseBytes = positiveInt("IGNITE_BENCH_EXPECTED_BYTES", 0);
const requestTimeoutMs = positiveInt("IGNITE_BENCH_REQUEST_TIMEOUT_MS", 5000);
const agent = useH2 ? null : new http.Agent({
  keepAlive: true,
  maxSockets: concurrency,
  maxFreeSockets: concurrency
});
const h2Session = useH2 ? http2.connect(target.origin) : null;
if (h2Session) {
  // Stream-level failures are counted by requestH2Once; keep the session event
  // from becoming an unrelated uncaught process error.
  h2Session.on("error", () => {});
}

await runPhase(warmupSeconds, false);
const result = await runPhase(durationSeconds, true);
if (agent) {
  agent.destroy();
}
if (h2Session) {
  h2Session.close();
}

const line = JSON.stringify(result);
if (output) {
  appendFileSync(output, `${line}\n`);
}
process.stdout.write(`${line}\n`);

async function runPhase(seconds, collect) {
  const deadline = process.hrtime.bigint() + BigInt(Math.floor(seconds * 1e9));
  const latencies = [];
  let completed = 0;
  let errors = 0;
  let bytes = 0;
  const started = process.hrtime.bigint();

  await Promise.all(Array.from({ length: concurrency }, async () => {
    while (process.hrtime.bigint() < deadline) {
      const requestStarted = process.hrtime.bigint();
      try {
        const responseBytes = await requestOnce();
        if (collect) {
          completed += 1;
          bytes += responseBytes;
          latencies.push(Number(process.hrtime.bigint() - requestStarted) / 1e6);
        }
      } catch (error) {
        if (collect) {
          errors += 1;
        }
      }
    }
  }));

  const elapsedSeconds = Number(process.hrtime.bigint() - started) / 1e9;
  latencies.sort((a, b) => a - b);
  return {
    schema: "ignite-benchmark-v1",
    timestamp: new Date().toISOString(),
    label,
    version,
    backend,
    track,
    benchmarkProfile,
    implementation,
    scenario,
    protocol,
    caveats,
    url: target.toString(),
    concurrency,
    expectedResponseBytes,
    requestTimeoutMs,
    durationSeconds: round(elapsedSeconds),
    requests: completed,
    errors,
    requestsPerSecond: round(completed / elapsedSeconds),
    transferBytesPerSecond: round(bytes / elapsedSeconds),
    latencyMs: {
      p50: percentile(latencies, 0.50),
      p95: percentile(latencies, 0.95),
      p99: percentile(latencies, 0.99),
      max: latencies.length === 0 ? 0 : round(latencies[latencies.length - 1])
    }
  };
}

function requestOnce() {
  if (h2Session) {
    return requestH2Once(h2Session);
  }
  return new Promise((resolve, reject) => {
    const request = http.request(target, { agent, method: "GET" }, response => {
      let bytes = 0;
      response.on("data", chunk => {
        bytes += chunk.length;
      });
      response.on("end", () => {
        if (response.statusCode !== 200) {
          reject(new Error(`unexpected status ${response.statusCode}`));
          return;
        }
        if (expectedResponseBytes > 0 && bytes !== expectedResponseBytes) {
          reject(new Error(`unexpected body size ${bytes}, expected ${expectedResponseBytes}`));
          return;
        }
        resolve(bytes);
      });
    });
    request.on("error", reject);
    request.setTimeout(requestTimeoutMs, () => {
      request.destroy(new Error(`request timeout after ${requestTimeoutMs}ms`));
    });
    request.end();
  });
}

function requestH2Once(session) {
  return new Promise((resolve, reject) => {
    const request = session.request({
      ":method": "GET",
      ":scheme": target.protocol === "https:" ? "https" : "http",
      ":authority": target.host,
      ":path": `${target.pathname}${target.search}`
    });
    let bytes = 0;
    let status = 0;
    const timer = setTimeout(() => {
      request.close(http2.constants.NGHTTP2_CANCEL);
      reject(new Error(`request timeout after ${requestTimeoutMs}ms`));
    }, requestTimeoutMs);
    request.on("response", headers => {
      status = Number(headers[":status"] ?? 0);
    });
    request.on("data", chunk => {
      bytes += chunk.length;
    });
    request.on("end", () => {
      clearTimeout(timer);
      if (status !== 200) {
        reject(new Error(`unexpected status ${status}`));
        return;
      }
      if (expectedResponseBytes > 0 && bytes !== expectedResponseBytes) {
        reject(new Error(`unexpected body size ${bytes}, expected ${expectedResponseBytes}`));
        return;
      }
      resolve(bytes);
    });
    request.on("error", error => {
      clearTimeout(timer);
      reject(error);
    });
    request.end();
  });
}

function percentile(values, ratio) {
  if (values.length === 0) {
    return 0;
  }
  return round(values[Math.min(values.length - 1, Math.ceil(values.length * ratio) - 1)]);
}

function positiveInt(name, fallback) {
  const value = Number.parseInt(process.env[name] ?? "", 10);
  return Number.isFinite(value) && value > 0 ? value : fallback;
}

function positiveNumber(name, fallback) {
  const value = Number.parseFloat(process.env[name] ?? "");
  return Number.isFinite(value) && value > 0 ? value : fallback;
}

function round(value) {
  return Math.round(value * 1000) / 1000;
}
