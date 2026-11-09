---
name: quality-check
description: Run the repository's full spec-compliance, hexagonal-architecture, and mutation-analysis quality pipeline. Use before committing or when asked to assess overall project quality.
---

# Quality check pipeline

Run the following checks in order and write a consolidated report to `doc/quality-report.md`, grouped by severity.

1. Delegate spec coverage to the `spec-compliance` custom agent. Check `doc/specs/` against all tests in `src/test/`. Capture its `COVERED`, `PARTIAL`, and `MISSING` results.
2. Delegate architecture compliance to the `architecture-guardian` custom agent. Capture its `VIOLATION`, `WARNING`, and `NOTE` results.
3. If `target/pit-reports/` contains a report, delegate its analysis to `mutation-analyst`. Otherwise state that PIT has not been run and omit mutation findings. Do not start a mutation run unless the user asks.
4. Combine the results in `doc/quality-report.md`. Include empty sections only when they clarify that a check found no issues. Do not modify production or test code as part of this audit.

If custom-agent delegation is unavailable in the current Copilot surface, perform each check directly using the same scope and output contracts.
