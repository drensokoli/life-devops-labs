# LIFE Lab 09 — grading report

_Generated: 2026-06-01 09:23:28 +0200_

- Total submissions found: **14**
- Successfully decrypted: **12**
- Missing / failed: **2**

## Scoreboard

| Branch | Score | Failed checks | Notes |
|--------|-------|---------------|-------|
| `andi-morina-20250115` | **24/24** | — |  |
| `jona-fazliu-20250806` | **24/24** | — | ⚠ receipt mismatch |
| `kaltrina-rashiti-20250815` | **24/24** | — |  |
| `nida-perolli-20250965` | **24/24** | — |  |
| `sumea-peci-123445679` | **24/24** | — |  |
| `albin-dana-20250055` | **22/24** | backend_nonroot, frontend_nonroot |  |
| `arianit-sadriu-20250183` | **22/24** | backend_nonroot, frontend_nonroot |  |
| `dren-halili-12345` | **22/24** | backend_nonroot, frontend_nonroot |  |
| `enes-drejta-12345` | **22/24** | backend_nonroot, frontend_nonroot |  |
| `leke-perlaska-20231063` | **22/24** | backend_nonroot, frontend_nonroot |  |
| `olti-ramadani-1234` | **22/24** | backend_nonroot, frontend_nonroot |  |
| `rudina-citaku-20251083` | **22/24** | backend_nonroot, frontend_nonroot |  |
| `drin-prekaj-20250418` | — | (no data) | decrypt_failed_rc1: could not decrypt (forged or corrupted blob?) |
| `jeta-fazliu-20250786` | — | (no data) | decrypt_failed_rc1: could not decrypt (forged or corrupted blob?) |

## ⚠ Branch name mismatch (possible receipt swap)

The branch name on the git commit **does not match** the branch name
recorded inside the encrypted blob. This means the student either:
- submitted a receipt generated on a different branch, or
- copied another student's `lab-09-receipt.md` file.

| Git branch | Branch in encrypted data |
|------------|--------------------------|
| `jona-fazliu-20250806` | `jona-fazliu-01` |

## Per-submission detail

### `andi-morina-20250115` — 24/24

- generated_at_utc: `2026-05-30T16:17:44Z`
- bundle_id: `5808e2bd`
- branch in receipt: `andi-morina-20250115`
- host: `Linux 6.6.87.2-microsoft-standard-WSL2 x86_64`
- docker_version: `29.4.1`
- branched from: `main`

**Checks:**

- ✅ branch — branch: andi-morina-20250115
- ✅ compose_file — sha256:adbfed92a1b8f483ad107510f73cbd411b2e6f5b493fe84e8cbe33735d64b1fd
- ✅ backend_dockerfile — sha256:8c2c93eb5c5ee15c562cdbaa9ed373cbea47b225a3d1e2cf55c67f0224ec640b
- ✅ frontend_dockerfile — sha256:0d504940f4eb30abb0bf17b12d8912afd99646cfea7521173803b9d5a930a99e
- ✅ backend_multistage — multi-stage detected
- ✅ backend_nonroot — non-root USER found
- ✅ backend_healthcheck_df — HEALTHCHECK found
- ✅ frontend_multistage — multi-stage detected
- ✅ frontend_nonroot — non-root USER found
- ✅ frontend_healthcheck_df — HEALTHCHECK found
- ✅ stack_up — 12 containers running
- ✅ postgres_healthy — container: life-shortener-postgres-1
- ✅ redis_healthy — healthy
- ✅ rabbitmq_healthy — healthy
- ✅ backend_http — HTTP 200
- ✅ backend_image_size — 91 MB
- ✅ pgadmin_running — container: life-shortener-pgadmin-1
- ✅ pgadmin_http — HTTP 302
- ✅ frontend_http — HTTP 200
- ✅ nginx_api_proxy — GET /api/urls returned JSON array
- ✅ shorten_roundtrip — created code: szzw47
- ✅ db_row_exists — 1 row(s) in shortened_urls
- ✅ loki_running — running
- ✅ grafana_running — running

### `jona-fazliu-20250806` — 24/24

- generated_at_utc: `2026-05-30T20:36:59Z`
- bundle_id: `bd595c15`
- branch in receipt: `jona-fazliu-01` ⚠ **MISMATCH**
- host: `Linux 6.6.87.2-microsoft-standard-WSL2 x86_64`
- docker_version: `29.3.1`
- branched from: `main`

