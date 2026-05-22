# Frontend Standards — Condensed AI Reference

**Project context:** Vue 3.5.x / Pinia 3.x / TypeScript (strict).

This is the **condensed checklist** used by `/review-my-pr` and Standards Reviewer Mode — examples and rationale stripped, designed for low-token consumption during AI-driven reviews. **This file is self-contained;** do not fetch other documents during a review.

> **For human maintainers:** a full human-facing reference exists separately. When the rules in either doc change, sync the other. The two must agree.

## How to report violations

For every issue you flag, include:

- **File and line** (e.g. `src/stores/user.ts:42`)
- **Rule** — cite the section number from this doc (e.g. `§9 Pinia — storeToRefs rule`)
- **Why** — one sentence on the impact (silent bug, reactivity loss, a11y violation, etc.)
- **Suggested fix** — concrete replacement code or one-line guidance

Severity tagging: 🔴 bug / 🟡 design smell / 🟢 style. Don't flag rules already followed.

---

## 1. Core principles

- **DRY:** Extract a shared abstraction only after the third occurrence (Rule of Three). DRY applies to *knowledge*, not character sequences.
- **KISS:** Prefer boring, well-understood code. A `for` loop can beat a clever `.reduce()`.
- **YAGNI:** No speculative config, options bags, or feature-flagged half-built features. Delete dead branches.
- **SRP:** Functions do one thing. Components have one reason to re-render. If the name needs "and", split it.
- **Principle of Least Surprise:** No hidden side effects in pure-looking functions. Props named `disabled` must disable, not hide.

## 2. TypeScript discipline

- Strict mode required: `strict: true`, `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes`, `noImplicitOverride`, `noFallthroughCasesInSwitch`.
- **No `any`** — use `unknown` (then narrow) or generics. ESLint `no-explicit-any: error`.
- **Model state as discriminated unions**, not flag soups like `{ loading, data?, error? }`.
- **Public function boundaries** — explicit parameter and return types. Internal helpers may rely on inference.
- **Validate untrusted input at the edge** with Zod/Valibot. Once inside the app, types are trusted.
- **No boolean flag parameters** — split into two functions or use a named options object.
- **`as` casts** — only after a real runtime check, or `as const`. Never to silence an error.
- **`as const`** for literal arrays, route maps, enum-like constants.
- **`interface`** for object shapes; **`type`** for unions, function signatures, mapped/conditional types.

## 3. Code hygiene

- **Delete dead code immediately.** No commented-out blocks "in case." Git history is the time capsule.
- **Comments explain WHY**, not what. No narration (`// loop through users`). No restating the function name.
- **Empty function bodies (`catch {}`, etc.) are bugs** unless followed by a comment justifying the no-op.
- **Naming:** descriptive over short; booleans read as questions (`isOpen`, `hasPermission`); functions are verbs; components are nouns.
- **Casing per layer:** PascalCase (components/types), camelCase (vars/funcs), SCREAMING_SNAKE (constants), kebab-case (non-component files).
- **Feature folders, not by file type.** Each feature exposes only what `index.ts` re-exports. No deep cross-feature imports.
- **Import order:** node built-ins → external → internal aliases (`@/`) → relative parent → relative sibling → side-effect imports → type-only. Blank line between groups.
- **No circular dependencies** (enforce via `madge` or `dependency-cruiser`).

## 4. Vue 3 — component design

- SFC order: `<script setup lang="ts">` → `<template>` → `<style scoped>`. Always `lang="ts"`. Always `scoped` on leaf components.
- **Multi-word PascalCase** component names (except `App.vue`). Single-word names collide with HTML.
- **Full words, not abbreviations** (`UserProfileOptions.vue`, not `UProfOpts.vue`).
- **Base/App/V prefix** for primitives (`BaseButton.vue`).
- **Parent name prefix** for tightly coupled children (`TodoList.vue`, `TodoListItem.vue`).
- **Order words general → specific** (`SearchInputQuery.vue`, not `QuerySearchInput.vue`).
- One component per file. PascalCase or kebab-case filenames — pick one.
- **Split a component** when template > ~150 lines, > 2 levels of nesting, or it has multiple concerns.

## 5. Vue 3 — `<script setup>` patterns

