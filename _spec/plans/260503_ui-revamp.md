# Plan: Upgrade Phoenix/LiveView + Migrate to Tailwind/DaisyUI/esbuild

## Context
Jobex is on Phoenix 1.5.14, LiveView 0.15.7, phoenix_html 2.14.3 with Webpack 4 + Bootstrap 4 + FontAwesome. The UI styling is completely broken. We need to upgrade to Phoenix 1.8, LiveView 1.1, phoenix_html 4.3, and transition the build system from Webpack to esbuild+Tailwind+DaisyUI. The target UI appearance is shown in `_spec/screenshots/260403_screenshot.png`.

## Key Breaking Changes to Address
- **Phoenix 1.8**: No more `Phoenix.View`, use `Phoenix.Component` instead. `~L` sigil removed, use `~H` (HEEx). `Routes.static_path` -> `~p` sigil. Router `live` macro changes.
- **LiveView 1.1**: `mount/2` -> `mount/3` (3-arity everywhere). `live_render` -> different embedding pattern. `~L` -> `~H`. `Phoenix.LiveView.Controller.live_render` removed.
- **phoenix_html 4.x**: `raw/1` removed from `Phoenix.HTML`, use `Phoenix.HTML.raw/1`. `~e` sigil removed. Tag helpers changed.
- **Build**: Webpack removed entirely. esbuild for JS, tailwind mix task for CSS.
- **Styling**: Bootstrap 4 -> Tailwind CSS + DaisyUI. FontAwesome kept via CDN.

## Implementation Steps

### Step 1: Update mix.exs dependencies
- `{:phoenix, "~> 1.8"}`
- `{:phoenix_html, "~> 4.3"}`
- `{:phoenix_live_view, "~> 1.1"}`
- `{:phoenix_live_reload, "~> 1.6"}`
- Add `{:esbuild, "~> 0.10.0", runtime: Mix.env() == :dev}`
- Add `{:tailwind, "~> 0.4.1", runtime: Mix.env() == :dev}`
- Add `{:phoenix_ecto, "~> 4.7"}`
- Remove `phoenix_html_simplified_helpers`, `phoenix_active_link`, `distillery`
- Remove `:phoenix` from `compilers` list
- Remove `:phoenix_html_simplified_helpers` from `extra_applications`

### Step 2: Update config files
- `config/config.exs` — add esbuild + tailwind config
- `config/dev.exs` — replace webpack watcher with esbuild + tailwind watchers
- `config/prod.exs` — fix `import config` -> `import Config`

### Step 3: Replace assets/ build system
- Delete webpack.config.js, .babelrc, package-lock.json, node_modules/
- New `assets/js/app.js` for phoenix_live_view 1.1
- New `assets/css/app.css` with Tailwind directives + custom styles
- New `assets/tailwind.config.js` with DaisyUI plugin
- New `assets/package.json` with just daisyui dependency

### Step 4: Update JobexWeb module (`lib/jobex_web.ex`)
- Rewrite for Phoenix 1.8 patterns (Phoenix.Component, verified routes, etc.)

### Step 5: Update Endpoint (`lib/jobex_web/endpoint.ex`)

### Step 6: Update Router (`lib/jobex_web/router.ex`)

### Step 7: Create new layouts
- `lib/jobex_web/components/layouts/root.html.heex`
- `lib/jobex_web/components/layouts/app.html.heex`
- `lib/jobex_web/components/layouts.ex`

### Step 8: Convert LiveView modules from `~L` to `~H`
- home.ex, sidebar.ex, body.ex, demo.ex, time_min.ex, time_sec.ex, admin/base.ex, schedule/body.ex
- Fix mount arity (2 -> 3) everywhere
- All components converted to Phoenix.LiveComponent

### Step 9: Convert EEx templates to HEEx

### Step 10: Replace views with HTML modules

### Step 11: Tailwind/DaisyUI styling to match screenshot

### Step 12: Update controllers for Phoenix 1.8

### Step 13: Update tests

### Step 14: Update CLAUDE.md

## Verification
1. `mix deps.get`
2. `mix compile --warnings-as-errors`
3. `mix test`
4. `mix phx.server` — visit http://localhost:4070/home
5. Visual check against screenshot
