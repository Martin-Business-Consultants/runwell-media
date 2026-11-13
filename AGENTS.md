# A Runwell plugin — guide for AI agents

This repository is a plugin for Runwell (a Rails 8.1 engine loaded into a Runwell install). It is
not an app on its own: run it from a Runwell checkout with `bin/rails "plugins:link[path]"`.

Read first, in Runwell's repository:
- `docs/plugin-contract.md`: everything a plugin may rely on, with versions. Use nothing else of
  the core's. Raise `requires:` in the manifest to the newest version you use.
- `AGENTS.md`: the core's conventions, which plugin code follows too.

## Rules

- Own your tables, prefixed with the key (`media_*`), pointing at core records by id. Never
  add columns to core tables or write core rows except through core model verbs.
- Register everything in `config.to_prepare`, keyed by the plugin's key. Controllers inherit
  `Media::ApplicationController` (404 while switched off); subscribers check
  `Runwell::Plugins.enabled?(:media)`.
- Every controller action declares an authorization rule (`allow_staff`, `require_permission`)
  and an `agent_tool` or `agent_exempt`. Reads get a `.json.jbuilder` view with `agent_ref` and a
  `summary`. Write notices an AI can act on.
- Views follow the core's ReActionView rules: strict locals on every partial's first line,
  `<%# herb:key %>` before each loop row, no inline CSS, no partials inside `form_with`. Use the
  core's helpers and shared partials (listed in the contract) and `term()` for the core's nouns.
- Views draw with runeui, Runwell 6.0's UI kit: `ui :button`, `ui :badge`, `ui :tabs`,
  `ui :toggle_group`, `ui :breadcrumb`, `ui :drawer` (the file sheet), `ui :alert_dialog`, `ui :empty`,
  and `form.ui :field` around each control, plus the core's helpers (`record_card`, `switch_field`,
  `icon_tag`, `person_tag`). No rune_ui helpers or classes.
- CSS reads runeui's tokens only (shadcn's names: `--foreground`, `--muted-foreground`, `--border`,
  `--primary` for the brand, `--accent` the hover fill, `--destructive`…; runeui's `--ui-*` scale;
  `docs/theming.md`), in `@layer components`, never rune_ui's old names (`--text-*`, `--line`,
  `--s-*`, `--accent` as the brand). Spacing in rems, corners `--ui-radius-*`. The stylesheet starts
  with `/* tokens: runeui */`, so the core serves it as written.
- Migrations are safe on a live install: add in one release, remove only in a later one.
- Use only gems Runwell bundles: plugins load outside Bundler.
- JavaScript is the plugin's own, in `app/javascript/media/`: Stimulus controllers in
  `controllers/` (the core registers them as `media--name`; this plugin has none yet: uploads use the core's
  upload controller), modules imported as `"media/…"`. Import only `@hotwired/stimulus`,
  `@hotwired/turbo-rails`, `@rails/request.js` and your own files; use only the core controllers
  the contract lists; never patch the core's. No inline scripts, no CDNs (vendor a library into
  `app/javascript/media/vendor/`). Everything still works for agents, which run no JavaScript.
- Keep it in the plugin: ask the core only for a real extension point, documented in the contract.
- Write for anyone running something (a business, a team, a household): never one industry's jargon.

## Layout

- `lib/media/engine.rb`: routes, model hooks, event subscriber, registrations
- `app/`: models, controllers, views, stylesheets and JavaScript under `media/`
- `db/migrate/`: the plugin's tables
- `bin/rename`: renames the template (delete once used)
