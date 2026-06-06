## Summary

Fixes the ScoutOS agent's WebContainer API integration so tool intents (write_file, read_file, run_command, etc.) can execute in the browser.

## Problem

The ScoutOS agent requires a `webcontainerApi` object to execute tool_intent atoms, but the Gleam `CallAgent` effect didn't have a field to pass it through to the JS runtime bridge. This caused the error:

> "WebContainer API is required for ScoutOS agent"

## Changes

- `src/build/actors/agent.gleam` — Added `webcontainer_api: String` field to `CallAgent` effect
- `src/build/update.gleam` — Pass empty string for `webcontainer_api` (JS bridge handles real API)
- `src/build/runtime/agent.gleam` — Forward `webcontainer_api` to JS external
- `src/gleam-externals/agent.mjs` — Accept `webcontainerApi` param, construct real WebContainer API when `provider === 'scoutos'`
- `test/build_update_test.gleam` — Updated assertions for new field

## How It Works

1. Gleam side passes a placeholder string (no direct WebContainer access)
2. JS bridge (`gleam-externals/agent.mjs`) receives it alongside other params
3. When calling `runAgent()`, the bridge passes `webcontainerApi` through
4. `runScoutOSAgent()` in `src/agent.ts` validates it and uses it for tool execution

## Testing

- **204 TypeScript tests** passing
- **35 Gleam tests** passing
- Build + compilation verified

## Related

Follow-up to PR #17 which added the ScoutOS Atoms provider.
