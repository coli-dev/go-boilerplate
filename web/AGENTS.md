# AGENTS.md - Frontend

Next.js 16 App Router frontend with shadcn/ui components.

---

## STRUCTURE

```
web/
├── src/
│   ├── app/              # App Router pages
│   │   ├── page.tsx      # Home
│   │   ├── layout.tsx    # Root layout
│   │   ├── login/        # Login page
│   │   ├── register/     # Register page
│   │   └── dashboard/    # Dashboard (protected)
│   ├── components/
│   │   └── ui/           # shadcn/ui components
│   └── lib/
│       └── utils.ts      # cn() helper
├── public/               # Static assets
├── next.config.ts        # Next.js config
├── tailwind.config.ts    # Tailwind 4 config
└── biome.json            # Linting config
```

---

## TECH STACK

- **Framework:** Next.js 16 (App Router)
- **Runtime:** React 19
- **Bundler:** Turbopack (`npm run dev`)
- **Styling:** Tailwind CSS 4
- **Linting:** Biome (not ESLint)
- **Components:** shadcn/ui + Radix UI
- **Icons:** Lucide React

---

## COMMANDS

```bash
npm run dev      # Dev server with Turbopack (port 3000)
npm run build    # Production build → dist/
npm run lint     # Biome check
npm run format   # Biome format --write
```

---

## API INTEGRATION

Fetch directly to `/api/v1/*` - proxied to backend in dev.

```tsx
const res = await fetch("/api/v1/user/login", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ email, password }),
})
const data = await res.json()
```

Token storage: `localStorage.setItem("token", data.data.token)`

---

## COMPONENT PATTERNS

### shadcn/ui Usage

Components in `src/components/ui/` follow shadcn pattern:
- Use `class-variance-authority` for variants
- Accept `className` prop for styling overrides
- Use `cn()` utility for class merging

### Client Components

Mark interactive components with `"use client"`:

```tsx
"use client"

import { useState } from "react"

export default function InteractiveComponent() {
  const [state, setState] = useState()
  // ...
}
```

---

## NOTES

- Biome config in `biome.json` (replaces ESLint + Prettier)
- Tailwind 4 uses `@import "tailwindcss"` in globals.css
- Built output in `dist/` served by Go backend
- SPA fallback handled by backend static middleware