- **`defineProps`**: type-based destructured form with inline defaults. Never untyped (`defineProps(['x'])`).

  ```ts
  const { id, status = 'idle' } = defineProps<{ id: string; status?: 'idle' | 'loading' }>();
  ```

- **Reactivity pitfall**: destructured props passed to `watch`, `computed`, composables lose reactivity. Use a getter:

  ```ts
  watch(() => status, /* ... */);   // ✅
  useFoo(() => status);             // ✅
  ```

- **`defineEmits`**: typed signature, list every event. kebab-case in templates, camelCase in code.
- **`defineModel`**: only way to declare a v-model. No manual `modelValue` prop + `update:modelValue` emit. Multiple named via `defineModel('name')`.
- **`useTemplateRef()`** (Vue 3.5+): use instead of `ref(null)` + string template ref. Correct typing without `InstanceType` gymnastics.
- **`useId()`** (Vue 3.5+): SSR-safe unique IDs for form labels and `aria-describedby`. Never hardcode IDs.
- **`defineExpose`**: default to NOT exposing. Only for genuine imperative APIs (`focus()`, `play()`). Expose a narrow surface.
- **Pick one prop access pattern per project** — destructured OR `props.foo`. Never mix.

## 6. Vue 3 — template hygiene

- **`v-for` `:key`** must be stable, unique, from the data itself (`item.id`).
- **Never use array index** as key for lists that reorder/filter/splice.
- **Never use translated/i18n strings** as keys — they change on locale switch.
- **`v-if`** vs **`v-show`**: `v-if` removes/recreates (rare or heavy content); `v-show` toggles `display: none` (frequent toggles, cheap content).
- **Never `v-if` + `v-for` on the same element** — move filter to a `computed`, or wrap `v-for` in `<template>`.
- **Conditional classes use object syntax**: `:class="{ 'is-active': isActive }"`. Bare booleans in arrays do nothing useful. Avoid ternaries.
- Extract conditional classes to a `computed` when 3+ conditions.
- Quote all non-empty attribute values. One attribute per line for multi-attr elements.
- Pick shorthand OR full directives consistently (`@click` vs `v-on:click`).
- Move complex expressions out of templates into computeds/methods.

## 7. Vue 3 — reactivity correctness

- **Default to `ref`** for everything (primitives, objects, arrays). Survives reassignment.
- **`reactive`** only for fixed-shape, never-reassigned internal-to-component state. Never destructure without `toRefs()`.
- **`computed`** for derived values; **methods** for handlers/side effects. Methods called in templates re-run every render.
- **`watch` vs `watchEffect` vs `computed`**:
  - `computed` → derive (cached, no side effects)
  - `watch(source, cb)` → specific change with old/new
  - `watchEffect(fn)` → side effect auto-tracking reads
- **`onWatcherCleanup()`** (Vue 3.5+) inside `watch`/`watchEffect` to cancel in-flight async on next run.
- **Avoid reactivity loss**: destructure `reactive` only via `toRefs`; pass refs (not `.value`) into composables; type composable inputs as `MaybeRefOrGetter<T>`, normalize with `toValue()`.
- **Single source of truth** — a `watch(a, v => b.value = v)` is a smell. Use `computed`, `defineModel`, or a shared composable.
- Use `{ immediate: true }`, `{ deep: true }`, `{ flush: 'post' }` consciously.

## 8. Vue 3 — composables

- **`useXxx`** camelCase prefix. One concern per composable.
- **What belongs in a composable**: reusable stateful logic, lifecycle wiring, derived reactive state, async fetching.
- **What stays in component**: template, prop wiring, layout-specific local UI state.
- **Return refs in a plain object**, never `reactive()` — so callers can destructure without losing reactivity.
- **Accept `MaybeRefOrGetter<T>`** for reactive inputs; normalize with `toValue()`.
- **Trailing `options` object** for configuration (extensible).
- **Cleanup via `onScopeDispose`** (preferred over `onUnmounted`). Pair every listener/interval/observer with a teardown.

## 9. Pinia — store design & usage

