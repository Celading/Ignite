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
IGNITE_BENCH_REQUEST_TIMEOUT_MS=5000 \
IGNITE_BENCH_VERSION=IgniteNEXT-d6c42b0 \
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

Each line contains a run label, version, backend, URL, concurrency, expected
response bytes, request timeout, elapsed duration, completed requests, errors,
requests/second, transferred bytes/second, and p50/p95/p99/max latency. The
load generator treats a non-200 response, wrong response length, network error,
or request timeout as an error rather than allowing a fast malformed response
to inflate throughput.

## Required Generational Control

Every Ignite performance packet must carry three roles in the same host window:

1. the current `IgniteNEXT` control checkpoint;
2. the candidate mutation, when one exists;
3. the current `Ignite0700 / 0.7.7` release-line control.

Interleave control and candidate turns when short-run host drift is visible.
`Ignite0700` currently has a single-accepted-connection structural limit, so a
requested concurrency greater than one may not be numerically comparable. In
that case the packet must also run a concurrency-1 common denominator and
report the higher-concurrency difference as a structural capability gap rather
than publishing a misleading ratio. The 0700 control must not be omitted merely
because its runtime model differs.

This baseline is not a public ranking and does not normalize CPU affinity,
power state, compiler optimization level, TLS, H2, cross-host networking, or
competitor configuration. Those controls belong in the later internal
multi-version/competitor benchmark packet after the 0800 capability baseline
is accepted.
