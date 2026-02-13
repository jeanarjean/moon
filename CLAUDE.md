# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Moon is a Phoenix 1.8 / LiveView web application (Elixir) for email inbox management, load/shipment tracking, and address book management. Uses PostgreSQL, Tailwind CSS v4, and daisyUI.

## Common Commands

```bash
mix setup                # Install deps, create DB, run migrations, build assets
mix phx.server           # Start dev server at http://localhost:4000
mix test                 # Run full test suite (auto-creates/migrates DB)
mix test test/path.exs   # Run a single test file
mix test --failed        # Re-run previously failed tests
mix precommit            # Compile (warnings-as-errors), unlock unused deps, format, test
mix format               # Format code
mix ecto.gen.migration name  # Generate a new migration
mix ecto.migrate         # Run pending migrations
```

## Architecture

**Contexts (lib/moon/):** Business logic organized by domain — `Accounts` (auth, users, scopes), `Addresses` (address CRUD).

**Web layer (lib/moon_web/):** Phoenix endpoint, router, controllers, and LiveViews.
- `live/inbox_live/` — Email inbox with threading
- `live/load_live/` — Shipment/load tracking by reference
- `live/adress_live/` — Address book CRUD
- `live/user_live/` — Auth flows (login, registration, settings)

**Authentication:** Uses `phx.gen.auth`-generated `Scope` pattern. Always pass `current_scope` (not `current_user`) to context functions and templates. Routes requiring auth go in `live_session :require_authenticated_user`; public-or-auth routes go in `live_session :current_user`. Never duplicate `live_session` names.

**Key conventions:**
- UUIDv7 primary keys
- LiveView streams for all collections (never assign raw lists)
- `to_form/2` for all form state; never pass changesets to templates
- Use `Req` for HTTP requests (already included); avoid HTTPoison/Tesla
- Colocated JS hooks (names prefixed with `.`) instead of inline `<script>` tags
- Tailwind v4 (no tailwind.config.js); never use `@apply`; use list syntax for conditional classes
- Use `<.icon name="hero-...">` for icons, `<.input>` for form inputs (both from core_components)

**Database:** PostgreSQL. Ecto schemas use `:string` for text columns. Fields set programmatically (e.g. `user_id`) must not appear in `cast` calls. Always preload associations needed in templates.

**Testing:** ExUnit + `Phoenix.LiveViewTest` + `LazyHTML`. Use `start_supervised!/1` for process cleanup. Avoid `Process.sleep`. Test element presence with `has_element?/2` rather than raw HTML matching.