- **Setup Stores by default.** Options Stores only when migrating from Vuex.
- **Naming**: `useXxxStore` composable, kebab/camel-case store ID.
- **One store per domain or feature**, one store per file. Keep state/getters/actions in the same file.
- Split a store when it covers two domains or exceeds ~200–300 lines.
- **State design**:
  - Declare all state upfront (Pinia won't pick up properties added later).
  - State is raw data only — anything derived → `computed`.
  - Initial: `[]` (not `null`) for lists; `null` (not `undefined`) for optional objects.
  - No DOM nodes, class instances, or non-serializable values.
  - Use `$patch(fn)` for bulk updates (single devtools entry).
- **Getters/computed**: cached, pure, no side effects. Naming = nouns/predicates (`fullName`, `isAuthenticated`), no `get` prefix.
- **Actions**: all business logic, async work, side effects. Standard async pattern:

  ```ts
  async function fetchUser(id: string) {
    isLoading.value = true;
    error.value = null;
    try {
      user.value = await api.get(`/users/${id}`);
    } catch (e) { error.value = e instanceof Error ? e : new Error(String(e)); throw e; }
    finally { isLoading.value = false; }
  }
  ```

- **`storeToRefs()` for state** — destructuring state directly loses reactivity. Destructuring actions is fine (they're stable function refs).
- **Cache the store handle once per setup** — `const userStore = useUserStore()` at the top, reuse everywhere.
- **Cross-store**: call `useOtherStore()` at the top of the setup function. Keep dependencies acyclic.
- **Anti-patterns**: mutating state from outside an action; exposing internal helpers via `return`; using a store for component-local state; god-stores re-exporting other stores.

## 10. CSS / styling

- **One styling approach per codebase** (Tailwind / CSS Modules / CSS-in-JS — pick one).
- **Design tokens** (colors, spacing, radii, shadows, type scale) in one place — `:root` CSS vars or `tailwind.config`. Never hardcode hex codes in components.
- **Single-class selectors** as the norm. No deep specificity. No `!important` except utility resets. No ID selectors for styling.
- **Mobile-first** responsive — base styles for mobile, layer up with `min-width` media queries.
- **No inline styles for repeatable patterns**. Inline only for truly dynamic per-instance values (e.g., `:style="{ width: progress + '%' }"`).

## 11. Accessibility

- Target **WCAG 2.2 AA**.
- **Semantic HTML before ARIA.** Don't re-implement `<button>` as `<div role="button">`. Use `<hr>`, `<nav>`, `<main>`, `<dialog>`, `<label>`, etc.
- **Forms**: every input has `<label :for>`; use `useId()` for the id. Required fields marked with `required` or `aria-required="true"`. Errors associated via `aria-describedby` and announced via `role="alert"` or `aria-live="polite"`. Placeholder is not a label.
- **Color contrast**: 4.5:1 normal text, 3:1 large text and UI components. Never communicate state by color alone.
- **`aria-label`** only when there's no visible text (icon buttons). Redundant `aria-label` *overrides* visible text and harms users.
- **Heading hierarchy**: one `<h1>` per page. No skipping levels. Levels reflect structure, not visual size.
- **Keyboard**: all interactive elements reachable via Tab, activated with Enter/Space. Visible focus ring. Tab order matches visual order. No `tabindex > 0`. Focus trapped in modals, restored on close.
- **Skip-to-content link** at top of page.
- **Alt text**: informative for content images, `alt=""` (empty, not missing) for decorative. Never start with "Image of…".
- Respect `prefers-reduced-motion`.

## 12. Performance

- Target Core Web Vitals: **LCP ≤ 2.5s, INP ≤ 200ms, CLS ≤ 0.1**.
- **Tree-shakable imports** always: `import { debounce } from 'lodash-es'`, never `import _ from 'lodash'`.
- **Performance budget in CI** (`size-limit`, `bundlesize`).
- **Lazy loading**: route-level via dynamic `import()`; component-level via `defineAsyncComponent`. Never lazy-load the LCP / above-the-fold content.
- **Image optimization**: `<picture>` with AVIF → WebP → JPEG; `srcset`+`sizes`; `loading="lazy"` for below-the-fold (never for LCP); always set `width`+`height` (CLS).
- **Memo only after measuring** — `useMemo`/`v-memo`/`shallowRef` aren't free.
- **`<Teleport defer>`** (Vue 3.5+) when teleport target is rendered later in the same template.
- **Lazy hydration** (`hydrateOnVisible`, `hydrateOnIdle`, etc.) for non-critical SSR components.
- Don't optimize prematurely — measure with Lighthouse / Vue DevTools profiler first.

## 13. Forms, validation & errors

- **Client AND server validation.** Client = UX; server = security (never trust the client). Share schemas (Zod/Valibot).
- **Accessible error messaging**: text not color, associated via `aria-describedby`, announced via `role="alert"` or `aria-live="polite"`, specific and actionable ("Email must include @" beats "Invalid input"). Show errors after blur/submit, not every keystroke.
- **Optimistic UI** (likes, favorites): update immediately, rollback on failure. **Pessimistic** for destructive/financial actions.
- **Loading state visible**, submit button disabled during submission, re-enabled on result (success OR failure).
- **`ErrorBoundary` per route + per major isolated feature.** Not one wrapping the whole app.
- **User-facing errors**: plain language, what happened, what to do next. **Developer logs**: structured JSON with request ID, hashed user ID — never raw email/token/PII.
- **Network**: retry idempotent GETs with exponential backoff (max 3). Never auto-retry POST/PUT/DELETE.

## 14. Git & pull-request workflow

- **Conventional Commits**: `<type>(<scope>): <subject>`. Types: `feat`, `fix`, `chore`, `refactor`, `docs`, `test`, `perf`, `build`, `ci`, `style`, `revert`. Body explains *why*. Footer references issues (`Closes #123`).
- **Branch naming**: `<type>/<short-description>` or `<type>/<ticket>-<slug>` (e.g. `feat/oauth-google`, `fix/PROJ-1234-dashboard-crash`).
- **PR size**: target < 400 lines changed. One PR = one logical change. Land refactors separately from features.
- **PR description required**: What changed (one sentence) · Why · How to test · Screenshots for UI · Risks/out-of-scope.
- **Review etiquette**: prefix comments — `nit:` (optional), `question:` (needs answer), `blocking:` (must change). Comment on code, not the developer.

## 15. Documentation

- **JSDoc** for public API of shared modules (params, return, throws, examples); non-obvious behavior/units/invariants; generic type roles. Skip JSDoc for internal helpers whose signatures speak for themselves.
- **README** answers: what is this · quick start (3 commands) · how to test · how to build/deploy · architecture pointer · contribution links.
- **ADRs** (`docs/adr/NNNN-title.md`) for big decisions: framework choice, state mgmt, styling, auth, deployment. **Immutable** — supersede with a new ADR rather than editing.
- **In-code comments: WHY, not WHAT.**

## 16. Testing

- **Testing trophy**: heavy on integration, thinner unit, thin E2E (3–10 critical journeys), plus static analysis (TS + ESLint).
- **Test user-visible behavior, not implementation.** Query by role, label, text. Refactors preserving behavior should not break tests.
- **Don't test framework features.** Don't test third-party libs; test your integration.
- **Pinia in tests**: fresh `createPinia()` per test (`beforeEach(() => setActivePinia(createPinia()))`). Components use `@pinia/testing`'s `createTestingPinia()` (actions stubbed by default).
- Co-locate test files with the code they test (`Foo.vue` + `Foo.spec.ts`).

---

## Review checklist quick scan

When reviewing a PR, scan for these high-impact violations first:

1. **Dead code** — commented-out blocks, unused exports, half-built features (§3, §1 YAGNI)
2. **Pinia state destructure without `storeToRefs`** — silent reactivity loss (§9)
3. **Untyped `defineProps`**, `any` types (§5, §2)
4. **`v-for` `:key`** stability — index keys or translated strings (§6)
5. **Mutating props or store state from outside an action** (§5, §9)
6. **Imperative dialog/modal patterns** when `v-model:visible` would suffice (§5)
7. **Boolean flag parameters** swapping behavior (§2)
8. **Missing form a11y** — no label, no `useId()`, no `aria-describedby` (§5, §11)
9. **`as` casts that silence errors** rather than narrow types (§2)
10. **Watchers bridging two refs** when a `computed` would do (§7)