**Checks:**

- ✅ branch — branch: jona-fazliu-01
- ✅ compose_file — sha256:91264a9b2ef973ffaeb23768c37fb16c1cf69a2e08977dbfc4d2fa36700e360c
- ✅ backend_dockerfile — sha256:74b70ec33c24e70f835eaa33b747ef47ad9bb3d1b8963e481d995b3e466973f5
- ✅ frontend_dockerfile — sha256:3590fc80724e1381a86c6093464febb85737414b9d1a526c62b61275a45707b8
- ✅ backend_multistage — multi-stage detected
- ✅ backend_nonroot — non-root USER found
- ✅ backend_healthcheck_df — HEALTHCHECK found
- ✅ frontend_multistage — multi-stage detected
- ✅ frontend_nonroot — non-root USER found
- ✅ frontend_healthcheck_df — HEALTHCHECK found
- ✅ stack_up — 12 containers running
- ✅ postgres_healthy — container: life-shortener-postgres-1
- ✅ redis_healthy — healthy
- ✅ rabbitmq_healthy — healthy
- ✅ backend_http — HTTP 200
- ✅ backend_image_size — 91 MB
- ✅ pgadmin_running — container: life-shortener-pgadmin-1
- ✅ pgadmin_http — HTTP 302
- ✅ frontend_http — HTTP 200
- ✅ nginx_api_proxy — GET /api/urls returned JSON array
- ✅ shorten_roundtrip — created code: kd5u4a
- ✅ db_row_exists — 3 row(s) in shortened_urls
- ✅ loki_running — running
- ✅ grafana_running — running

### `kaltrina-rashiti-20250815` — 24/24

- generated_at_utc: `2026-05-30T21:24:04Z`
- bundle_id: `c3494898`
- branch in receipt: `kaltrina-rashiti-20250815`
- host: `Linux 6.6.87.2-microsoft-standard-WSL2 x86_64`
- docker_version: `29.4.2`
- branched from: `main`

**Checks:**

- ✅ branch — branch: kaltrina-rashiti-20250815
- ✅ compose_file — sha256:00765f3bb30d07f271d403db4f0de81cea600d021f023468d15ec8371543214f
- ✅ backend_dockerfile — sha256:a9e1971e401f243cb063445f09e28bd57221d4c73f4bb37f0845296b92d51c31
- ✅ frontend_dockerfile — sha256:d71941568b07935ac2a19cdccb0cdbeb01e541a1057c11fbffff03487163ecea
- ✅ backend_multistage — multi-stage detected
- ✅ backend_nonroot — non-root USER found
- ✅ backend_healthcheck_df — HEALTHCHECK found
- ✅ frontend_multistage — multi-stage detected
- ✅ frontend_nonroot — non-root USER found
- ✅ frontend_healthcheck_df — HEALTHCHECK found
- ✅ stack_up — 11 containers running
- ✅ postgres_healthy — container: life-shortener-postgres-1
- ✅ redis_healthy — healthy
- ✅ rabbitmq_healthy — healthy
- ✅ backend_http — HTTP 200
- ✅ backend_image_size — 91 MB
- ✅ pgadmin_running — container: life-shortener-pgadmin-1
- ✅ pgadmin_http — HTTP 302
- ✅ frontend_http — HTTP 200
- ✅ nginx_api_proxy — GET /api/urls returned JSON array
- ✅ shorten_roundtrip — created code: nefvhs
- ✅ db_row_exists — 18 row(s) in shortened_urls
- ✅ loki_running — running
- ✅ grafana_running — running

### `nida-perolli-20250965` — 24/24

- generated_at_utc: `2026-05-29T20:14:20Z`
- bundle_id: `56e078fe`
- branch in receipt: `nida-perolli-20250965`
- host: `Linux 6.6.114.1-microsoft-standard-WSL2 x86_64`
- docker_version: `29.4.3`
- branched from: `main`

**Checks:**

