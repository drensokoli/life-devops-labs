# lab-tools

Shared scripts that back the per-lab completion checks.

## Files

| File | Audience | Purpose |
|------|----------|---------|
| `_lib.sh` | Both | Sourced by every `verify.sh`. Provides check tracking, fact collection, and the receipt-packing helpers. |
| `setup-instructor.sh` | Instructor | One-time bootstrap. Generates the keypair, stores the private half under `~/.life-devops/`, embeds the public half into `_lib.sh`. |
| `decrypt-submissions.sh` | Instructor | Iterates student branches, decrypts receipts, writes `grading-<lab>.md`. |

## Instructor workflow

```bash
# Once per machine, ever:
./lab-tools/setup-instructor.sh
git add lab-tools/_lib.sh
git commit -m "chore: bootstrap lab tooling"
git push

# For each grading session:
./lab-tools/decrypt-submissions.sh 09
open grading-09.md
```

The private key never leaves `~/.life-devops/teacher.key`. If you change machines, copy that file across.

## Student workflow

Students do not run anything here directly. They `cd` into a lab folder and run `./verify.sh`, which sources `_lib.sh` automatically.

## Files you should never commit

- `~/.life-devops/teacher.key` — your private key (already outside the repo).
- `grading-*.md` and `grading-*/` — your decrypted grading artifacts (add to your local repo `.gitignore`).
