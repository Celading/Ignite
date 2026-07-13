# Ignite 0.8.0 Benchmark Baseline

This directory is the first repository-owned executable benchmark for the
`IgniteNEXT` 0.8.0 line. It is intentionally smaller than a public performance
report: it proves that one repeatable server/load/result loop exists before we
add multi-version or competitor comparisons.

## Run

```bash
./manual/benchmark/run.sh
```

The default matrix exercises:

- `/plaintext`: small fixed text response;
- `/json`: fixed JSON response through `Ctx.json(String)`;
- `/bytes/64k`: a prebuilt response crossing common socket buffer boundaries.

The runner writes JSON Lines to `/tmp/ignite0800-benchmark.jsonl` and keeps the
server log at `/tmp/ignite0800-benchmark-server.log`.

## Controls

```bash
IGNITE_BENCH_CONCURRENCY=64 \
IGNITE_BENCH_WARMUP=3 \
IGNITE_BENCH_DURATION=15 \
IGNITE_BENCH_OUTPUT=/tmp/ignite0800-run.jsonl \
./manual/benchmark/run.sh
```

Use `IGNITE_BENCH_BACKEND=stdx` to exercise the explicit rollback server path.
The default is Ignite native cleartext H1.

If the current commit has already been built and the host is intentionally
offline, set `IGNITE_SAMPLE_SKIP_BUILD=1`. Without that flag the runner builds
the current package first so stale artifacts cannot silently become benchmark
truth.

## Result Contract

Each line contains the URL, concurrency, elapsed duration, completed requests,
errors, requests/second, transferred bytes/second, and p50/p95/p99/max latency.

This baseline is not a public ranking and does not normalize CPU affinity,
power state, compiler optimization level, TLS, H2, cross-host networking, or
competitor configuration. Those controls belong in the later internal
multi-version/competitor benchmark packet after the 0800 capability baseline
is accepted.