- ✅ branch — branch: nida-perolli-20250965
- ✅ compose_file — sha256:783370c5f60b2838262bb4aa85f1f3e28e64d5fc6a43b57fcee99c0486a93a6f
- ✅ backend_dockerfile — sha256:68b9beb907b21b9b1b8b46974904b8b5fc7b2c1ed51ae5021aecc634b6e633ba
- ✅ frontend_dockerfile — sha256:29760b34fcb50a7ce07d82ae9849b93a4127856893f6697d40cf6803c3e06b72
- ✅ backend_multistage — multi-stage detected
- ✅ backend_nonroot — non-root USER found
- ✅ backend_healthcheck_df — HEALTHCHECK found
- ✅ frontend_multistage — multi-stage detected
- ✅ frontend_nonroot — non-root USER found
- ✅ frontend_healthcheck_df — HEALTHCHECK found
- ✅ stack_up — 11 containers running
- ✅ postgres_healthy — container: life-shortener-postgres-1
- ✅ redis_healthy — healthy
- ✅ rabbitmq_healthy — healthy
- ✅ backend_http — HTTP 200
- ✅ backend_image_size — 91 MB
- ✅ pgadmin_running — container: life-shortener-pgadmin-1
- ✅ pgadmin_http — HTTP 302
- ✅ frontend_http — HTTP 200
- ✅ nginx_api_proxy — GET /api/urls returned JSON array
- ✅ shorten_roundtrip — created code: yyfenw
- ✅ db_row_exists — 2 row(s) in shortened_urls
- ✅ loki_running — running
- ✅ grafana_running — running

### `sumea-peci-123445679` — 24/24

- generated_at_utc: `2026-05-31T09:56:22Z`
- bundle_id: `60fcecc0`
- branch in receipt: `sumea-peci-123445679`
- host: `Linux 6.6.87.2-microsoft-standard-WSL2 x86_64`
- docker_version: `29.2.0`
- branched from: `main`

**Checks:**

- ✅ branch — branch: sumea-peci-123445679
- ✅ compose_file — sha256:553eab3a473934ae62320dabaf99cd41dce1fe1b86a2660ded3cf1739f011670
- ✅ backend_dockerfile — sha256:909429b4d315200a8ac934585cd391eb8e1977033eedd588bc4188ab7ac48ec3
- ✅ frontend_dockerfile — sha256:960281aa5132d7f624bf23e6675ecd844e6aba8b4fa57d4d805da7c877660bdd
- ✅ backend_multistage — multi-stage detected
- ✅ backend_nonroot — non-root USER found
- ✅ backend_healthcheck_df — HEALTHCHECK found
- ✅ frontend_multistage — multi-stage detected
- ✅ frontend_nonroot — non-root USER found
- ✅ frontend_healthcheck_df — HEALTHCHECK found
- ✅ stack_up — 12 containers running
- ✅ postgres_healthy — container: life-shortener-postgres-1
- ✅ redis_healthy — healthy
- ✅ rabbitmq_healthy — healthy
- ✅ backend_http — HTTP 200
- ✅ backend_image_size — 91 MB
- ✅ pgadmin_running — container: life-shortener-pgadmin-1
- ✅ pgadmin_http — HTTP 302
- ✅ frontend_http — HTTP 200
- ✅ nginx_api_proxy — GET /api/urls returned JSON array
- ✅ shorten_roundtrip — created code: r29mc7
- ✅ db_row_exists — 1 row(s) in shortened_urls
- ✅ loki_running — running
- ✅ grafana_running — running

### `albin-dana-20250055` — 22/24

- generated_at_utc: `2026-05-30T14:31:37Z`
- bundle_id: `d25ca9d8`
- branch in receipt: `albin-dana-20250055`
- host: `Darwin 24.3.0 arm64`
- docker_version: `29.2.1`
- branched from: `main`

**Checks:**

- ✅ branch — branch: albin-dana-20250055
- ✅ compose_file — sha256:dfb781f9cc546b7f3b5fe06d299e38bdab1c17c7daf2dae9c6d973a0f5b21412
- ✅ backend_dockerfile — sha256:51cd5e729e0335fbb6f50258ddd0c4e930d0ffe128cd9ad0ce46baeee544282f
- ✅ frontend_dockerfile — sha256:38343a2606f2fd4e6fb7fed78002ae9db0cda990054da8854153ce47f4ec919e
- ✅ backend_multistage — multi-stage detected
- ❌ backend_nonroot — no non-root USER instruction — add USER app (or similar) to final stage
- ✅ backend_healthcheck_df — HEALTHCHECK found
- ✅ frontend_multistage — multi-stage detected
- ❌ frontend_nonroot — no non-root USER instruction — add USER nextjs (or similar) to final stage
- ✅ frontend_healthcheck_df — HEALTHCHECK found
- ✅ stack_up — 12 containers running
- ✅ postgres_healthy — container: life-shortener-postgres-1
- ✅ redis_healthy — healthy
- ✅ rabbitmq_healthy — healthy
- ✅ backend_http — HTTP 200
- ✅ backend_image_size — 259 MB
- ✅ pgadmin_running — container: life-shortener-pgadmin-1
- ✅ pgadmin_http — HTTP 302
- ✅ frontend_http — HTTP 200
- ✅ nginx_api_proxy — GET /api/urls returned JSON array
- ✅ shorten_roundtrip — created code: nrxae6
- ✅ db_row_exists — 4 row(s) in shortened_urls
- ✅ loki_running — running
- ✅ grafana_running — running

