# SDD complete manual
## Spec-driven development — setup, workflow, and reference

> **Audience:** Business Analyst · Product Owner · Frontend Developer  
> **Toolchain:** Azure Boards · GitHub Copilot · VS Code · ADO MCP Server  
> **Branch convention:** `feature/[story-id]-[feature-name]`  
> **Last updated:** July 2026

---

## The process in three lines

**BA/PO** — write the story in Azure Boards with Given/When/Then acceptance criteria. Done.  
**Anyone** — run `#sdd.prompt.md  story: #4821` in Copilot Chat. Branch created. Specs written.  
**Developer** — open `plan.md`, add technical detail. Implement one task at a time. Raise PR.

---

## Table of contents

1. [What SDD is and why we use it](#1-what-sdd-is-and-why-we-use-it)
2. [Roles and what each person owns](#2-roles-and-what-each-person-owns)
3. [Repository structure — where everything lives](#3-repository-structure--where-everything-lives)
4. [One-time setup — prerequisites](#4-one-time-setup--prerequisites)
5. [One-time setup — ADO MCP server](#5-one-time-setup--ado-mcp-server)
6. [One-time setup — Copilot instructions](#6-one-time-setup--copilot-instructions)
7. [One-time setup — spec templates](#7-one-time-setup--spec-templates)
8. [One-time setup — constitution.md](#8-one-time-setup--constitutionmd)
9. [The sdd.prompt.md — full source](#9-the-sddpromptmd--full-source)
10. [Azure Boards — work item setup](#10-azure-boards--work-item-setup)
11. [The full workflow — step by step](#11-the-full-workflow--step-by-step)
12. [What the three spec files contain](#12-what-the-three-spec-files-contain)
13. [Overlap detection — how it works](#13-overlap-detection--how-it-works)
14. [Branch lifecycle and PR](#14-branch-lifecycle-and-pr)
15. [Handling small changes](#15-handling-small-changes)
16. [Spec folder structure at scale](#16-spec-folder-structure-at-scale)
17. [Spec health and maintenance](#17-spec-health-and-maintenance)
18. [Troubleshooting](#18-troubleshooting)
19. [Quick reference card](#19-quick-reference-card)

---

## 1. What SDD is and why we use it

Spec-driven development means the specification is the primary artifact. Code is what gets generated from it. Instead of writing vague prompts and hoping Copilot guesses correctly, we write a precise specification first. Copilot then has a clear contract to implement against.

### The three failure modes it solves

Without specs, AI-assisted development breaks in predictable ways:

- **Intent drift** — "add form validation" means something different to the BA, the dev, and Copilot. Everyone builds a slightly different thing.
- **Context decay** — as the codebase grows, Copilot forgets earlier decisions and silently contradicts them in new features.
- **No definition of done** — without explicit acceptance criteria, there is no way to verify whether the output is correct. Code review becomes guesswork.

A spec eliminates all three. It is the shared contract between the BA who defines what to build, the developer who decides how to build it, and Copilot which does the mechanical translation.

### Our mode: spec-anchored

We use spec-anchored development:

- Specs are written before implementation begins.
- Specs stay alive and evolve as requirements change — they are never thrown away.
- The spec always describes what the feature does right now, not just what it did when it was created.
- Code lives on a feature branch alongside the spec. Both travel together through the PR and merge to main together.

---

## 2. Roles and what each person owns

| Role | Primary tool | Owns | Never does |
|---|---|---|---|
| Business Analyst | Azure Boards | User story · acceptance criteria · scope boundaries | Touch any file in the repo |
| Product Owner | Azure Boards | Reviews spec.md before dev starts · approves scope | Write technical requirements |
| Frontend Developer | VS Code + Copilot | plan.md · tasks.md · implementation | Rewrite BA's acceptance criteria |
| Anyone | Copilot Chat | Running `#sdd.prompt.md` to generate the branch and specs | — |

### The handoff contract

The BA writes a structured user story in Azure Boards. That work item is the single source of truth for *what* to build.

The `sdd.prompt.md` command reads the story live from ADO, creates the branch, scans existing specs, and writes the three spec files. The spec files are the single source of truth for *how* to build it.

**The BA never touches a markdown file. The developer never rewrites acceptance criteria.**

---

## 3. Repository structure — where everything lives

```
your-repo/
│
├── specs/                              ← all spec files live here
│   ├── _templates/                     ← blank templates for new specs
│   │   ├── spec.md
│   │   ├── plan.md
│   │   └── tasks.md
│   ├── _global/                        ← cross-cutting rules, applies to everything
│   │   ├── api-conventions.md
│   │   ├── accessibility.md
│   │   └── error-handling.md
│   ├── _shared/                        ← reusable components used in 2+ features
│   │   ├── button/
│   │   │   └── spec.md
│   │   ├── form-fields/
│   │   │   └── spec.md
│   │   └── navigation/
│   │       └── spec.md
│   ├── checkout/                       ← domain folder
│   │   ├── _domain.md                  ← domain overview, team, key entities
│   │   ├── payment-form/               ← feature folder
│   │   │   ├── spec.md                 ← WHAT to build (BA scenarios + edge cases)
│   │   │   ├── plan.md                 ← HOW to build it (dev-owned, technical)
│   │   │   └── tasks.md                ← atomic implementation checklist
│   │   └── order-summary/
│   │       ├── spec.md
│   │       ├── plan.md
│   │       └── tasks.md
│   └── user-profile/                   ← another domain folder
│       ├── _domain.md
│       └── personal-details/
│           ├── spec.md
│           ├── plan.md
│           └── tasks.md
│
├── .github/
│   ├── copilot-instructions.md         ← global Copilot behaviour rules
│   └── prompts/
│       └── sdd.prompt.md               ← THE command — branch + spec generation
│
├── .specify/
│   └── memory/
│       └── constitution.md             ← team-wide non-negotiables
│
├── .vscode/
│   └── mcp.json                        ← ADO MCP server connection config
│
└── docs/
    ├── sdd-complete-manual.md          ← this file
    └── SDD-quickstart.md               ← one-page summary for daily use
```

### The three spec files explained

| File | Written by | Contains | Copilot uses it for |
|---|---|---|---|
| `spec.md` | Prompt (from ADO AC) + Dev (edge cases) | What to build — user scenarios, scope, edge cases | Definition of done during code review |
| `plan.md` | Prompt (skeleton) + Dev (fills in detail) | How to build it — components, state, API, accessibility | Context when implementing each task |
| `tasks.md` | Prompt (generated from spec + plan) | Atomic implementation steps, prefixed by story ID | One task per Copilot implementation session |

---

## 4. One-time setup — prerequisites

These must be in place before any team member can use the workflow.

### Node.js

```bash
node --version   # needs v18 or later
```

Download from nodejs.org if not installed.

### Azure CLI

```bash
# macOS
brew install azure-cli

# Windows
winget install Microsoft.AzureCLI

# Verify
az --version
```

### Sign in to Azure CLI

```bash
az login
# Opens browser — sign in with the account that has access to your ADO organisation
```

### GitHub Copilot

Each developer needs an active GitHub Copilot subscription. Confirm by opening VS Code and checking that the Copilot icon is active in the status bar.

### Git configured

```bash
git config --global user.name "Your Name"
git config --global user.email "you@company.com"
```

---

## 5. One-time setup — ADO MCP server

The ADO MCP server is what lets Copilot read your Azure Boards work items directly inside VS Code, without copy-pasting. It is how `sdd.prompt.md` reads story details and title automatically.

### Option A — Remote server (recommended, no local install)

Create `.vscode/mcp.json` in your repository root:

```json
{
  "servers": {
    "ado-remote-mcp": {
      "url": "https://mcp.dev.azure.com/YOUR-ORG-NAME",
      "type": "http"
    }
  },
  "inputs": []
}
```

Replace `YOUR-ORG-NAME` with the organisation name from your ADO URL: `https://dev.azure.com/YOUR-ORG-NAME`.

**Authenticate:** Open VS Code → open Copilot Chat → switch to Agent mode → click the tools icon (⚒). VS Code will prompt you to authenticate via browser. Sign in with your ADO account.

**Verify:** Type in Copilot Chat:
```
List my Azure DevOps projects
```
If you see your project names, the connection is working.

### Option B — Local server (fallback for restricted networks)

Use this if your organisation's network blocks the remote endpoint.

```json
{
  "inputs": [{
    "id": "ado_org",
    "type": "promptString",
    "description": "Azure DevOps organisation name"
  }],
  "servers": {
    "ado": {
      "type": "stdio",
      "command": "npx",
      "args": [
        "-y", "@azure-devops/mcp",
        "${input:ado_org}",
        "--authentication", "azcli",
        "-d", "core", "work", "work-items"
      ]
    }
  }
}
```

The `-d work-items` flag loads only the tools needed — keeps Copilot's context lean.

### Commit mcp.json to the repo

Commit `.vscode/mcp.json` so every developer on the team gets the same MCP configuration automatically when they clone.

```bash
git add .vscode/mcp.json
git commit -m "chore: add ADO MCP server config"
```

---

## 6. One-time setup — Copilot instructions

This file tells Copilot how to behave across every chat session in this repository. Without it, Copilot does not know to use ADO tools automatically.

Create `.github/copilot-instructions.md`:

```markdown
# Copilot instructions — SDD frontend team

This project uses Azure DevOps for work item tracking and
spec-driven development for all feature work.

## ADO MCP
Always check if the Azure DevOps MCP server has a tool relevant
to the user's request before answering. Use it to read work items,
stories, and acceptance criteria live from Azure Boards.

## Spec-driven development
When generating or updating specs, always:
1. Read the ADO work item first using the MCP server
2. Scan existing specs under specs/ for overlap before creating new ones
3. Follow the spec templates in specs/_templates/
4. Use the spec.md as the definition of done when implementing

## Implementation rules
- Always read specs/[domain]/[feature]/spec.md and plan.md before
  implementing any task
- Implement one task at a time — never all tasks in one session
- Do not add behaviour not described in spec.md
- Reference specs/_global/ and specs/_shared/ where relevant

## Branch convention
All feature branches follow: feature/[story-id]-[feature-name]
Example: feature/4821-add-email-form-validation
```

Commit this file:

```bash
git add .github/copilot-instructions.md
git commit -m "chore: add Copilot instructions for SDD workflow"
```

---

## 7. One-time setup — spec templates

These blank templates are what the `sdd.prompt.md` command uses when creating a new spec. Create the `specs/_templates/` folder and add three files.

### specs/_templates/spec.md

```markdown
---
feature: [feature-slug]
status: active
related-ado: []
related-specs: []
created: [YYYY-MM-DD]
last-updated: [YYYY-MM-DD]
---

# Feature: [feature name]

## Context
[One paragraph: why this feature exists and what user problem it solves.]

## User scenarios

**Scenario: [name]**
Given [context]
When [action]
Then [outcome]

## Scope boundaries

### In scope
- [what this spec covers]

### Out of scope
- [what this spec explicitly does NOT cover]

## Edge cases
- Empty state: [behaviour when there is no data]
- Error state: [behaviour when something fails]
- Loading state: [behaviour while waiting for data]
- [any feature-specific edge cases]
```

### specs/_templates/plan.md

```markdown
# Technical plan: [feature name]

## Stack and approach
[Framework, libraries, patterns used — no implementation details from spec.md]

## Component structure
[Component hierarchy, props interfaces, state management approach]

## API / data contracts
[Endpoints, request/response shapes, error codes the UI must handle]

## States to handle
- Default
- Loading
- Empty
- Error
- [feature-specific states]

## Accessibility
[ARIA labels, keyboard navigation, focus management, screen reader behaviour]

## Responsive behaviour
[Breakpoints, layout changes, touch targets]

## Technical decisions and trade-offs
[Architecture choices made during planning and why]
```

### specs/_templates/tasks.md

```markdown
# Tasks: [feature name]

## Phase 1: Foundation
- [ ] [Story #XXXX] [task description]

## Phase 2: Core behaviour
- [ ] [Story #XXXX] [task description]

## Phase 3: Edge cases
- [ ] [Story #XXXX] [task description]

## Phase 4: Polish
- [ ] [Story #XXXX] [task description]
```

Commit the templates:

```bash
git add specs/_templates/
git commit -m "chore: add SDD spec templates"
```

---

## 8. One-time setup — constitution.md

The constitution captures team-wide rules that apply to every feature, every time. It is the layer above all specs. Copilot reads it after every spec generation and flags any contradiction.

Create `.specify/memory/constitution.md`:

```markdown
# Team constitution

These rules apply to every feature, every spec, every PR.
No feature spec or plan may contradict these.

## Testing
- Every component must have at least one unit test covering the happy path.
- Form validation logic must be tested with at least one invalid input case.
- Edge cases listed in spec.md must have corresponding test cases.

## Accessibility
- All form inputs must have associated visible labels.
- Error messages must use role="alert" so screen readers announce them.
- All interactive elements must be keyboard accessible.
- Colour contrast must meet WCAG AA (4.5:1 for normal text).

## Component conventions
- Use controlled components for all form inputs — no uncontrolled inputs.
- Shared components live in src/components/shared/ not in feature folders.
- Feature-specific components live co-located with their feature code.

## TypeScript
- No `any` types. Use `unknown` and narrow explicitly.
- All props interfaces must be explicitly defined and exported.
- No implicit returns from functions that may return undefined.

## API and error handling
- All API calls must handle loading, success, and error states.
- Error messages shown to users must be human-readable strings,
  never raw error objects or stack traces.
- All API calls must include a timeout.

## Performance
- No component may block the main thread for more than 50ms.
- Images must have explicit width and height to prevent layout shift.
```

Commit:

```bash
mkdir -p .specify/memory
git add .specify/memory/constitution.md
git commit -m "chore: add team constitution for SDD"
```

---

## 9. The sdd.prompt.md — full source

This is the single command that powers the entire workflow. It creates the branch, reads the ADO story, scans for spec overlap, and generates or updates the three spec files.

Create `.github/prompts/sdd.prompt.md` with this exact content:

```markdown
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
\```
git branch --show-current
\```

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
\```
git checkout main
git pull origin main
git checkout -b feature/[story-id]-[slugified-title]
\```
5. Confirm the branch was created and print:
\```
BRANCH CREATED: feature/4821-add-email-form-validation
\```

If git commands fail (e.g. uncommitted changes blocking checkout), stop and tell
the developer what to resolve before continuing.

---

## Step 1 — Read the story from Azure Boards

Use the Azure DevOps MCP server tool `wit_get_work_item` to read work item: **${input:story}**

Extract:
- Title
- Description (the "As a / I want / So that" text)
- Acceptance Criteria (the Given/When/Then scenarios)
- Any "Out of scope" notes

If the MCP server is unavailable, ask the developer to paste the acceptance
criteria directly before continuing.

---

## Step 2 — Scan existing specs on main

**Always scan specs from the `main` branch, not the current feature branch.**
The feature branch is in-flight and not yet the source of truth.
Two parallel branches could otherwise both scan, both see "no overlap", and
generate duplicate specs that conflict at merge time.

Use git to list all spec paths on main first:
\```
git ls-tree -r --name-only main specs/
\```

Then read each spec.md frontmatter:
\```
git show main:specs/[path]/spec.md
\```

Read the YAML frontmatter (`feature`, `status`, `related-specs`) from every spec.md
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
Add a `_domain.md` file to the new domain folder describing its scope.

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
- Generate a skeleton with section headings — the developer fills in the detail
- Reference `specs/_shared/` and `specs/_global/` where relevant
- Do not repeat acceptance criteria from spec.md

### tasks.md
- Each task must be completable in one Copilot session
- Group into phases: Foundation → Core behaviour → Edge cases → Polish
- Prefix every task with its story ID: `[Story #4821]`
- Include the spec path as a comment on the first task so Copilot always has context

---

## Step 4 — Output a summary before writing

Before writing any files, print:

\```
BRANCH:  feature/4821-add-email-form-validation (created / already exists)
ACTION:  UPDATING specs/checkout/payment-form
         — OR —
         CREATING specs/checkout/email-form-validation

  spec.md  — [what changed or what was added]
  plan.md  — [what changed or what was added]
  tasks.md — [N tasks added / N tasks appended]
\```

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
```

Commit the prompt:

```bash
mkdir -p .github/prompts
git add .github/prompts/sdd.prompt.md
git commit -m "chore: add SDD master prompt"
```

---

## 10. Azure Boards — work item setup

### User story template

Configure a work item template in Azure Boards so every story is pre-filled with the structure the prompt expects.

Go to **Azure Boards → Work Items → any User Story → three-dot menu → Save as template**. Name it `SDD User Story`.

**Description field default:**

```
As a [type of user]
I want [some goal]
So that [some reason]
```

**Acceptance Criteria field default:**

```
Scenario: [scenario name]
Given [initial context]
When [user action or event]
Then [expected outcome]

Out of scope:
- [what this story will NOT do]

Edge cases to consider:
- Empty state
- Error state
- [any feature-specific edge cases]
```

### Add a Spec Path field

Add a custom text field called `Spec Path` to the User Story work item type. After the developer runs the command and the spec is created, they fill this in with the spec folder path (e.g. `specs/checkout/payment-form`). This creates a hard link from the ADO story to the repo spec that anyone can follow.

**To add the field:** Organisation Settings → Process → your process → User Story → New Field → Text (single line) → name it `Spec Path`.

### Work item states

Add or rename states to match the SDD lifecycle:

| State | Meaning |
|---|---|
| `New` | Story written, not yet refined |
| `Ready for Dev` | BA and PO have completed the story. AC is structured. |
| `Spec Created` | `#sdd.prompt.md` has been run. Spec files exist on the branch. |
| `In Progress` | Developer is implementing tasks |
| `In Review` | PR is open |
| `Done` | PR merged. Specs are on main. |

---

## 11. The full workflow — step by step

### Step 1 — BA writes the story

The BA creates a User Story using the SDD template (section 10). The story must have:

- Description in "As a / I want / So that" format
- At least one Given/When/Then scenario in the Acceptance Criteria field
- An "Out of scope" list
- Moves to **Ready for Dev** once the PO has reviewed and agreed on scope

### Step 2 — Anyone runs the command

In VS Code, open Copilot Chat and switch to **Agent mode** (dropdown next to the input).

Type:

```
#sdd.prompt.md  story: #4821
```

Press Enter. Watch the output. The command will:

1. Check if you are already on a matching feature branch
2. If not: `git checkout main` → `git pull` → `git checkout -b feature/4821-[name]`
3. Read story 4821 from Azure Boards via MCP
4. Scan all specs on `main` for overlap
5. Print a summary of what it is about to do
6. Write `spec.md`, `plan.md`, and `tasks.md` to the correct folder on the branch

Total time: typically under 60 seconds.

### Step 3 — PO reviews spec.md

Before any code is written, the PO opens `specs/[domain]/[feature]/spec.md` and confirms:

- The Given/When/Then scenarios match the intent of the story
- The "Out of scope" list correctly excludes what was not agreed

This is the cheapest point to catch a misunderstanding. One conversation before a line of code exists.

### Step 4 — Developer enriches plan.md

The developer opens `specs/[domain]/[feature]/plan.md`. The prompt has generated a skeleton with the right section headings. The developer fills in the real technical detail:

- Which components will be created or modified
- How state is managed (local, Zustand, Context, server state)
- Which API endpoints are called and what the expected response shapes are
- What accessibility implementation is required
- How responsive behaviour works at each breakpoint

The BA never reads `plan.md`. It is purely for the development team and Copilot.

### Step 5 — Implement task by task

Open `specs/[domain]/[feature]/tasks.md`. Take the first unchecked task.

In Copilot Chat (Agent mode):

```
Read specs/checkout/payment-form/spec.md and plan.md.
Implement task: "[paste the task title here]"
Only implement what is described in spec.md. Do not add behaviour not in the spec.
```

Review the output. If it looks correct, accept it. Mark the task `[x]` in `tasks.md`. Move to the next task.

Never ask Copilot to implement all tasks at once. The output is harder to review, more likely to drift from the spec, and harder to attribute to the correct task when something goes wrong.

### Step 6 — Raise the PR

The PR contains:

- The implementation code
- `spec.md` — what was agreed to build
- `plan.md` — how it was built and why
- `tasks.md` — the completed checklist

PR description should include:

```markdown
## ADO Story
[link to ADO work item #4821]

## Spec
specs/checkout/payment-form/

## What changed
[brief summary]

## Checklist
- [ ] spec.md reflects what was actually built
- [ ] plan.md documents all technical decisions made during implementation
- [ ] All tasks in tasks.md are checked off
- [ ] No spec was created that duplicates an existing one on main
```

### Step 7 — Code review validates against spec

The reviewer opens `spec.md` alongside the PR diff.

For every scenario in `spec.md`: the implementation must satisfy it.

If a scenario is not covered → it is a bug, not a scope question.  
If the implementation added behaviour not in `spec.md` → it needs to be either removed or the spec needs updating before merge.

### Step 8 — Merge to main

After approval, the PR merges to main. The spec files are now on main and become the source of truth for future overlap scans.

Update the ADO work item:

- Set state to `Done`
- Fill in the `Spec Path` field with the spec folder path
- Optionally add a comment linking to the merged PR

### Step 9 — Story changed mid-sprint?

If the BA updates the acceptance criteria in ADO after the branch has been created, re-run the same command:

```
#sdd.prompt.md  story: #4821
```

The command detects you are already on the correct branch (skips branch creation), re-reads the updated story from ADO, finds the existing spec, and patches only the sections that changed. Existing completed tasks are never touched.

---

## 12. What the three spec files contain

### spec.md — the contract

Written by the prompt (scenarios from ADO), enriched by the dev (edge cases). The BA can read it and recognise their own requirements.

```markdown
---
feature: payment-form
status: active
related-ado: [4821]
related-specs: []
created: 2026-07-01
last-updated: 2026-07-01
---

# Feature: Payment form

## Context
Allows users to enter card details and submit payment during checkout.
The card processing is handled by Stripe — we never handle raw card numbers.

## User scenarios

<!-- Updated: 2026-07-01 | Story #4821 | Initial spec -->

**Scenario: Successful payment**
Given the user has items in their cart
When they enter valid card details and click Pay
Then the payment is submitted to Stripe and they are redirected to confirmation

**Scenario: Invalid card number**
Given the user is on the payment form
When they enter an invalid card number
Then an inline error appears below the card field before they can submit

## Scope boundaries

### In scope
- Card number, expiry, CVV entry
- Real-time validation of card number format
- Submit button loading and disabled state during processing

### Out of scope
- Saved payment methods (separate story)
- PayPal or Apple Pay (separate stories)
- Refund flow (handled in Orders domain)

## Edge cases
- Empty state: all fields blank, submit button disabled
- Error state: Stripe returns a payment failure, human-readable error shown
- Loading state: button shows spinner, form fields disabled during processing
- Network timeout: error message with retry option
```

### plan.md — the technical blueprint

Written by the developer after reviewing `spec.md`. Copilot reads this as context for every implementation task.

```markdown
# Technical plan: Payment form

## Stack and approach
React with TypeScript. Stripe Elements for card input components (PCI compliance —
we cannot use custom inputs for card numbers). Zustand for checkout cart state.
React Query for the payment mutation.

## Component structure
PaymentForm (page-level, owns form state)
  ├── CardElement (Stripe's component — not built by us)
  ├── SubmitButton (from _shared/button, primary variant)
  └── PaymentError (local component, uses role="alert")

## API / data contracts
POST /api/v1/checkout/payment
  Body: { stripePaymentMethodId: string, cartId: string }
  Success: 200 { orderId: string, redirectUrl: string }
  Failure: 400 { error: { code: string, message: string } }
  Timeout: treat same as failure — show retry error

## States to handle
- Default: form ready, submit enabled when Stripe card element is complete
- Loading: submit clicked, button disabled and shows spinner
- Error: Stripe or API failure, error message below form
- Success: redirect to /order-confirmation/[orderId]

## Accessibility
- CardElement is managed by Stripe and is already accessible
- SubmitButton aria-disabled during loading
- PaymentError uses role="alert" for screen reader announcement
- Focus moves to error message on failure

## Responsive behaviour
- Single column on mobile, max-width 480px on desktop
- Full-width submit button on mobile

## Technical decisions
- Using Stripe Elements not custom inputs: PCI compliance requirement (ADR-001)
- No client-side card number storage of any kind
```

### tasks.md — the implementation checklist

Generated by the prompt from `spec.md` and `plan.md`. The developer works through it one task per Copilot session.

```markdown
# Tasks: Payment form

## Phase 1: Foundation
- [ ] [Story #4821] Scaffold PaymentForm component with Stripe Elements provider
- [ ] [Story #4821] Add Stripe CardElement with basic styling
- [ ] [Story #4821] Connect form state to Stripe's onReady and onChange events

## Phase 2: Core behaviour
- [ ] [Story #4821] Implement submit handler — call POST /api/v1/checkout/payment
- [ ] [Story #4821] Add loading state — disable form, show spinner on SubmitButton
- [ ] [Story #4821] Handle success response — redirect to order confirmation

## Phase 3: Edge cases
- [ ] [Story #4821] Handle API error response — show PaymentError with message
- [ ] [Story #4821] Handle network timeout — show retry error message
- [ ] [Story #4821] Disable submit button when CardElement is not complete

## Phase 4: Polish
- [ ] [Story #4821] Add focus management on error — move focus to PaymentError
- [ ] [Story #4821] Add unit tests for submit handler (success, API failure, timeout)
- [ ] [Story #4821] Verify keyboard navigation through full form
```

---

## 13. Overlap detection — how it works

When `sdd.prompt.md` runs, it scans all specs on the `main` branch before writing anything. This is the mechanism that prevents duplicate specs from being created.

### Why main, not the current branch

If two developers both start a story on the same day and both scan the specs on their own feature branches, both scans will return "nothing found" — because neither branch has been merged yet. Both will create a new spec for the same component, which will conflict at merge time.

Scanning `main` means scanning only specs that are already merged and stable. This is the correct source of truth.

### The three outcomes

| Result | What it means | What the prompt does |
|---|---|---|
| OVERLAP | New story changes or extends behaviour already in an existing spec | Updates that spec in-place. Appends to tasks.md. Never rewrites. |
| RELATED | New story uses a shared component but adds a genuinely separate user flow | Creates a new spec. Adds cross-references in both specs' frontmatter. |
| INDEPENDENT | No meaningful connection to any existing spec | Creates a new spec in the appropriate domain folder. |

### The email form example

**Sprint 1, Story #4801:** "Create a contact email form"
→ Scan returns INDEPENDENT
→ Creates `specs/contact/email-form/spec.md`, `plan.md`, `tasks.md`
→ Branch: `feature/4801-contact-email-form`

**Sprint 2, Story #4821:** "Add email format validation to the contact form"
→ Scan returns OVERLAP with `specs/contact/email-form/`
→ Updates `spec.md` — adds validation scenarios
→ Appends to `tasks.md` — adds validation tasks prefixed `[Story #4821]`
→ Branch: `feature/4821-email-form-validation`

**Sprint 3, Story #4835:** "Add the contact form to the About page"
→ Scan returns RELATED — same component, different page
→ Creates `specs/about/contact-form-section/spec.md`
→ Adds `related-specs: [contact/email-form]` in both specs' frontmatter
→ Branch: `feature/4835-about-contact-form`

### Parallel branches (the one edge case)

If two stories are picked up simultaneously and both touch the same domain, the overlap scan cannot see each other's in-flight branches. The practical mitigation:

At sprint planning, when two stories touch the same domain, agree upfront which story creates and which story updates. This takes one conversation. Write the decision in the ADO story comments so it is visible to anyone picking up the work.

---

## 14. Branch lifecycle and PR

### Branch naming

The command derives the branch name automatically:

```
format: feature/[story-id]-[slugified-title]

Story 4821: "Add email form validation"
Branch:     feature/4821-add-email-form-validation

Story 4835: "User can save notification preferences"
Branch:     feature/4835-user-can-save-notification-pref
```

The title is lowercased, spaces and special characters replaced with hyphens, truncated to 40 characters.

### What the PR contains

A PR in this workflow always contains both spec files and code. Reviewers see:

```
specs/checkout/payment-form/spec.md    ← what was agreed to build
specs/checkout/payment-form/plan.md    ← how it was built
specs/checkout/payment-form/tasks.md   ← implementation checklist (all checked)
src/features/checkout/PaymentForm.tsx  ← the implementation
src/features/checkout/PaymentForm.test.tsx
```

This means the PR review is a complete audit: the spec says what should be there, the code either satisfies it or it does not.

### Spec update before merge

If implementation revealed something that differs from the spec — an edge case that needed a different approach, a decision that changed during development — the spec must be updated before the PR is merged, not after.

```
#sdd.prompt.md  story: #4821
```

Re-running the command on an existing branch will detect the branch, re-read the ADO story, and prompt the developer to describe what changed. The spec is then patched accordingly.

---

## 15. Handling small changes

Not every change needs the full cycle. Use this scale:

| Change | Spec update? | Process |
|---|---|---|
| Button colour, label text, spacing | No | Just do it. Note it in the PR description. |
| Adding a loading or empty state | Minimal | Add one line to the edge cases section of spec.md manually. |
| New error handling | Yes | Add scenario to spec.md, new tasks to tasks.md. |
| New Given/When/Then scenario from BA | Yes | Re-run `#sdd.prompt.md` — it will patch the spec. |
| New feature or page | Yes | Run `#sdd.prompt.md` — creates new branch and spec. |

### The threshold test

Ask: "If Copilot were implementing this feature from the spec tomorrow, would it miss this change?"

If yes → update the spec before merging.  
If no → PR description note is enough.

---

## 16. Spec folder structure at scale

A flat list of spec folders works for a small product. As the product grows to 20+ features and 3–5 domains, organise specs to mirror the product's architecture.

### The four layers

| Layer | Folder | What it contains | Rate of change |
|---|---|---|---|
| Global | `specs/_global/` | API conventions, accessibility rules, error handling patterns | Low — team-wide agreement needed to change |
| Shared | `specs/_shared/` | Components used in 2+ features: buttons, modals, form fields | Medium — grows with design system |
| Domain | `specs/[domain]/` | A bounded business area with a `_domain.md` overview | Medium — one domain per team |
| Feature | `specs/[domain]/[feature]/` | A specific user flow | High — changes every sprint |

### The one-way dependency rule

Specs at higher layers constrain all specs below. A feature spec can reference a shared component spec. A shared component spec cannot reference a feature spec.

```
_global        →  referenced by everything
_shared        →  references _global only
_domain.md     →  references _global and relevant _shared
feature/       →  references _global, relevant _shared, its own _domain.md
```

When giving Copilot context for implementation, load in this order:

```
1. specs/_global/api-conventions.md        (if the feature makes API calls)
2. specs/_global/accessibility.md          (always)
3. specs/_shared/[relevant]/spec.md        (if the feature uses shared components)
4. specs/[domain]/_domain.md
5. specs/[domain]/[feature]/spec.md
6. specs/[domain]/[feature]/plan.md
```

### The _domain.md file

Every domain folder contains a `_domain.md` that Copilot reads before touching any feature in that domain. It captures:

```markdown
# Domain: Checkout

## Purpose
Covers everything from cart through to order confirmed.
Does NOT include post-purchase flows — those live in the Orders domain.

## Team
Domain lead: [name]
Frontend squad: [names]

## Key entities
- Cart — belongs to a user session, persists across browser reloads
- Order — created on successful payment, immutable after creation

## Architecture decisions
- ADR-001: Stripe Elements for card input (PCI compliance)
- ADR-002: Cart state in Zustand (performance)

## Dependencies
- Reads from: Product domain (product IDs, prices)
- Writes to: Orders domain (on payment completion)
- Shared components: form-fields, button, modal
```

### When to introduce each level

| Stage | Approach |
|---|---|
| First 10 features, 1 team | Flat: `specs/feature-name/` — simple, fast |
| 10–30 features, 1–2 teams | Add `_global/` and `_shared/`. Keep features flat. |
| 30+ features, 2–5 teams | Full domain hierarchy with `_domain.md` files |

The signal to move up: developers say "I didn't know that spec existed" or Copilot implements the same shared behaviour differently in different features.

---

## 17. Spec health and maintenance

### Sprint start checklist

Before writing a line of code each sprint:

- [ ] Every new story has been through `#sdd.prompt.md`
- [ ] All spec files have been reviewed by the PO
- [ ] No two specs describe the same component differently
- [ ] `constitution.md` has not been violated by any new spec

### Sprint end checklist

Before closing the sprint:

- [ ] Every implemented spec reflects what was actually built (no spec drift)
- [ ] Completed tasks in `tasks.md` are marked `[x]`
- [ ] ADO work items are in the correct state
- [ ] Spec files have been merged to main via PR

### Signs of spec drift — watch for these

- A developer says "the spec is outdated, just look at the code" → update the spec immediately before anyone builds on top of it
- Two specs describe the same component differently → consolidate into one, archive the other
- Copilot generates something inconsistent with existing behaviour → a spec is missing context from `_shared/` or `_global/`
- A PR review finds behaviour the spec does not mention → update the spec before merging, not after

### Consolidating two specs that overlap

When two specs have grown to describe the same thing:

1. Create a new `spec.md` that represents the current complete state of the feature
2. Archive the old specs: move them to `specs/_archive/[year]/`
3. Update frontmatter: `status: archived`, note the superseding spec
4. Update `related-specs` on any spec that referenced the old ones
5. Commit with message: `docs: consolidate payment-form and payment-validation specs`

---

## 18. Troubleshooting

### MCP server not connecting

```bash
# Re-authenticate
az login

# Restart VS Code
# Reopen Copilot Chat → Agent mode → click tools icon
# Look for ado-remote-mcp in the list
```

If the tools icon does not show the MCP server, check `.vscode/mcp.json` for syntax errors. Run `az account show` to confirm you are logged in.

### Branch creation fails — uncommitted changes

```bash
# Stash your current changes
git stash

# Then re-run the SDD command
# After branch is created and specs are written:
git stash pop
```

### Spec written to wrong domain folder

Re-run the command and describe the domain explicitly:

```
#sdd.prompt.md  story: #4821
Note: this story belongs to the checkout domain, not user-profile.
```

The command will move the files to the correct location.

### spec.md was rewritten instead of patched

If Copilot rewrote the entire spec instead of appending, restore the previous version from git:

```bash
git diff HEAD specs/[domain]/[feature]/spec.md    # see what changed
git checkout HEAD -- specs/[domain]/[feature]/spec.md  # restore
```

Then re-run the command with an explicit instruction:

```
#sdd.prompt.md  story: #4821
Important: do NOT rewrite spec.md. Only append the new scenarios from this story.
```

### Two parallel branches created duplicate specs

Identify which spec to keep (usually the one on the branch that will merge first). On the other branch:

```
The spec at specs/checkout/payment-form already exists from another branch.
Please update that spec with Story #4821's scenarios instead of creating
a new one. Do not create a duplicate folder.
```

---

## 19. Quick reference card

### The one command

```
#sdd.prompt.md  story: #[ADO story ID]
```

Run in Copilot Chat Agent mode. Works for new stories and updated stories. Same command every time.

### What it does

| Step | What happens |
|---|---|
| 0 | Creates branch `feature/[id]-[name]` from latest main (skips if already on one) |
| 1 | Reads story from Azure Boards via MCP |
| 2 | Scans specs on main for overlap |
| 3 | Creates or updates `spec.md`, `plan.md`, `tasks.md` |
| 4 | Prints summary of what was done |
| 5–6 | Constitution check, warns if violated |

### Branch naming

```
feature/[story-id]-[slugified-title]
feature/4821-add-email-form-validation
```

### Implementing a task

```
Read specs/[domain]/[feature]/spec.md and plan.md.
Implement task: "[paste task title]"
Only implement what is described in spec.md. Nothing extra.
```

### File ownership

| File | Who writes it | Who reads it |
|---|---|---|
| ADO work item | BA / PO | Everyone |
| `spec.md` | Prompt + Dev (edge cases) | PO (review) · Dev · Copilot (implementation) · Reviewer (PR) |
| `plan.md` | Prompt (skeleton) + Dev (detail) | Dev · Copilot |
| `tasks.md` | Prompt | Dev (tick off) · Copilot (one task at a time) |
| `constitution.md` | Team (agreed together) | Copilot (checks every spec against it) |

### When to update the spec vs just do it

| Change | Action |
|---|---|
| Button style, colour, copy | Just do it. PR note. |
| New loading / empty / error state | Add one line to spec.md edge cases |
| New scenario or changed AC | Re-run `#sdd.prompt.md` |
| New feature or page | Re-run `#sdd.prompt.md` |

### The one rule

> The spec always reflects what was built.  
> Update the spec before the PR merges, not after.

---

*Review this document at the end of each quarter, or when the toolchain changes.*  
*Quick reference: `docs/SDD-quickstart.md`*
