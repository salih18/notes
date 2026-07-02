# SDD quickstart
> One command. Three files. Build from spec.

---

## BA / PO — Azure Boards only

Write every user story with this structure in the **Acceptance Criteria** field:

```
Scenario: [name]
Given [context]
When [action]
Then [outcome]

Out of scope:
- [what this story will NOT do]
```

Move the story to **Ready for Dev** when done. You never touch the repo.

---

## Everyone — one command

When a story is ready, anyone on the team runs this in Copilot Chat (Agent mode):

```
#sdd.prompt.md  story: #4821
```

Replace `4821` with the ADO story ID. That's the whole command.

**What happens automatically:**
1. Creates branch `feature/4821-email-form-validation` from latest main
2. Reads the story live from Azure Boards via MCP
3. Scans every existing spec **on main** for overlap
4. Decides whether to update an existing spec or create a new one
5. Writes `spec.md`, `plan.md`, and `tasks.md` into the right folder on the branch
6. Shows a one-line summary of what it did

The branch exists. The files are there. The dev can open VS Code and start immediately.

---

## Developer — after the command runs

The branch `feature/4821-[name]` is already created and you are on it.
Open `specs/[domain]/[feature]/`:

| File | What it contains | What you do with it |
|---|---|---|
| `spec.md` | BA's scenarios in Given/When/Then | Read it. It's the definition of done. |
| `plan.md` | Technical skeleton auto-generated | **Fill in the gaps** — component structure, state management, API contracts, edge cases |
| `tasks.md` | Atomic implementation steps | Work through them one at a time |

### Implementing — one task per Copilot session

Pick the first unchecked task from `tasks.md` and tell Copilot:

```
Read specs/[folder]/spec.md and plan.md.
Implement task: "[paste task title here]"
Only implement what is described in spec.md. Nothing extra.
```

Check it off. Pick the next task. Repeat.

### Code review

Open `spec.md` alongside the PR diff.
Every scenario in spec.md must be satisfied by the code.
If a scenario isn't covered → it's a bug, not a scope question.

---

## If a story changes mid-sprint

BA updated the AC in ADO? Run the same command again:

```
#sdd.prompt.md  story: #4821
```

It re-reads the story, finds the existing spec, and patches only what changed.
Existing completed tasks are never touched.

---

## Small changes (no command needed)

| Change | What to do |
|---|---|
| Button style, label copy, colour | Just do it. Note it in the PR. |
| New error/loading state | Add one line to `spec.md` edge cases manually |
| New or changed scenario | Run `#sdd.prompt.md` — it will patch the spec |
| New feature or page | Run `#sdd.prompt.md` — it will create a new spec |

---

## The one rule

> **The spec always reflects what was built.**  
> If the code changed, update the spec before the PR merges.

---

*Full detail: `docs/sdd-process-manual.md`*
