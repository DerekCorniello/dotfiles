---
name: mux-release
description: "Full release ritual for the mux-lang multi-repo project: bump versions, write changelog, sync docs/READMEs, lint clean, then hand exact tag commands to Derek - never tag or push without his go. Use when releasing mux, cutting a mux version, or 'release mux'."
---

# Mux Release

Release ritual for the mux-lang ecosystem: compiler, runtime, stdlib crates, docs website.

## Steps

1. **Version bump**
   - Bump the `VERSION` file(s) and every crate's manifest version.
   - Sweep the whole set of repos for stale old-version strings (configs, lockfiles, doc badges). Grep for the previous version number; fix every hit.
2. **Changelog**
   - Write the entry from git log/diffs since the last tag. One line per **user-visible** change; skip internal churn.
   - Match the existing changelog format.
3. **Docs sync**
   - Sync all three READMEs and the website content if behavior or syntax changed.
   - Verify stdlib usage examples actually compile against the new version.
   - ASCII arrows only (`->`) in diagrams and examples.
4. **Lint clean**
   - Run fmt and clippy across crates. Zero warnings tolerated; fix or justify nothing - fix everything.
5. **Hand off tagging**
   - State the **exact** tag + push commands for Derek to run.
   - NEVER tag or push without his explicit go.
6. **Post-push watch**
   - After his push, watch CI on the release commits and report pass/fail per repo.

## Done when

- [ ] Every repo/version reference consistent - grep for old version returns zero hits.
- [ ] Changelog entry written, user-visible changes only.
- [ ] READMEs and website synced; examples verified.
- [ ] fmt + clippy clean, zero warnings.
- [ ] Exact tag/push commands presented and approved by Derek.
- [ ] Post-push CI green across all repos, reported.