### `arianit-sadriu-20250183` — 22/24

- generated_at_utc: `2026-05-30T18:43:14Z`
- bundle_id: `506ba370`
- branch in receipt: `arianit-sadriu-20250183`
- host: `MINGW64_NT-10.0-26200 3.3.6-341.x86_64 x86_64`
- docker_version: `29.4.0`
- branched from: `main`

**Checks:**

- ✅ branch — branch: arianit-sadriu-20250183
- ✅ compose_file — sha256:9d84f501ed8c794f4addeab2d51928d292b053eb3c02d58cf16191ad14e6cfd3
- ✅ backend_dockerfile — sha256:2ee4998bf21ee082896f41670f5d1c8c37c43f8e91e7d264b20fe24696cbc841
- ✅ frontend_dockerfile — sha256:c3c2df7ff0461ef226b69d93dd08799e3c83b283c8881da8cd4aba79c3949043
- ✅ backend_multistage — multi-stage detected
- ❌ backend_nonroot — no non-root USER instruction — add USER app (or similar) to final stage
- ✅ backend_healthcheck_df — HEALTHCHECK found
- ✅ frontend_multistage — multi-stage detected
- ❌ frontend_nonroot — no non-root USER instruction — add USER nextjs (or similar) to final stage
- ✅ frontend_healthcheck_df — HEALTHCHECK found
- ✅ stack_up — 12 containers running
- ✅ postgres_healthy — container: life-shortener-postgres-1
- ✅ redis_healthy — healthy
- ✅ rabbitmq_healthy — healthy
- ✅ backend_http — HTTP 200
- ✅ backend_image_size — 91 MB
- ✅ pgadmin_running — container: life-shortener-pgadmin-1
- ✅ pgadmin_http — HTTP 302
- ✅ frontend_http — HTTP 200
- ✅ nginx_api_proxy — GET /api/urls returned JSON array
- ✅ shorten_roundtrip — created code: cfkihc
- ✅ db_row_exists — 2 row(s) in shortened_urls
- ✅ loki_running — running
- ✅ grafana_running — running

### `dren-halili-12345` — 22/24

- generated_at_utc: `2026-05-30T23:01:23Z`
- bundle_id: `d183990e`
- branch in receipt: `dren-halili-12345`
- host: `Darwin 23.1.0 arm64`
- docker_version: `29.4.3`
- branched from: `main`

**Checks:**

- ✅ branch — branch: dren-halili-12345
- ✅ compose_file — sha256:5339818a9f54f64cf42183fcb572ca8827b5d78d51ca8a2bc6e3513e47edd0ed
- ✅ backend_dockerfile — sha256:b9aed6fc6f9a8aedc05c947c1b3a944eb90ba0e8dcb673e52f880c5b7b5f43eb
- ✅ frontend_dockerfile — sha256:6684cc010070837179d513f9cee193a62dfabb4be6b3a1c8a94d50be56ad3607
- ✅ backend_multistage — multi-stage detected
- ❌ backend_nonroot — no non-root USER instruction — add USER app (or similar) to final stage
- ✅ backend_healthcheck_df — HEALTHCHECK found
- ✅ frontend_multistage — multi-stage detected
- ❌ frontend_nonroot — no non-root USER instruction — add USER nextjs (or similar) to final stage
- ✅ frontend_healthcheck_df — HEALTHCHECK found
- ✅ stack_up — 12 containers running
- ✅ postgres_healthy — container: life-shortener-postgres-1
- ✅ redis_healthy — healthy
- ✅ rabbitmq_healthy — healthy
- ✅ backend_http — HTTP 200
- ✅ backend_image_size — 89 MB
- ✅ pgadmin_running — container: life-shortener-pgadmin-1
- ✅ pgadmin_http — HTTP 302
- ✅ frontend_http — HTTP 200
- ✅ nginx_api_proxy — GET /api/urls returned JSON array
- ✅ shorten_roundtrip — created code: p98ech
- ✅ db_row_exists — 3 row(s) in shortened_urls
- ✅ loki_running — running
- ✅ grafana_running — running

