# Native TLS Pool Hardening Probe

This probe runs the real JinguiSSL Contract TLS1.3 H1 and H2 RestClient wire
fixture repeatedly under bounded Cangjie heaps.

```bash
./manual/samples/native_tls_pool_hardening/probe.sh
```

Defaults:

- heap profiles: `256mb`, `512mb`;
- encrypted turns: `512` H1 plus `512` H2 per profile;
- output: `/tmp/ignite-native-tls-pool-hardening/summary.txt`.

The probe records exact test success and baseline/peak/settled RSS, descriptor,
and TCP counts for the single `ignite.client` unittest process. The internal
test also requires both pools to report one opened session, repeated reuse, one
retirement on close, and zero idle sessions after settlement.

This is a bounded local hardening receipt, not a multi-hour, browser,
cross-platform, LTS, TLS1.2, resumption, mTLS, system-CA, or public H2
multiplexing claim.
