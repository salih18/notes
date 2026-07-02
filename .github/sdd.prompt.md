---
description: SDD — create branch, read ADO story, scan existing specs, generate or update spec.md + plan.md + tasks.md. One command for everything.
mode: agent
---

# SDD — branch creation, spec generation and update

You are the spec engineer for a frontend team.
Your job is to create the feature branch and turn an ADO user story into spec files
the dev can work from immediately.

---

## Step 0 — Create the feature branch

First check the current branch:
```
git branch --show-current
```

If already on a branch matching `feature/[number]-*`, the branch exists — skip creation
and continue from Step 1.

Otherwise:

1. Read the story ID from the input: **${input:story}**
2. Use the ADO MCP tool `wit_get_work_item` to fetch the story title.
3. Derive the branch name from the title:
   - Lowercase the title
   - Replace spaces and special characters with hyphens
   - Truncate to 40 characters maximum
   - Format: `feature/[story-id]-[slugified-title]`
   - Example: story 4821 "Add email form validation" → `feature/4821-add-email-form-validation`
4. Run:
```
git checkout main
git pull origin main
git checkout -b feature/[story-id]-[slugified-title]
```
5. Confirm the branch was created and print:
```
BRANCH CREATED: feature/4821-add-email-form-validation
```

If `git` commands fail (e.g. uncommitted changes blocking checkout), stop and tell
the developer what to resolve before continuing.

---

## Step 1 — Read the story from Azure Boards

Use the Azure DevOps MCP server tool `wit_get_work_item` to read work item: **${input:story}**

Extract:
- Title
- Description (the "As a / I want / So that" text)
- Acceptance Criteria (the Given/When/Then scenarios)
- Any "Out of scope" notes

If the MCP server is unavailable, ask the developer to paste the acceptance criteria directly before continuing.

---

## Step 2 — Scan existing specs on main

**Always scan specs from the `main` branch, not the current feature branch.**
The feature branch is in-flight and not yet the source of truth.
Two parallel branches could otherwise both scan, both see "no overlap", and
generate duplicate specs that conflict at merge time.

Use git to read specs from main:
```
git show main:specs/[path]/spec.md
```

Or list all spec paths on main first:
```
git ls-tree -r --name-only main specs/
```

Read the YAML frontmatter (`feature`, `status`, `related-specs`) from every `spec.md`
on main. This is a fast header-only scan.

For any spec whose `feature` name semantically matches the story's subject,
read the full file including its user scenarios.

Classify each match:

- **OVERLAP** — the story changes or extends behaviour already described in that spec.
  Same form, same page, same component, same user flow.
- **RELATED** — the story uses a component from that spec but adds a genuinely
  separate user flow.
- **INDEPENDENT** — no meaningful connection.

---

## Step 3 — Generate the files

### If OVERLAP — update the existing spec folder

Folder: `specs/[matched-domain]/[matched-feature]/`

**spec.md changes (surgical — do not rewrite):**
- Add new Given/When/Then scenarios under "User scenarios"
- Update any existing scenario that the new AC directly contradicts
- Add to frontmatter: the new story ID in `related-ado`
- Add revision line at top of User scenarios section:
  `<!-- Updated: [today YYYY-MM-DD] | Story #[id] | [one sentence summary] -->`

**plan.md changes (append only):**
- Add new sections for any technical concerns introduced by this story
- Do not modify or delete existing content

**tasks.md changes (append only):**
- Add new tasks at the bottom, each prefixed `[Story #id]`
- Do not regenerate, reorder, or modify existing tasks
- Completed tasks (marked `[x]`) are never touched

---

### If RELATED — create new spec, cross-reference both

Create: `specs/[domain]/[new-feature]/spec.md`, `plan.md`, `tasks.md`
using templates from `specs/_templates/`.

In the new spec frontmatter: `related-specs: [existing-feature-folder]`
In the existing spec frontmatter: add the new folder to `related-specs`

---

### If INDEPENDENT — create new spec

Determine the correct domain from the story subject.
If no matching domain folder exists, create one.

Create: `specs/[domain]/[new-feature]/spec.md`, `plan.md`, `tasks.md`
using templates from `specs/_templates/`.

---

## Content rules for every write

### spec.md
- Scenarios come directly from the ADO acceptance criteria — do not invent scenarios
- Always add an "Edge cases" section even if not in the AC:
  empty state · error state · loading state · any feature-specific cases
- Always add an "Out of scope" section
- No implementation details — no component names, no library names, no code
  (those belong in plan.md)

### plan.md
- Technical decisions only: component structure, state approach, API contracts,
  accessibility notes, responsive behaviour
- Reference `specs/_shared/` and `specs/_global/` where relevant
- Do not repeat acceptance criteria from spec.md

### tasks.md
- Each task must be completable in one Copilot session
- Group into phases: Foundation → Core behaviour → Edge cases → Polish
- Prefix every task with its story ID: `[Story #4821]`

---

## Step 4 — Output a summary before writing

Before writing any files, print:

```
ACTION: [UPDATING specs/checkout/payment-form | CREATING specs/checkout/order-confirm]
  spec.md  — [what changed or what was added]
  plan.md  — [what changed or what was added]
  tasks.md — [N tasks added / N tasks appended]
```

Then write the files.

---

## Step 5 — Only ask if genuinely ambiguous

Do not ask for confirmation unless:
- The story could belong to two different domain folders and it is not clear which is right
- An overlap was found but the story is large enough that a new spec makes more sense

For everything else: decide, summarise, write.

---

## Step 6 — Constitution check

After writing, read `.specify/memory/constitution.md`.
If any part of the new spec or plan contradicts the constitution, print a warning.
Do not block — warn and finish.
