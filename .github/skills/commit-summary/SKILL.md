---
name: commit-summary
description: Summarize the current branch changes and suggest an accurate commit message. Use when asked for a change summary or commit-message suggestion.
---

## Change context

Inspect the current branch name, working-tree status, staged and unstaged diffs,
and commits relative to the repository's base branch when one is available.
Include untracked files that are part of the change.

## Your task

Summarize the changes on this branch using the structure in
`templates/summary.md` (relative to this skill) — keep its section order and the
🔎 header, and fill every placeholder from the change context above.

Keep the summary concise, practical, and developer-focused. Base everything on
the diff and commits shown — do not invent changes that aren't there. If a
section has nothing to report (e.g. no tests touched), say so briefly rather than
padding it.
