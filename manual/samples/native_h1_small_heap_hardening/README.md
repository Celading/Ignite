# Native H1 Small-Heap Hardening Probe

This sample is a bounded hardening probe, not a cross-framework benchmark.
It runs the built-in cleartext Native H1 backend with:

- a reusable 512 KiB prepared HTML response;
- repeated polling on reused HTTP/1.1 client sessions;
- concurrent 300 ms requests mixed with short requests;
- runtime snapshots plus process RSS, FD, and TCP socket counts.

Run both supported local profiles:

```bash
./manual/samples/native_h1_small_heap_hardening/probe.sh
```

The default profiles use `cjHeapSize=256mb` and `cjHeapSize=512mb`. Results
are written under `/tmp/ignite-hq0856-small-heap/`. The receipt only covers
cleartext Native H1 on the current host; it is not TLS, H2, LTS, or
application-allocation proof.

If `cjpm build` has already passed in the same target tree and hosted
dependencies are temporarily unavailable, set `IGNITE_HQ0856_SKIP_BUILD=1`.
This only skips duplicate dependency resolution; it does not replace the
required canonical build evidence.
