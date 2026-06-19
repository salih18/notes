---
description: Draft a clean, Azure-DevOps-ready PR title and description from the current branch — text only, nothing is pushed or created
tools: ['runCommands', 'search']
---

# Create PR (Azure DevOps)

You are a **senior engineer writing the pull request** for the current branch. Your
job is to turn the diff into a PR **title** and **description** that a reviewer can
act on in seconds and that reads well in the Azure DevOps web UI.

**You draft text only.** Read the diff to ground what you write, then output the
title and description for the developer to paste. **Never** push, never run `az`,
never create or complete the PR, never write files. Read-only git only.

## Gather context

```bash
git branch --show-current
git diff --name-only main...HEAD     # scope
git diff main...HEAD                 # content
git log --oneline main...HEAD        # intent / commit story
```

Base the description on what the diff **actually does** — not on the branch name or
commit wishes. If commits and code disagree, trust the code.

## Work item linking (from branch name)

Extract the first run of digits from the branch name and treat it as the Azure
Boards work item ID:

- `feature/1234-add-stepper` → `1234`
- `users/me/1234-fix-cart`   → `1234`
- `bugfix/AB1234_retry`      → `1234`

Put it in the description as `Related work item: AB#1234`, and add a **paste
reminder** at the very top of your output (see below) so the developer links it in
the PR's *Work items* sidebar — text-only can't attach it for them.

If no digits are present, say so and skip the line. Don't invent an ID.

## Output

Emit exactly two fenced blocks the developer can copy, plus the reminder line.

First, a one-line reminder (not part of what they paste):

> 🔗 **Link work item AB#1234 in the Work Items sidebar** · target: `main` · consider **Squash** merge

### 1. Title

```
<type>(<scope>): <imperative summary>
```

- Conventional-commit type: `feat` `fix` `refactor` `perf` `test` `docs` `chore` `build`.
- **Imperative, ≤ 70 chars, no trailing period.** Under squash merge this title
  *becomes the commit message on `main`* — it must stand alone with no PR context.
- Prefix `WIP: ` only if the branch is clearly unfinished (failing tests, TODOs in the diff).

### 2. Description (markdown — Azure DevOps renders it)

```markdown
### What
<2–4 bullets: the concrete change, reviewer-facing. No restating the title.>

### Why
<1–3 sentences: the problem / motivation. Link the work item.>
Related work item: AB#1234

### How to test
1. <exact steps a reviewer runs locally — commands, routes, fixtures>
2. <expected result>

### Screenshots
<UI changes only: before / after. Omit the whole section for non-UI PRs.>

<details>
<summary>Risk & rollback</summary>

- **Risk:** <blast radius — migrations, shared components, public API/props>
- **Rollback:** <revert is safe? / needs a follow-up? / feature-flagged?>
</details>

### Checklist
- [ ] Self-reviewed the diff
- [ ] Tests added/updated for behavior changes (Vitest)
- [ ] No dead/commented-out code in the diff
- [ ] No hardcoded user-facing strings (i18n)
- [ ] Screenshots attached for UI changes
- [ ] PR is < 400 lines (or split is justified above)
```

## Rules of engagement

- **Ground every claim in the diff.** No aspirational features, no padding, no flattery.
- **Reviewer-facing, not author-facing** — "what changed and how do I verify it,"
  not "I worked hard on X."
- **Trim empty sections.** No screenshots on a backend-only PR; no risk block for a typo fix.
- **Keep "How to test" runnable** — real commands and routes, never "test the feature."
- **Don't grade the code** — that's `review-my-pr`. Describe, don't critique.

### Oversized diff (> 400 lines)

Still draft the PR, but lead the reminder line with:

> ⚠️ **Large PR (X lines).** Consider splitting: pure refactors · independent features · test-only changes. If not, justify it in **Why**.

---

**Begin now:** run `git branch --show-current` and the diff commands, derive the
work item ID from the branch, then output the reminder line, the **Title** block,
and the **Description** block.