### `enes-drejta-12345` — 22/24

- generated_at_utc: `2026-05-31T22:18:05Z`
- bundle_id: `6cbfd486`
- branch in receipt: `enes-drejta-12345`
- host: `Linux 7.0.4-100.fc43.x86_64 x86_64`
- docker_version: `29.4.3`
- branched from: `main`

**Checks:**

- ✅ branch — branch: enes-drejta-12345
- ✅ compose_file — sha256:e209d3392d717817bd9ec1dc3f79fd98b88c65872102c162570cff9bb47f8582
- ✅ backend_dockerfile — sha256:640e10c5b55af7fabe55e8b1675bc4d95cdd8304febff7fc726749a988a56a6d
- ✅ frontend_dockerfile — sha256:f9cc1b546841ffeac96f4712b489fc2f188fea69805707031bc700316f477ee2
- ✅ backend_multistage — multi-stage detected
- ❌ backend_nonroot — no non-root USER instruction — add USER app (or similar) to final stage
- ✅ backend_healthcheck_df — HEALTHCHECK found
- ✅ frontend_multistage — multi-stage detected
- ❌ frontend_nonroot — no non-root USER instruction — add USER nextjs (or similar) to final stage
- ✅ frontend_healthcheck_df — HEALTHCHECK found
- ✅ stack_up — 12 containers running
- ✅ postgres_healthy — container: life-shortener-postgres-1
- ✅ redis_healthy — healthy
- ✅ rabbitmq_healthy — healthy
- ✅ backend_http — HTTP 200
- ✅ backend_image_size — 91 MB
- ✅ pgadmin_running — container: life-shortener-pgadmin-1
- ✅ pgadmin_http — HTTP 302
- ✅ frontend_http — HTTP 200
- ✅ nginx_api_proxy — GET /api/urls returned JSON array
- ✅ shorten_roundtrip — created code: 23gfnk
- ✅ db_row_exists — 1 row(s) in shortened_urls
- ✅ loki_running — running
- ✅ grafana_running — running

### `leke-perlaska-20231063` — 22/24

- generated_at_utc: `2026-05-31T01:42:02Z`
- bundle_id: `c535d135`
- branch in receipt: `leke-perlaska-20231063`
- host: `Linux 7.0.3-arch1-2 x86_64`
- docker_version: `29.4.3`
- branched from: `main`

**Checks:**

- ✅ branch — branch: leke-perlaska-20231063
- ✅ compose_file — sha256:04be8189407efb9adb788bdefecaeef56c440abeb1411d2ce9e18b3f5810ad27
- ✅ backend_dockerfile — sha256:508b49ad72346c4961f2dea8c5cab133594a5b329a8e9992a5d9b83452665a3a
- ✅ frontend_dockerfile — sha256:6b835405696214ad04137e61131c9adcb2a6276289a336042dc1fe7e77b63d06
- ✅ backend_multistage — multi-stage detected
- ❌ backend_nonroot — no non-root USER instruction — add USER app (or similar) to final stage
- ✅ backend_healthcheck_df — HEALTHCHECK found
- ✅ frontend_multistage — multi-stage detected
- ❌ frontend_nonroot — no non-root USER instruction — add USER nextjs (or similar) to final stage
- ✅ frontend_healthcheck_df — HEALTHCHECK found
- ✅ stack_up — 11 containers running
- ✅ postgres_healthy — container: life-shortener-postgres-1
- ✅ redis_healthy — healthy
- ✅ rabbitmq_healthy — healthy
- ✅ backend_http — HTTP 200
- ✅ backend_image_size — 228 MB
- ✅ pgadmin_running — container: life-shortener-pgadmin-1
- ✅ pgadmin_http — HTTP 302
- ✅ frontend_http — HTTP 200
- ✅ nginx_api_proxy — GET /api/urls returned JSON array
- ✅ shorten_roundtrip — created code: 9pxvmx
- ✅ db_row_exists — 6 row(s) in shortened_urls
- ✅ loki_running — running
- ✅ grafana_running — running

