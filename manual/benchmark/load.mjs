import http from "node:http";
import { appendFileSync } from "node:fs";

const target = new URL(process.env.IGNITE_BENCH_URL ?? "http://127.0.0.1:18880/plaintext");
const concurrency = positiveInt("IGNITE_BENCH_CONCURRENCY", 32);
const durationSeconds = positiveNumber("IGNITE_BENCH_DURATION", 10);
const warmupSeconds = positiveNumber("IGNITE_BENCH_WARMUP", 2);
const output = process.env.IGNITE_BENCH_OUTPUT ?? "";
const agent = new http.Agent({ keepAlive: true, maxSockets: concurrency, maxFreeSockets: concurrency });

await runPhase(warmupSeconds, false);
const result = await runPhase(durationSeconds, true);
agent.destroy();

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
    url: target.toString(),
    concurrency,
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
        resolve(bytes);
      });
    });
    request.on("error", reject);
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
