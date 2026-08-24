# Ignite 0.8.17 Benchmark Baseline

This directory owns the public Benchmark track for the `Ignite0800` 0.8.17
line. Public results compare only Ignite native and the explicit stdx rollback
backend. Competitor comparisons stay in the workspace-internal Benchmark lab.

## Run

```bash
./manual/benchmark/run.sh
```

The default matrix exercises:

- `/plaintext`: small fixed text response;
- `/json`: fixed JSON response through `Ctx.json(String)`;
- `/bytes/64k`: a `PreparedResponseBody` encoded once and reused across
  requests while crossing common socket buffer boundaries.

The runner writes JSON Lines to `/tmp/ignite0800-benchmark.jsonl` and keeps the
server log at `/tmp/ignite0800-benchmark-server.log`.

Every JSONL measurement names its public/internal track, benchmark profile,
implementation, scenario, protocol family, exact expected bytes,
backend/version, concurrency, error count, timeout, P50/P95/P99, and current
caveats. HTTP/H1 remains the only public matrix protocol family. Cleartext
prior-knowledge H2 has a separate internal smoke runner and result file; HTTPS
still requires a future runner.

## Public Matrix

```bash
./manual/benchmark/run_public_matrix.sh
```

The default public matrix compares Ignite native and stdx across:

- plaintext and fixed JSON;
- exact `64 / 256 / 1024 KiB` binary-shaped responses;
- concurrency `1 / 8 / 32 / 128`.

The separate high-concurrency profile uses `64 / 256 / 1024` concurrent
requests against plaintext, JSON, and `64 KiB`. It intentionally excludes
`256 / 1024 KiB` bodies by default because `1024` simultaneous `1 MiB`
responses is a memory-pressure experiment, not a safe routine benchmark:

```bash
IGNITE_BENCH_PROFILE=concurrency-stress \
./manual/benchmark/run_public_matrix.sh
```

Each cell is interleaved as `native-r1 -> stdx-r1 -> stdx-r2 -> native-r2`
by default so a long host-time drift does not systematically favor one
backend. The matrix records the current Git checkpoint automatically and adds
`+dirty` when the worktree is not clean. Set `IGNITE_BENCH_ROUNDS=1` only for
a quick diagnostic smoke.

Use a bounded smoke before a full run:

```bash
IGNITE_BENCH_CONCURRENCIES="1 8" \
IGNITE_BENCH_SCENARIOS="plaintext:14 bytes/64k:65536" \
IGNITE_BENCH_WARMUP=1 \
IGNITE_BENCH_DURATION=3 \
./manual/benchmark/run_public_matrix.sh
```

## Controls

```bash
IGNITE_BENCH_CONCURRENCY=64 \
IGNITE_BENCH_WARMUP=3 \
IGNITE_BENCH_DURATION=15 \
IGNITE_BENCH_REQUEST_TIMEOUT_MS=5000 \
IGNITE_BENCH_VERSION=ignite-0.8.17 \
IGNITE_BENCH_OUTPUT=/tmp/ignite0800-run.jsonl \
./manual/benchmark/run.sh
```

Use `IGNITE_BENCH_BACKEND=stdx` to exercise the explicit rollback server path.
The default is Ignite native cleartext H1.

The experimental cleartext prior-knowledge Native H2 `App.listen()` entry has
a separate internal smoke runner: `./manual/benchmark/run_native_h2_smoke.sh`.
It first uses Ignite's own Native H2 client, then runs the shared Node JSONL
load generator over one reused HTTP/2 session. The request decoder accepts the
bounded Huffman and connection-owned dynamic-table behavior reproduced from
Node, but this is not full RFC HPACK coverage. The smoke is not TLS/ALPN, h2c
Upgrade, browser certification, or a release-grade H2 ranking.

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

1. the current checkout control checkpoint;
2. the candidate mutation, when one exists;
3. the `0.7.7` compatibility-line control.

Interleave control and candidate turns when short-run host drift is visible.
The `0.7.7` compatibility line has a single-accepted-connection structural limit, so a
requested concurrency greater than one may not be numerically comparable. In
that case the packet must also run a concurrency-1 common denominator and
report the higher-concurrency difference as a structural capability gap rather
than publishing a misleading ratio. The 0700 control must not be omitted merely
because its runtime model differs.

This baseline is not a public ranking and does not normalize CPU affinity,
power state, compiler optimization level, TLS, H2, cross-host networking, or
competitor configuration. Those controls belong in the later internal
multi-version/competitor Benchmark. Public HTTP/H1, HTTPS, and H2 results must
remain separate tables rather than one blended score.
