# MSW (Mock Service Worker) — API mocking for frontend apps

MSW intercepts requests at the **network level** (Service Worker in the browser, request
interceptor in Node). Your app code makes real `fetch`/`axios` calls — MSW answers them. Same
mocks work in the browser, tests, and Storybook. Ideal for building against a **delayed/unavailable
backend** while keeping the swap to the real API a no-op (just stop the worker).

## Install

```bash
npm i -D msw
npx msw init public/ --save     # generates public/mockServiceWorker.js (browser only)
```

## Define handlers (shared)

```js
// src/mocks/handlers.js
import { http, HttpResponse } from 'msw'

export const handlers = [
  http.get('/api/user', () =>
    HttpResponse.json({ id: 1, name: 'Ada' })
  ),

  http.post('/api/login', async ({ request }) => {
    const { email } = await request.json()
    if (!email) return new HttpResponse(null, { status: 400 })
    return HttpResponse.json({ token: 'fake-jwt' })
  }),

  // params + query
  http.get('/api/items/:id', ({ params, request }) => {
    const url = new URL(request.url)
    return HttpResponse.json({ id: params.id, q: url.searchParams.get('q') })
  }),
]
```

## Browser (dev / app)

```js
// src/mocks/browser.js
import { setupWorker } from 'msw/browser'
import { handlers } from './handlers'
export const worker = setupWorker(...handlers)
```

```js
// main.js — start before mounting, only in dev / when flag set
async function enableMocking() {
  if (!import.meta.env.DEV) return
  const { worker } = await import('./mocks/browser')
  await worker.start({ onUnhandledRequest: 'bypass' }) // let real requests pass through
}

enableMocking().then(() => {
  createApp(App).mount('#app')
})
```

`onUnhandledRequest`: `'bypass'` (default-ish, let unmocked hit network) | `'warn'` | `'error'`.

## Node (tests — Vitest/Jest)

```js
// src/mocks/server.js
import { setupServer } from 'msw/node'
import { handlers } from './handlers'
export const server = setupServer(...handlers)
```

```js
// vitest.setup.js
import { server } from './src/mocks/server'
import { beforeAll, afterEach, afterAll } from 'vitest'

beforeAll(() => server.listen({ onUnhandledRequest: 'error' }))
afterEach(() => server.resetHandlers())   // undo per-test overrides
afterAll(() => server.close())
```

Per-test override:

```js
import { http, HttpResponse } from 'msw'
import { server } from '../mocks/server'

server.use(
  http.get('/api/user', () => new HttpResponse(null, { status: 500 }))
)
```

## Handy patterns

```js
import { http, HttpResponse, delay } from 'msw'

// latency
http.get('/api/slow', async () => { await delay(1500); return HttpResponse.json({}) })

// error
http.get('/api/fail', () => new HttpResponse(null, { status: 503 }))

// pass through to the real server (when it comes online)
http.get('/api/real', () => passthrough())
```

## Swap to the real backend later

No app-code change — the calls are already real. Just don't start the worker:

- gate `worker.start()` behind an env flag (e.g. `VITE_USE_MOCKS`),
- or delete `src/mocks/browser.js` start call. Tests can keep using the Node server independently.

## Gotchas

- Run `msw init` again if you upgrade — `public/mockServiceWorker.js` must match the installed version.
- The service worker only intercepts requests under its scope (served from `public/`).
- v2 API uses `http`/`graphql` + `HttpResponse` (older v1 used `rest` + `res(ctx...)`).
