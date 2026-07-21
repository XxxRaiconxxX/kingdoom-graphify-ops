# Kingdoom Graphify Ops

Shared Graphify operations layer for the main Kingdoom repos.

## Purpose

This repo is the source of truth for:

- Graphify operational scripts
- AGENTS.md graphify sections
- Antigravity `.agents` graphify rules and workflows
- Shared Graphify operations documentation
- Repo bootstrap and sync scripts

It does **not** store the live `graphify-out/` working graphs from each project.
Those stay local inside each repo root because Graphify resolves `graphify-out/graph.json`
relative to the current project.

## Managed repos

- `kingdoom-bot`
- `Kingdoom-sync`
- `kingdoom-fichas`
- `kingdoom-library`

## Main commands

From this repo:

```powershell
.\scripts\apply-to-repo.ps1 -RepoPath "C:\path\to\repo" -Profile bot -Activate
.\scripts\apply-kingdoom-suite.ps1
```

Inside each managed repo after sync:

```powershell
npm run graphify:setup
npm run graphify:doctor
npm run graphify:update
npm run graphify:rebuild
npm run graphify:watch
```

## Policy

- `graphify-out/` stays local in each repo root.
- `.codex/hooks.json` stays local in each repo root.
- `.codex/skills/graphify/` is tracked and shared so Codex clones keep the same `/graphify` skill behavior.
- Tracked instructions live in `AGENTS.md`, `.agents/rules/graphify.md`, and `.agents/workflows/graphify.md`.
- The official Graphify git hooks are installed per repo via `graphify hook install`.

## Notes

- `Kingdoom-sync` previously versioned `graphify-out/`. The suite installer can localize it by removing it from the git index while keeping files on disk.
- If you update templates here, re-run `.\scripts\apply-kingdoom-suite.ps1` to propagate the shared layer.