### `olti-ramadani-1234` — 22/24

- generated_at_utc: `2026-05-30T15:44:19Z`
- bundle_id: `e919e28c`
- branch in receipt: `olti-ramadani-1234`
- host: `Linux 7.0.3-arch1-2 x86_64`
- docker_version: `29.4.3`
- branched from: `main`

**Checks:**

- ✅ branch — branch: olti-ramadani-1234
- ✅ compose_file — sha256:26c21e1aca65855d8410ad9e1d21d3bb11dd88df642194c98905a6db91cd29e4
- ✅ backend_dockerfile — sha256:b9b88cb52c1181a9873a74002e5452a10bac984b8e3ef8d75baa55e83902d1ea
- ✅ frontend_dockerfile — sha256:2049b8ced8021c6fea2cb32dc855f2b464255872f25fecea869f3452264f12c4
- ✅ backend_multistage — multi-stage detected
- ❌ backend_nonroot — no non-root USER instruction — add USER app (or similar) to final stage
- ✅ backend_healthcheck_df — HEALTHCHECK found
- ✅ frontend_multistage — multi-stage detected
- ❌ frontend_nonroot — no non-root USER instruction — add USER nextjs (or similar) to final stage
- ✅ frontend_healthcheck_df — HEALTHCHECK found
- ✅ stack_up — 12 containers running
- ✅ postgres_healthy — container: life-shortener-postgres-1
- ✅ redis_healthy — healthy
- ✅ rabbitmq_healthy — healthy
- ✅ backend_http — HTTP 200
- ✅ backend_image_size — 91 MB
- ✅ pgadmin_running — container: life-shortener-pgadmin-1
- ✅ pgadmin_http — HTTP 302
- ✅ frontend_http — HTTP 200
- ✅ nginx_api_proxy — GET /api/urls returned JSON array
- ✅ shorten_roundtrip — created code: 6gavy7
- ✅ db_row_exists — 2 row(s) in shortened_urls
- ✅ loki_running — running
- ✅ grafana_running — running

### `rudina-citaku-20251083` — 22/24

- generated_at_utc: `2026-05-31T13:09:04Z`
- bundle_id: `0e844b2b`
- branch in receipt: `rudina-citaku-20251083`
- host: `Linux 6.6.87.2-microsoft-standard-WSL2 x86_64`
- docker_version: `29.1.3`
- branched from: `main`

**Checks:**

- ✅ branch — branch: rudina-citaku-20251083
- ✅ compose_file — sha256:59f8b5ae32c0274d928cb815c649ad2ddaf0c27b8ac25948d64cb54327ce5782
- ✅ backend_dockerfile — sha256:d31e1095773e223597a2b6cdf5dd42d27b7dabb08f3a115c5f18cde4b59cbfbb
- ✅ frontend_dockerfile — sha256:785ce20d53cfd42c7891a0af1c7311b7f85feaf3f0c627bf1583af0eb2008787
- ✅ backend_multistage — multi-stage detected
- ❌ backend_nonroot — no non-root USER instruction — add USER app (or similar) to final stage
- ✅ backend_healthcheck_df — HEALTHCHECK found
- ✅ frontend_multistage — multi-stage detected
- ❌ frontend_nonroot — no non-root USER instruction — add USER nextjs (or similar) to final stage
- ✅ frontend_healthcheck_df — HEALTHCHECK found
- ✅ stack_up — 12 containers running
- ✅ postgres_healthy — container: life-shortener-postgres-1
- ✅ redis_healthy — healthy
- ✅ rabbitmq_healthy — healthy
- ✅ backend_http — HTTP 200
- ✅ backend_image_size — 91 MB
- ✅ pgadmin_running — container: life-shortener-pgadmin-1
- ✅ pgadmin_http — HTTP 302
- ✅ frontend_http — HTTP 200
- ✅ nginx_api_proxy — GET /api/urls returned JSON array
- ✅ shorten_roundtrip — created code: 5sfsud
- ✅ db_row_exists — 5 row(s) in shortened_urls
- ✅ loki_running — running
- ✅ grafana_running — running

### `drin-prekaj-20250418` — decrypt_failed_rc1

> could not decrypt (forged or corrupted blob?)

### `jeta-fazliu-20250786` — decrypt_failed_rc1

> could not decrypt (forged or corrupted blob?)

