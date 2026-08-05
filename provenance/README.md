# Provenance policy

Every accepted runtime file needs four pieces of evidence before it becomes a release input:

1. upstream source commit;
2. clean production-only patch series;
3. exact build/configure command and toolchain image;
4. SHA-256 of the staged output.

Until all four exist, the file belongs in the accepted-hash ledger but not in a claimed source-build release.

Machine-local sources, prefixes, AE installs, caches, screenshots, logs, tests, and harnesses remain outside this repository. Their paths may appear in provenance notes only when needed to identify an artifact.
